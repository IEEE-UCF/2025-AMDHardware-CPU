module stage_id_top #(parameter ADDR_WIDTH = 64, INST_WIDTH = 32, REG_NUM = 32, PC_TYPE_NUM = 4) (
    input  wire                       clk,
    input  wire                       reset,
    input  wire                       interrupt,
    input  wire                       stall,
    input  wire                       w_en,
    input  wire                       w_en_gpu,
    input  wire                       ex_w_en,
    input  wire                       mm_w_en,
    input  wire                       mm_is_load,
    input  wire                       inst_valid,
    input  wire [INST_WIDTH-1:0]      inst,
    input  wire [ADDR_WIDTH-1:0]      pc,
    input  wire [ADDR_WIDTH-1:0]      w_in,
    input  wire [ADDR_WIDTH-1:0]      ex_pro,
    input  wire [ADDR_WIDTH-1:0]      mm_pro,
    input  wire [ADDR_WIDTH-1:0]      mm_mem,
    input  wire [$clog2(REG_NUM)-1:0] w_rd,
    input  wire [$clog2(REG_NUM)-1:0] w_rd_gpu,
    input  wire [$clog2(REG_NUM)-1:0] rs_gpu,
    input  wire [$clog2(REG_NUM)-1:0] ex_rd,
    input  wire [$clog2(REG_NUM)-1:0] mm_rd,
    output wire                       reg_write,
    output wire                       mem_read,
    output wire                       mem_write,
    output wire                       is_load_out,
    output wire                       is_store,
    output wire                       is_branch,
    output wire                       is_jump,
    output wire                       is_system,
    output wire                       buffer_stall_out,
    output wire                       load_stall_out,
    output wire                       pc_override,
    output wire                       d_inst_valid_out,
    output wire [4:0]                 alu_op,
    output wire [4:0]                 rd,
    output wire [4:0]                 rs1,
    output wire [4:0]                 rs2,
    output wire [2:0]                 funct3,
    output wire [6:0]                 funct7,
    output wire [6:0]                 opcode,
    output wire [INST_WIDTH-1:0]      d_inst_out,
    output wire [ADDR_WIDTH-1:0]      d_pc_out,
    output wire [ADDR_WIDTH-1:0]      d_pc4_out,
    output wire [ADDR_WIDTH-1:0]      read_out_a,
    output wire [ADDR_WIDTH-1:0]      read_out_b,
    output wire [ADDR_WIDTH-1:0]      bra_addr,
    output wire [ADDR_WIDTH-1:0]      jal_addr,
    output wire [ADDR_WIDTH-1:0]      jar_addr
);
    // Immediate control
    wire                  has_imm;
    wire [1:0]            imm_type;
    
    // Branch control (including branch prediction)
    wire                           is_equal;
    wire                           pre_is_branch;
    wire                           branch_predict;
    wire                           branch_prediction;
    wire                           pc_match;
    wire                           pc_unstable_type;
    wire [ADDR_WIDTH-1:0]          pc_next_correct;
    wire [ADDR_WIDTH-1:0]          pc_next;
    wire [$clog2(PC_TYPE_NUM)-1:0] pc_sel;

    // Load stall logic
    wire load_stall;
    wire is_load;
    wire has_rs1;
    wire has_rs2;
    wire has_rs3;

    // Buffer control
    wire buffer_stall;
    wire buffer_active;
    
    // Reg to main stage signals 
    wire                  d_inst_valid;
    wire [INST_WIDTH-1:0] d_inst;
    wire [ADDR_WIDTH-1:0] d_pc;

    assign is_load_out = is_load;
    assign load_stall_out = load_stall;
    assign buffer_stall_out = buffer_stall;

    reg_if_to_id regs(.clk(clk),
                      .reset(reset),
                      .stall(stall),
                      .inst_valid(inst_valid),
                      .pc(pc),
                      .inst(inst),
                      .if_buffer_stall_out(buffer_stall),
                      .buffer_active_out(buffer_active), // Control_unit
                      .branch_predict(branch_predict), // Branch_prediction and control_unit
                      .d_inst_valid(d_inst_valid), // Stage_id
                      .d_pc(d_pc),
                      .d_inst(d_inst),
                      .pc_next(pc_next),
                      .bra_addr(bra_addr),
                      .jal_addr(jal_addr),
                      .jar_addr(jar_addr)             
                     );

    stage_id main_stage_id (.clk(clk),
                            .reset(reset),
                            .interrupt(interrupt),
                            .stall(interrupt),
                            .w_en(w_en),
                            .w_en_gpu(w_en_gpu),
                            .has_imm(has_imm), // Control Unit
                            .ex_w_en(ex_w_en),
                            .mm_w_en(mm_w_en),
                            .mm_is_load(mm_is_load),
                            .d_inst_valid(d_inst_valid), // Reg_if_to_id
                            .pc_unstable_type(pc_unstable_type), // Control Unit
                            .imm_type(imm_type), // Control Unit
                            .d_inst(d_inst), // Reg_if_to_id
                            .d_pc(d_pc), // Reg_if_to_id
                            .w_in(w_in),
                            .w_in_gpu(w_in_gpu),
                            .ex_pro(ex_pro),
                            .mm_pro(mm_pro),
                            .mm_mem(mm_mem),
                            .w_rd(w_rd),
                            .w_rd_gpu(w_rd_gpu),
                            .rs_gpu(rs_gpu),
                            .ex_rd(ex_rd),
                            .mm_rd(mm_rd),
                            .is_equal(is_equal), // Control Unit
                            .load_stall(load_stall), // Reg_if_to_id & beyond
                            .d_inst_valid_out(d_inst_valid_out),
                            .d_inst_out(d_inst_out),
                            .d_pc_out(d_pc_out),
                            .d_pc4_out(d_pc4_out),
                            .read_out_gpu(read_out_gpu),
                            .read_out_a(read_out_a),
                            .read_out_b(read_out_b),
                            .pc_next_correct(pc_next_correct) // Control Unit
                           );
    
    control_unit cu (.instruction(d_inst), // Reg_if_to_id
                     .pre_instruction(inst), 
                     .inst_valid(d_inst_valid), // Reg_if_to_id
                     .pre_inst_valid(inst_valid),
                     .pc_next(pc_next), // Reg_if_to_id
                     .pc_next_correct(pc_next_correct), // Stage_id
                     .stall(stall),
                     .is_equal(is_equal), // Stage_id
                     .branch_predict(branch_predict), // Stage_id
                     .buffer_active(buffer_active), // Stage_id
                     .branch_prediction(branch_prediction), // Branch_prediction
                     .reg_write(reg_write),
                     .mem_read(mem_read),
                     .mem_write(mem_write),
                     .alu_op(alu_op),
                     .has_imm(has_imm), // Stage_id
                     .imm_type(imm_type), // Stage_id
                     .pc_sel(pc_sel), // Branch_prediction
                     .pc_unstable_type(pc_unstable_type), // Stage_id
                     .is_load(is_load), // Load stall check
                     .is_store(is_store),
                     .pre_is_branch(pre_is_branch),
                     .is_branch(is_branch),
                     .is_jump(is_jump),
                     .is_system(is_system),          
                     .rd(rd),
                     .rs1(rs1),
                     .rs2(rs2),
                     .funct3(funct3),
                     .funct7(funct7),
                     .opcode(opcode),
                     .has_rs1_out(has_rs1),
                     .has_rs2_out(has_rs2),
                     .has_rs3_out(has_rs3),
                     .pc_match(pc_match), // Branch_prediction
                     .pc_override(pc_override) // Reg_if_to_id & beyond
                    );
    
    branch_prediction bra_pred (.clk(clk),
                                .reset(reset),
                                .stall(stall),
                                .is_branch(is_branch), // Control unit
                                .pre_is_branch(pre_is_branch)
                                .buffer_active(buffer_active), // Reg_if_to_id
                                .pc_match(pc_match), // Control unit
                                .pc_sel(pc_sel), // Control unit
                                .branch_prediction(branch_prediction) // Control unit
                               );
    
    stage_id_stall load_stall (.is_load(is_load), // Control unit
                               .has_rs1(has_rs1), // Control unit
                               .has_rs2(has_rs2), // Control unit
                               .has_rs3(has_rs3), // Control unit 
                               .rs1_addr(d_inst[19:15]),
                               .rs2_addr(d_inst[24:20]),
                               .rs3_addr(d_inst[31:27]),
                               .load_rd(ex_rd), 
                               .load_stall(load_stall) // Reg_if_to_id and beyond
                              );
    
endmodule
