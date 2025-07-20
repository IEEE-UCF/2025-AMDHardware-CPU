module stage_id #(parameter ADDR_WIDTH = 64, INST_WIDTH = 32, REG_NUM = 32) (
    input  wire                           clk,
    input  wire                           reset,
    input  wire                           interrupt,
    input  wire                           stall,
    input  wire                           w_en,
    input  wire                           w_en_gpu,
    input  wire                           has_imm,
    input  wire                           ex_w_en,
    input  wire                           mm_w_en,
    input  wire                           mm_is_load,
    input  wire                           d_inst_valid,
    input  wire                           pc_unstable_type,
    input  wire [1:0]                     imm_type,
    input  wire [INST_WIDTH-1:0]          d_inst,
    input  wire [ADDR_WIDTH-1:0]          d_pc,
    input  wire [ADDR_WIDTH-1:0]          w_in,
    input  wire [ADDR_WIDTH-1:0]          w_in_gpu,
    input  wire [ADDR_WIDTH-1:0]          ex_pro,
    input  wire [ADDR_WIDTH-1:0]          mm_pro,
    input  wire [ADDR_WIDTH-1:0]          mm_mem,
    input  wire [$clog2(REG_NUM)-1:0]     w_rd,
    input  wire [$clog2(REG_NUM)-1:0]     w_rd_gpu,
    input  wire [$clog2(REG_NUM)-1:0]     rs_gpu,
    input  wire [$clog2(REG_NUM)-1:0]     ex_rd,
    input  wire [$clog2(REG_NUM)-1:0]     mm_rd,
    output wire                           is_equal,
    output wire                           d_inst_valid_out,
    output wire [INST_WIDTH-1:0]          d_inst_out,
    output wire [ADDR_WIDTH-1:0]          d_pc_out,
    output wire [ADDR_WIDTH-1:0]          d_pc4_out,
    output wire [ADDR_WIDTH-1:0]          read_out_gpu,
    output wire [ADDR_WIDTH-1:0]          read_out_a,
    output wire [ADDR_WIDTH-1:0]          read_out_b,
    output wire [ADDR_WIDTH-1:0]          pc_next_correct
);

    wire [ADDR_WIDTH-1:0] a_out;
    wire [ADDR_WIDTH-1:0] b_out_options [0:1];
    wire [ADDR_WIDTH-1:0] a_file_out;
    wire [ADDR_WIDTH-1:0] b_file_out;
    
    wire [ADDR_WIDTH-1:0] pc_next_correct_options [0:1];

    // Push PC selector back to stage_if

    stage_id_addr_calc stage_id_addrs (.pc(d_pc),
                                       .inst(d_inst),
                                       .data_a(a_out),
                                       .pc4_addr(d_pc4_out),
                                       .bra_addr(pc_next_correct_options[0]),
                                       .jalr_addr(pc_next_correct_options[1])
                                      );

    mux_n #(.INPUT_NUM(2)) pc_next_correct_mux (.data_in(pc_next_correct_options),
                                                .sel(pc_unstable_type),
                                                .data_out(pc_next_correct)
                                               );
    
    equ rs_equality (.data_a(a_out),
                     .data_b(b_out_options[0]),
                     .is_equal(is_equal)
                    );
    
    /*
    branch_calc branch_addrs (.pc(d_pc),
                              .inst(d_inst),
                              .data_a(a_out),
                              .bra_addr(bra_addr),
                              .jal_addr(jal_addr),
                              .jalr_addr(jar_addr)
                             );
    */

    // Decode instruction, including operand forwarding

    register_bank_list register_files (.clk(clk),
                                       .reset(reset),
                                       .interrupt(interrupt),
                                       .write_addr_cpu(w_rd),
                                       .write_addr_gpu(w_rd_gpu),
                                       .data_in_cpu(w_in),
                                       .data_in_gpu(w_in_gpu),
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
                         .ex_rd(ex_rd),
                         .mm_rd(mm_rd),
                         .ex_w_en(ex_w_en),
                         .mm_w_en(mm_w_en),
                         .mm_is_load(mm_is_load),
                         .bypass_out(a_out)
                        );
    
    bypass_mux b_bypass (.file_out(a_file_out),
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

    imme gen_imme (.inst(d_inst),
                   .imm_type(imm_type),
                   .imm(b_out_options[1])
                  );
     
    mux_n #(.INPUT_NUM(2)) b_mux (.data_in(b_out_options),
                                  .sel(has_imm),
                                  .data_out(read_out_b)
                                 );

    assign read_out_a = a_out;

    assign d_inst_out       = d_inst;
    assign d_inst_valid_out = d_inst_valid;
    assign d_pc_out         = d_pc;

endmodule
