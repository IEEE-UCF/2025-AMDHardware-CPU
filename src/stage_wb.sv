module pl_stage_wb #(parameter DATA_WIDTH = 64)(
    input  wire [DATA_WIDTH-1:0] walu,
    input  wire [DATA_WIDTH-1:0] wmem,
    input  wire                  wmem2reg,
    output wire [DATA_WIDTH-1:0] wdata
);
    // 2-to-1 mux for write-back data selection
    assign wdata = wmem2reg ? wmem : walu;

endmodule