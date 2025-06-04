module pc4 #(parameter ADDR_WIDTH = 64)(
    input  wire [ADDR_WIDTH-1:0] pc,
    output wire [ADDR_WIDTH-1:0] pc4
);
    localparam OFFSET = 4;
    assign pc4 = pc + OFFSET;
endmodule