<<<<<<< HEAD
module bypass_mux  #(parameter ADDR_WIDTH = 64, REG_NUM = 32)(
    input                        ex_wr_reg_en,
    input                        mm_wr_reg_en,
    input                        mm_is_load,
=======
// Purpose: Forwards operand values from later stages if decode stage's instruction is using them
// Input: Register file data, execute's processor result, memory's processor result, and memory's data mem result,
// alongside register numbers, write enable signals, and is_load check
// Output: Correct register data after accounting for operand forwarding
module bypass_mux #(parameter ADDR_WIDTH = 64, REG_NUM = 32)(
    input  wire                  ex_w_en,
    input  wire                  mm_w_en,
    input  wire                  mm_is_load,
>>>>>>> sebas-dev-cocotb
    input  wire [ADDR_WIDTH-1:0] file_out,
    input  wire [ADDR_WIDTH-1:0] ex_pro,
    input  wire [ADDR_WIDTH-1:0] mm_pro,
    input  wire [ADDR_WIDTH-1:0] mm_mem,
    input  wire [$clog2(REG_NUM)-1:0] file_out_rs,
    input  wire [$clog2(REG_NUM)-1:0] ex_rd,
    input  wire [$clog2(REG_NUM)-1:0] mm_rd,
    output wire [ADDR_WIDTH-1:0] bypass_out
);
    // Select values
    localparam FILE_OUT = 2'b00;
    localparam EX_PRO   = 2'b01;
    localparam MM_PRO   = 2'b10;
    localparam MM_MEM   = 2'b11;

    // Selector and options for mux
    reg [1:0] bypass_sel;
    wire [ADDR_WIDTH-1:0] bypass_options [0:3];
    
    // Selector combinational logic
    always_comb begin
        if (file_out_rs == ex_rd & ex_w_en) begin
            bypass_sel = EX_PRO;
        end
        else if (file_out_rs == mm_rd & mm_w_en) begin
            if (mm_is_load) begin
                bypass_sel = MM_MEM;
            end else begin
                bypass_sel = MM_PRO;
            end
        end
        else begin
            bypass_sel = FILE_OUT;
        end
    end

    // Bypass options set to possible data values
    assign bypass_options = {file_out, ex_pro, mm_pro, mm_mem};

    // Mux to select correct output
    mux_n bypass_selection (
        .data_in(bypass_options),
        .sel(bypass_sel),
        .data_out(bypass_out)
    );

endmodule
