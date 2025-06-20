// Coprocessor Dispatcher Unit
// Routes instructions to appropriate coprocessors based on opcode

module coprocessor_dispatcher #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter CP_NUM = 3
)(
    input  logic                    clk,
    input  logic                    rst_n,
    
    // CPU Pipeline Interface
    input  logic [INST_WIDTH-1:0]  instruction,
    input  logic                    inst_valid,
    input  logic [DATA_WIDTH-1:0]  rs1_data,
    input  logic [DATA_WIDTH-1:0]  rs2_data,
    input  logic [ADDR_WIDTH-1:0]  pc,
    input  logic                    pipeline_stall,
    
    // Coprocessor System Interface
    output logic                    cp_valid,
    output logic [INST_WIDTH-1:0]  cp_instruction,
    output logic [DATA_WIDTH-1:0]  cp_data_in,
    output logic [1:0]              cp_select,
    input  logic [DATA_WIDTH-1:0]  cp_data_out,
    input  logic                    cp_ready,
    input  logic                    cp_exception,
    
    // CPU Control Interface
    output logic                    cp_instruction_detected,
    output logic                    cp_stall_request,
    output logic                    cp_exception_out,
    output logic [DATA_WIDTH-1:0]  cp_result,
    output logic                    cp_result_valid,
    
    // Register Writeback Interface
    output logic                    cp_reg_write,
    output logic [4:0]              cp_reg_addr,
    output logic [DATA_WIDTH-1:0]  cp_reg_data
);

    // Detect coprocessor instructions based on opcode
    logic [6:0] opcode;
    assign opcode = instruction[6:0];
    
    always_comb begin
        cp_instruction_detected = 1'b0;
        cp_select = 2'b00;
        
        if (inst_valid && !pipeline_stall) begin
            case (opcode)
                7'b1110011: begin // System instructions (CSR, etc.) -> CP0
                    cp_instruction_detected = 1'b1;
                    cp_select = 2'b00;
                end
                7'b1010011: begin // Floating point instructions -> CP1
                    cp_instruction_detected = 1'b1;
                    cp_select = 2'b01;
                end
                7'b0001011: begin // Custom instructions -> CP2
                    cp_instruction_detected = 1'b1;
                    cp_select = 2'b10;
                end
                default: begin
                    cp_instruction_detected = 1'b0;
                    cp_select = 2'b00;
                end
            endcase
        end
    end
    
    // Forward instruction and data to coprocessor
    assign cp_valid = cp_instruction_detected;
    assign cp_instruction = instruction;
    assign cp_data_in = rs1_data;
    
    // Handle coprocessor results
    assign cp_result = cp_data_out;
    assign cp_result_valid = cp_ready && cp_valid;
    assign cp_stall_request = cp_valid && !cp_ready;
    assign cp_exception_out = cp_exception;
    
    // Register writeback (simplified)
    assign cp_reg_write = cp_result_valid;
    assign cp_reg_addr = instruction[11:7]; // rd field
    assign cp_reg_data = cp_data_out;

endmodule