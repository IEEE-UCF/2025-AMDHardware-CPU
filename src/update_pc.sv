module update_pc #(parameter ADDR_WIDTH = 64, PC_TYPE_NUM = 4)(
    input  wire [ADDR_WIDTH-1:0]          pc,
    input  wire [$clog2(PC_TYPE_NUM)-1:0] pc_sel,
    input  wire [ADDR_WIDTH-1:0]          bra_addr,
    input  wire [ADDR_WIDTH-1:0]          jal_addr,
    input  wire [ADDR_WIDTH-1:0]          jar_addr,
    output wire [ADDR_WIDTH-1:0]          pc_next
);
    localparam BRA = 2'b01;
    localparam JAL = 2'b10;
    localparam JAR = 2'b11;
    assign pc_next = (pc_sel == 2'b01) ? bra_addr :
                     (pc_sel == 2'b10) ? jal_addr :
                     (pc_sel == 2'b11) ? jar_addr :
                                         pc + 4;
endmodule