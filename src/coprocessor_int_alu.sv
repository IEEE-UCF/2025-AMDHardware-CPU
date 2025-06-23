// Coprocessor Integer ALU
// Specialized ALU for coprocessor integer operations

module coprocessor_int_alu #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst_n,
    
    // Control Interface
    input  logic                    alu_enable,
    input  logic [4:0]              alu_operation,
    input  logic [2:0]              alu_format,
    
    // Data Interface
    input  logic [DATA_WIDTH-1:0]  operand_a,
    input  logic [DATA_WIDTH-1:0]  operand_b,
    input  logic [DATA_WIDTH-1:0]  operand_c,
    output logic [DATA_WIDTH-1:0]  result,
    output logic                    result_valid,
    
    // Status Flags
    output logic                    zero_flag,
    output logic                    negative_flag,
    output logic                    carry_flag,
    output logic                    overflow_flag,
    output logic                    parity_flag,
    
    // Control Outputs
    output logic                    alu_ready,
    output logic                    alu_busy
);

    // ALU Operation Codes
    typedef enum logic [4:0] {
        ALU_ADD     = 5'b00000,
        ALU_SUB     = 5'b00001,
        ALU_AND     = 5'b00010,
        ALU_OR      = 5'b00011,
        ALU_XOR     = 5'b00100,
        ALU_SLL     = 5'b00101,  // Shift left logical
        ALU_SRL     = 5'b00110,  // Shift right logical
        ALU_SRA     = 5'b00111,  // Shift right arithmetic
        ALU_SLT     = 5'b01000,  // Set less than
        ALU_SLTU    = 5'b01001,  // Set less than unsigned
        ALU_MUL     = 5'b01010,  // Multiply
        ALU_MULH    = 5'b01011,  // Multiply high
        ALU_MULHU   = 5'b01100,  // Multiply high unsigned
        ALU_MULHSU  = 5'b01101,  // Multiply high signed-unsigned
        ALU_DIV     = 5'b01110,  // Divide
        ALU_DIVU    = 5'b01111,  // Divide unsigned
        ALU_REM     = 5'b10000,  // Remainder
        ALU_REMU    = 5'b10001,  // Remainder unsigned
        ALU_MAX     = 5'b10010,  // Maximum
        ALU_MIN     = 5'b10011,  // Minimum
        ALU_MAXU    = 5'b10100,  // Maximum unsigned
        ALU_MINU    = 5'b10101,  // Minimum unsigned
        ALU_CLZ     = 5'b10110,  // Count leading zeros
        ALU_CTZ     = 5'b10111,  // Count trailing zeros
        ALU_PCNT    = 5'b11000,  // Population count
        ALU_BSWAP   = 5'b11001,  // Byte swap
        ALU_SEXT_B  = 5'b11010,  // Sign extend byte
        ALU_SEXT_H  = 5'b11011,  // Sign extend halfword
        ALU_ZEXT_B  = 5'b11100,  // Zero extend byte
        ALU_ZEXT_H  = 5'b11101,  // Zero extend halfword
        ALU_ROL     = 5'b11110,  // Rotate left
        ALU_ROR     = 5'b11111   // Rotate right
    } alu_op_t;
    
    // Format types
    typedef enum logic [2:0] {
        FMT_WORD    = 3'b000,    // 32-bit operation
        FMT_DWORD   = 3'b001,    // 64-bit operation
        FMT_BYTE    = 3'b010,    // 8-bit operation
        FMT_HWORD   = 3'b011,    // 16-bit operation
        FMT_SIGNED  = 3'b100,    // Signed operation
        FMT_UNSIGNED = 3'b101    // Unsigned operation
    } alu_fmt_t;
    
    // Internal signals
    logic [DATA_WIDTH-1:0]   alu_result;
    logic [DATA_WIDTH*2-1:0] extended_result;  // For multiply operations
    logic [5:0]              shift_amount;
    logic                    operation_done;
    logic                    multi_cycle_op;
    logic [3:0]              cycle_counter;
    
    // Status flag computation
    logic result_zero, result_negative, result_carry, result_overflow, result_parity;
    
    // Determine if operation is multi-cycle
    always_comb begin
        multi_cycle_op = 1'b0;
        case (alu_operation)
            ALU_MUL, ALU_MULH, ALU_MULHU, ALU_MULHSU,
            ALU_DIV, ALU_DIVU, ALU_REM, ALU_REMU:
                multi_cycle_op = 1'b1;
            default:
                multi_cycle_op = 1'b0;
        endcase
    end
    
    // Shift amount extraction
    always_comb begin
        if (alu_format == FMT_WORD) begin
            shift_amount = operand_b[4:0];  // 32-bit shifts use 5 bits
        end else begin
            shift_amount = operand_b[5:0];  // 64-bit shifts use 6 bits
        end
    end
    
    // Multi-cycle operation counter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_counter <= 4'b0;
            operation_done <= 1'b0;
        end else begin
            if (alu_enable && multi_cycle_op) begin
                if (cycle_counter < 4'd8) begin // Max 8 cycles for complex ops
                    cycle_counter <= cycle_counter + 1;
                    operation_done <= 1'b0;
                end else begin
                    operation_done <= 1'b1;
                    cycle_counter <= 4'b0;
                end
            end else if (alu_enable) begin
                operation_done <= 1'b1;
                cycle_counter <= 4'b0;
            end else begin
                operation_done <= 1'b0;
                cycle_counter <= 4'b0;
            end
        end
    end
    
    // Main ALU logic
    always_comb begin
        alu_result = 64'b0;
        extended_result = 128'b0;
        result_carry = 1'b0;
        result_overflow = 1'b0;
        
        case (alu_operation)
            ALU_ADD: begin
                {result_carry, alu_result} = operand_a + operand_b;
                result_overflow = (operand_a[DATA_WIDTH-1] == operand_b[DATA_WIDTH-1]) &&
                                 (alu_result[DATA_WIDTH-1] != operand_a[DATA_WIDTH-1]);
            end
            
            ALU_SUB: begin
                {result_carry, alu_result} = operand_a - operand_b;
                result_overflow = (operand_a[DATA_WIDTH-1] != operand_b[DATA_WIDTH-1]) &&
                                 (alu_result[DATA_WIDTH-1] != operand_a[DATA_WIDTH-1]);
            end
            
            ALU_AND: begin
                alu_result = operand_a & operand_b;
            end
            
            ALU_OR: begin
                alu_result = operand_a | operand_b;
            end
            
            ALU_XOR: begin
                alu_result = operand_a ^ operand_b;
            end
            
            ALU_SLL: begin
                if (alu_format == FMT_WORD) begin
                    alu_result = {{32{1'b0}}, operand_a[31:0] << shift_amount[4:0]};
                end else begin
                    alu_result = operand_a << shift_amount;
                end
            end
            
            ALU_SRL: begin
                if (alu_format == FMT_WORD) begin
                    alu_result = {{32{1'b0}}, operand_a[31:0] >> shift_amount[4:0]};
                end else begin
                    alu_result = operand_a >> shift_amount;
                end
            end
            
            ALU_SRA: begin
                if (alu_format == FMT_WORD) begin
                    alu_result = {{32{operand_a[31]}}, $signed(operand_a[31:0]) >>> shift_amount[4:0]};
                end else begin
                    alu_result = $signed(operand_a) >>> shift_amount;
                end
            end
            
            ALU_SLT: begin
                alu_result = ($signed(operand_a) < $signed(operand_b)) ? 64'b1 : 64'b0;
            end
            
            ALU_SLTU: begin
                alu_result = (operand_a < operand_b) ? 64'b1 : 64'b0;
            end
            
            ALU_MUL: begin
                if (alu_format == FMT_WORD) begin
                    extended_result = $signed(operand_a[31:0]) * $signed(operand_b[31:0]);
                    alu_result = {{32{extended_result[31]}}, extended_result[31:0]};
                end else begin
                    extended_result = $signed(operand_a) * $signed(operand_b);
                    alu_result = extended_result[63:0];
                end
            end
            
            ALU_MULH: begin
                extended_result = $signed(operand_a) * $signed(operand_b);
                alu_result = extended_result[127:64];
            end
            
            ALU_MULHU: begin
                extended_result = operand_a * operand_b;
                alu_result = extended_result[127:64];
            end
            
            ALU_MULHSU: begin
                extended_result = $signed(operand_a) * operand_b;
                alu_result = extended_result[127:64];
            end
            
            ALU_DIV: begin
                if (operand_b != 64'b0) begin
                    alu_result = $signed(operand_a) / $signed(operand_b);
                end else begin
                    alu_result = 64'hFFFFFFFFFFFFFFFF; // Division by zero
                end
            end
            
            ALU_DIVU: begin
                if (operand_b != 64'b0) begin
                    alu_result = operand_a / operand_b;
                end else begin
                    alu_result = 64'hFFFFFFFFFFFFFFFF; // Division by zero
                end
            end
            
            ALU_REM: begin
                if (operand_b != 64'b0) begin
                    alu_result = $signed(operand_a) % $signed(operand_b);
                end else begin
                    alu_result = operand_a; // Remainder by zero
                end
            end
            
            ALU_REMU: begin
                if (operand_b != 64'b0) begin
                    alu_result = operand_a % operand_b;
                end else begin
                    alu_result = operand_a; // Remainder by zero
                end
            end
            
            ALU_MAX: begin
                alu_result = ($signed(operand_a) > $signed(operand_b)) ? operand_a : operand_b;
            end
            
            ALU_MIN: begin
                alu_result = ($signed(operand_a) < $signed(operand_b)) ? operand_a : operand_b;
            end
            
            ALU_MAXU: begin
                alu_result = (operand_a > operand_b) ? operand_a : operand_b;
            end
            
            ALU_MINU: begin
                alu_result = (operand_a < operand_b) ? operand_a : operand_b;
            end
            
            ALU_CLZ: begin // Count leading zeros
                alu_result = 64'b0;
                for (int i = 63; i >= 0; i--) begin
                    if (operand_a[i] == 1'b0) begin
                        alu_result = alu_result + 1;
                    end else begin
                        break;
                    end
                end
            end
            
            ALU_CTZ: begin // Count trailing zeros
                alu_result = 64'b0;
                for (int i = 0; i < 64; i++) begin
                    if (operand_a[i] == 1'b0) begin
                        alu_result = alu_result + 1;
                    end else begin
                        break;
                    end
                end
            end
            
            ALU_PCNT: begin // Population count
                alu_result = 64'b0;
                for (int i = 0; i < 64; i++) begin
                    alu_result = alu_result + operand_a[i];
                end
            end
            
            ALU_BSWAP: begin // Byte swap
                alu_result = {operand_a[7:0], operand_a[15:8], operand_a[23:16], operand_a[31:24],
                             operand_a[39:32], operand_a[47:40], operand_a[55:48], operand_a[63:56]};
            end
            
            ALU_SEXT_B: begin // Sign extend byte
                alu_result = {{56{operand_a[7]}}, operand_a[7:0]};
            end
            
            ALU_SEXT_H: begin // Sign extend halfword
                alu_result = {{48{operand_a[15]}}, operand_a[15:0]};
            end
            
            ALU_ZEXT_B: begin // Zero extend byte
                alu_result = {56'b0, operand_a[7:0]};
            end
            
            ALU_ZEXT_H: begin // Zero extend halfword
                alu_result = {48'b0, operand_a[15:0]};
            end
            
            ALU_ROL: begin // Rotate left
                alu_result = (operand_a << shift_amount) | (operand_a >> (64 - shift_amount));
            end
            
            ALU_ROR: begin // Rotate right
                alu_result = (operand_a >> shift_amount) | (operand_a << (64 - shift_amount));
            end
            
            default: begin
                alu_result = operand_a;
            end
        endcase
    end
    
    // Status flag computation
    always_comb begin
        result_zero = (alu_result == 64'b0);
        result_negative = alu_result[DATA_WIDTH-1];
        
        // Parity calculation (even parity)
        result_parity = 1'b0;
        for (int i = 0; i < 8; i++) begin
            result_parity = result_parity ^ alu_result[i];
        end
    end
    
    // Output assignments
    assign result = alu_result;
    assign result_valid = operation_done;
    assign alu_ready = !alu_enable || operation_done;
    assign alu_busy = alu_enable && !operation_done;
    
    // Status flags
    assign zero_flag = result_zero;
    assign negative_flag = result_negative;
    assign carry_flag = result_carry;
    assign overflow_flag = result_overflow;
    assign parity_flag = result_parity;

endmodule