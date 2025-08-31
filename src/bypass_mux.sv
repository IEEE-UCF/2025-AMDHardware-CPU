module bypass_mux #(
    parameter ADDR_WIDTH = 64, 
    parameter REG_NUM = 32
)(
    // Control signals for forwarding decisions
    input  logic                               ex_wr_reg_en,    // EX stage writing to register
    input  logic                               mm_wr_reg_en,    // MM stage writing to register
    input  logic                               mm_is_load,      // MM stage is a load instruction
    
    // Data inputs
    input  logic [ADDR_WIDTH-1:0]              file_out,        // Data from register file
    input  logic [ADDR_WIDTH-1:0]              ex_pro,          // EX stage ALU result
    input  logic [ADDR_WIDTH-1:0]              mm_pro,          // MM stage ALU result
    input  logic [ADDR_WIDTH-1:0]              mm_mem,          // MM stage memory data
    
    // Register addresses for comparison
    input  logic [$clog2(REG_NUM)-1:0]         file_out_rs,     // Source register being read
    input  logic [$clog2(REG_NUM)-1:0]         ex_rd,           // EX stage destination register
    input  logic [$clog2(REG_NUM)-1:0]         mm_rd,           // MM stage destination register
    
    // Output
    output logic [ADDR_WIDTH-1:0]              bypass_out       // Final forwarded data
);

    logic [1:0] bypass_sel;
    logic [ADDR_WIDTH-1:0] bypass_options [0:3];
    
    // Data forwarding decision logic
    always_comb begin
        // Default: no forwarding, use register file data
        bypass_sel = 2'b00;
        
        // Check for EX stage forwarding (highest priority)
        if (file_out_rs == ex_rd && ex_wr_reg_en && file_out_rs != '0) begin
            bypass_sel = 2'b01;  // Forward from EX stage
        end
        // Check for MM stage forwarding
        else if (file_out_rs == mm_rd && mm_wr_reg_en && file_out_rs != '0) begin
            if (mm_is_load) begin
                bypass_sel = 2'b11;  // Forward from MM stage memory data
            end else begin
                bypass_sel = 2'b10;  // Forward from MM stage ALU result
            end
        end
        // If no matches or source register is x0, use register file data
        else begin
            bypass_sel = 2'b00;  // Use register file value
        end
    end

    // Assign the data source options
    assign bypass_options[0] = file_out;    // Register file value
    assign bypass_options[1] = ex_pro;      // EX stage ALU result
    assign bypass_options[2] = mm_pro;      // MM stage ALU result  
    assign bypass_options[3] = mm_mem;      // MM stage memory data

    // Instantiate the multiplexer to select the correct data
    mux_n #(
        .INPUT_WIDTH(ADDR_WIDTH),
        .INPUT_NUM(4)
    ) bypass_selection (
        .data_in(bypass_options),
        .sel(bypass_sel),
        .data_out(bypass_out)
    );
    
    // Debug output for verification (can be removed for synthesis)
    `ifdef DEBUG
    always_comb begin
        if (bypass_sel != 2'b00) begin
            $display("[BYPASS] Rs=%d, Ex_rd=%d, Mm_rd=%d, Sel=%d", 
                     file_out_rs, ex_rd, mm_rd, bypass_sel);
        end
    end
    `endif

endmodule