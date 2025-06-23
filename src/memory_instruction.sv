`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2025 05:32:43 PM
// Design Name: 
// Module Name: imem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module xdecode #(parameter SIZE = 4)(
    input  wire [SIZE-1:0] addr,
    output reg  [(1<<SIZE)-1:0] loc
);
    always @(*) begin
        loc = 0;
        loc[addr] = 1'b1;
    end
endmodule

module imem #(parameter ADDR_BITS = 4, DATA_WIDTH = 32)(
    input  wire                      Clock,
    input  wire                      WriteEnable,
    input  wire [ADDR_BITS-1:0]     X_addr,
    input  wire [ADDR_BITS-1:0]     Y_addr,
    input  wire [DATA_WIDTH-1:0]    Data_in,
    output reg  [DATA_WIDTH-1:0]    Data_out
);
    localparam NUM_ROWS = (1 << ADDR_BITS);
    localparam NUM_COLS = (1 << ADDR_BITS);
    reg [DATA_WIDTH-1:0] memory_array [0:NUM_ROWS-1][0:NUM_COLS-1];
    integer i, j;
    wire [NUM_ROWS-1:0] Xloca, Yloca;
    xdecode #(ADDR_BITS) xdec (.addr(X_addr), .loc(Xloca));
    xdecode #(ADDR_BITS) ydec (.addr(Y_addr), .loc(Yloca));
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

