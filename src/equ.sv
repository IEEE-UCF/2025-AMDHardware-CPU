module equ #(parameter DATA_WIDTH = 64)(
    input  wire [DATA_WIDTH-1:0] data_a,
    input  wire [DATA_WIDTH-1:0] data_b,
    output wire                  is_equal
);
    assign is_equal = (data_a == data_b);
endmodule