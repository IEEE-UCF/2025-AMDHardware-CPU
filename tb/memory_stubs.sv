// Stub modules for missing memory interfaces
// These provide basic functionality for testbench compilation

module memory_instruction #(
    parameter ADDR_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter PC_TYPE_NUM = 4
)(
    input  wire [ADDR_WIDTH-1:0]          pc,
    input  wire [$clog2(PC_TYPE_NUM)-1:0] pc_sel,
    output wire                           inst_valid,
    output wire [INST_WIDTH-1:0]          inst_word
);
    // Simple stub - always return valid instruction
    assign inst_valid = 1'b1;
    assign inst_word = 32'h00000013; // NOP instruction (ADDI x0, x0, 0)
endmodule

module memory_data #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] write_data,
    input  wire                  read_en,
    input  wire                  write_en,
    output reg  [DATA_WIDTH-1:0] read_data,
    output wire                  ready
);
    // Simple memory array
    reg [DATA_WIDTH-1:0] memory [0:1023];
    
    always @(posedge clk) begin
        if (reset) begin
            read_data <= 0;
        end else begin
            if (write_en) begin
                memory[addr[11:3]] <= write_data; // Word-aligned access
            end
            if (read_en) begin
                read_data <= memory[addr[11:3]];
            end
        end
    end
    
    assign ready = 1'b1; // Always ready
endmodule
