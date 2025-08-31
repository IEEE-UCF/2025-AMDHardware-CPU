#ifndef CPU_REGS_H
#define CPU_REGS_H

#include <stdint.h>

// Base addresses for Red Pitaya memory mapping
#define RP_BASE_ADDR        0x40000000
#define CPU_BASE_ADDR       (RP_BASE_ADDR + 0x100000)  // CPU at offset 1MB

// CPU Memory Regions
#define CPU_IMEM_BASE       (CPU_BASE_ADDR + 0x00000)  // Instruction memory
#define CPU_DMEM_BASE       (CPU_BASE_ADDR + 0x10000)  // Data memory  
#define CPU_CTRL_BASE       (CPU_BASE_ADDR + 0x20000)  // Control registers
#define CPU_STATUS_BASE     (CPU_BASE_ADDR + 0x21000)  // Status registers
#define CPU_DEBUG_BASE      (CPU_BASE_ADDR + 0x22000)  // Debug interface

// Memory sizes
#define CPU_IMEM_SIZE       0x10000    // 64KB instruction memory
#define CPU_DMEM_SIZE       0x10000    // 64KB data memory
#define CPU_REG_COUNT       32         // 32 RISC-V registers

// Control Register Offsets
#define CPU_CTRL_ENABLE     0x00    // CPU enable/disable
#define CPU_CTRL_RESET      0x04    // CPU reset control
#define CPU_CTRL_CLOCK      0x08    // Clock control
#define CPU_CTRL_PC         0x0C    // Program counter control
#define CPU_CTRL_IRQ        0x10    // Interrupt control
#define CPU_CTRL_MODE       0x14    // Operating mode
#define CPU_CTRL_STEP       0x18    // Single step mode
#define CPU_CTRL_BREAK      0x1C    // Breakpoint control

// Status Register Offsets  
#define CPU_STATUS_STATE    0x00    // CPU state
#define CPU_STATUS_PC       0x04    // Current PC
#define CPU_STATUS_CYCLES   0x08    // Cycle counter
#define CPU_STATUS_INSTRET  0x0C    // Instructions retired
#define CPU_STATUS_STALL    0x10    // Stall status
#define CPU_STATUS_EXCEPT   0x14    // Exception status
#define CPU_STATUS_IRQ_PEND 0x18    // Pending interrupts
#define CPU_STATUS_PIPELINE 0x1C    // Pipeline status

// Debug Register Offsets
#define CPU_DEBUG_REG_SEL   0x00    // Register select
#define CPU_DEBUG_REG_VAL   0x04    // Register value
#define CPU_DEBUG_MEM_ADDR  0x08    // Memory address
#define CPU_DEBUG_MEM_DATA  0x0C    // Memory data
#define CPU_DEBUG_TRACE     0x10    // Trace buffer
#define CPU_DEBUG_BP_ADDR   0x14    // Breakpoint address
#define CPU_DEBUG_BP_CTRL   0x18    // Breakpoint control
#define CPU_DEBUG_WATCH     0x1C    // Watchpoint control

// Control Register Bits
// CPU_CTRL_ENABLE
#define CPU_ENABLE_BIT      (1 << 0)
#define CPU_CLOCK_EN_BIT    (1 << 1)
#define CPU_DEBUG_EN_BIT    (1 << 2)
#define CPU_COPROC_EN_BIT   (1 << 3)

// CPU_CTRL_RESET  
#define CPU_RESET_BIT       (1 << 0)
#define CPU_RESET_PIPE_BIT  (1 << 1)
#define CPU_RESET_CACHE_BIT (1 << 2)
#define CPU_RESET_COPROC_BIT (1 << 3)

// CPU_CTRL_CLOCK
#define CPU_CLOCK_DIV_MASK  0xFF
#define CPU_CLOCK_SRC_MASK  (0x3 << 8)
#define CPU_CLOCK_SRC_125M  (0x0 << 8)
#define CPU_CLOCK_SRC_EXT   (0x1 << 8)
#define CPU_CLOCK_SRC_PLL   (0x2 << 8)

// CPU_CTRL_MODE
#define CPU_MODE_RUN        0x0
#define CPU_MODE_STEP       0x1
#define CPU_MODE_DEBUG      0x2
#define CPU_MODE_HALT       0x3

// Status Register Bits
// CPU_STATUS_STATE
#define CPU_STATE_RUNNING   (1 << 0)
#define CPU_STATE_HALTED    (1 << 1)
#define CPU_STATE_EXCEPTION (1 << 2)
#define CPU_STATE_INTERRUPT (1 << 3)
#define CPU_STATE_DEBUG     (1 << 4)
#define CPU_STATE_RESET     (1 << 5)

// CPU_STATUS_STALL
#define CPU_STALL_NONE      0x0
#define CPU_STALL_HAZARD    0x1
#define CPU_STALL_MEMORY    0x2
#define CPU_STALL_COPROC    0x3
#define CPU_STALL_DEBUG     0x4

// Exception codes
#define CPU_EXCEPT_NONE         0x00
#define CPU_EXCEPT_INST_FAULT   0x01
#define CPU_EXCEPT_ILLEGAL_INST 0x02
#define CPU_EXCEPT_BREAKPOINT   0x03
#define CPU_EXCEPT_LOAD_FAULT   0x05
#define CPU_EXCEPT_STORE_FAULT  0x07
#define CPU_EXCEPT_ECALL_U      0x08
#define CPU_EXCEPT_ECALL_S      0x09
#define CPU_EXCEPT_ECALL_M      0x0B

