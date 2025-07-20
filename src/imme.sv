module imme #(parameter DATA_WIDTH = 64, INST_WIDTH = 32, IMM_TYPE_NUM = 4)(
    input  wire [INST_WIDTH-1:0]            inst,
    input  wire [$clog2(IMM_TYPE_NUM)-1:0]  imm_type,
    output reg [DATA_WIDTH-1:0]             imm
); // $clog2(N) returns n such that 2^n >= N (Synthesizable if input is constant)
    
    localparam IMM_S_TYPE = 2'b00;  // I-type immediate
    localparam IMM_SHIFT  = 2'b01;  // Shift immediate
    localparam IMM_I_TYPE = 2'b10;  // S-type immediate
    localparam IMM_U_TYPE = 2'b11;  // U-type immediate
    
    always @(*) begin
        case(imm_type)
            IMM_S_TYPE: imm = {{DATA_WIDTH-11{inst[31]}},inst[30:25],inst[11:7]}; // Store
            IMM_SHIFT:  imm = {{DATA_WIDTH-6{1'b0}}, inst[25:20]};                // I-Type Shift
            IMM_I_TYPE: imm = {{DATA_WIDTH-11{inst[31]}}, inst[30:20]};           // I-Type 
            IMM_U_TYPE: imm = {inst[31:12], {DATA_WIDTH-20{1'b0}}};               // LUI
        endcase
    end
endmodule
