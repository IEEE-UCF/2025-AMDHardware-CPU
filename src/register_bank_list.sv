module register_bank_list #(parameter REG_NUM = 32, DATA_WIDTH = 64)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire                       interrupt,
    input  wire [$clog2(REG_NUM)-1:0] write_addr_cpu,
    input  wire [$clog2(REG_NUM)-1:0] write_addr_gpu,
    input  wire [DATA_WIDTH-1:0]      data_in_cpu,
    input  wire [DATA_WIDTH-1:0]      data_in_gpu,
    input  wire                       write_en_cpu,
    input  wire                       write_en_gpu,
    input  wire [$clog2(REG_NUM)-1:0] read_addr_a,
    input  wire [$clog2(REG_NUM)-1:0] read_addr_b,
    input  wire [$clog2(REG_NUM)-1:0] read_addr_gpu,
    output wire [DATA_WIDTH-1:0]      data_out_a,
    output wire [DATA_WIDTH-1:0]      data_out_b,
    output wire [DATA_WIDTH-1:0]      data_out_gpu
);
    wire write_en_main;
    assign write_en_main = write_en_cpu & ~interrupt;

    wire [DATA_WIDTH-1:0] data_out_a_options [0:1];
    wire [DATA_WIDTH-1:0] data_out_b_options [0:1];

    register_bank_cpu main (.clk(clk),
                            .reset(reset),
                            .write_addr(write_addr_cpu),
                            .data_in(data_in_cpu),
                            .write_en(write_en_main),
                            .read_addr_a(read_addr_a),
                            .read_addr_b(read_addr_b),
                            .data_out_a(data_out_a_options[0]),
                            .data_out_b(data_out_b_options[0])
                           );
    //TODO: Build post-interrupt behavior to handle inconsistent data between main and shadow for future interrupt handling
    register_bank_cpu shadow (.clk(clk),
                              .reset(reset),
                              .write_addr(write_addr_cpu),
                              .data_in(data_in_cpu),
                              .write_en(write_en_cpu),
                              .read_addr_a(read_addr_a),
                              .read_addr_b(read_addr_b),
                              .data_out_a(data_out_a_options[1]),
                              .data_out_b(data_out_b_options[1])
                             );
    
    register_bank_gpu gpu (.clk(clk),
                           .reset(reset),
                           .write_addr(write_addr_gpu),
                           .data_in(data_in_gpu),
                           .write_en(write_en_gpu),
                           .read_addr(read_addr_gpu),
                           .data_out(data_out_gpu)
                          );
    
    // Choose to output main or shadow register data depending on context (interrupt)
    mux_n #(.INPUT_NUM(2)) a_out (.data_in(data_out_a_options),
                                  .sel(interrupt),
                                  .data_out(data_out_a)
                                 );

    mux_n #(.INPUT_NUM(2)) b_out (.data_in(data_out_b_options),
                                  .sel(interrupt),
                                  .data_out(data_out_b)
                                 );
endmodule
