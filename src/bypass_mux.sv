module bypass_mux  #(parameter ADDR_WIDTH = 64, REG_NUM = 32)(
    input                        ex_wr_reg_en,
    input                        mm_wr_reg_en,
    input                        mm_is_load,
    input  wire [ADDR_WIDTH-1:0] file_out,
    input  wire [ADDR_WIDTH-1:0] ex_pro,
    input  wire [ADDR_WIDTH-1:0] mm_pro,
    input  wire [ADDR_WIDTH-1:0] mm_mem,
    input  wire [$clog2(REG_NUM)-1:0] file_out_rs,
    input  wire [$clog2(REG_NUM)-1:0] ex_rd,
    input  wire [$clog2(REG_NUM)-1:0] mm_rd,
    output wire [ADDR_WIDTH-1:0] bypass_out
);

    wire [1:0] bypass_sel;
    wire [ADDR_WIDTH-1:0] bypass_options [0:3];
    
    always_comb {
        if (file_out_rs == ex_rd & ex_wr_reg_en) begin
            bypass_sel = 2'b01;
        end
        else if (file_out_rs == mm_rd & mm_wr_reg_en) begin
            if (mm_is_load) begin
                bypass_sel = 2'b11;
            end else begin
                bypass_sel = 2'b10;
            end
        end
        else begin
            bypass_sel = 2'b00;
        end
    }

    assign bypass_options = {file_out, ex_pro, mm_pro, mm_mem};

    mux_n bypass_selection (
        .data_in(bypass_options),
        .sel(bypass_sel),
        .data_out(bypass_out)
    );
endmodule
