// Coprocessor Interface
// Defines the interface between CPU and coprocessors for system operations

module coprocessor_interface #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter CP_NUM = 4  // Number of coprocessors
)(
    input  logic                    clk,
    input  logic                    rst_n,
    
    // CPU Interface
    input  logic                    cp_valid,        // Coprocessor instruction valid
    input  logic [INST_WIDTH-1:0]  cp_instruction,  // Coprocessor instruction
    input  logic [DATA_WIDTH-1:0]  cp_data_in,      // Data from CPU
    output logic [DATA_WIDTH-1:0]  cp_data_out,     // Data to CPU
    output logic                    cp_ready,        // Coprocessor ready
    output logic                    cp_exception,    // Exception occurred
    
    // Coprocessor Select
    input  logic [1:0]              cp_select,       // Which coprocessor (0-3)
    
    // Individual Coprocessor Interfaces
    output logic [CP_NUM-1:0]       cp_enable,       // Enable signals for each CP
    output logic [INST_WIDTH-1:0]   cp_inst_out,     // Instruction to selected CP
    output logic [DATA_WIDTH-1:0]   cp_data_to_cp,   // Data to selected CP
    input  logic [DATA_WIDTH-1:0]   cp_data_from_cp [CP_NUM-1:0], // Data from CPs
    input  logic [CP_NUM-1:0]       cp_ready_in,     // Ready signals from CPs
    input  logic [CP_NUM-1:0]       cp_exception_in  // Exception signals from CPs
);

    // Coprocessor selection logic
    always_comb begin
        cp_enable = '0;
        cp_data_out = '0;
        cp_ready = 1'b0;
        cp_exception = 1'b0;
        
        if (cp_valid && cp_select < CP_NUM) begin
            cp_enable[cp_select] = 1'b1;
            cp_data_out = cp_data_from_cp[cp_select];
            cp_ready = cp_ready_in[cp_select];
            cp_exception = cp_exception_in[cp_select];
        end
    end
    
    // Forward instruction and data to selected coprocessor
    assign cp_inst_out = cp_instruction;
    assign cp_data_to_cp = cp_data_in;

endmodule