module reg_ex_to_mm #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst,
    // Inputs from EX stage
    input  logic                  reg_write_in,
    input  logic                  mem_read_in,
    input  logic                  mem_write_in,
    input  logic [DATA_WIDTH-1:0] alu_result_in,
    input  logic [DATA_WIDTH-1:0] write_data_in,
    input  logic [4:0]            rd_in,
    // Outputs to MM stage
    output logic                  reg_write_out,
    output logic                  mem_read_out,
    output logic                  mem_write_out,
    output logic [DATA_WIDTH-1:0] alu_result_out,
    output logic [DATA_WIDTH-1:0] write_data_out,
    output logic [4:0]            rd_out
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        reg_write_out   <= 0;
        mem_read_out    <= 0;
        mem_write_out   <= 0;
        alu_result_out  <= 0;
        write_data_out  <= 0;
        rd_out          <= 0;
    end else begin
        reg_write_out   <= reg_write_in;
        mem_read_out    <= mem_read_in;
        mem_write_out   <= mem_write_in;
        alu_result_out  <= alu_result_in;
        write_data_out  <= write_data_in;
        rd_out          <= rd_in;
    end