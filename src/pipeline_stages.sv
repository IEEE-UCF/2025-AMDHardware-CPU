module stage_if  #(parameter ADDR_WIDTH = 64, INST_WIDTH = 32, PC_TYPE_NUM = 4)(
    input  wire                           clk,
    input  wire                           reset,
    input  wire                           stall,
    input  wire                           inst_w_en,
    input  wire [INST_WIDTH-1:0]          inst_w_in,
    input  wire [$clog2(PC_TYPE_NUM)-1:0] pc_sel, // Selector for PC: 0 = Plus4, 1 = Branch, 2 = Jump, 3 = Jump Register
    input  wire [ADDR_WIDTH-1:0]          bra_addr,
    input  wire [ADDR_WIDTH-1:0]          jal_addr,
    input  wire [ADDR_WIDTH-1:0]          jar_addr,
    output wire [ADDR_WIDTH-1:0]          pc,
    output wire [ADDR_WIDTH-1:0]          pc4,
    output wire [INST_WIDTH-1:0]          inst_word,
    output wire                           inst_valid,
    output wire                           inst_buffer_empty,
    output wire                           inst_buffer_full
);

    wire [ADDR_WIDTH-1:0] pc_next;
    wire [ADDR_WIDTH-1:0] pc_curr;
    wire [ADDR_WIDTH-1:0] pc_next_options [0:PC_TYPE_NUM-1];

    assign pc_next_options[0] = pc_curr + 4;
    assign pc_next_options[1] = bra_addr;
    assign pc_next_options[2] = jal_addr;
    assign pc_next_options[3] = jar_addr;

    // M1: Compute next PC based on pc_sel and curr_pc
    mux_n M1 (.data_in(pc_next_options), 
              .sel(pc_sel),
              .data_out(pc_next)
             );

    // M2: Register slice to store PC
    // PC returns as output for M1 to take as input
    reg_if M2 (.clk(clk),
               .reset(reset),
               .stall(stall),
               .pc_next(pc_next),
               .pc_reg(pc_curr)
              );

    // M3: Conditional instruction fetch from instruction memory
    // pc_curr bits split between X and Y arbitrarily, first two bits ignored due to address incrementing by 4
    memory_instruction instruction_memory (.Clock(clk),
                           .WriteEnable(inst_w_en),
                           .X_addr(pc_curr[5:2]),
                           .Y_addr(pc_curr[9:6]),
                           .Data_in(inst_w_in),
                           .Data_out(inst_word)
                          );

    assign inst_valid = (pc_sel == 2'b00);
    assign pc = pc_curr;
    assign pc4 = pc_next_options[0];
endmodule

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

module stage_id_stall #(parameter ADDR_WIDTH = 64, REG_NUM = 32) (
    input  wire                       is_load,
    input  wire                       has_rs1,
    input  wire                       has_rs2,
    input  wire                       has_rs3,    
    input  wire [$clog2(REG_NUM)-1:0] rs1_addr,
    input  wire [$clog2(REG_NUM)-1:0] rs2_addr,
    input  wire [$clog2(REG_NUM)-1:0] rs3_addr,
    input  wire [$clog2(REG_NUM)-1:0] load_rd,
    output wire                       stall 
);
    assign stall = is_load &&   ((has_rs1 && (rs1_addr == load_rd)) 
                              || (has_rs2 && (rs2_addr == load_rd)) 
                              || (has_rs3 && (rs3_addr == load_rd)));
endmodule

