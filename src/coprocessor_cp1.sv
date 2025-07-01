// Floating Point Coprocessor (CP1)
// Handles floating point arithmetic operations

module coprocessor_cp1 #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter FP_REG_NUM = 32
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
    
    // Floating Point Register File Interface
    output logic                    fp_reg_write,
    output logic [4:0]              fp_reg_waddr,
    output logic [DATA_WIDTH-1:0]   fp_reg_wdata,
    output logic [4:0]              fp_reg_raddr1,
    output logic [4:0]              fp_reg_raddr2,
    input  logic [DATA_WIDTH-1:0]   fp_reg_rdata1,
    input  logic [DATA_WIDTH-1:0]   fp_reg_rdata2,
    
    // Status flags
    output logic                    fp_invalid,
    output logic                    fp_divide_by_zero,
    output logic                    fp_overflow,
    output logic                    fp_underflow,
    output logic                    fp_inexact
);

    // Instruction decode
    logic [6:0]  opcode;
    logic [4:0]  rd, rs1, rs2;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [4:0]  rs3;
    logic [1:0]  fmt;        // Format: 00=S(32-bit), 01=D(64-bit)
    logic [2:0]  rm;         // Rounding mode
    
    assign opcode = cp_instruction[6:0];
    assign rd = cp_instruction[11:7];
    assign funct3 = cp_instruction[14:12];
    assign rs1 = cp_instruction[19:15];
    assign rs2 = cp_instruction[24:20];
    assign funct7 = cp_instruction[31:25];
    assign rs3 = cp_instruction[31:27];
    assign fmt = cp_instruction[26:25];
    assign rm = cp_instruction[14:12];
    
    // FP operation types
    typedef enum logic [6:0] {
        FP_LOAD     = 7'b0000111,  // FLW, FLD
        FP_STORE    = 7'b0100111,  // FSW, FSD
        FP_MADD     = 7'b1000011,  // FMADD
        FP_MSUB     = 7'b1000111,  // FMSUB
        FP_NMSUB    = 7'b1001011,  // FNMSUB
        FP_NMADD    = 7'b1001111,  // FNMADD
        FP_OP       = 7'b1010011   // FP arithmetic
    } fp_opcode_t;
    
    // FP arithmetic function codes
    typedef enum logic [6:0] {
        FP_ADD      = 7'b0000000,  // FADD
        FP_SUB      = 7'b0000100,  // FSUB
        FP_MUL      = 7'b0001000,  // FMUL
        FP_DIV      = 7'b0001100,  // FDIV
        FP_SQRT     = 7'b0101100,  // FSQRT
        FP_SGNJ     = 7'b0010000,  // FSGNJ, FSGNJN, FSGNJX
        FP_MINMAX   = 7'b0010100,  // FMIN, FMAX
        FP_CVT_W    = 7'b1100000,  // FCVT.W.S/D
        FP_CVT_WU   = 7'b1100001,  // FCVT.WU.S/D
        FP_CVT_L    = 7'b1100010,  // FCVT.L.S/D
        FP_CVT_LU   = 7'b1100011,  // FCVT.LU.S/D
        FP_CVT_S    = 7'b1101000,  // FCVT.S.W/WU/L/LU
        FP_CVT_D    = 7'b1101001,  // FCVT.D.W/WU/L/LU
        FP_CVT_SD   = 7'b0100000,  // FCVT.S.D, FCVT.D.S
        FP_CMP      = 7'b1010000,  // FEQ, FLT, FLE
        FP_CLASS    = 7'b1110000,  // FCLASS
        FP_MV       = 7'b1111000   // FMV.X.W/D, FMV.W/D.X
    } fp_funct7_t;
    
    // Pipeline stages
    typedef enum logic [2:0] {
        FP_IDLE,
        FP_DECODE,
        FP_EXECUTE,
        FP_COMPLETE
    } fp_state_t;
    
    fp_state_t current_state, next_state;
    
    // Internal registers
    logic [DATA_WIDTH-1:0] operand_a, operand_b, operand_c;
    logic [DATA_WIDTH-1:0] result;
    logic result_valid;
    logic [4:0] operation_cycles;
    logic [4:0] cycle_counter;
    
    // Floating point flags
    logic fp_flags_invalid, fp_flags_div_zero, fp_flags_overflow;
    logic fp_flags_underflow, fp_flags_inexact;
    
    // Detect FP instructions
    logic is_fp_instruction;
    assign is_fp_instruction = cp_enable && (
        opcode == FP_LOAD || opcode == FP_STORE || opcode == FP_MADD ||
        opcode == FP_MSUB || opcode == FP_NMSUB || opcode == FP_NMADD ||
        opcode == FP_OP
    );
    
    // State machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= FP_IDLE;
            cycle_counter <= '0;
        end else begin
            current_state <= next_state;
            if (current_state == FP_EXECUTE) begin
                cycle_counter <= cycle_counter + 1;
            end else begin
                cycle_counter <= '0;
            end
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = current_state;
        case (current_state)
            FP_IDLE: begin
                if (is_fp_instruction)
                    next_state = FP_DECODE;
            end
            FP_DECODE: begin
                next_state = FP_EXECUTE;
            end
            FP_EXECUTE: begin
                if (cycle_counter >= operation_cycles)
                    next_state = FP_COMPLETE;
            end
            FP_COMPLETE: begin
                next_state = FP_IDLE;
            end
        endcase
    end
    
    // Operation cycle determination
    always_comb begin
        operation_cycles = 5'd1; // Default single cycle
        if (opcode == FP_OP) begin
            case (funct7)
                FP_ADD, FP_SUB:     operation_cycles = 5'd3;
                FP_MUL:             operation_cycles = 5'd4;
                FP_DIV:             operation_cycles = 5'd16;
                FP_SQRT:            operation_cycles = 5'd20;
                FP_CVT_W, FP_CVT_WU,
                FP_CVT_L, FP_CVT_LU,
                FP_CVT_S, FP_CVT_D,
                FP_CVT_SD:          operation_cycles = 5'd2;
                default:            operation_cycles = 5'd1;
            endcase
        end
    end
    
    // Operand selection
    always_comb begin
        operand_a = fp_reg_rdata1;
        operand_b = fp_reg_rdata2;
        operand_c = '0; // For fused multiply-add operations
        
        // Special cases for immediate operations or CPU data
        if (opcode == FP_LOAD || (opcode == FP_OP && funct7 == FP_MV && rs2[0])) begin
            operand_a = cp_data_in;
        end
    end
    
    // Simplified FP execution (placeholder for actual FP units)
    always_comb begin
        result = '0;
        fp_flags_invalid = 1'b0;
        fp_flags_div_zero = 1'b0;
        fp_flags_overflow = 1'b0;
        fp_flags_underflow = 1'b0;
        fp_flags_inexact = 1'b0;
        
        if (current_state == FP_EXECUTE || current_state == FP_COMPLETE) begin
            case (opcode)
                FP_LOAD: begin
                    result = operand_a;
                end
                FP_STORE: begin
                    result = operand_a;
                end
                FP_OP: begin
                    case (funct7)
                        FP_ADD: begin
                            // Simplified: just pass through for now
                            result = operand_a;
                        end
                        FP_SUB: begin
                            result = operand_a;
                        end
                        FP_MUL: begin
                            result = operand_a;
                        end
                        FP_DIV: begin
                            result = operand_a;
                            // Check for divide by zero
                            if (operand_b == '0) begin
                                fp_flags_div_zero = 1'b1;
                            end
                        end
                        FP_MV: begin
                            if (rs2[0]) // FMV.W/D.X
                                result = operand_a;
                            else        // FMV.X.W/D
                                result = operand_a;
                        end
                        FP_CMP: begin
                            // Comparison result (0 or 1)
                            case (funct3)
                                3'b010: result = (operand_a == operand_b) ? 1 : 0; // FEQ
                                3'b001: result = (operand_a < operand_b) ? 1 : 0;  // FLT
                                3'b000: result = (operand_a <= operand_b) ? 1 : 0; // FLE
                                default: result = '0;
                            endcase
                        end
                        default: begin
                            result = operand_a;
                        end
                    endcase
                end
                default: begin
                    result = '0;
                end
            endcase
        end
    end
    
    // Register file control
    assign fp_reg_raddr1 = rs1;
    assign fp_reg_raddr2 = rs2;
    assign fp_reg_write = (current_state == FP_COMPLETE) && 
                         (opcode != FP_STORE) && (rd != 5'b00000);
    assign fp_reg_waddr = rd;
    assign fp_reg_wdata = result;
    
    // Output assignments
    assign cp_data_out = result;
    assign cp_ready = (current_state == FP_COMPLETE) || 
                     (current_state == FP_IDLE && !is_fp_instruction);
    assign cp_exception = fp_flags_invalid || fp_flags_div_zero;
    
    // Status flags
    assign fp_invalid = fp_flags_invalid;
    assign fp_divide_by_zero = fp_flags_div_zero;
    assign fp_overflow = fp_flags_overflow;
    assign fp_underflow = fp_flags_underflow;
    assign fp_inexact = fp_flags_inexact;

endmodule