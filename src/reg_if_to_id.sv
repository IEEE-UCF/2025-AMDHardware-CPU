module reg_if_to_id #(ADDR_WIDTH = 64, INST_WIDTH = 32) (
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  stall,
    input  wire [ADDR_WIDTH-1:0] pc4,
    input  wire [ADDR_WIDTH-1:0] pc,
    input  wire [INST_WIDTH-1:0] inst,
    output wire                  inst_buffer_empty,
    output wire                  inst_buffer_full,
    output wire [ADDR_WIDTH-1:0] d_pc4,
    output wire [ADDR_WIDTH-1:0] d_pc,
    output wire [INST_WIDTH-1:0] d_inst
    // output wire [INST_WIDTH-1:0] d_inst_next
);

    reg [ADDR_WIDTH-1:0] pc4_reg;
    reg [ADDR_WIDTH-1:0] pc_reg;

    always_ff @(posedge clk) begin
        if (reset) begin
            pc4_reg <= {ADDR_WIDTH{1'b0}};
            pc_reg <= {ADDR_WIDTH{1'b0}};
        end
        else if (stall) begin
            pc4_reg <= pc4_reg;
            pc_reg <= pc_reg;
        end
        else begin
            pc4_reg <= pc4;
            pc_reg <= pc;
        end
    end

    assign d_pc4 = pc4_reg;
    assign d_pc = pc_reg;

    instruction_buffer insts (.clk(clk),
                              .reset(reset),
                              .write_en(~stall),
                              .data_in(inst),
                              .data_out(d_inst),
                              .is_empty(inst_buffer_empty),
                              .is_full(inst_buffer_full)
                             );

    // For now, just assign d_inst_next to d_inst (would need more complex lookahead logic)
    // assign d_inst_next = d_inst;
endmodule
