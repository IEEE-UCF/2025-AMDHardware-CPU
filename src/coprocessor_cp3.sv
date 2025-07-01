// Debug Coprocessor (CP3)
// Handles debugging, performance monitoring, and trace functionality

module coprocessor_cp3 #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter NUM_BREAKPOINTS = 8,
    parameter NUM_WATCHPOINTS = 4,
    parameter TRACE_BUFFER_SIZE = 256
)(
    input  logic                    clk,
    input  logic                    rst_n,
    
    // Coprocessor Interface
    input  logic                    cp_enable,
    input  logic [INST_WIDTH-1:0]  cp_instruction,
    input  logic [DATA_WIDTH-1:0]  cp_data_in,
    output logic [DATA_WIDTH-1:0]  cp_data_out,
    output logic                    cp_ready,
    output logic                    cp_exception,
    
    // Debug Interface
    input  logic [ADDR_WIDTH-1:0]  debug_pc,
    input  logic [INST_WIDTH-1:0]  debug_instruction,
    input  logic [ADDR_WIDTH-1:0]  debug_mem_addr,
    input  logic [DATA_WIDTH-1:0]  debug_mem_data,
    input  logic                    debug_mem_write,
    input  logic                    debug_inst_valid,
    
    // Debug Control Outputs
    output logic                    debug_halt_request,
    output logic                    debug_single_step,
    output logic                    debug_breakpoint_hit,
    output logic                    debug_watchpoint_hit,
    
    // External Debug Interface
    input  logic                    external_debug_req,
    input  logic                    external_halt_req,
    output logic [DATA_WIDTH-1:0]  debug_status,
    output logic [ADDR_WIDTH-1:0]  debug_halt_pc
);

    // Debug register addresses
    typedef enum logic [11:0] {
        DBG_CTRL        = 12'h000,  // Debug control register
        DBG_STATUS      = 12'h001,  // Debug status register
        DBG_PC          = 12'h002,  // Current PC
        DBG_INST        = 12'h003,  // Current instruction
        DBG_BP_CTRL     = 12'h010,  // Breakpoint control
        DBG_BP_ADDR_BASE = 12'h020, // Breakpoint addresses start
        DBG_WP_CTRL     = 12'h030,  // Watchpoint control
        DBG_WP_ADDR_BASE = 12'h040, // Watchpoint addresses start
        DBG_WP_DATA_BASE = 12'h050, // Watchpoint data start
        DBG_PERF_CTR_BASE = 12'h100, // Performance counters start
        DBG_TRACE_CTRL  = 12'h200,  // Trace control
        DBG_TRACE_DATA  = 12'h201   // Trace data
    } dbg_reg_addr_t;
    
    // Instruction decode
    logic [6:0]  opcode;
    logic [2:0]  funct3;
    logic [11:0] csr_addr;
    logic [4:0]  rs1, rd;
    
    assign opcode = cp_instruction[6:0];
    assign funct3 = cp_instruction[14:12];
    assign csr_addr = cp_instruction[31:20];
    assign rs1 = cp_instruction[19:15];
    assign rd = cp_instruction[11:7];
    
    // Debug control registers
    logic [DATA_WIDTH-1:0] dbg_ctrl_reg;
    logic [DATA_WIDTH-1:0] dbg_status_reg;
    logic [DATA_WIDTH-1:0] dbg_pc_reg;
    logic [DATA_WIDTH-1:0] dbg_inst_reg;
    
    // Breakpoint registers
    logic [NUM_BREAKPOINTS-1:0] bp_enable;
    logic [ADDR_WIDTH-1:0] bp_addresses [NUM_BREAKPOINTS-1:0];
    logic [NUM_BREAKPOINTS-1:0] bp_hit;
    
    // Watchpoint registers
    logic [NUM_WATCHPOINTS-1:0] wp_enable;
    logic [NUM_WATCHPOINTS-1:0] wp_read_enable;
    logic [NUM_WATCHPOINTS-1:0] wp_write_enable;
    logic [ADDR_WIDTH-1:0] wp_addresses [NUM_WATCHPOINTS-1:0];
    logic [DATA_WIDTH-1:0] wp_data_values [NUM_WATCHPOINTS-1:0];
    logic [DATA_WIDTH-1:0] wp_data_masks [NUM_WATCHPOINTS-1:0];
    logic [NUM_WATCHPOINTS-1:0] wp_hit;
    
    // Performance counters
    logic [DATA_WIDTH-1:0] perf_cycle_count;
    logic [DATA_WIDTH-1:0] perf_inst_count;
    logic [DATA_WIDTH-1:0] perf_branch_count;
    logic [DATA_WIDTH-1:0] perf_cache_miss_count;
    
    // Trace buffer
    typedef struct packed {
        logic [ADDR_WIDTH-1:0]  pc;
        logic [INST_WIDTH-1:0]  instruction;
        logic [ADDR_WIDTH-1:0]  mem_addr;
        logic [DATA_WIDTH-1:0]  mem_data;
        logic                   mem_write;
        logic [63:0]            timestamp;
    } trace_entry_t;
    
    trace_entry_t trace_buffer [TRACE_BUFFER_SIZE-1:0];
    logic [$clog2(TRACE_BUFFER_SIZE)-1:0] trace_write_ptr;
    logic [$clog2(TRACE_BUFFER_SIZE)-1:0] trace_read_ptr;
    logic trace_enable;
    logic trace_full;
    logic trace_overflow;
    logic [63:0] trace_timestamp;
    
    // Debug state machine
    typedef enum logic [2:0] {
        DEBUG_RUNNING,
        DEBUG_HALTED,
        DEBUG_SINGLE_STEP,
        DEBUG_BREAKPOINT,
        DEBUG_WATCHPOINT
    } debug_state_t;
    
    debug_state_t debug_state;
    logic debug_halt_internal;
    logic debug_resume_req;
    logic debug_step_req;
    
    // Detect debug instructions
    logic is_debug_instruction;
    assign is_debug_instruction = cp_enable && (opcode == 7'b1110011) && (funct3 != 3'b000);
    
    // Breakpoint detection
    always_comb begin
        bp_hit = '0;
        for (int i = 0; i < NUM_BREAKPOINTS; i++) begin
            if (bp_enable[i] && (debug_pc == bp_addresses[i])) begin
                bp_hit[i] = 1'b1;
            end
        end
    end
    
    // Watchpoint detection
    always_comb begin
        wp_hit = '0;
        for (int i = 0; i < NUM_WATCHPOINTS; i++) begin
            if (wp_enable[i] && (debug_mem_addr == wp_addresses[i])) begin
                logic data_match = ((debug_mem_data & wp_data_masks[i]) == 
                                   (wp_data_values[i] & wp_data_masks[i]));
                if ((wp_read_enable[i] && !debug_mem_write) ||
                    (wp_write_enable[i] && debug_mem_write)) begin
                    if (wp_data_masks[i] == '0 || data_match) begin
                        wp_hit[i] = 1'b1;
                    end
                end
            end
        end
    end
    
    // Debug state management
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            debug_state <= DEBUG_RUNNING;
            debug_halt_internal <= 1'b0;
        end else begin
            case (debug_state)
                DEBUG_RUNNING: begin
                    if (external_halt_req || (|bp_hit) || (|wp_hit)) begin
                        debug_state <= DEBUG_HALTED;
                        debug_halt_internal <= 1'b1;
                    end else if (debug_step_req) begin
                        debug_state <= DEBUG_SINGLE_STEP;
                    end
                end
                DEBUG_HALTED: begin
                    if (debug_resume_req) begin
                        debug_state <= DEBUG_RUNNING;
                        debug_halt_internal <= 1'b0;
                    end else if (debug_step_req) begin
                        debug_state <= DEBUG_SINGLE_STEP;
                    end
                end
                DEBUG_SINGLE_STEP: begin
                    // Execute one instruction then halt
                    debug_state <= DEBUG_HALTED;
                    debug_halt_internal <= 1'b1;
                end
                default: begin
                    debug_state <= DEBUG_RUNNING;
                end
            endcase
        end
    end
    
    // Performance counter updates
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            perf_cycle_count <= '0;
            perf_inst_count <= '0;
            perf_branch_count <= '0;
            perf_cache_miss_count <= '0;
        end else begin
            perf_cycle_count <= perf_cycle_count + 1;
            if (debug_inst_valid) begin
                perf_inst_count <= perf_inst_count + 1;
                // Count branches (simplified detection)
                if (debug_instruction[6:0] == 7'b1100011 || // Branch instructions
                    debug_instruction[6:0] == 7'b1101111 || // JAL
                    debug_instruction[6:0] == 7'b1100111) begin // JALR
                    perf_branch_count <= perf_branch_count + 1;
                end
            end
        end
    end
    
    // Trace buffer management
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            trace_write_ptr <= '0;
            trace_read_ptr <= '0;
            trace_enable <= 1'b0;
            trace_overflow <= 1'b0;
            trace_timestamp <= '0;
        end else begin
            trace_timestamp <= trace_timestamp + 1;
            
            if (trace_enable && debug_inst_valid) begin
                trace_buffer[trace_write_ptr] <= '{
                    pc: debug_pc,
                    instruction: debug_instruction,
                    mem_addr: debug_mem_addr,
                    mem_data: debug_mem_data,
                    mem_write: debug_mem_write,
                    timestamp: trace_timestamp
                };
                
                if (trace_write_ptr == TRACE_BUFFER_SIZE - 1) begin
                    trace_write_ptr <= '0;
                    if (trace_read_ptr == 0) begin
                        trace_overflow <= 1'b1;
                    end
                end else begin
                    trace_write_ptr <= trace_write_ptr + 1;
                end
            end
        end
    end
    
    // Register read/write logic
    logic [DATA_WIDTH-1:0] reg_read_data;
    logic reg_write_enable;
    logic [DATA_WIDTH-1:0] reg_write_data;
    
    always_comb begin
        reg_read_data = '0;
        reg_write_enable = 1'b0;
        reg_write_data = cp_data_in;
        debug_resume_req = 1'b0;
        debug_step_req = 1'b0;
        
        if (is_debug_instruction) begin
            if (funct3 == 3'b001 || funct3 == 3'b010 || funct3 == 3'b011) begin // CSR operations
                case (csr_addr)
                    DBG_CTRL: begin
                        reg_read_data = dbg_ctrl_reg;
                        if (funct3 == 3'b001) begin // CSRRW
                            reg_write_enable = 1'b1;
                            debug_resume_req = reg_write_data[0];
                            debug_step_req = reg_write_data[1];
                        end
                    end
                    DBG_STATUS: begin
                        reg_read_data = dbg_status_reg;
                    end
                    DBG_PC: begin
                        reg_read_data = debug_pc;
                    end
                    DBG_TRACE_CTRL: begin
                        reg_read_data = {trace_overflow, trace_full, 62'b0} | trace_enable;
                        if (funct3 == 3'b001) begin
                            reg_write_enable = 1'b1;
                        end
                    end
                    DBG_TRACE_DATA: begin
                        if (trace_read_ptr != trace_write_ptr) begin
                            reg_read_data = trace_buffer[trace_read_ptr].pc;
                        end
                    end
                    default: begin
                        // Handle breakpoint and watchpoint registers
                        if (csr_addr >= DBG_BP_ADDR_BASE && csr_addr < DBG_BP_ADDR_BASE + NUM_BREAKPOINTS) begin
                            logic [3:0] bp_idx = csr_addr[3:0];
                            reg_read_data = bp_addresses[bp_idx];
                            if (funct3 == 3'b001) begin
                                reg_write_enable = 1'b1;
                            end
                        end
                    end
                endcase
            end
        end
    end
    
    // Register updates
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dbg_ctrl_reg <= '0;
            dbg_status_reg <= '0;
            trace_enable <= 1'b0;
            bp_enable <= '0;
            wp_enable <= '0;
            for (int i = 0; i < NUM_BREAKPOINTS; i++) begin
                bp_addresses[i] <= '0;
            end
            for (int i = 0; i < NUM_WATCHPOINTS; i++) begin
                wp_addresses[i] <= '0;
                wp_data_values[i] <= '0;
                wp_data_masks[i] <= '0;
            end
        end else begin
            // Update status register
            dbg_status_reg <= {
                58'b0,
                debug_state == DEBUG_HALTED,    // [5] Halted
                (|wp_hit),                      // [4] Watchpoint hit
                (|bp_hit),                      // [3] Breakpoint hit
                debug_state == DEBUG_SINGLE_STEP, // [2] Single step
                external_debug_req,             // [1] External debug request
                debug_state != DEBUG_RUNNING    // [0] Debug mode
            };
            
            if (reg_write_enable && is_debug_instruction) begin
                case (csr_addr)
                    DBG_CTRL: begin
                        dbg_ctrl_reg <= reg_write_data;
                    end
                    DBG_TRACE_CTRL: begin
                        trace_enable <= reg_write_data[0];
                    end
                    default: begin
                        if (csr_addr >= DBG_BP_ADDR_BASE && csr_addr < DBG_BP_ADDR_BASE + NUM_BREAKPOINTS) begin
                            logic [3:0] bp_idx = csr_addr[3:0];
                            bp_addresses[bp_idx] <= reg_write_data[ADDR_WIDTH-1:0];
                            bp_enable[bp_idx] <= 1'b1;
                        end
                    end
                endcase
            end
        end
    end
    
    // Output assignments
    assign cp_data_out = reg_read_data;
    assign cp_ready = 1'b1; // Debug operations complete immediately
    assign cp_exception = 1'b0; // No exceptions for debug operations
    
    assign debug_halt_request = debug_halt_internal;
    assign debug_single_step = (debug_state == DEBUG_SINGLE_STEP);
    assign debug_breakpoint_hit = (|bp_hit);
    assign debug_watchpoint_hit = (|wp_hit);
    assign debug_status = dbg_status_reg;
    assign debug_halt_pc = debug_pc;

endmodule