module pl_stage_exe #(parameter DATA_WIDTH = 64)(
    input  wire [DATA_WIDTH-1:0] ea,
    input  wire [DATA_WIDTH-1:0] eb,
    input  wire [DATA_WIDTH-1:0] epc4,
    input  wire [4:0]            ealuc,
    input  wire                  ecall,
    output wire [DATA_WIDTH-1:0] eal
);
    // ALU implementation with important operations
    reg [DATA_WIDTH-1:0] ealu;
    always @(*) begin
        case (ealuc)
            5'b00000: ealu = ea + eb;                        // ADD
            5'b00001: ealu = ea - eb;                        // SUB
            5'b00010: ealu = ea & eb;                        // AND
            5'b00011: ealu = ea | eb;                        // OR
            5'b00100: ealu = ea ^ eb;                        // XOR
            5'b00101: ealu = ~(ea | eb);                     // NOR
            5'b00110: ealu = ~(ea & eb);                     // NAND
            5'b00111: ealu = ea << eb[4:0];                  // Logical shift left
            5'b01000: ealu = ea >> eb[4:0];                  // Logical shift right
            5'b01001: ealu = $signed(ea) >>> eb[4:0];        // Arithmetic shift right
            5'b01010: ealu = ($signed(ea) < $signed(eb)) ? 1 : 0; // Set less than (signed)
            5'b01011: ealu = (ea < eb) ? 1 : 0;              // Set less than (unsigned)
            5'b01100: ealu = ea;                             // Pass-through A
            5'b01101: ealu = eb;                             // Pass-through B
            5'b01110: ealu = ~ea;                            // Bitwise NOT A
            5'b01111: ealu = (ea == eb) ? 1 : 0;             // Equality test
            5'b10000: ealu = (ea != eb) ? 1 : 0;             // Inequality test
            5'b10001: ealu = ea + 1;                         // Increment A
            5'b10010: ealu = ea - 1;                         // Decrement A
            default:  ealu = {DATA_WIDTH{1'b0}};
        endcase
    end

    // 2-to-1 mux for ecall
    assign eal = ecall ? epc4 : ealu;

endmodule

module mm_stage #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 64
)(
    input wire clk,
    input wire rst_n,

    // Inputs from EX/MEM pipeline register
    input wire [DATA_WIDTH-1:0] ex_mem_alu_result,
    input wire [DATA_WIDTH-1:0] ex_mem_write_data,
    input wire [4:0] ex_mem_rd,
    input wire ex_mem_mem_read,
    input wire ex_mem_mem_write,
    input wire ex_mem_reg_write,

    // Memory interface
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output reg [DATA_WIDTH-1:0] mem_write_data,
    output reg mem_read,
    output reg mem_write,
    input wire [DATA_WIDTH-1:0] mem_read_data,

    // Outputs to MEM/WB pipeline register
    output reg [DATA_WIDTH-1:0] mem_wb_mem_data,
    output reg [DATA_WIDTH-1:0] mem_wb_alu_result,
    output reg [4:0] mem_wb_rd,
    output reg mem_wb_reg_write
);

always @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        mem_addr         <= 0;
        mem_write_data   <= 0;
        mem_read         <= 0;
        mem_write        <= 0;
        mem_wb_mem_data  <= 0;
        mem_wb_alu_result<= 0;
        mem_wb_rd        <= 0;
        mem_wb_reg_write <= 0;
    end else begin
        // Set up memory access
        mem_addr       <= ex_mem_alu_result;
        mem_write_data <= ex_mem_write_data;
        mem_read       <= ex_mem_mem_read;
        mem_write      <= ex_mem_mem_write;

        // Pass ALU result forward for instructions that don't access memory
        mem_wb_alu_result <= ex_mem_alu_result;
        mem_wb_rd         <= ex_mem_rd;
        mem_wb_reg_write  <= ex_mem_reg_write;

        // For load instructions, capture memory data
        if (ex_mem_mem_read)
            mem_wb_mem_data <= mem_read_data;
        else
            mem_wb_mem_data <= 0;
    end
end

endmodule

module pl_stage_wb #(parameter DATA_WIDTH = 64)(
    input  wire [DATA_WIDTH-1:0] walu,
    input  wire [DATA_WIDTH-1:0] wmem,
    input  wire                  wmem2reg,
    output wire [DATA_WIDTH-1:0] wdata
);
    // 2-to-1 mux for write-back data selection
    assign wdata = wmem2reg ? wmem : walu;

endmodule