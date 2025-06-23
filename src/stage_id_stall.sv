module stage_id_stall #(parameter ADDR_WIDTH = 64, REG_NUM = 32) (
    input  wire [$clog2(REG_NUM)-1:0] load_rd,
    input  wire                       is_load,
    input  wire [$clog2(REG_NUM)-1:0] rs1_addr,
    input  wire [$clog2(REG_NUM)-1:0] rs2_addr,
    output wire                       stall 
);
    assign stall = is_load && (rs1_addr == load_rd || rs2_addr == load_rd);
endmodule