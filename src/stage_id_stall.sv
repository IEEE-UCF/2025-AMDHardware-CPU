module stage_id_stall #(REG_NUM = 32) (
    input  wire                       ex_is_load,
    input  wire                       is_u_type,
    input  wire                       is_j_type,
    input  wire                       is_i_type,
    input  wire [$clog2(REG_NUM)-1:0] ex_rd,
    input  wire [$clog2(REG_NUM)-1:0] read_addr_a,
    input  wire [$clog2(REG_NUM)-1:0] read_addr_b,
    input  wire [6:0]                 opcode,
    output wire                       stall 
);
    // Note: Opcode type logic does not check for uncommon instructions such as CSR, FENCE, etc.

    // If the execute inst is a load, and decode inst will read load_rd, stall until execute inst moves to mem stage (to forward load_rd value)
    assign stall = ex_is_load & ((~(is_u_type | is_j_type) & (read_addr_a == ex_rd)) | (~(is_u_type | is_j_type | is_i_type) & (read_addr_b == ex_rd)));
endmodule