// Interrupt sources
#define CPU_IRQ_TIMER       (1 << 0)
#define CPU_IRQ_SOFTWARE    (1 << 1)
#define CPU_IRQ_EXTERNAL    (1 << 2)
#define CPU_IRQ_GPIO        (1 << 3)
#define CPU_IRQ_UART        (1 << 4)
#define CPU_IRQ_SPI         (1 << 5)
#define CPU_IRQ_I2C         (1 << 6)
#define CPU_IRQ_DMA         (1 << 7)

// Register access macros
#define CPU_REG(offset)     (*((volatile uint32_t*)(CPU_CTRL_BASE + (offset))))
#define CPU_STATUS(offset)  (*((volatile uint32_t*)(CPU_STATUS_BASE + (offset))))
#define CPU_DEBUG(offset)   (*((volatile uint32_t*)(CPU_DEBUG_BASE + (offset))))

// Memory access macros
#define CPU_IMEM(addr)      (*((volatile uint32_t*)(CPU_IMEM_BASE + (addr))))
#define CPU_DMEM(addr)      (*((volatile uint32_t*)(CPU_DMEM_BASE + (addr))))

// Helper macros
#define CPU_SET_BIT(reg, bit)       ((reg) |= (bit))
#define CPU_CLEAR_BIT(reg, bit)     ((reg) &= ~(bit))
#define CPU_TEST_BIT(reg, bit)      (((reg) & (bit)) != 0)

// Clock frequency calculations
#define RP_BASE_FREQ_HZ     125000000   // 125 MHz base frequency
#define CPU_MAX_FREQ_HZ     100000000   // 100 MHz maximum CPU frequency
#define CPU_MIN_FREQ_HZ     1000000     // 1 MHz minimum CPU frequency

// Calculate clock divider value
#define CPU_CALC_DIV(freq_hz) \
    (((RP_BASE_FREQ_HZ / (freq_hz)) - 1) & CPU_CLOCK_DIV_MASK)

// Get actual frequency from divider
#define CPU_ACTUAL_FREQ(div) \
    (RP_BASE_FREQ_HZ / ((div) + 1))

// Timeout values
#define CPU_RESET_TIMEOUT_MS    100
#define CPU_HALT_TIMEOUT_MS     1000
#define CPU_LOAD_TIMEOUT_MS     5000

// RISC-V Register Names (for debugging)
typedef enum {
    REG_X0 = 0, REG_RA = 1, REG_SP = 2, REG_GP = 3,
    REG_TP = 4, REG_T0 = 5, REG_T1 = 6, REG_T2 = 7,
    REG_S0 = 8, REG_S1 = 9, REG_A0 = 10, REG_A1 = 11,
    REG_A2 = 12, REG_A3 = 13, REG_A4 = 14, REG_A5 = 15,
    REG_A6 = 16, REG_A7 = 17, REG_S2 = 18, REG_S3 = 19,
    REG_S4 = 20, REG_S5 = 21, REG_S6 = 22, REG_S7 = 23,
    REG_S8 = 24, REG_S9 = 25, REG_S10 = 26, REG_S11 = 27,
    REG_T3 = 28, REG_T4 = 29, REG_T5 = 30, REG_T6 = 31
} cpu_reg_t;

// CPU state structure
typedef struct {
    uint32_t state;         // CPU state flags
    uint32_t pc;            // Program counter
    uint64_t cycles;        // Cycle count
    uint64_t instret;       // Instructions retired
    uint32_t stall_reason;  // Last stall reason
    uint32_t exception;     // Exception status
    uint32_t irq_pending;   // Pending interrupts
    uint32_t registers[32]; // Register file snapshot
} cpu_state_t;

// Function declarations
static inline uint32_t cpu_read_reg(uint32_t offset) {
    return CPU_REG(offset);
}

static inline void cpu_write_reg(uint32_t offset, uint32_t value) {
    CPU_REG(offset) = value;
}

static inline uint32_t cpu_read_status(uint32_t offset) {
    return CPU_STATUS(offset);
}

static inline uint32_t cpu_read_debug(uint32_t offset) {
    return CPU_DEBUG(offset);
}

static inline void cpu_write_debug(uint32_t offset, uint32_t value) {
    CPU_DEBUG(offset) = value;
}

// Convenience functions
static inline void cpu_enable(void) {
    CPU_SET_BIT(CPU_REG(CPU_CTRL_ENABLE), CPU_ENABLE_BIT);
}

static inline void cpu_disable(void) {
    CPU_CLEAR_BIT(CPU_REG(CPU_CTRL_ENABLE), CPU_ENABLE_BIT);
}

static inline int cpu_is_running(void) {
    return CPU_TEST_BIT(CPU_STATUS(CPU_STATUS_STATE), CPU_STATE_RUNNING);
}

static inline void cpu_set_pc(uint32_t pc) {
    CPU_REG(CPU_CTRL_PC) = pc;
}

static inline uint32_t cpu_get_pc(void) {
    return CPU_STATUS(CPU_STATUS_PC);
}

#endif // CPU_REGS_H