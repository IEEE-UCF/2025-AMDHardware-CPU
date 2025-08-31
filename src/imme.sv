module imme #(parameter DATA_WIDTH = 64, INST_WIDTH = 32, IMM_TYPE_NUM = 4)(
    input  wire [INST_WIDTH-1:0]            inst,
    input  wire [$clog2(IMM_TYPE_NUM)-1:0]  imm_type,
    output reg [DATA_WIDTH-1:0]             imm
);
    // Fixed immediate type constants for RISC-V
    localparam IMM_I_TYPE = 2'b00;  // I-type immediate (loads, ADDI, etc.)
    localparam IMM_S_TYPE = 2'b01;  // S-type immediate (stores)
    localparam IMM_U_TYPE = 2'b10;  // U-type immediate (LUI, AUIPC)
    localparam IMM_B_TYPE = 2'b11;  // B-type immediate (branches)
    
    always_comb begin
        case(imm_type)
            IMM_I_TYPE: 
                // I-type: inst[31:20] sign-extended
                imm = {{(DATA_WIDTH-12){inst[31]}}, inst[31:20]};
            
            IMM_S_TYPE: 
                // S-type: {inst[31:25], inst[11:7]} sign-extended
                imm = {{(DATA_WIDTH-12){inst[31]}}, inst[31:25], inst[11:7]};
            
            IMM_U_TYPE: 
                // U-type: inst[31:12] shifted left 12 bits
                imm = {{(DATA_WIDTH-32){inst[31]}}, inst[31:12], 12'b0};
            
            IMM_B_TYPE: 
                // B-type: {inst[31], inst[7], inst[30:25], inst[11:8], 0} sign-extended
                imm = {{(DATA_WIDTH-13){inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            
            default: 
                imm = {DATA_WIDTH{1'b0}};
        endcase
    end
endmodule