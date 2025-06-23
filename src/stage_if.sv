module stage_if  #(parameter ADDR_WIDTH = 64, INST_WIDTH = 32, PC_TYPE_NUM = 4)(
    input  wire                           clk,
    input  wire                           reset,
    input  wire                           stall,
    input  wire [$clog2(PC_TYPE_NUM)-1:0] pc_sel, // Selector for PC: 0 = Plus4, 1 = Branch, 2 = Jump, 3 = Jump Register
    input  wire [ADDR_WIDTH-1:0]          bra_addr,
    input  wire [ADDR_WIDTH-1:0]          jal_addr,
    input  wire [ADDR_WIDTH-1:0]          jar_addr,
    output wire [ADDR_WIDTH-1:0]          d_pc,
    output wire [ADDR_WIDTH-1:0]          d_pc4,
    output wire [INST_WIDTH-1:0]          d_inst_word,
    output wire                           inst_valid,
    output wire                           inst_buffer_empty,
    output wire                           inst_buffer_full
);

    wire [ADDR_WIDTH-1:0] pc_next;
    wire [ADDR_WIDTH-1:0] pc_curr;
    wire [ADDR_WIDTH-1:0] pc_next_options [0:PC_TYPE_NUM-1];
    wire [INST_WIDTH-1:0] inst_word;

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
               .pc_next(pc_next)
              );

    // M3: Conditional instruction fetch from instruction memory
    // TODO: Write memory instruction such that it returns garbage or filter value if pc_sel indicates not Plus4
    memory_instruction M3 (.pc(pc_curr),
                           .pc_sel(pc_sel),
                           .inst_valid(inst_valid),
                           .inst_word(inst_word)
                          );


endmodule
