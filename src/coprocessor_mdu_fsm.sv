// Coprocessor MDU FSM
// Finite State Machine for Multiply/Divide Unit operations

module coprocessor_mdu_fsm #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst_n,
    
    // Control Interface
    input  logic                    mdu_start,
    input  logic [2:0]              mdu_operation,
    input  logic [1:0]              mdu_format,
    output logic                    mdu_ready,
    output logic                    mdu_busy,
    output logic                    mdu_done,
    
    // Pipeline Control
    output logic                    stage_setup_en,
    output logic                    stage_compute_en,
    output logic                    stage_normalize_en,
    output logic                    stage_complete_en,
    
    // Operation Control
    input  logic                    divide_by_zero,
    input  logic                    overflow_detected,
    output logic                    exception_raised,
    
    // Cycle Management
    output logic [4:0]              cycle_count,
    input  logic [4:0]              required_cycles,
    output logic                    operation_complete
);

    // FSM States
    typedef enum logic [2:0] {
        MDU_IDLE        = 3'b000,
        MDU_SETUP       = 3'b001,
        MDU_COMPUTE     = 3'b010,
        MDU_NORMALIZE   = 3'b011,
        MDU_COMPLETE    = 3'b100,
        MDU_EXCEPTION   = 3'b101,
        MDU_STALL       = 3'b110
    } mdu_state_t;
    
    mdu_state_t current_state, next_state;
    
    // Operation types
    typedef enum logic [2:0] {
        MDU_MUL     = 3'b000,  // Multiply
        MDU_MULH    = 3'b001,  // Multiply high
        MDU_MULHU   = 3'b010,  // Multiply high unsigned
        MDU_MULHSU  = 3'b011,  // Multiply high signed-unsigned
        MDU_DIV     = 3'b100,  // Divide
        MDU_DIVU    = 3'b101,  // Divide unsigned
        MDU_REM     = 3'b110,  // Remainder
        MDU_REMU    = 3'b111   // Remainder unsigned
    } mdu_op_t;
    
    // Internal registers
    logic [4:0]  cycle_counter;
    logic [2:0]  operation_reg;
    logic [1:0]  format_reg;
    logic        is_divide_op;
    logic        is_multiply_op;
    logic        exception_pending;
    
    // Operation classification
    always_comb begin
        is_multiply_op = (mdu_operation[2] == 1'b0); // MUL operations
        is_divide_op = (mdu_operation[2] == 1'b1);   // DIV operations
    end
    
    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= MDU_IDLE;
            cycle_counter <= 5'b0;
            operation_reg <= 3'b0;
            format_reg <= 2'b0;
            exception_pending <= 1'b0;
        end else begin
            current_state <= next_state;
            
            // Cycle counter management
            if (current_state == MDU_COMPUTE) begin
                cycle_counter <= cycle_counter + 1;
            end else begin
                cycle_counter <= 5'b0;
            end
            
            // Latch operation parameters
            if (current_state == MDU_SETUP) begin
                operation_reg <= mdu_operation;
                format_reg <= mdu_format;
            end
            
            // Exception handling
            if ((divide_by_zero || overflow_detected) && current_state != MDU_EXCEPTION) begin
                exception_pending <= 1'b1;
            end else if (current_state == MDU_EXCEPTION) begin
                exception_pending <= 1'b0;
            end
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = current_state;
        operation_complete = (cycle_counter >= required_cycles);
        
        case (current_state)
            MDU_IDLE: begin
                if (mdu_start) begin
                    next_state = MDU_SETUP;
                end
            end
            
            MDU_SETUP: begin
                if (divide_by_zero) begin
                    next_state = MDU_EXCEPTION;
                end else if (overflow_detected) begin
                    next_state = MDU_EXCEPTION;
                end else begin
                    next_state = MDU_COMPUTE;
                end
            end
            
            MDU_COMPUTE: begin
                if (exception_pending) begin
                    next_state = MDU_EXCEPTION;
                end else if (operation_complete) begin
                    next_state = MDU_NORMALIZE;
                end
                // Stay in compute state for multi-cycle operations
            end
            
            MDU_NORMALIZE: begin
                if (exception_pending) begin
                    next_state = MDU_EXCEPTION;
                end else begin
                    next_state = MDU_COMPLETE;
                end
            end
            
            MDU_COMPLETE: begin
                next_state = MDU_IDLE;
            end
            
            MDU_EXCEPTION: begin
                next_state = MDU_IDLE;
            end
            
            MDU_STALL: begin
                // Future use for pipeline stalls
                next_state = MDU_IDLE;
            end
            
            default: begin
                next_state = MDU_IDLE;
            end
        endcase
    end
    
    // Output control signals
    always_comb begin
        // Default values
        stage_setup_en = 1'b0;
        stage_compute_en = 1'b0;
        stage_normalize_en = 1'b0;
        stage_complete_en = 1'b0;
        mdu_ready = 1'b0;
        mdu_busy = 1'b0;
        mdu_done = 1'b0;
        exception_raised = 1'b0;
        
        case (current_state)
            MDU_IDLE: begin
                mdu_ready = 1'b1;
            end
            
            MDU_SETUP: begin
                stage_setup_en = 1'b1;
                mdu_busy = 1'b1;
            end
            
            MDU_COMPUTE: begin
                stage_compute_en = 1'b1;
                mdu_busy = 1'b1;
            end
            
            MDU_NORMALIZE: begin
                stage_normalize_en = 1'b1;
                mdu_busy = 1'b1;
            end
            
            MDU_COMPLETE: begin
                stage_complete_en = 1'b1;
                mdu_done = 1'b1;
            end
            
            MDU_EXCEPTION: begin
                exception_raised = 1'b1;
            end
            
            MDU_STALL: begin
                mdu_busy = 1'b1;
            end
            
            default: begin
                mdu_ready = 1'b1;
            end
        endcase
    end
    
    // Cycle count output
    assign cycle_count = cycle_counter;

endmodule