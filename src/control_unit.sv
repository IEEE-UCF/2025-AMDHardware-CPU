module control_unit #(
    parameter INST_WIDTH = 32,
    parameter ADDR_WIDTH = 64,
    parameter PC_TYPE_NUM = 4,
    parameter IMM_TYPE_NUM = 4,
    parameter REG_NUM = 32
)(
    input  wire [INST_WIDTH-1:0]          instruction,
    input  wire                           pre_instruction, // IF to ID
    input  wire                           inst_valid,
    input  wire                           pre_inst_valid, // IF to ID
    input  wire [ADDR_WIDTH-1:0]          pc_next,
    input  wire [ADDR_WIDTH-1:0]          pc_next_correct,
    input  wire                           stall,
    input  wire                           is_equal,      // From branch comparison
    input  wire                           buffer_active,
    input  wire                           branch_predict,
    input  wire                           branch_prediction,
    
    // Control outputs
    output reg                            reg_write,
    output reg                            mem_read,
    output reg                            mem_write,
    output reg [4:0]                      alu_op,
    output reg                            has_imm,
    output reg [1:0]                      imm_type,
    output reg [$clog2(PC_TYPE_NUM)-1:0]  pc_sel,
    output reg                            pc_unstable_type,
    output reg                            is_load,
    output reg                            is_store,
    output reg                            pre_is_branch,
    output reg                            is_branch,
    output reg                            is_jump,
    output reg                            is_system,             
    
    // Register addresses
    output wire [4:0]                     rd,
    output wire [4:0]                     rs1,
    output wire [4:0]                     rs2,
    
    // Function codes for further decoding
    output wire [2:0]                     funct3,
    output wire [6:0]                     funct7,
    output wire [6:0]                     opcode,

    // Flags for detecting rs1, rs2, and rs3 in stage_id_stall's load-stall check
    output wire                           has_rs1_out,
    output wire                           has_rs2_out,
    output wire                           has_rs3_out,

    output wire                           pc_match,
    output wire                           pc_override
);
    reg  is_mscmem;
    reg  pc_unstable;

    assign pc_match = (pc_next == pc_next_correct);

    wire [6:0] pre_opcode;
    assign pre_opcode = pre_instruction[6:0];

    // Extract instruction fields
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    // RISC-V Opcodes
    localparam OP_LUI     = 7'b0110111;  // Load Upper Immediate
    localparam OP_AUIPC   = 7'b0010111;  // Add Upper Immediate to PC
    localparam OP_JAL     = 7'b1101111;  // Jump and Link
    localparam OP_JALR    = 7'b1100111;  // Jump and Link Register
    localparam OP_BRANCH  = 7'b1100011;  // Branch instructions
    localparam OP_LOAD    = 7'b0000011;  // Load instructions
    localparam OP_STORE   = 7'b0100011;  // Store instructions
    localparam OP_OP_IMM  = 7'b0010011;  // Immediate ALU operations
    localparam OP_OP      = 7'b0110011;  // Register ALU operations
    localparam OP_MISCMEM = 7'b0001111;  // FENCE instructions
    localparam OP_SYSTEM  = 7'b1110011;  // System instructions (ECALL, EBREAK, CSR)
    localparam OP_FL      = 7'b0000111;  // Floating-Point Load
    localparam OP_FOTHER  = 7'b1010011;

    // ALU Operations (matching your stage_ex.sv)
    localparam ALU_ADD    = 5'b00000;
    localparam ALU_SUB    = 5'b00001;
    localparam ALU_AND    = 5'b00010;
    localparam ALU_OR     = 5'b00011;
    localparam ALU_XOR    = 5'b00100;
    localparam ALU_NOR    = 5'b00101;
    localparam ALU_NAND   = 5'b00110;
    localparam ALU_SLL    = 5'b00111;  // Shift Left Logical
    localparam ALU_SRL    = 5'b01000;  // Shift Right Logical
    localparam ALU_SRA    = 5'b01001;  // Shift Right Arithmetic
    localparam ALU_SLT    = 5'b01010;  // Set Less Than (signed)
    localparam ALU_SLTU   = 5'b01011;  // Set Less Than (unsigned)
    localparam ALU_PASS_A = 5'b01100;  // Pass A
    localparam ALU_PASS_B = 5'b01101;  // Pass B
    localparam ALU_NOT_A  = 5'b01110;  // Bitwise NOT A
    localparam ALU_EQ     = 5'b01111;  // Equality test
    localparam ALU_NE     = 5'b10000;  // Inequality test

    // PC Selection
    localparam PC_PLUS4   = 2'b00;
    localparam PC_JAL     = 2'b01;
    localparam PC_BRANCH  = 2'b10;
    localparam PC_JALR    = 2'b11;

    // Immediate Types (matching imme.sv)
    localparam IMM_I_TYPE      = 2'b00;  // I-type immediate
    localparam IMM_SHIFT       = 2'b01;  // Shift immediate
    localparam IMM_S_TYPE      = 2'b10;  // S-type immediate
    localparam IMM_U_OR_J_TYPE = 2'b11;  // U-type immediate

    // pc_sel (pre_stage_id) logic
    always_comb begin
        pc_sel = PC_PLUS4;
        pre_is_branch = 1'b0;
        if (pre_inst_valid && !stall) begin
            case (pre_opcode)
                OP_JAL: begin
                    pc_sel = PC_JAL;
                end
                OP_JALR: begin
                    pc_sel = PC_JALR;
                end
                OP_BRANCH: begin
                    pre_is_branch = 1'b1;
                    if (buffer_active) begin
                        pc_sel = branch_prediction ? PC_BRANCH : PC_PLUS4
                    end else begin
                        case (funct3)
                            3'b000:  pc_sel = is_equal  ? PC_BRANCH : PC_PLUS4; // BEQ
                            3'b001:  pc_sel = !is_equal ? PC_BRANCH : PC_PLUS4; // BNE
                            3'b100:  pc_sel = is_equal  ? PC_BRANCH : PC_PLUS4; // BLT (simplified)
                            3'b101:  pc_sel = !is_equal ? PC_BRANCH : PC_PLUS4; // BGE (simplified)
                            3'b110:  pc_sel = is_equal  ? PC_BRANCH : PC_PLUS4;  // BLTU (simplified)
                            3'b111:  pc_sel = !is_equal ? PC_BRANCH : PC_PLUS4; // BGEU (simplified)
                            default: pc_sel = PC_PLUS4;
                        endcase
                    end
                end 
            endcase
        end
    end

    // Main control logic
    always_comb begin
        // Default values
        reg_write = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        alu_op    = ALU_ADD;
        has_imm   = 1'b0;
        imm_type  = IMM_I_TYPE;
        pc_unstable      = 1'b0;
        pc_unstable_type = 1'b0;
        is_load   = 1'b0;
        is_store  = 1'b0;
        is_branch = 1'b0;
        is_jump   = 1'b0;
        is_system = 1'b0;
        is_mscmem = 1'b0;

        // Only decode if instruction is valid and not stalled
        if (inst_valid && !stall) begin
            case (opcode)
                OP_LUI: begin
                    reg_write = 1'b1;
                    has_imm   = 1'b1;
                    imm_type  = IMM_U_OR_J_TYPE;
                    alu_op    = ALU_PASS_B;  // Pass immediate to output
                end

                OP_AUIPC: begin
                    reg_write = 1'b1;
                    has_imm   = 1'b1;
                    imm_type  = IMM_U_OR_J_TYPE;
                    alu_op    = ALU_ADD;     // PC + immediate
                end

                OP_JAL: begin
                    reg_write = 1'b1;
                    is_jump   = 1'b1;
                    imm_type  = IMM_U_OR_J_TYPE; // Determines when instruction has rs1 in stage_id_stall
                    alu_op    = ALU_PASS_A;  // Pass PC+4 for return address
                end

                OP_JALR: begin
                    reg_write = 1'b1;
                    has_imm   = 1'b1;
                    imm_type  = IMM_I_TYPE;
                    is_jump   = 1'b1;
                    pc_unstable = 1'b1;
                    pc_unstable_type = 1'b1;
                    alu_op    = ALU_PASS_A;  // Pass PC+4 for return address
                end

                OP_BRANCH: begin
                    is_branch        = 1'b1;
                    pc_unstable      = 1'b1;
                    pc_unstable_type = 1'b0;
                    // Branch taken based on condition and is_equal signal
                    alu_op = ALU_EQ;  // Use ALU for comparison
                end

                OP_LOAD: begin
                    reg_write = 1'b1;
                    mem_read  = 1'b1;
                    has_imm   = 1'b1;
                    imm_type  = IMM_I_TYPE;
                    is_load   = 1'b1;
                    alu_op    = ALU_ADD;  // Base + offset address calculation
                end

                OP_STORE: begin
                    mem_write = 1'b1;
                    has_imm   = 1'b1;
                    imm_type  = IMM_S_TYPE;
                    is_store  = 1'b1;
                    alu_op    = ALU_ADD;  // Base + offset address calculation
                end

                OP_OP_IMM: begin
                    reg_write = 1'b1;
                    has_imm   = 1'b1;
                    case (funct3)
                        3'b000: begin  // ADDI
                            imm_type = IMM_I_TYPE;
                            alu_op   = ALU_ADD;
                        end
                        3'b010: begin  // SLTI
                            imm_type = IMM_I_TYPE;
                            alu_op   = ALU_SLT;
                        end
                        3'b011: begin  // SLTIU
                            imm_type = IMM_I_TYPE;
                            alu_op   = ALU_SLTU;
                        end
                        3'b100: begin  // XORI
                            imm_type = IMM_I_TYPE;
                            alu_op   = ALU_XOR;
                        end
                        3'b110: begin  // ORI
                            imm_type = IMM_I_TYPE;
                            alu_op   = ALU_OR;
                        end
                        3'b111: begin  // ANDI
                            imm_type = IMM_I_TYPE;
                            alu_op   = ALU_AND;
                        end
                        3'b001: begin  // SLLI
                            imm_type = IMM_SHIFT;
                            alu_op   = ALU_SLL;
                        end
                        3'b101: begin  // SRLI/SRAI
                            imm_type = IMM_SHIFT;
                            alu_op   = funct7[5] ? ALU_SRA : ALU_SRL;
                        end
                        default: begin
                            imm_type = IMM_I_TYPE;
                            alu_op   = ALU_ADD;
                        end
                    endcase
                end

                OP_OP: begin
                    reg_write = 1'b1;
                    case (funct3)
                        3'b000: alu_op = (funct7[5]) ? ALU_SUB : ALU_ADD;  // ADD/SUB
                        3'b001: alu_op = ALU_SLL;   // SLL
                        3'b010: alu_op = ALU_SLT;   // SLT
                        3'b011: alu_op = ALU_SLTU;  // SLTU
                        3'b100: alu_op = ALU_XOR;   // XOR
                        3'b101: alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL;  // SRL/SRA
                        3'b110: alu_op = ALU_OR;    // OR
                        3'b111: alu_op = ALU_AND;   // AND
                        default: alu_op = ALU_ADD;
                    endcase
                end

                OP_MISCMEM: begin
                    is_mscmem = 1'b1;
                    // FENCE instructions - treat as NOP for now
                    // Could add memory ordering logic here
                end

                OP_SYSTEM: begin
                    is_system = 1'b1;
                    case (funct3)
                        3'b000: begin
                            // ECALL/EBREAK
                            if (instruction[20])
                                ; // EBREAK - could trigger debug trap
                            else
                                ; // ECALL - could trigger system call
                        end
                        default: begin
                            // CSR instructions
                            reg_write = 1'b1;
                            has_imm   = (funct3[2]) ? 1'b1 : 1'b0;  // CSRR*I vs CSRR*
                            imm_type  = IMM_I_TYPE;
                            alu_op    = ALU_PASS_B;  // Pass CSR value or immediate
                        end
                    endcase
                end

                default: begin
                    // Invalid/unsupported instruction - treat as NOP
                    // Could add exception handling here
                end
            endcase
        end
    end

    assign pc_override = pc_unstable && !pc_match && branch_predict;

    // Load-stall RS flags
    // TODO: Find an easier way to calculate has_rs1 and has_rs2
    wire is_mscmem_or_system_imm = is_mscmem || (is_system && (has_imm || funct3 == 3'b000));
    // If instruction isn't U-Type, J-Type, MSCMEM, or SYSTEM with IMM, there has to be an RS1
    wire has_rs1 = (imm_type != IMM_U_OR_J_TYPE) || !is_mscmem_or_system_imm;
    // If imm_type is S, either we have S-Type instruction or other RV32/64I instruction that always has RS2
    // When opcode is FOTHER, inst[30] always shows when RS2 isn't used
    wire has_rs2 = (imm_type == IMM_S_TYPE) || !is_mscmem_or_system_imm || (opcode != OP_FL) || !(opcode == OP_FOTHER && inst[30]); 
    // All instructions with RS3 have the last three bits of the opcode set to 100
    wire has_rs3 = (opcode[6:4] == 3'b100);

    assign has_rs1_out = has_rs1;
    assign has_rs2_out = has_rs2;
    assign has_rs3_out = has_rs3;
endmodule
