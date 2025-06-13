module register_bank_cpu #(parameter REG_NUM = 32, DATA_WIDTH = 64)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire [$clog2(REG_NUM)-1:0] write_addr,
    input  wire [DATA_WIDTH-1:0]      data_in,
    input  wire                       write_en,
    input  wire [$clog2(REG_NUM)-1:0] read_addr_a,
    input  wire [$clog2(REG_NUM)-1:0] read_addr_b,
    output wire [DATA_WIDTH-1:0]      data_out_a,
    output wire [DATA_WIDTH-1:0]      data_out_b
);
    reg [DATA_WIDTH-1:0] registers [0:REG_NUM-1];
    
    // Reading data combinationally
    assign data_out_a = registers[read_addr_a];
    assign data_out_b = registers[read_addr_b];

    // Writing data in clock sequence
    always_ff @(negedge clk) {
        if (reset) begin
            registers <= '0;
        end
        else if (write_en && (write_addr != 0)) begin
            registers[write_addr] <= data_in;
        end
    }

endmodule