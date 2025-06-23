module reg_id_to_ex #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst,
    // Control signals
    input  logic                  reg_write_in,
    input  logic                  mem_read_in,
    input  logic                  mem_write_in,
    input  logic [3:0]            alu_op_in,
    // Data signals
    input  logic [DATA_WIDTH-1:0] rs1_data_in,
    input  logic [DATA_WIDTH-1:0] rs2_data_in,
    input  logic [DATA_WIDTH-1:0] imm_in,
    input  logic [4:0]            rd_in,
    input  logic [4:0]            rs1_in,
    input  logic [4:0]            rs2_in,

    // Outputs to EX stage
    output logic                  reg_write_out,
    output logic                  mem_read_out,
    output logic                  mem_write_out,
    output logic [3:0]            alu_op_out,
    output logic [DATA_WIDTH-1:0] rs1_data_out,
    output logic [DATA_WIDTH-1:0] rs2_data_out,
    output logic [DATA_WIDTH-1:0] imm_out,
    output logic [4:0]            rd_out,
    output logic [4:0]            rs1_out,
    output logic [4:0]            rs2_out
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        reg_write_out <= 0;
        mem_read_out  <= 0;
        mem_write_out <= 0;
        alu_op_out    <= 0;
        rs1_data_out  <= 0;
        rs2_data_out  <= 0;
        imm_out       <= 0;
        rd_out        <= 0;
        rs1_out       <= 0;
        rs2_out       <= 0;
    end else begin
        reg_write_out <= reg_write_in;
        mem_read_out  <= mem_read_in;
        mem_write_out <= mem_write_in;
        alu_op_out    <= alu_op_in;
        rs1_data_out  <= rs1_data_in;
        rs2_data_out  <= rs2_data_in;
        imm_out       <= imm_in;
        rd_out        <= rd_in;
        rs1_out       <= rs1_in;
        rs2_out       <= rs2_in;
    end
end

endmodule