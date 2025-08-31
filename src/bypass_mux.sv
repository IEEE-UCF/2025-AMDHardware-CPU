module bypass_mux #(parameter ADDR_WIDTH = 64, REG_NUM = 32)(
    input                               ex_wr_reg_en,
    input                               mm_wr_reg_en,
    input                               mm_is_load,
    input  wire [ADDR_WIDTH-1:0]       file_out,
    input  wire [ADDR_WIDTH-1:0]       ex_pro,
    input  wire [ADDR_WIDTH-1:0]       mm_pro,
    input  wire [ADDR_WIDTH-1:0]       mm_mem,
    input  wire [$clog2(REG_NUM)-1:0]  file_out_rs,
    input  wire [$clog2(REG_NUM)-1:0]  ex_rd,
    input  wire [$clog2(REG_NUM)-1:0]  mm_rd,
    output wire [ADDR_WIDTH-1:0]       bypass_out
);

    logic [1:0] bypass_sel;
    wire [ADDR_WIDTH-1:0] bypass_options [0:3];
    
    // Fixed: Use always_comb properly without mixing reg/wire
    always_comb begin
        if (file_out_rs == ex_rd && ex_wr_reg_en && file_out_rs != 0) begin
            bypass_sel = 2'b01;  // Forward from EX stage
        end
        else if (file_out_rs == mm_rd && mm_wr_reg_en && file_out_rs != 0) begin
            if (mm_is_load) begin
                bypass_sel = 2'b11;  // Forward from memory
            end else begin
                bypass_sel = 2'b10;  // Forward from MM ALU result
            end
        end
        else begin
            bypass_sel = 2'b00;  // Use register file value
        end
    end

    // Assign bypass options
    assign bypass_options[0] = file_out;  // Register file value
    assign bypass_options[1] = ex_pro;    // EX stage result
    assign bypass_options[2] = mm_pro;    // MM stage ALU result
    assign bypass_options[3] = mm_mem;    // MM stage memory result

    // Instantiate mux
    mux_n #(
        .INPUT_WIDTH(ADDR_WIDTH),
        .INPUT_NUM(4)
    ) bypass_selection (
        .data_in(bypass_options),
        .sel(bypass_sel),
        .data_out(bypass_out)
    );
    
endmodule