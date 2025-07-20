module reg_if_to_id #(parameter ADDR_WIDTH = 64, INST_WIDTH = 32) (
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  stall,
    input  wire                  inst_valid,
    input  wire [ADDR_WIDTH-1:0] pc,
    input  wire [INST_WIDTH-1:0] inst,
    output wire                  if_buffer_stall_out, // Check if this is necessary
    output wire                  d_inst_valid,
    output wire                  buffer_active_out,
    output wire                  branch_predict,
    output wire [ADDR_WIDTH-1:0] d_pc,
    output wire [INST_WIDTH-1:0] d_inst,
    output wire [ADDR_WIDTH-1:0] pc_next,
    output wire [ADDR_WIDTH-1:0] bra_addr,
    output wire [ADDR_WIDTH-1:0] jal_addr,
    output wire [ADDR_WIDTH-1:0] jar_addr
    // output wire [INST_WIDTH-1:0] d_inst_next
);

    reg                  inst_valid_reg;
    reg [ADDR_WIDTH-1:0] pc_reg;

    wire [INST_WIDTH-1:0] inst_buffer_out;
    wire [ADDR_WIDTH-1:0] pc_buffer_out;
    wire [ADDR_WIDTH-1:0] pc_buffer_next;

    wire buffer_active;
    wire buffer_read_en;
    wire buffer_write_en;
    wire buffer_reset;
    wire buffer_empty;
    wire if_buffer_stall;
    wire buffer_full;

    assign buffer_active_out = buffer_active;
    assign if_buffer_stall_out = if_buffer_stall;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_reg <= {ADDR_WIDTH{1'b0}};
            inst_valid_reg <= 1'b0;
        end else if (stall || if_buffer_stall || if_load_stall) begin
            pc_reg <= pc_reg;
            inst_valid_reg <= inst_valid_reg;
        end else begin
            pc_reg <= pc;
            inst_valid_reg <= inst_valid;
        end
    end

    stage_id_buffer_fsm stall_buffer_fsm (.clk(clk),
                                          .reset(reset),
                                          .buffer_reset(buffer_reset),
                                          .stall(stall),
                                          .buffer_is_empty(buffer_empty),
                                          .buffer_is_full(buffer_full),
                                          .inst_valid(inst_valid),
                                          .buffer_write_en(buffer_write_en),
                                          .buffer_read_en(buffer_read_en),
                                          .if_buffer_stall(if_buffer_stall),
                                          .buffer_active(buffer_active),
                                          .buffer_sel(buffer_sel)
                                         );
                                        
    stage_id_buffer stall_buffer (.clk(clk),
                                  .reset(reset),
                                  .buffer_reset(buffer_reset),
                                  .read_en(buffer_read_en),
                                  .write_en(buffer_write_en),
                                  .inst_in(inst),
                                  .pc_in(pc_reg),
                                  .inst_out(inst_buffer_out),
                                  .pc_out(pc_buffer_out),
                                  .pc_next(pc_buffer_next),
                                  .is_empty(buffer_empty),
                                  .is_full(buffer_full)
                                 );
    
    assign d_inst_valid = inst_valid_reg || buffer_active; // During buffer use, all instructions will be valid
    
    // Instruction Execution Types
        // 1. Non-Buffer Execution
        // 2. Stall Execution
        // 3. Buffer Execution
    // Buffer Improvement Steps:
        // 1. Add branch predictor to handle branch control while using buffer DONE
        // 2. Add logic to handle branch or jump issues while using buffer with only one instruction inside DONE
        // 3. Move branch control to buffer input (aka regs) to ensure buffer always has correct instruction order DONE
        // 4. Add equality check to next instruction's PC and the override address output to flush for prediction failures DONE
        // 5. Keep pc+4, branch_addr, and jalr_addr calculators in decode and use with equality check to "fix" curr_pc DONE
        // 6. Set up muxes to handle PC override at fetch due to prediction failure or jalr failure DONE
    branch_calc if_to_id_branch_addrs (.pc(pc_reg),
                                       .inst(inst),
                                       .data_a(a_out),
                                       .bra_addr(bra_addr),
                                       .jal_addr(jal_addr),
                                       .jalr_addr(jar_addr)
                                      );

    // Mux determines whether to read directly from memory or use buffer (usually after stall)
    wire [INST_WIDTH-1:0] inst_out_options [1:0] = {inst_buffer_out, inst}; // No inst_reg since instruction memory takes cycle to read
    wire [ADDR_WIDTH-1:0] pc_out_options   [1:0] = {pc_buffer_out, pc_reg};
    wire [ADDR_WIDTH-1:0] pc_next_options  [1:0] = {pc, pc_buffer_next};
    
    mux_n #(.INPUT_NUM(2)) d_inst_mux (.data_in(inst_out_options),
                                       .sel(buffer_sel),
                                       .data_out(d_inst)
                                      );
    
    mux_n #(.INPUT_NUM(2)) d_pc_mux (.data_in(pc_out_options),
                                     .sel(buffer_sel),
                                     .data_out(d_pc)
                                    );

    mux_n #(.INPUT_NUM(2)) pc_next_mux (.data_in(pc_next_options),
                                        .sel(has_next),
                                        .data_out(pc_next)
                                       );
    
    assign branch_predict = buffer_sel;
endmodule
