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
