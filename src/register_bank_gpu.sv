module register_bank_gpu #(parameter REG_NUM = 32, DATA_WIDTH = 64)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire [$clog2(REG_NUM)-1:0] write_addr,
    input  wire [DATA_WIDTH-1:0]      data_in,
    input  wire                       write_en,
    input  wire [$clog2(REG_NUM)-1:0] read_addr,
    output wire [DATA_WIDTH-1:0]      data_out
);
    reg [DATA_WIDTH-1:0] registers [0:REG_NUM-1];
    
    // Reading data combinationally
    assign data_out = registers[read_addr];

    // Writing data in clock sequence
    always_ff @(negedge clk) begin
        if (reset) begin
            for (int i = 0; i < REG_NUM; i++) begin
                registers[i] <= {DATA_WIDTH{1'b0}};
            end
        end
        else if (write_en && (write_addr != 0)) begin
            registers[write_addr] <= data_in;
        end
    end
endmodule
