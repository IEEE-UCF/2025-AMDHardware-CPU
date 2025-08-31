#ifndef CPU_DRIVER_H
#define CPU_DRIVER_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include "cpu_regs.h"

#ifdef __cplusplus
extern "C" {
#endif

// Return codes
#define CPU_SUCCESS         0
#define CPU_ERROR           -1
#define CPU_ERROR_TIMEOUT   -2
#define CPU_ERROR_INVALID   -3
#define CPU_ERROR_BUSY      -4
#define CPU_ERROR_MEMORY    -5
#define CPU_ERROR_HW        -6

// CPU configuration structure
typedef struct {
    uint32_t clock_freq_hz;     // CPU clock frequency
    bool enable_debug;          // Enable debug interface
    bool enable_coprocessors;   // Enable coprocessors
    uint32_t reset_vector;      // Reset vector address
    uint32_t interrupt_vector;  // Interrupt vector address
} cpu_config_t;

// Memory region structure
typedef struct {
    uint32_t start_addr;        // Start address
    uint32_t size;             // Size in bytes
    bool readable;             // Read permission
    bool writable;             // Write permission
    bool executable;           // Execute permission
} cpu_memory_region_t;

// Breakpoint structure
typedef struct {
    uint32_t address;          // Breakpoint address
    bool enabled;              // Breakpoint enabled
    bool hardware;             // Hardware or software breakpoint
    uint32_t hit_count;        // Number of times hit
} cpu_breakpoint_t;

// Performance counters
typedef struct {
    uint64_t cycles;           // Total cycles
    uint64_t instructions;     // Instructions executed
    uint32_t cache_hits;       // Cache hits
    uint32_t cache_misses;     // Cache misses
    uint32_t branch_taken;     // Branches taken
    uint32_t branch_missed;    // Branch mispredictions
    uint32_t stall_cycles;     // Cycles stalled
    uint32_t exception_count;  // Total exceptions
} cpu_perf_counters_t;

// CPU statistics
typedef struct {
    cpu_perf_counters_t counters;
    double ipc;                // Instructions per cycle
    double cache_hit_rate;     // Cache hit rate
    double branch_prediction_rate; // Branch prediction accuracy
    uint32_t uptime_ms;        // CPU uptime in milliseconds
} cpu_stats_t;

// =======================
// Core CPU Functions
// =======================

/**
 * Initialize CPU driver
 * @param config CPU configuration (NULL for defaults)
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_init(const cpu_config_t *config);

/**
 * Cleanup CPU driver resources
 */
void cpu_cleanup(void);

/**
 * Reset the CPU
 * @param hard_reset True for full hardware reset
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_reset(bool hard_reset);

/**
 * Start CPU execution
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_start(void);

/**
 * Stop CPU execution
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_stop(void);

/**
 * Execute a single instruction (step mode)
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_step(void);

/**
 * Check if CPU is running
 * @return true if running, false if stopped
 */
bool cpu_is_active(void);

/**
 * Get current CPU state
 * @param state Pointer to state structure to fill
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_get_state(cpu_state_t *state);

// =======================
// Memory Management
// =======================

/**
 * Load program into instruction memory
 * @param program Pointer to program data
 * @param size Size of program in bytes
 * @param start_addr Starting address to load at
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_load_program(const void *program, size_t size, uint32_t start_addr);

/**
 * Read from CPU memory
 * @param addr Memory address
 * @param data Buffer to store read data
 * @param size Number of bytes to read
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_read_memory(uint32_t addr, void *data, size_t size);

/**
 * Write to CPU memory
 * @param addr Memory address
 * @param data Data to write
 * @param size Number of bytes to write
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_write_memory(uint32_t addr, const void *data, size_t size);

/**
 * Verify memory contents
 * @param addr Memory address
 * @param expected Expected data
 * @param size Number of bytes to verify
 * @return CPU_SUCCESS if matches, error code on failure
 */
int cpu_verify_memory(uint32_t addr, const void *expected, size_t size);

/**
 * Clear memory region
 * @param addr Starting address
 * @param size Number of bytes to clear
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_clear_memory(uint32_t addr, size_t size);

// =======================
// Register Access
// =======================

/**
 * Read CPU register
 * @param reg_num Register number (0-31)
 * @param value Pointer to store register value
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_read_register(uint32_t reg_num, uint32_t *value);

/**
 * Write CPU register
 * @param reg_num Register number (0-31)
 * @param value Value to write
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_write_register(uint32_t reg_num, uint32_t value);

/**
 * Read all CPU registers
 * @param registers Array to store all 32 register values
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_read_all_registers(uint32_t registers[32]);

/**
 * Write all CPU registers
 * @param registers Array of 32 register values to write
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_write_all_registers(const uint32_t registers[32]);

// =======================
// Debug Interface
// =======================

/**
 * Set breakpoint
 * @param address Address to set breakpoint
 * @param bp_id Breakpoint ID (output)
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_set_breakpoint(uint32_t address, uint32_t *bp_id);

/**
 * Clear breakpoint
 * @param bp_id Breakpoint ID
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_clear_breakpoint(uint32_t bp_id);

/**
 * List active breakpoints
 * @param breakpoints Array to store breakpoint info
 * @param max_count Maximum number of breakpoints to return
 * @param count Actual number of breakpoints returned
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_list_breakpoints(cpu_breakpoint_t *breakpoints, uint32_t max_count, uint32_t *count);

/**
 * Enable/disable single step mode
 * @param enable True to enable single step
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_set_single_step(bool enable);

/**
 * Get instruction trace
 * @param trace_buffer Buffer to store trace data
 * @param buffer_size Size of trace buffer
 * @param entries_returned Number of trace entries returned
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_get_trace(void *trace_buffer, size_t buffer_size, uint32_t *entries_returned);

// =======================
// Clock and Timing
// =======================

/**
 * Set CPU clock frequency
 * @param freq_hz Desired frequency in Hz
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_set_clock_frequency(uint32_t freq_hz);

/**
 * Get CPU clock frequency
 * @param freq_hz Pointer to store current frequency
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_get_clock_frequency(uint32_t *freq_hz);

/**
 * Enable/disable CPU clock
 * @param enable True to enable clock
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_set_clock_enable(bool enable);

// =======================
// Interrupt Management
// =======================

/**
 * Enable interrupt source
 * @param irq_mask Interrupt mask (CPU_IRQ_* constants)
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_enable_interrupt(uint32_t irq_mask);

/**
 * Disable interrupt source
 * @param irq_mask Interrupt mask
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_disable_interrupt(uint32_t irq_mask);

/**
 * Get pending interrupts
 * @param pending Pointer to store pending interrupt mask
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_get_pending_interrupts(uint32_t *pending);

/**
 * Trigger software interrupt
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_trigger_software_interrupt(void);

// =======================
// Performance Monitoring
// =======================

/**
 * Reset performance counters
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_reset_performance_counters(void);

/**
 * Get performance statistics
 * @param stats Pointer to statistics structure
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_get_performance_stats(cpu_stats_t *stats);

/**
 * Start performance profiling
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_start_profiling(void);

/**
 * Stop performance profiling
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_stop_profiling(void);

// =======================
// Utility Functions
// =======================

/**
 * Get CPU driver version
 * @return Version string
 */
const char* cpu_get_version(void);

/**
 * Get last error message
 * @return Error message string
 */
const char* cpu_get_error_message(void);

/**
 * Convert register number to name
 * @param reg_num Register number
 * @return Register name string
 */
const char* cpu_register_name(uint32_t reg_num);

/**
 * Disassemble instruction
 * @param instruction 32-bit instruction word
 * @param buffer Buffer to store disassembly string
 * @param buffer_size Size of buffer
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_disassemble(uint32_t instruction, char *buffer, size_t buffer_size);

/**
 * Wait for CPU to reach specific state
 * @param state State flags to wait for
 * @param timeout_ms Timeout in milliseconds
 * @return CPU_SUCCESS on success, CPU_ERROR_TIMEOUT on timeout
 */
int cpu_wait_for_state(uint32_t state, uint32_t timeout_ms);

/**
 * Dump CPU state to string
 * @param buffer Buffer to store state dump
 * @param buffer_size Size of buffer
 * @return CPU_SUCCESS on success, error code on failure
 */
int cpu_dump_state(char *buffer, size_t buffer_size);

// =======================
// Default Configurations
// =======================

// Get default CPU configuration
static inline cpu_config_t cpu_get_default_config(void) {
    cpu_config_t config = {
        .clock_freq_hz = 50000000,      // 50 MHz default
        .enable_debug = true,
        .enable_coprocessors = true,
        .reset_vector = 0x00000000,
        .interrupt_vector = 0x00000100
    };
    return config;
}

#ifdef __cplusplus
}
#endif

#endif // CPU_DRIVER_H