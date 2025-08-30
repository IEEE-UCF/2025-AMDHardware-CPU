module reg_ex_to_mm #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,
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

always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
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
end

endmodule

module reg_id_to_ex #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,
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

always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
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

module reg_if_to_id #(ADDR_WIDTH = 64, INST_WIDTH = 32) (
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  stall,
    input  wire [ADDR_WIDTH-1:0] pc4,
    input  wire [ADDR_WIDTH-1:0] pc,
    input  wire [INST_WIDTH-1:0] inst,
    output wire                  inst_buffer_empty,
    output wire                  inst_buffer_full,
    output wire [ADDR_WIDTH-1:0] d_pc4,
    output wire [ADDR_WIDTH-1:0] d_pc,
    output wire [INST_WIDTH-1:0] d_inst
    // output wire [INST_WIDTH-1:0] d_inst_next
);

    reg [ADDR_WIDTH-1:0] pc4_reg;
    reg [ADDR_WIDTH-1:0] pc_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            pc4_reg <= {ADDR_WIDTH{1'b0}};
            pc_reg <= {ADDR_WIDTH{1'b0}};
        end
        else if (stall) begin
            pc4_reg <= pc4_reg;
            pc_reg <= pc_reg;
        end
        else begin
            pc4_reg <= pc4;
            pc_reg <= pc;
        end
    end

    assign d_pc4 = pc4_reg;
    assign d_pc = pc_reg;

    instruction_buffer insts (.clk(clk),
                              .rst_n(rst_n),
                              .write_en(~stall),
                              .data_in(inst),
                              .data_out(d_inst),
                              .is_empty(inst_buffer_empty),
                              .is_full(inst_buffer_full)
                             );

    // For now, just assign d_inst_next to d_inst (would need more complex lookahead logic)
    // assign d_inst_next = d_inst;
endmodule

module reg_if #(parameter ADDR_WIDTH = 64)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  stall,
    input  wire [ADDR_WIDTH-1:0] pc_next,
    output reg  [ADDR_WIDTH-1:0] pc_reg
);
    localparam RESET_ADDR = {ADDR_WIDTH{1'b0}};

    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            pc_reg <= RESET_ADDR;
        end
        else if (stall) begin
            pc_reg <= pc_reg;
        end
        else begin
            pc_reg <= pc_next;
        end
    end
endmodule

module reg_mm_to_wb #(
    parameter DATA_WIDTH = 64
)(
    input  logic                  clk,
    input  logic                  rst_n,
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

always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
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

endmodule
