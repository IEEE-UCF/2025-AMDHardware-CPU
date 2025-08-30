module datamem #(parameter ADDR_BITS = 16, DATA_WIDTH = 64)(
    input  wire                      Clock,
    input  wire                      WriteEnable,
    input  wire [ADDR_BITS/2-1:0]     X_addr,
    input  wire [ADDR_BITS/2-1:0]     Y_addr,
    input  wire [DATA_WIDTH-1:0]    Data_in,
    output reg  [DATA_WIDTH-1:0]    Data_out
);
    localparam NUM_ROWS = (1 << ADDR_BITS/2);
    localparam NUM_COLS = (1 << ADDR_BITS/2);
    reg [DATA_WIDTH-1:0] memory_array [0:NUM_ROWS-1][0:NUM_COLS-1];
    integer i, j;
    initial begin
        for (i = 0; i < NUM_ROWS; i = i + 1) begin
            for (j = 0; j < NUM_COLS; j = j + 1) begin
                 memory_array[i][j] ={DATA_WIDTH{1'bx}};
            end
        end
    end
    always @(posedge Clock) begin
        if (WriteEnable &&(X_addr < NUM_ROWS) && (Y_addr < NUM_COLS)) begin
            memory_array[X_addr][Y_addr] <= Data_in;
        end       
        if ((X_addr < NUM_ROWS) && (Y_addr < NUM_COLS)) begin
            Data_out = memory_array[X_addr][Y_addr];
        end else begin
            Data_out = {DATA_WIDTH{1'bx}};
        end
    end
endmodule

