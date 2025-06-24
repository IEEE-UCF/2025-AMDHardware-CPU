// Coprocessor MDU
// Multiply/Divide Unit for coprocessor operations

module coprocessor_mdu #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 64,
    parameter INST_WIDTH = 32
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
    
    // Register Interface
    input  logic [DATA_WIDTH-1:0]  rs1_data,
    input  logic [DATA_WIDTH-1:0]  rs2_data,
    output logic                    reg_write,
    output logic [4:0]              reg_addr,
    output logic [DATA_WIDTH-1:0]  reg_data,
    
    // Status and Control
    output logic [4:0]              mdu_flags,
    output logic                    mdu_busy
);

    // Instruction decode
    logic [6:0]  opcode;
    logic [4:0]  rd, rs1, rs2;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    
    assign opcode = cp_instruction[6:0];
    assign rd = cp_instruction[11:7];
    assign funct3 = cp_instruction[14:12];
    assign rs1 = cp_instruction[19:15];
    assign rs2 = cp_instruction[24:20];
    assign funct7 = cp_instruction[31:25];
    
    // MDU operation encoding
    logic [2:0] mdu_operation;
    logic [1:0] mdu_format;
    logic       mdu_start;
    logic       mdu_done;
    logic       mdu_ready_internal;
    
    // FSM interface
    logic       stage_setup_en;
    logic       stage_compute_en;
    logic       stage_normalize_en;
    logic       stage_complete_en;
    logic [4:0] cycle_count;
    logic [4:0] required_cycles;
    logic       operation_complete;
    
    // Operands and intermediate results
    logic [DATA_WIDTH-1:0]   operand_a, operand_b;
    logic [DATA_WIDTH*2-1:0] multiply_result;
    logic [DATA_WIDTH-1:0]   divide_quotient;
    logic [DATA_WIDTH-1:0]   divide_remainder;
    logic [DATA_WIDTH-1:0]   final_result;
    
    // Exception detection
    logic divide_by_zero;
    logic overflow_detected;
    logic exception_raised;
    
    // Status flags
    logic flag_zero, flag_negative, flag_overflow, flag_div_zero, flag_invalid;
    
    // Instruction decoding and operation setup
    always_comb begin
        mdu_operation = 3'b000;
        mdu_format = 2'b01; // Default 64-bit
        mdu_start = 1'b0;
        
        if (cp_enable && opcode == 7'b0110011 && funct7 == 7'b0000001) begin
            mdu_start = 1'b1;
            case (funct3)
                3'b000: mdu_operation = 3'b000; // MUL
                3'b001: mdu_operation = 3'b001; // MULH
                3'b010: mdu_operation = 3'b010; // MULHSU
                3'b011: mdu_operation = 3'b011; // MULHU
                3'b100: mdu_operation = 3'b100; // DIV
                3'b101: mdu_operation = 3'b101; // DIVU
                3'b110: mdu_operation = 3'b110; // REM
                3'b111: mdu_operation = 3'b111; // REMU
                default: mdu_start = 1'b0;
            endcase
        end else if (cp_enable && opcode == 7'b0111011 && funct7 == 7'b0000001) begin
            // 32-bit variants (RV64 *W instructions)
            mdu_start = 1'b1;
            mdu_format = 2'b00; // 32-bit
            case (funct3)
                3'b000: mdu_operation = 3'b000; // MULW
                3'b100: mdu_operation = 3'b100; // DIVW
                3'b101: mdu_operation = 3'b101; // DIVUW
                3'b110: mdu_operation = 3'b110; // REMW
                3'b111: mdu_operation = 3'b111; // REMUW
                default: mdu_start = 1'b0;
            endcase
        end
    end
    
    // Determine required cycles for operation
    always_comb begin
        case (mdu_operation)
            3'b000, 3'b001, 3'b010, 3'b011: required_cycles = 5'd3;  // Multiply operations
            3'b100, 3'b101, 3'b110, 3'b111: required_cycles = 5'd16; // Divide operations
            default:                         required_cycles = 5'd1;
        endcase
    end
    
    // Operand selection
    always_comb begin
        operand_a = rs1_data;
        operand_b = rs2_data;
    end
    
    // Exception detection
    always_comb begin
        divide_by_zero = (mdu_operation[2] == 1'b1) && (operand_b == 64'b0); // Division by zero
        overflow_detected = 1'b0;
        
        // Check for signed division overflow: -2^(n-1) / -1
        if (mdu_operation == 3'b100 || mdu_operation == 3'b110) begin // DIV or REM
            if (mdu_format == 2'b00) begin // 32-bit
                overflow_detected = (operand_a == 64'h80000000) && (operand_b == 64'hFFFFFFFF);
            end else begin // 64-bit
                overflow_detected = (operand_a == 64'h8000000000000000) && (operand_b == 64'hFFFFFFFFFFFFFFFF);
            end
        end
    end
    
    // MDU FSM instantiation
    coprocessor_mdu_fsm mdu_fsm (
        .clk(clk),
        .rst_n(rst_n),
        .mdu_start(mdu_start),
        .mdu_operation(mdu_operation),
        .mdu_format(mdu_format),
        .mdu_ready(mdu_ready_internal),
        .mdu_busy(mdu_busy),
        .mdu_done(mdu_done),
        .stage_setup_en(stage_setup_en),
        .stage_compute_en(stage_compute_en),
        .stage_normalize_en(stage_normalize_en),
        .stage_complete_en(stage_complete_en),
        .divide_by_zero(divide_by_zero),
        .overflow_detected(overflow_detected),
        .exception_raised(exception_raised),
        .cycle_count(cycle_count),
        .required_cycles(required_cycles),
        .operation_complete(operation_complete)
    );
    
    // Multiply logic
    always_comb begin
        multiply_result = 128'b0;
        case (mdu_operation)
            3'b000: begin // MUL
                if (mdu_format == 2'b00) begin // 32-bit
                    multiply_result = $signed(operand_a[31:0]) * $signed(operand_b[31:0]);
                end else begin // 64-bit
                    multiply_result = $signed(operand_a) * $signed(operand_b);
                end
            end
            3'b001: begin // MULH
                multiply_result = $signed(operand_a) * $signed(operand_b);
            end
            3'b010: begin // MULHSU
                multiply_result = $signed(operand_a) * $unsigned(operand_b);
            end
            3'b011: begin // MULHU
                multiply_result = $unsigned(operand_a) * $unsigned(operand_b);
            end
            default: multiply_result = 128'b0;
        endcase
    end
    
    // Divide logic
    always_comb begin
        divide_quotient = 64'b0;
        divide_remainder = 64'b0;
        
        if (!divide_by_zero && !overflow_detected) begin
            case (mdu_operation)
                3'b100: begin // DIV
                    if (mdu_format == 2'b00) begin // 32-bit
                        divide_quotient = {{32{1'b0}}, $signed(operand_a[31:0]) / $signed(operand_b[31:0])};
                        divide_remainder = {{32{1'b0}}, $signed(operand_a[31:0]) % $signed(operand_b[31:0])};
                    end else begin // 64-bit
                        divide_quotient = $signed(operand_a) / $signed(operand_b);
                        divide_remainder = $signed(operand_a) % $signed(operand_b);
                    end
                end
                3'b101: begin // DIVU
                    if (mdu_format == 2'b00) begin // 32-bit
                        divide_quotient = {{32{1'b0}}, operand_a[31:0] / operand_b[31:0]};
                        divide_remainder = {{32{1'b0}}, operand_a[31:0] % operand_b[31:0]};
                    end else begin // 64-bit
                        divide_quotient = operand_a / operand_b;
                        divide_remainder = operand_a % operand_b;
                    end
                end
                3'b110: begin // REM
                    if (mdu_format == 2'b00) begin // 32-bit
                        divide_remainder = {{32{1'b0}}, $signed(operand_a[31:0]) % $signed(operand_b[31:0])};
                    end else begin // 64-bit
                        divide_remainder = $signed(operand_a) % $signed(operand_b);
                    end
                end
                3'b111: begin // REMU
                    if (mdu_format == 2'b00) begin // 32-bit
                        divide_remainder = {{32{1'b0}}, operand_a[31:0] % operand_b[31:0]};
                    end else begin // 64-bit
                        divide_remainder = operand_a % operand_b;
                    end
                end
                default: begin
                    divide_quotient = 64'b0;
                    divide_remainder = 64'b0;
                end
            endcase
        end else begin
            // Handle exception cases
            if (divide_by_zero) begin
                divide_quotient = 64'hFFFFFFFFFFFFFFFF; // -1
                divide_remainder = operand_a;
            end else if (overflow_detected) begin
                divide_quotient = operand_a; // Return dividend
                divide_remainder = 64'b0;
            end
        end
    end
    
    // Result selection
    always_comb begin
        case (mdu_operation)
            3'b000: begin // MUL
                if (mdu_format == 2'b00) begin // 32-bit
                    final_result = {{32{multiply_result[31]}}, multiply_result[31:0]};
                end else begin // 64-bit
                    final_result = multiply_result[63:0];
                end
            end
            3'b001, 3'b010, 3'b011: begin // MULH variants
                final_result = multiply_result[127:64];
            end
            3'b100, 3'b101: begin // DIV, DIVU
                if (mdu_format == 2'b00) begin // 32-bit
                    final_result = {{32{divide_quotient[31]}}, divide_quotient[31:0]};
                end else begin // 64-bit
                    final_result = divide_quotient;
                end
            end
            3'b110, 3'b111: begin // REM, REMU
                if (mdu_format == 2'b00) begin // 32-bit
                    final_result = {{32{divide_remainder[31]}}, divide_remainder[31:0]};
                end else begin // 64-bit
                    final_result = divide_remainder;
                end
            end
            default: final_result = 64'b0;
        endcase
    end
    
    // Status flag generation
    always_comb begin
        flag_zero = (final_result == 64'b0);
        flag_negative = final_result[63];
        flag_overflow = overflow_detected;
        flag_div_zero = divide_by_zero;
        flag_invalid = exception_raised;
    end
    
    // Output assignments
    assign cp_data_out = final_result;
    assign cp_ready = mdu_ready_internal;
    assign cp_exception = exception_raised;
    
    assign reg_write = mdu_done && (rd != 5'b0);
    assign reg_addr = rd;
    assign reg_data = final_result;
    
    assign mdu_flags = {flag_invalid, flag_div_zero, flag_overflow, flag_negative, flag_zero};

endmodule