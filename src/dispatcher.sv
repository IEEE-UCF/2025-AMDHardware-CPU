module dispatcher #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter INST_WIDTH = 32,
    parameter CP_NUM = 3
) (
    input wire clk,
    input wire rst_n,
    
    // Interface from decode stage
    input wire [INST_WIDTH-1:0] instruction,
    input wire inst_valid,
    input wire [DATA_WIDTH-1:0] rs1_data,
    input wire [DATA_WIDTH-1:0] rs2_data,
    input wire [ADDR_WIDTH-1:0] pc,
    input wire pipeline_stall,
    
    // Coprocessor interface
    output wire cp_valid,
    output wire [INST_WIDTH-1:0] cp_instruction,
    output wire [DATA_WIDTH-1:0] cp_data_in,
    output wire [1:0] cp_select,
    input wire [DATA_WIDTH-1:0] cp_data_out,
    input wire cp_ready,
    input wire cp_exception,
    output wire cp_instruction_detected,
    output wire cp_stall_request,
    output wire cp_exception_out,
    output wire [DATA_WIDTH-1:0] cp_result,
    output wire cp_result_valid,
    output wire cp_reg_write,
    output wire [4:0] cp_reg_addr,
    output wire [DATA_WIDTH-1:0] cp_reg_data
);

    // Extract instruction fields
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
    wire [4:0] rd = instruction[11:7];
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    
    // Coprocessor instruction detection (custom opcode)
    wire is_coprocessor_inst = (opcode == 7'b1010111) && inst_valid && !pipeline_stall;
    
    // Coprocessor dispatch logic
    assign cp_valid = is_coprocessor_inst;
    assign cp_instruction = instruction;
    assign cp_data_in = rs1_data; // Use rs1 data as input to coprocessor
    assign cp_select = funct3[1:0]; // Use lower 2 bits of funct3 for coprocessor selection
    assign cp_instruction_detected = is_coprocessor_inst;
    assign cp_stall_request = is_coprocessor_inst && !cp_ready;
    assign cp_exception_out = cp_exception;
    
    // Result handling
    assign cp_result = cp_data_out;
    assign cp_result_valid = cp_valid && cp_ready;
    assign cp_reg_write = cp_result_valid && (rd != 5'b0); // Don't write to x0
    assign cp_reg_addr = rd;
    assign cp_reg_data = cp_result;

endmodule