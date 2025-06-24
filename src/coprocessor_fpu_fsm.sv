// Coprocessor FPU FSM
// Finite State Machine for Floating Point Unit operations

module coprocessor_fpu_fsm #(
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst_n,
    
    // Control Interface
    input  logic                    fpu_start,
    input  logic [4:0]              fpu_operation,
    input  logic [1:0]              fpu_format,
    output logic                    fpu_ready,
    output logic                    fpu_busy,
    output logic                    fpu_done,
    
    // Pipeline Control
    output logic                    stage_decode_en,
    output logic                    stage_unpack_en,
    output logic                    stage_execute_en,
    output logic                    stage_normalize_en,
    output logic                    stage_round_en,
    output logic                    stage_pack_en,
    
    // Exception Handling
    input  logic                    exception_detected,
    output logic                    exception_handled,
    
    // Cycle Counter
    output logic [4:0]              cycle_count,
    input  logic [4:0]              required_cycles
);

    // FSM States
    typedef enum logic [3:0] {
        FPU_IDLE        = 4'b0000,
        FPU_DECODE      = 4'b0001,
        FPU_UNPACK      = 4'b0010,
        FPU_EXECUTE     = 4'b0011,
        FPU_NORMALIZE   = 4'b0100,
        FPU_ROUND       = 4'b0101,
        FPU_PACK        = 4'b0110,
        FPU_COMPLETE    = 4'b0111,
        FPU_EXCEPTION   = 4'b1000,
        FPU_STALL       = 4'b1001
    } fpu_state_t;
    
    fpu_state_t current_state, next_state;
    
    // Internal counters and flags
    logic [4:0] cycle_counter;
    logic       operation_complete;
    logic       multi_cycle_op;
    
    // Determine if operation is multi-cycle
    always_comb begin
        multi_cycle_op = 1'b0;
        case (fpu_operation)
            5'b00011: multi_cycle_op = 1'b1; // DIV
            5'b00100: multi_cycle_op = 1'b1; // SQRT
            5'b00101,
            5'b00110,
            5'b00111,
            5'b01000: multi_cycle_op = 1'b1; // FMADD operations
            default:  multi_cycle_op = 1'b0;
        endcase
    end
    
    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= FPU_IDLE;
            cycle_counter <= 5'b0;
        end else begin
            current_state <= next_state;
            
            if (current_state == FPU_EXECUTE) begin
                cycle_counter <= cycle_counter + 1;
            end else begin
                cycle_counter <= 5'b0;
            end
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = current_state;
        operation_complete = (cycle_counter >= required_cycles);
        
        case (current_state)
            FPU_IDLE: begin
                if (fpu_start) begin
                    next_state = FPU_DECODE;
                end
            end
            
            FPU_DECODE: begin
                if (exception_detected) begin
                    next_state = FPU_EXCEPTION;
                end else begin
                    next_state = FPU_UNPACK;
                end
            end
            
            FPU_UNPACK: begin
                if (exception_detected) begin
                    next_state = FPU_EXCEPTION;
                end else begin
                    next_state = FPU_EXECUTE;
                end
            end
            
            FPU_EXECUTE: begin
                if (exception_detected) begin
                    next_state = FPU_EXCEPTION;
                end else if (multi_cycle_op && !operation_complete) begin
                    next_state = FPU_EXECUTE; // Stay in execute
                end else begin
                    next_state = FPU_NORMALIZE;
                end
            end
            
            FPU_NORMALIZE: begin
                if (exception_detected) begin
                    next_state = FPU_EXCEPTION;
                end else begin
                    next_state = FPU_ROUND;
                end
            end
            
            FPU_ROUND: begin
                if (exception_detected) begin
                    next_state = FPU_EXCEPTION;
                end else begin
                    next_state = FPU_PACK;
                end
            end
            
            FPU_PACK: begin
                next_state = FPU_COMPLETE;
            end
            
            FPU_COMPLETE: begin
                next_state = FPU_IDLE;
            end
            
            FPU_EXCEPTION: begin
                next_state = FPU_IDLE;
            end
            
            FPU_STALL: begin
                // Future use for pipeline stalls
                next_state = FPU_IDLE;
            end
            
            default: begin
                next_state = FPU_IDLE;
            end
        endcase
    end
    
    // Output control signals
    always_comb begin
        // Default values
        stage_decode_en = 1'b0;
        stage_unpack_en = 1'b0;
        stage_execute_en = 1'b0;
        stage_normalize_en = 1'b0;
        stage_round_en = 1'b0;
        stage_pack_en = 1'b0;
        fpu_ready = 1'b0;
        fpu_busy = 1'b0;
        fpu_done = 1'b0;
        exception_handled = 1'b0;
        
        case (current_state)
            FPU_IDLE: begin
                fpu_ready = 1'b1;
            end
            
            FPU_DECODE: begin
                stage_decode_en = 1'b1;
                fpu_busy = 1'b1;
            end
            
            FPU_UNPACK: begin
                stage_unpack_en = 1'b1;
                fpu_busy = 1'b1;
            end
            
            FPU_EXECUTE: begin
                stage_execute_en = 1'b1;
                fpu_busy = 1'b1;
            end
            
            FPU_NORMALIZE: begin
                stage_normalize_en = 1'b1;
                fpu_busy = 1'b1;
            end
            
            FPU_ROUND: begin
                stage_round_en = 1'b1;
                fpu_busy = 1'b1;
            end
            
            FPU_PACK: begin
                stage_pack_en = 1'b1;
                fpu_busy = 1'b1;
            end
            
            FPU_COMPLETE: begin
                fpu_done = 1'b1;
            end
            
            FPU_EXCEPTION: begin
                exception_handled = 1'b1;
            end
            
            default: begin
                fpu_ready = 1'b1;
            end
        endcase
    end
    
    // Cycle count output
    assign cycle_count = cycle_counter;

endmodule