module reg_if #(parameter ADDR_WIDTH = 64)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  stall,
    input  wire [ADDR_WIDTH-1:0] pc_next,
    output reg  [ADDR_WIDTH-1:0] pc_reg
);
    localparam RESET_ADDR = {ADDR_WIDTH{1'b0}};

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_reg <= RESET_ADDR;
        end
        else if (stall) begin
            pc_reg <= pc_reg;
        end
        else begin
            pc_reg <= pc_next;
        end
    end
endmodule
