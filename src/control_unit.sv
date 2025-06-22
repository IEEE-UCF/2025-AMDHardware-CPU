module control_unit #(parameter INST_WIDTH = 32, ADDR_WIDTH = 64, PC_TYPE_NUM = 4, IMM_TYPE_NUM = 4) (
    input  wire                            is_equal,
    input  wire [INST_WIDTH-1:0]           inst,
    output wire                            has_imm,
    output wire                            is_j_type,
    output wire                            is_u_type,
    output wire                            is_i_type,
    output wire                            w_en,
    output wire                            is_load,
    output wire [$clog2(PC_TYPE_NUM)-1:0]  pc_sel,
    output wire [$clog2(IMM_TYPE_NUM)-1:0] imm_sel
);  
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];

    wire b_type = (opcode == 7'b1100011);
    wire is_beq = b_type & (funct3 == 3'b000);
    wire is_bne = b_type & (funct3 == 3'b001);
    wire is_jar = (opcode == 7'b1100111);
    wire is_jal = (opcode == 7'b1101111);

    // Check if op is R-Type utilizing shamt (shift amount)
    wire shift_type = ((opcode == 7'b0010011) & ((funct3 == 3'b001) | (funct3 == 3'b101)));

    // Check if op indicates S-Type
    wire s_type = (opcode == 7'b0100011) | (opcode == 7'b0100111);

    // Check if op is LUI or AUIPC
    wire u_type = (opcode == 7'b0110111) | (opcode == 7'b0010111);

    wire load_type = (opcode == 7'b0000011) | (opcode == 7'b0000111);

    // Determine immediate type by instruction type
    assign imm_sel[0] = u_type | shift_type;
    assign imm_sel[1] = u_type | s_type;

    // is_type outputs used for stage_id_stall load-stall check
    assign is_j_type = is_jal;
    assign is_u_type = u_type;
    // Check if op is JALR, load instructions, arithmetic immediates, arithmetic immediate words, FLW, or FCVT
    assign is_i_type = (opcode == 7'b1100111) | load_type | (opcode == 7'b0010011) | (opcode == 7'b0011011) | (opcode == 7'b1010011);

    // If op does not have immediate (basically R-Type), negate to indicate when there is immediate
    assign has_imm = ~((opcode == 7'b0110011) | (opcode == 7'b0111011) | (opcode[6:5] == 2'b10))

    assign pc_sel[0] = is_jal | (is_beq & is_equal) | (is_bne & ~is_equal);
    assign pc_sel[1] = is_jal | is_jar;

    assign w_en = ~(s_type | b_type);

    // Checks if instruction will load, pushed to execute for load-stall and memory for operand forwarding
    assign is_load = load_type;

endmodule