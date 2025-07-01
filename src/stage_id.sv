module stage_id #(parameter ADDR_WIDTH = 64, INST_WIDTH = 32, REG_NUM = 32) (
    input  wire                           clk,
    input  wire                           reset,
    input  wire                           interrupt,
    input  wire                           stall,
    input  wire                           w_en,
    input  wire                           w_en_gpu,
    input  wire                           has_imm,
    input  wire                           has_rs1,
    input  wire                           has_rs2,
    input  wire                           has_rs3,
    input  wire [1:0]                     imm_type,
    input  wire [ADDR_WIDTH-1:0]          pc4,
    input  wire [ADDR_WIDTH-1:0]          pc,
    input  wire [ADDR_WIDTH-1:0]          w_result,
    input  wire [ADDR_WIDTH-1:0]          w_result_gpu,
    input  wire [ADDR_WIDTH-1:0]          ex_pro,
    input  wire [ADDR_WIDTH-1:0]          mm_pro,
    input  wire [ADDR_WIDTH-1:0]          mm_mem,
    input  wire [INST_WIDTH-1:0]          inst_word,
    input  wire [$clog2(REG_NUM)-1:0]     load_rd,
    input  wire                           is_load,
    input  wire [$clog2(REG_NUM)-1:0]     w_rd,
    input  wire [$clog2(REG_NUM)-1:0]     w_rd_gpu,
    input  wire [$clog2(REG_NUM)-1:0]     rs_gpu,
    input  wire [$clog2(REG_NUM)-1:0]     ex_pro_rs,
    input  wire [$clog2(REG_NUM)-1:0]     mm_pro_rs,
    input  wire [$clog2(REG_NUM)-1:0]     mm_mem_rs,
    output wire                           is_equal,
    output wire [ADDR_WIDTH-1:0]          read_out_gpu,
    output wire [ADDR_WIDTH-1:0]          read_out_a,
    output wire [ADDR_WIDTH-1:0]          read_out_b,
    output wire [ADDR_WIDTH-1:0]          bra_addr,
    output wire [ADDR_WIDTH-1:0]          jal_addr,
    output wire [ADDR_WIDTH-1:0]          jar_addr
);

    wire                  inst_buffer_empty;
    wire                  inst_buffer_full;
    wire                  load_stall;
    wire                  reg_stall;
    wire [ADDR_WIDTH-1:0] d_pc;
    wire [ADDR_WIDTH-1:0] d_pc4;
    wire [ADDR_WIDTH-1:0] a_out;
    wire [ADDR_WIDTH-1:0] b_out_options [0:1];
    wire [ADDR_WIDTH-1:0] a_file_out;
    wire [ADDR_WIDTH-1:0] b_file_out;
    wire [INST_WIDTH-1:0] d_inst;
    // wire [INST_WIDTH-1:0] d_inst_next;

    // M1: Push PC selector back to stage_if

    equ rs_equality (.data_a(a_out),
                     .data_b(b_out_options[0]),
                     .is_equal(is_equal)
                    );
    
    branch_calc branch_addrs (.pc(pc),
                              .inst(d_inst),
                              .data_a(a_out),
                              .bra_addr(bra_addr),
                              .jal_addr(jal_addr),
                              .jalr_addr(jar_addr)
                             );

    // M2: Have register IF to ID for pipeline stage
    // Stall if load-stall register from execute has register being read

    // TODO: Maybe update stage_id_stall to check opcode if it's reading registers
    // Change rs1 and rs2 to read_addr_a and read_addr_b for consistency with register banks
    // NOTE: If d_inst_next is reset value ('0), loading to register 0 (which shouldn't happen anyway)
    // will send stall for one cycle
    stage_id_stall load_stall_check (.load_rd(load_rd),
                                     .is_load(is_load),
                                     .rs1_addr(d_inst[19:15]),
                                     .rs2_addr(d_inst[24:20]),
                                     .rs3_addr(d_inst[31:27]),
                                     .has_rs1(has_rs1),
                                     .has_rs2(has_rs2),
                                     .has_rs3(has_rs3),
                                     .stall(load_stall)
                                    );

    assign reg_stall = stall | load_stall;

    // TODO: Convert into FIFO module to use same structure across buffers
    reg_if_to_id stage2 (.clk(clk),
                     .reset(reset),
                     .stall(reg_stall),
                     .pc4(pc4),
                     .pc(pc),
                     .inst(inst_word),
                     .inst_buffer_empty(inst_buffer_empty),
                     .inst_buffer_full(inst_buffer_full),
                     .d_pc(d_pc),
                     .d_pc4(d_pc4),
                     .d_inst(d_inst)
                     // .d_inst_next(d_inst_next)
                    );


    // M3: Decode instruction, including operand forwarding

    register_bank_list register_file (.clk(clk),
                                      .reset(reset),
                                      .interrupt(interrupt),
                                      .write_addr_cpu(w_rd),
                                      .write_addr_gpu(w_rd_gpu),
                                      .data_in_cpu(w_result),
                                      .data_in_gpu(w_result_gpu),
                                      .write_en_cpu(w_en),
                                      .write_en_gpu(w_en_gpu),
                                      .read_addr_a(d_inst[19:15]),
                                      .read_addr_b(d_inst[24:20]),
                                      .read_addr_gpu(rs_gpu),
                                      .data_out_a(a_file_out),
                                      .data_out_b(b_file_out),
                                      .data_out_gpu(read_out_gpu)
                                     );
    
    bypass_mux a_bypass (.file_out(a_file_out),
                             .ex_pro(ex_pro),
                             .mm_pro(mm_pro),
                             .mm_mem(mm_mem),
                             .file_out_rs(d_inst[19:15]),
                             .ex_pro_rs(ex_pro_rs),
                             .mm_pro_rs(mm_pro_rs),
                             .mm_mem_rs(mm_mem_rs),
                             .bypass_out(a_out)
                             );
    
    bypass_mux b_bypass (.file_out(b_file_out),
                             .ex_pro(ex_pro),
                             .mm_pro(mm_pro),
                             .mm_mem(mm_mem),
                             .file_out_rs(d_inst[24:20]),
                             .ex_pro_rs(ex_pro_rs),
                             .mm_pro_rs(mm_pro_rs),
                             .mm_mem_rs(mm_mem_rs),
                             .bypass_out(b_out_options[0])
                             );

    imme gen_imme (.inst(d_inst),
                   .imm_type(imm_type),
                   .imm(b_out_options[1])
                  );
    
    mux_n #(.INPUT_NUM(2)) b_mux (.data_in(b_out_options),
                                  .sel(has_imm),
                                  .data_out(read_out_b)
                                 );

    assign read_out_a = a_out;
endmodule
