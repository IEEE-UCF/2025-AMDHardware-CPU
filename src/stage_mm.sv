module mm_stage #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input wire clk,
    input wire rst,

    // Inputs from EX/MEM pipeline register
    input wire [DATA_WIDTH-1:0] ex_mem_alu_result,
    input wire [DATA_WIDTH-1:0] ex_mem_write_data,
    input wire [4:0] ex_mem_rd,
    input wire ex_mem_mem_read,
    input wire ex_mem_mem_write,
    input wire ex_mem_reg_write,

    // Memory interface
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output reg [DATA_WIDTH-1:0] mem_write_data,
    output reg mem_read,
    output reg mem_write,
    input wire [DATA_WIDTH-1:0] mem_read_data,

    // Outputs to MEM/WB pipeline register
    output reg [DATA_WIDTH-1:0] mem_wb_mem_data,
    output reg [DATA_WIDTH-1:0] mem_wb_alu_result,
    output reg [4:0] mem_wb_rd,
    output reg mem_wb_reg_write
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        mem_addr         <= 0;
        mem_write_data   <= 0;
        mem_read         <= 0;
        mem_write        <= 0;
        mem_wb_mem_data  <= 0;
        mem_wb_alu_result<= 0;
        mem_wb_rd        <= 0;
        mem_wb_reg_write <= 0;
    end else begin
        // Set up memory access
        mem_addr       <= ex_mem_alu_result;
        mem_write_data <= ex_mem_write_data;
        mem_read       <= ex_mem_mem_read;
        mem_write      <= ex_mem_mem_write;

        // Pass ALU result forward for instructions that don't access memory
        mem_wb_alu_result <= ex_mem_alu_result;
        mem_wb_rd         <= ex_mem_rd;
        mem_wb_reg_write  <= ex_mem_reg_write;

        // For load instructions, capture memory data
        if (ex_mem_mem_read)
            mem_wb_mem_data <= mem_read_data;
        else
            mem_wb_mem_data <= 0;
    end
end

endmodule