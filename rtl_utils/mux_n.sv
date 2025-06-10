module mux_n #(parameter INPUT_WIDTH = 64, INPUT_NUM = 4)(
    input  wire [INPUT_WIDTH-1:0]       data_in [0:INPUT_NUM-1],
    input  wire [$clog2(INPUT_NUM)-1:0] sel,
    output wire [INPUT_WIDTH-1:0]       data_out
);
    assign data_out = data_in[sel];
endmodule