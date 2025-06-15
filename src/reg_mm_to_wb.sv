module reg_mm_to_wb #(
    parameter DATA_WIDTH = 64
)(
    input  logic                  clk,
    input  logic                  rst,
    // Inputs from MM stage
    input  logic [DATA_WIDTH-1:0] mem_data_in,
    input  logic [DATA_WIDTH-1:0] alu_result_in,
    input  logic [4:0]            rd_in,
    input  logic                  reg_write_in,
    // Outputs to WB stage
    output logic [DATA_WIDTH-1:0] mem_data_out,
    output logic [DATA_WIDTH-1:0] alu_result_out,
    output logic [4:0]            rd_out,
    output logic                  reg_write_out
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        mem_data_out   <= 0;
        alu_result_out <= 0;
        rd_out         <= 0;
        reg_write_out  <= 0;
    end else begin
        mem_data_out   <= mem_data_in;
        alu_result_out <= alu_result_in;
        rd_out         <= rd_in;
        reg_write_out  <= reg_write_in;
    end
end