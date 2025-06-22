module stage_id #(parameter ADDR_WIDTH = 64, INST_WIDTH = 32, REG_NUM = 32, PC_TYPE_NUM = 4) (
    input  wire                           clk,
    input  wire                           reset,
    input  wire                           interrupt,
    input  wire                           stall,
    input  wire                           ex_is_load,
    input  wire                           mm_is_load,
    input  wire                           ex_w_en,
    input  wire                           mm_w_en,
    input  wire                           wb_w_en,                            
    input  wire                           w_en_gpu,
    input  wire [ADDR_WIDTH-1:0]          pc4,
    input  wire [ADDR_WIDTH-1:0]          pc,
    input  wire [ADDR_WIDTH-1:0]          w_result,
    input  wire [ADDR_WIDTH-1:0]          w_result_gpu,
    input  wire [ADDR_WIDTH-1:0]          ex_pro,
    input  wire [ADDR_WIDTH-1:0]          mm_pro,
    input  wire [ADDR_WIDTH-1:0]          mm_mem,
    input  wire [INST_WIDTH-1:0]          inst_word,
    input  wire [$clog2(REG_NUM)-1:0]     w_rd_gpu,
    input  wire [$clog2(REG_NUM)-1:0]     rs_gpu,
    input  wire [$clog2(REG_NUM)-1:0]     ex_rd,
    input  wire [$clog2(REG_NUM)-1:0]     mm_rd,
    input  wire [$clog2(REG_NUM)-1:0]     wb_rd,
    output wire                           is_load,
    output wire                           w_en,
    output wire [ADDR_WIDTH-1:0]          read_out_gpu,
    output wire [ADDR_WIDTH-1:0]          read_out_a,
    output wire [ADDR_WIDTH-1:0]          read_out_b,
    output wire [ADDR_WIDTH-1:0]          mem_data_in,
    output wire [ADDR_WIDTH-1:0]          bra_addr,
    output wire [ADDR_WIDTH-1:0]          jal_addr,
    output wire [ADDR_WIDTH-1:0]          jar_addr,
    output wire [$clog2(PC_TYPE_NUM-1):0] pc_sel
);

    wire                  inst_buffer_empty;
    wire                  inst_buffer_full;
    wire                  load_stall;
    wire                  is_equal;
    wire                  is_i_type;
    wire                  is_j_type;
    wire                  is_u_type;
    wire [ADDR_WIDTH-1:0] d_pc;
    wire [ADDR_WIDTH-1:0] d_pc4;
    wire [ADDR_WIDTH-1:0] a_out;
    wire [ADDR_WIDTH-1:0] b_out_options [0:1];
    wire [ADDR_WIDTH-1:0] a_file_out;
    wire [ADDR_WIDTH-1:0] b_file_out;
    wire [INST_WIDTH-1:0] d_inst;
    wire [INST_WIDTH-1:0] d_inst_next;

    control_unit cu (.is_equal(is_equal),
                          .inst(d_inst),
                          .has_imm(has_imm),
                          .is_j_type(is_j_type),
                          .is_u_type(is_u_type),
                          .is_i_type(is_i_type),
                          .w_en(w_en),
                          .is_load(is_load),
                          .pc_sel(pc_sel),
                          .imm_sel(imm_sel)
                         );
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
                              .jar_addr(jar_addr)
                             );

    // M2: Have register IF to ID for pipeline stage
    // Stall if load-stall register from execute has register being read

    // NOTE: If d_inst is reset value ('0), loading to register 0 (which shouldn't happen anyway)
    // will send stall for one cycle
    stage_id_stall load_stall_check (.ex_rd(ex_rd),
                                     .ex_is_load(ex_is_load),
                                     .is_j_type(is_j_type),
                                     .is_u_type(is_u_type),
                                     .is_i_type(is_i_type),
                                     .read_addr_a(d_inst[19:15]),
                                     .read_addr_b(d_inst[24:20]), 
                                     .opcode(d_inst[6:0])
                                     .stall(load_stall)
                                    );

    assign reg_stall = stall | load_stall;
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
                     //.d_inst_next(d_inst_next);
                    );


    // M3: Decode instruction, including operand forwarding

    register_bank_list register_file (.clk(clk),
                                      .reset(reset),
                                      .interrupt(interrupt)
                                      .write_addr_cpu(wb_rd),
                                      .write_addr_gpu(w_rd_gpu),
                                      .data_in_cpu(w_result),
                                      .data_in_gpu(w_result_gpu),
                                      .write_en_cpu(wb_w_en),
                                      .write_en_gpu(w_en_gpu),
                                      .read_addr_a(d_inst[19:15]),
                                      .read_addr_b(d_inst[24:20]),
                                      .read_addr_gpu(rs_gpu),
                                      .data_out_a(a_file_out),
                                      .data_out_b(b_file_out),
                                      .data_out_gpu(read_out_gpu)
                                     );
    
    // Outputs correct data for registers A and B each
    bypass_mux a_bypass (.file_out(a_file_out),
                         .ex_pro(ex_pro),
                         .mm_pro(mm_pro),
                         .mm_mem(mm_mem),
                         .file_out_rs(d_inst[19:15]),
                         .ex_rd(ex_rd),
                         .mm_rd(mm_rd),
                         .ex_w_en(ex_w_en),
                         .mm_w_en(mm_w_en),
                         .mm_is_load(mm_is_load),
                         .bypass_out(a_out)
                        );
    
    bypass_mux b_bypass (.file_out(b_file_out),
                         .ex_pro(ex_pro),
                         .mm_pro(mm_pro),
                         .mm_mem(mm_mem),
                         .file_out_rs(d_inst[24:20]),
                         .ex_rd(ex_rd),
                         .mm_rd(mm_rd),
                         .ex_w_en(ex_w_en),
                         .mm_w_en(mm_w_en),
                         .mm_is_load(mm_is_load),
                         .bypass_out(b_out_options[0])
                        );

    assign mem_data_in = b_out_options[0];

    imme gen_imme (.inst(d_inst),
                   .imm_type(imm_type),
                   .imm(b_out_options[1])
                  );
    
    mux_n b_mux (.data_in(b_out_options),
                 .sel(has_imm),
                 .data_out(read_out_b)
                );

    assign read_out_a = a_out;
    
endmodule