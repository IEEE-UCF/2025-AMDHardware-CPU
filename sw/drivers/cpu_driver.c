#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <time.h>

#include "cpu_driver.h"
#include "cpu_regs.h"

// Driver version
#define CPU_DRIVER_VERSION "1.0.0"

// Internal state
static struct {
    bool initialized;
    int mem_fd;
    void *mem_base;
    cpu_config_t config;
    char last_error[256];
    uint32_t breakpoint_count;
    cpu_breakpoint_t breakpoints[16];  // Max 16 breakpoints
} cpu_driver = {0};

// RISC-V register names
static const char* register_names[32] = {
    "zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
    "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
    "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
    "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

// Internal helper functions
static void set_error(const char *format, ...);
static int wait_for_condition(bool (*condition)(void), uint32_t timeout_ms);
static bool is_valid_address(uint32_t addr, size_t size, bool write_access);
static uint32_t read_cpu_reg_safe(uint32_t offset);
static void write_cpu_reg_safe(uint32_t offset, uint32_t value);

// =======================
// Core CPU Functions
// =======================

int cpu_init(const cpu_config_t *config) {
    if (cpu_driver.initialized) {
        return CPU_SUCCESS;  // Already initialized
    }

    // Open /dev/mem for memory mapping
    cpu_driver.mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (cpu_driver.mem_fd < 0) {
        set_error("Failed to open /dev/mem: %s", strerror(errno));
        return CPU_ERROR_HW;
    }

    // Map CPU memory region
    cpu_driver.mem_base = mmap(NULL, 0x30000, PROT_READ | PROT_WRITE, 
                              MAP_SHARED, cpu_driver.mem_fd, CPU_BASE_ADDR);
    if (cpu_driver.mem_base == MAP_FAILED) {
        close(cpu_driver.mem_fd);
        set_error("Failed to map CPU memory: %s", strerror(errno));
        return CPU_ERROR_HW;
    }

    // Use provided config or defaults
    if (config) {
        cpu_driver.config = *config;
    } else {
        cpu_driver.config = cpu_get_default_config();
    }

    // Initialize CPU hardware
    cpu_reset(true);
    
    // Set clock frequency
    int ret = cpu_set_clock_frequency(cpu_driver.config.clock_freq_hz);
    if (ret != CPU_SUCCESS) {
        cpu_cleanup();
        return ret;
    }

    // Configure debug interface
    if (cpu_driver.config.enable_debug) {
        write_cpu_reg_safe(CPU_CTRL_ENABLE, read_cpu_reg_safe(CPU_CTRL_ENABLE) | CPU_DEBUG_EN_BIT);
    }

    // Configure coprocessors
    if (cpu_driver.config.enable_coprocessors) {
        write_cpu_reg_safe(CPU_CTRL_ENABLE, read_cpu_reg_safe(CPU_CTRL_ENABLE) | CPU_COPROC_EN_BIT);
    }

    cpu_driver.initialized = true;
    return CPU_SUCCESS;
}

void cpu_cleanup(void) {
    if (!cpu_driver.initialized) {
        return;
    }

    cpu_stop();
    
    if (cpu_driver.mem_base && cpu_driver.mem_base != MAP_FAILED) {
        munmap(cpu_driver.mem_base, 0x30000);
    }
    
    if (cpu_driver.mem_fd >= 0) {
        close(cpu_driver.mem_fd);
    }

    memset(&cpu_driver, 0, sizeof(cpu_driver));
}

int cpu_reset(bool hard_reset) {
    if (!cpu_driver.initialized) {
        set_error("CPU driver not initialized");
        return CPU_ERROR_INVALID;
    }

    uint32_t reset_bits = CPU_RESET_BIT;
    if (hard_reset) {
        reset_bits |= CPU_RESET_PIPE_BIT | CPU_RESET_CACHE_BIT | CPU_RESET_COPROC_BIT;
    }

    // Assert reset
    write_cpu_reg_safe(CPU_CTRL_RESET, reset_bits);
    usleep(1000);  // 1ms delay

    // Deassert reset
    write_cpu_reg_safe(CPU_CTRL_RESET, 0);
    usleep(1000);  // 1ms delay

    // Set reset vector
    cpu_set_pc(cpu_driver.config.reset_vector);

    // Clear breakpoints
    cpu_driver.breakpoint_count = 0;
    memset(cpu_driver.breakpoints, 0, sizeof(cpu_driver.breakpoints));

    return CPU_SUCCESS;
}

int cpu_start(void) {
    if (!cpu_driver.initialized) {
        set_error("CPU driver not initialized");
        return CPU_ERROR_INVALID;
    }

    // Enable CPU
    cpu_enable();
    
    // Wait for CPU to start running
    return wait_for_condition(cpu_is_running, 100);  // 100ms timeout
}

int cpu_stop(void) {
    if (!cpu_driver.initialized) {
        set_error("CPU driver not initialized");
        return CPU_ERROR_INVALID;
    }

    // Disable CPU
    cpu_disable();
    
    // Wait for CPU to stop
    return wait_for_condition([]() { return !cpu_is_running(); }, 1000);  // 1s timeout
}

int cpu_step(void) {
    if (!cpu_driver.initialized) {
        set_error("CPU driver not initialized");
        return CPU_ERROR_INVALID;
    }

    if (cpu_is_running()) {
        set_error("CPU must be stopped for single step");
        return CPU_ERROR_BUSY;
    }

    // Set single step mode
    write_cpu_reg_safe(CPU_CTRL_MODE, CPU_MODE_STEP);
    
    // Enable CPU for one cycle
    cpu_enable();
    usleep(100);  // Small delay
    cpu_disable();

    // Return to normal mode
    write_cpu_reg_safe(CPU_CTRL_MODE, CPU_MODE_RUN);

    return CPU_SUCCESS;
}

bool cpu_is_active(void) {
    if (!cpu_driver.initialized) {
        return false;
    }
    return cpu_is_running();
}

int cpu_get_state(cpu_state_t *state) {
    if (!cpu_driver.initialized || !state) {
        set_error("Invalid parameters");
        return CPU_ERROR_INVALID;
    }

    state->state = cpu_read_status(CPU_STATUS_STATE);
    state->pc = cpu_read_status(CPU_STATUS_PC);
    state->cycles = ((uint64_t)cpu_read_status(CPU_STATUS_CYCLES + 4) << 32) | 
                    cpu_read_status(CPU_STATUS_CYCLES);
    state->instret = ((uint64_t)cpu_read_status(CPU_STATUS_INSTRET + 4) << 32) | 
                     cpu_read_status(CPU_STATUS_INSTRET);
    state->stall_reason = cpu_read_status(CPU_STATUS_STALL);
    state->exception = cpu_read_status(CPU_STATUS_EXCEPT);
    state->irq_pending = cpu_read_status(CPU_STATUS_IRQ_PEND);

    // Read all registers
    for (int i = 0; i < 32; i++) {
        cpu_read_register(i, &state->registers[i]);
    }

    return CPU_SUCCESS;
}

// =======================
// Memory Management
// =======================

int cpu_load_program(const void *program, size_t size, uint32_t start_addr) {
    if (!cpu_driver.initialized || !program || size == 0) {
        set_error("Invalid parameters");
        return CPU_ERROR_INVALID;
    }

    if (!is_valid_address(start_addr, size, true)) {
        set_error("Invalid memory address range");
        return CPU_ERROR_MEMORY;
    }

    // Stop CPU during programming
    bool was_running = cpu_is_running();
    if (was_running) {
        cpu_stop();
    }

    // Copy program to instruction memory
    volatile uint8_t *imem = (volatile uint8_t*)cpu_driver.mem_base + start_addr;
    const uint8_t *src = (const uint8_t*)program;
    
    for (size_t i = 0; i < size; i++) {
        imem[i] = src[i];
    }

    // Verify programming
    int verify_result = cpu_verify_memory(start_addr, program, size);
    
    // Restart CPU if it was running
    if (was_running) {
        cpu_start();
    }

    return verify_result;
}

int cpu_read_memory(uint32_t addr, void *data, size_t size) {
    if (!cpu_driver.initialized || !data || size == 0) {
        set_error("Invalid parameters");
        return CPU_ERROR_INVALID;
    }

    if (!is_valid_address(addr, size, false)) {
        set_error("Invalid memory address range");
        return CPU_ERROR_MEMORY;
    }

    volatile uint8_t *mem = (volatile uint8_t*)cpu_driver.mem_base + addr;
    uint8_t *dst = (uint8_t*)data;
    
    for (size_t i = 0; i < size; i++) {
        dst[i] = mem[i];
    }

    return CPU_SUCCESS;
}

int cpu_write_memory(uint32_t addr, const void *data, size_t size) {
    if (!cpu_driver.initialized || !data || size == 0) {
        set_error("Invalid parameters");
        return CPU_ERROR_INVALID;
    }

    if (!is_valid_address(addr, size, true)) {
        set_error("Invalid memory address range");
        return CPU_ERROR_MEMORY;
    }

    volatile uint8_t *mem = (volatile uint8_t*)cpu_driver.mem_base + addr;
    const uint8_t *src = (const uint8_t*)data;
    
    for (size_t i = 0; i < size; i++) {
        mem[i] = src[i];
    }

    return CPU_SUCCESS;
}

int cpu_verify_memory(uint32_t addr, const void *expected, size_t size) {
    if (!cpu_driver.initialized || !expected || size == 0) {
        set_error("Invalid parameters");
        return CPU_ERROR_INVALID;
    }

    uint8_t *buffer = malloc(size);
    if (!buffer) {
        set_error("Memory allocation failed");
        return CPU_ERROR_MEMORY;
    }

    int result = cpu_read_memory(addr, buffer, size);
    if (result == CPU_SUCCESS) {
        if (memcmp(buffer, expected, size) != 0) {
            set_error("Memory verification failed");
            result = CPU_ERROR_MEMORY;
        }
    }

    free(buffer);
    return result;
}

int cpu_clear_memory(uint32_t addr, size_t size) {
    if (!cpu_driver.initialized || size == 0) {
        set_error("Invalid parameters");
        return CPU_ERROR_INVALID;
    }

    uint8_t *zero_buffer = calloc(size, 1);
    if (!zero_buffer) {
        set_error("Memory allocation failed");
        return CPU_ERROR_MEMORY;
    }

    int result = cpu_write_memory(addr, zero_buffer, size);
    free(zero_buffer);
    return result;
}

// =======================
// Register Access
// =======================

int cpu_read_register(uint32_t reg_num, uint32_t *value) {
    if (!cpu_driver.initialized || !value || reg_num >= 32) {
        set_error("Invalid parameters");
        return CPU_ERROR_INVALID;
    }

    // Select register
    write_cpu_reg_safe(CPU_DEBUG_REG_SEL, reg_num);
    
    // Read register value
    *value = cpu_read_debug(CPU_DEBUG_REG_VAL);
    
    return CPU_SUCCESS;
}

int cpu_write_register(uint32_t reg_num, uint32_t value) {
    if (!cpu_driver.initialized || reg_num >= 32) {
        set_error("Invalid parameters");
        return CPU_ERROR_INVALID;
    }

    if (reg_num == 0) {
        // x0 is hardwired to zero
        return CPU_SUCCESS;
    }

    // Select register
    write_cpu_reg_safe(CPU_DEBUG_REG_SEL, reg_num);
    
    // Write register value
    cpu_write_debug(CPU_DEBUG_REG_VAL, value);
    
    return CPU_SUCCESS;
}

int cpu_read_all_registers(uint32_t registers[32]) {
    if (!cpu_driver.initialized || !registers) {
        set_error("Invalid parameters");
        return CPU_ERROR_INVALID;
    }

    for (int i = 0; i < 32; i++) {
        int result = cpu_read_register(i, &registers[i]);
        if (result != CPU_SUCCESS) {
            return result;
        }
    }

    return CPU_SUCCESS;
}

int cpu_write_all_registers(const uint32_t registers[32]) {
    if (!cpu_driver.initialized || !registers) {
        set_error("Invalid parameters");
        return CPU_ERROR_INVALID;
    }

    for (int i = 1; i < 32; i++) {  // Skip x0
        int result = cpu_write_register(i, registers[i]);
        if (result != CPU_SUCCESS) {
            return result;
        }
    }

    return CPU_SUCCESS;
}

// =======================
// Clock and Timing
// =======================

int cpu_set_clock_frequency(uint32_t freq_hz) {
    if (!cpu_driver.initialized) {
        set_error("CPU driver not initialized");
        return CPU_ERROR_INVALID;
    }

    if (freq_hz < CPU_MIN_FREQ_HZ || freq_hz > CPU_MAX_FREQ_HZ) {
        set_error("Frequency out of range: %u Hz", freq_hz);
        return CPU_ERROR_INVALID;
    }

    uint32_t divider = CPU_CALC_DIV(freq_hz);
    uint32_t actual_freq = CPU_ACTUAL_FREQ(divider);
    
    // Update clock control register
    uint32_t clock_ctrl = read_cpu_reg_safe(CPU_CTRL_CLOCK);
    clock_ctrl = (clock_ctrl & ~CPU_CLOCK_DIV_MASK) | (divider & CPU_CLOCK_DIV_MASK);
    write_cpu_reg_safe(CPU_CTRL_CLOCK, clock_ctrl);

    printf("CPU clock set to %u Hz (requested %u Hz, divider %u)\n", 
           actual_freq, freq_hz, divider);

    return CPU_SUCCESS;
}

int cpu_get_clock_frequency(uint32_t *freq_hz) {
    if (!cpu_driver.initialized || !freq_hz) {
        set_error("Invalid parameters");
        return CPU_ERROR_INVALID;
    }

    uint32_t clock_ctrl = read_cpu_reg_safe(CPU_CTRL_CLOCK);
    uint32_t divider = clock_ctrl & CPU_CLOCK_DIV_MASK;
    *freq_hz = CPU_ACTUAL_FREQ(divider);

    return CPU_SUCCESS;
}

int cpu_set_clock_enable(bool enable) {
    if (!cpu_driver.initialized) {
        set_error("CPU driver not initialized");
        return CPU_ERROR_INVALID;
    }

    uint32_t ctrl = read_cpu_reg_safe(CPU_CTRL_ENABLE);
    if (enable) {
        ctrl |= CPU_CLOCK_EN_BIT;
    } else {
        ctrl &= ~CPU_CLOCK_EN_BIT;
    }
    write_cpu_reg_safe(CPU_CTRL_ENABLE, ctrl);

    return CPU_SUCCESS;
}

// =======================
// Utility Functions
// =======================

const char* cpu_get_version(void) {
    return CPU_DRIVER_VERSION;
}

const char* cpu_get_error_message(void) {
    return cpu_driver.last_error;
}

const char* cpu_register_name(uint32_t reg_num) {
    if (reg_num >= 32) {
        return "invalid";
    }
    return register_names[reg_num];
}

int cpu_disassemble(uint32_t instruction, char *buffer, size_t buffer_size) {
    if (!buffer || buffer_size == 0) {
        return CPU_ERROR_INVALID;
    }

    // Basic RISC-V disassembly (simplified)
    uint32_t opcode = instruction & 0x7F;
    uint32_t rd = (instruction >> 7) & 0x1F;
    uint32_t rs1 = (instruction >> 15) & 0x1F;
    uint32_t rs2 = (instruction >> 20) & 0x1F;
    uint32_t funct3 = (instruction >> 12) & 0x7;

    switch (opcode) {
        case 0x33: // R-type
            if (funct3 == 0) {
                snprintf(buffer, buffer_size, "add %s, %s, %s", 
                        register_names[rd], register_names[rs1], register_names[rs2]);
            } else if (funct3 == 1) {
                snprintf(buffer, buffer_size, "sll %s, %s, %s",
                        register_names[rd], register_names[rs1], register_names[rs2]);
            } else {
                snprintf(buffer, buffer_size, "r-type (0x%08x)", instruction);
            }
            break;
        case 0x13: // I-type
            if (funct3 == 0) {
                int32_t imm = ((int32_t)instruction) >> 20;
                snprintf(buffer, buffer_size, "addi %s, %s, %d",
                        register_names[rd], register_names[rs1], imm);
            } else {
                snprintf(buffer, buffer_size, "i-type (0x%08x)", instruction);
            }
            break;
        default:
            snprintf(buffer, buffer_size, "unknown (0x%08x)", instruction);
            break;
    }

    return CPU_SUCCESS;
}

int cpu_wait_for_state(uint32_t state, uint32_t timeout_ms) {
    if (!cpu_driver.initialized) {
        set_error("CPU driver not initialized");
        return CPU_ERROR_INVALID;
    }

    uint32_t start_time = (uint32_t)time(NULL) * 1000;  // Simplified timing
    
    while (((uint32_t)time(NULL) * 1000) - start_time < timeout_ms) {
        uint32_t current_state = cpu_read_status(CPU_STATUS_STATE);
        if (current_state & state) {
            return CPU_SUCCESS;
        }
        usleep(1000);  // 1ms sleep
    }

    set_error("Timeout waiting for CPU state 0x%08x", state);
    return CPU_ERROR_TIMEOUT;
}

int cpu_dump_state(char *buffer, size_t buffer_size) {
    if (!cpu_driver.initialized || !buffer || buffer_size == 0) {
        set_error("Invalid parameters");
        return CPU_ERROR_INVALID;
    }

    cpu_state_t state;
    int result = cpu_get_state(&state);
    if (result != CPU_SUCCESS) {
        return result;
    }

    size_t offset = 0;
    offset += snprintf(buffer + offset, buffer_size - offset,
                      "CPU State Dump:\n");
    offset += snprintf(buffer + offset, buffer_size - offset,
                      "PC: 0x%08x\n", state.pc);
    offset += snprintf(buffer + offset, buffer_size - offset,
                      "Cycles: %llu\n", (unsigned long long)state.cycles);
    offset += snprintf(buffer + offset, buffer_size - offset,
                      "Instructions: %llu\n", (unsigned long long)state.instret);
    offset += snprintf(buffer + offset, buffer_size - offset,
                      "State: 0x%08x\n", state.state);
    
    offset += snprintf(buffer + offset, buffer_size - offset,
                      "\nRegisters:\n");
    for (int i = 0; i < 32; i += 4) {
        offset += snprintf(buffer + offset, buffer_size - offset,
                          "x%2d-x%2d: %08x %08x %08x %08x\n",
                          i, i+3, state.registers[i], state.registers[i+1],
                          state.registers[i+2], state.registers[i+3]);
        if (offset >= buffer_size - 100) break;  // Prevent overflow
    }

    return CPU_SUCCESS;
}

// =======================
// Internal Helper Functions
// =======================

static void set_error(const char *format, ...) {
    va_list args;
    va_start(args, format);
    vsnprintf(cpu_driver.last_error, sizeof(cpu_driver.last_error), format, args);
    va_end(args);
}

static int wait_for_condition(bool (*condition)(void), uint32_t timeout_ms) {
    uint32_t start_time = (uint32_t)time(NULL) * 1000;
    
    while (((uint32_t)time(NULL) * 1000) - start_time < timeout_ms) {
        if (condition()) {
            return CPU_SUCCESS;
        }
        usleep(1000);
    }
    
    set_error("Timeout waiting for condition");
    return CPU_ERROR_TIMEOUT;
}

static bool is_valid_address(uint32_t addr, size_t size, bool write_access) {
    // Check instruction memory range
    if (addr >= 0 && addr + size <= CPU_IMEM_SIZE) {
        return true;
    }
    
    // Check data memory range
    if (addr >= CPU_IMEM_SIZE && addr + size <= CPU_IMEM_SIZE + CPU_DMEM_SIZE) {
        return true;
    }
    
    return false;
}

static uint32_t read_cpu_reg_safe(uint32_t offset) {
    volatile uint32_t *reg = (volatile uint32_t*)((char*)cpu_driver.mem_base + 0x20000 + offset);
    return *reg;
}

static void write_cpu_reg_safe(uint32_t offset, uint32_t value) {
    volatile uint32_t *reg = (volatile uint32_t*)((char*)cpu_driver.mem_base + 0x20000 + offset);
    *reg = value;
}