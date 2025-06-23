// Coprocessor FSM
// Generic Finite State Machine for coprocessor operations

module coprocessor_fsm #(
    parameter DATA_WIDTH = 64,
    parameter STATE_WIDTH = 4,
    parameter OP_WIDTH = 5
)(
    input  logic                    clk,
    input  logic                    rst_n,
    
    // Control Interface
    input  logic                    cp_start,
    input  logic [OP_WIDTH-1:0]     cp_operation,
    input  logic                    cp_stall,
    output logic                    cp_ready,
    output logic                    cp_busy,
    output logic                    cp_done,
    
    // Pipeline Stage Control
    output logic                    stage_fetch_en,
    output logic                    stage_decode_en,
    output logic                    stage_execute_en,
    output logic                    stage_writeback_en,
    
    // Exception Handling
    input  logic                    exception_request,
    input  logic [3:0]              exception_code,
    output logic                    exception_active,
    output logic                    exception_handled,
    
    // Multi-cycle Operation Support
    input  logic [7:0]              required_cycles,
    output logic [7:0]              current_cycle,
    output logic                    operation_complete,
    
    // Debug Interface
    output logic [STATE_WIDTH-1:0] current_state_debug,
    output logic [STATE_WIDTH-1:0] next_state_debug
);

    // FSM States
    typedef enum logic [STATE_WIDTH-1:0] {
        CP_IDLE         = 4'b0000,
        CP_FETCH        = 4'b0001,
        CP_DECODE       = 4'b0010,
        CP_EXECUTE      = 4'b0011,
        CP_WRITEBACK    = 4'b0100,
        CP_COMPLETE     = 4'b0101,
        CP_EXCEPTION    = 4'b0110,
        CP_STALL        = 4'b0111,
        CP_FLUSH        = 4'b1000,
        CP_RESET        = 4'b1001
    } cp_state_t;
    
    cp_state_t current_state, next_state;
    
    // Internal registers
    logic [7:0]  cycle_counter;
    logic [OP_WIDTH-1:0] operation_reg;
    logic        multi_cycle_operation;
    logic        exception_pending;
    logic [3:0]  exception_code_reg;
    
    // Operation classification
    always_comb begin
        multi_cycle_operation = 1'b0;
        case (cp_operation)
            5'b00011,  // Division
            5'b00100,  // Square root
            5'b00101,  // Multiply-add
            5'b00110,  // Multiply-sub
            5'b00111,  // Negative multiply-add
            5'b01000,  // Negative multiply-sub
            5'b10000,  // Load/Store operations
            5'b10001,  // Memory operations
            5'b11000,  // System operations
            5'b11001:  // Debug operations
                multi_cycle_operation = 1'b1;
            default:
                multi_cycle_operation = 1'b0;
        endcase
    end
    
    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= CP_IDLE;
            cycle_counter <= 8'b0;
            operation_reg <= '0;
            exception_pending <= 1'b0;
            exception_code_reg <= 4'b0;
        end else begin
            current_state <= next_state;
            
            // Cycle counter management
            if (current_state == CP_EXECUTE) begin
                cycle_counter <= cycle_counter + 1;
            end else begin
                cycle_counter <= 8'b0;
            end
            
            // Operation register
            if (current_state == CP_DECODE) begin
                operation_reg <= cp_operation;
            end
            
            // Exception handling
            if (exception_request && current_state != CP_EXCEPTION) begin
                exception_pending <= 1'b1;
                exception_code_reg <= exception_code;
            end else if (current_state == CP_EXCEPTION) begin
                exception_pending <= 1'b0;
            end
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = current_state;
        operation_complete = (cycle_counter >= required_cycles);
        
        case (current_state)
            CP_IDLE: begin
                if (exception_request || exception_pending) begin
                    next_state = CP_EXCEPTION;
                end else if (cp_start) begin
                    next_state = CP_FETCH;
                end
            end
            
            CP_FETCH: begin
                if (exception_request || exception_pending) begin
                    next_state = CP_EXCEPTION;
                end else if (cp_stall) begin
                    next_state = CP_STALL;
                end else begin
                    next_state = CP_DECODE;
                end
            end
            
            CP_DECODE: begin
                if (exception_request || exception_pending) begin
                    next_state = CP_EXCEPTION;
                end else if (cp_stall) begin
                    next_state = CP_STALL;
                end else begin
                    next_state = CP_EXECUTE;
                end
            end
            
            CP_EXECUTE: begin
                if (exception_request || exception_pending) begin
                    next_state = CP_EXCEPTION;
                end else if (cp_stall) begin
                    next_state = CP_STALL;
                end else if (multi_cycle_operation && !operation_complete) begin
                    next_state = CP_EXECUTE; // Stay in execute
                end else begin
                    next_state = CP_WRITEBACK;
                end
            end
            
            CP_WRITEBACK: begin
                if (exception_request || exception_pending) begin
                    next_state = CP_EXCEPTION;
                end else if (cp_stall) begin
                    next_state = CP_STALL;
                end else begin
                    next_state = CP_COMPLETE;
                end
            end
            
            CP_COMPLETE: begin
                next_state = CP_IDLE;
            end
            
            CP_EXCEPTION: begin
                // Stay in exception state for one cycle
                next_state = CP_IDLE;
            end
            
            CP_STALL: begin
                if (exception_request || exception_pending) begin
                    next_state = CP_EXCEPTION;
                end else if (!cp_stall) begin
                    // Return to previous state logic
                    case (operation_reg)
                        default: next_state = CP_EXECUTE;
                    endcase
                end
            end
            
            CP_FLUSH: begin
                next_state = CP_IDLE;
            end
            
            CP_RESET: begin
                next_state = CP_IDLE;
            end
            
            default: begin
                next_state = CP_IDLE;
            end
        endcase
    end
    
    // Output control signals
    always_comb begin
        // Default values
        stage_fetch_en = 1'b0;
        stage_decode_en = 1'b0;
        stage_execute_en = 1'b0;
        stage_writeback_en = 1'b0;
        cp_ready = 1'b0;
        cp_busy = 1'b0;
        cp_done = 1'b0;
        exception_active = 1'b0;
        exception_handled = 1'b0;
        
        case (current_state)
            CP_IDLE: begin
                cp_ready = 1'b1;
            end
            
            CP_FETCH: begin
                stage_fetch_en = 1'b1;
                cp_busy = 1'b1;
            end
            
            CP_DECODE: begin
                stage_decode_en = 1'b1;
                cp_busy = 1'b1;
            end
            
            CP_EXECUTE: begin
                stage_execute_en = 1'b1;
                cp_busy = 1'b1;
            end
            
            CP_WRITEBACK: begin
                stage_writeback_en = 1'b1;
                cp_busy = 1'b1;
            end
            
            CP_COMPLETE: begin
                cp_done = 1'b1;
            end
            
            CP_EXCEPTION: begin
                exception_active = 1'b1;
                exception_handled = 1'b1;
            end
            
            CP_STALL: begin
                cp_busy = 1'b1;
            end
            
            CP_FLUSH: begin
                // Flush state - no enables
            end
            
            CP_RESET: begin
                // Reset state - no enables
            end
            
            default: begin
                cp_ready = 1'b1;
            end
        endcase
    end
    
    // Cycle counter output
    assign current_cycle = cycle_counter;
    
    // Debug outputs
    assign current_state_debug = current_state;
    assign next_state_debug = next_state;

endmodule