module stage_id_stall #(parameter ADDR_WIDTH = 64, REG_NUM = 32) (
    input  wire                       is_load,
    input  wire                       has_rs1,
    input  wire                       has_rs2,
    input  wire                       has_rs3,    
    input  wire [$clog2(REG_NUM)-1:0] rs1_addr,
    input  wire [$clog2(REG_NUM)-1:0] rs2_addr,
    input  wire [$clog2(REG_NUM)-1:0] rs3_addr,
    input  wire [$clog2(REG_NUM)-1:0] load_rd,
    output wire                       stall 
);
    assign stall = is_load &&   ((has_rs1 && (rs1_addr == load_rd)) 
                              || (has_rs2 && (rs2_addr == load_rd)) 
                              || (has_rs3 && (rs3_addr == load_rd)));
endmodule