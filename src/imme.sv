module imme #(parameter DATA_WIDTH = 64, INST_WIDTH = 32, IMM_TYPE_WIDTH = 2)(
    input  wire [INST_WIDTH-1:0]      inst,
    input  wire [IMM_TYPE_WIDTH-1:0]  imm_type,
    output wire [DATA_WIDTH-1:0]      imm
);
    always @(*) begin
        case(imm_type)
            2'b00: imm = {{DATA_WIDTH-11{inst[31]}}, inst[30:20]}; // R-Type EXCEPT Shift
            2'b01: imm = {{DATA_WIDTH-5{1'b0}}, inst[24:20]}; // R-Type Shift
            2'b10: imm = {{DATA_WIDTH-11{inst[31]}},inst[30:25],inst[11:7]}; // Store
            2'b11: imm = {inst[31:12],DATA_WIDTH-20{1'b0}}; // LUI
        endcase
    end
endmodule
