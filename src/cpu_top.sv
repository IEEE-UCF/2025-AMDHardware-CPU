module cpu_top #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter REG_NUM = 32,
    parameter PC_TYPE_NUM = 4,
    parameter IMM_TYPE_NUM = 4
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  interrupt,
    
    // Memory interface - Instruction
    output wire [ADDR_WIDTH-1:0] imem_addr,
    input  wire [INST_WIDTH-1:0] imem_data,
    input  wire                  imem_ready,
    
    // Memory interface - Data
    output wire [ADDR_WIDTH-1:0] dmem_addr,
    output wire [DATA_WIDTH-1:0] dmem_write_data,
    output wire                  dmem_read,
    output wire                  dmem_write,
    input  wire [DATA_WIDTH-1:0] dmem_read_data,
    input  wire                  dmem_ready,
    
    // Debug/Status outputs
    output wire [ADDR_WIDTH-1:0] debug_pc,
    output wire [INST_WIDTH-1:0] debug_inst,
    output wire                  pipeline_stall
);

    // Pipeline stage interconnections
    
    // IF stage outputs
    wire [ADDR_WIDTH-1:0] if_pc;
    wire [ADDR_WIDTH-1:0] if_pc4;
    wire [INST_WIDTH-1:0] if_inst;
    wire                  if_inst_valid;
    wire                  if_inst_buffer_empty;
    wire                  if_inst_buffer_full;
    
    // ID stage outputs
    wire                  id_is_equal;
    wire [ADDR_WIDTH-1:0] id_read_out_gpu;
    wire [ADDR_WIDTH-1:0] id_read_out_a;
    wire [ADDR_WIDTH-1:0] id_read_out_b;
    wire [ADDR_WIDTH-1:0] id_bra_addr;
    wire [ADDR_WIDTH-1:0] id_jal_addr;
    wire [ADDR_WIDTH-1:0] id_jar_addr;
    
    // Control signals from ID stage (would come from control unit)
    wire                  id_reg_write;
    wire                  id_mem_read;
    wire                  id_mem_write;
    wire [4:0]            id_alu_op;
    wire                  id_has_imm;
    wire [1:0]            id_imm_type;
    wire [$clog2(PC_TYPE_NUM)-1:0] id_pc_sel;
    wire                  id_is_load;
    wire [$clog2(REG_NUM)-1:0] id_rd;
    wire [$clog2(REG_NUM)-1:0] id_rs1;
    wire [$clog2(REG_NUM)-1:0] id_rs2;
    
    // ID/EX pipeline register outputs
    wire                  idex_reg_write;
    wire                  idex_mem_read;
    wire                  idex_mem_write;
    wire [3:0]            idex_alu_op;
    wire [DATA_WIDTH-1:0] idex_rs1_data;
    wire [DATA_WIDTH-1:0] idex_rs2_data;
    wire [DATA_WIDTH-1:0] idex_imm;
    wire [4:0]            idex_rd;
    wire [4:0]            idex_rs1;
    wire [4:0]            idex_rs2;
    
    // EX stage outputs
    wire [DATA_WIDTH-1:0] ex_alu_result;
    
    // EX/MM pipeline register outputs
    wire                  exmm_reg_write;
    wire                  exmm_mem_read;
    wire                  exmm_mem_write;
    wire [DATA_WIDTH-1:0] exmm_alu_result;
    wire [DATA_WIDTH-1:0] exmm_write_data;
    wire [4:0]            exmm_rd;
    
    // MM stage outputs
    wire [DATA_WIDTH-1:0] mm_mem_data;
    wire [DATA_WIDTH-1:0] mm_alu_result;
    wire [4:0]            mm_rd;
    wire                  mm_reg_write;
    
    // WB stage outputs
    wire [DATA_WIDTH-1:0] wb_data;
    
    // Forwarding/bypass signals
    wire [DATA_WIDTH-1:0] ex_forward_data;
    wire [DATA_WIDTH-1:0] mm_forward_data;
    wire [DATA_WIDTH-1:0] mm_mem_forward_data;
    wire [$clog2(REG_NUM)-1:0] ex_forward_rd;
    wire [$clog2(REG_NUM)-1:0] mm_forward_rd;
    wire [$clog2(REG_NUM)-1:0] mm_mem_forward_rd;
    
    // GPU interface signals (simplified)
    wire                  gpu_write_en;
    wire [$clog2(REG_NUM)-1:0] gpu_write_addr;
    wire [DATA_WIDTH-1:0] gpu_write_data;
    wire [$clog2(REG_NUM)-1:0] gpu_read_addr;
    
    // Stall control
    wire load_stall;
    wire global_stall;
    
    // Branch/Jump control
    wire branch_taken;
    
    // Assign forwarding data (from EX and MM stages)
    assign ex_forward_data = ex_alu_result;
    assign mm_forward_data = mm_alu_result;
    assign mm_mem_forward_data = mm_mem_data;
    assign ex_forward_rd = idex_rd;
    assign mm_forward_rd = exmm_rd;
    assign mm_mem_forward_rd = mm_rd;
    
    // Assign memory interface
    assign imem_addr = if_pc;
    assign dmem_addr = exmm_alu_result;
    assign dmem_write_data = exmm_write_data;
    assign dmem_read = exmm_mem_read;
    assign dmem_write = exmm_mem_write;
    
    // Debug outputs
    assign debug_pc = if_pc;
    assign debug_inst = if_inst;
    assign pipeline_stall = global_stall;
    
    // Global stall control
    assign global_stall = load_stall | if_inst_buffer_full | ~dmem_ready;
    
    // Simple control unit logic (basic decode)
    // In a full implementation, this would be a separate control unit module
    always_comb begin
        // Default values
        id_reg_write = 1'b0;
        id_mem_read = 1'b0;
        id_mem_write = 1'b0;
        id_alu_op = 5'b00000;
        id_has_imm = 1'b0;
        id_imm_type = 2'b00;
        id_pc_sel = 2'b00; // Default: PC+4
        id_is_load = 1'b0;
        
        // Decode based on opcode (simplified RISC-V-like)
        if (if_inst_valid && !global_stall) begin
            case (if_inst[6:0]) // opcode
                7'b0110011: begin // R-type (ADD, SUB, etc.)
                    id_reg_write = 1'b1;
                    id_alu_op = {if_inst[30], if_inst[14:12], 1'b0};
                end
                7'b0010011: begin // I-type (ADDI, etc.)
                    id_reg_write = 1'b1;
                    id_has_imm = 1'b1;
                    id_imm_type = 2'b00;
                    id_alu_op = {1'b0, if_inst[14:12], 1'b0};
                end
                7'b0000011: begin // Load instructions
                    id_reg_write = 1'b1;
                    id_mem_read = 1'b1;
                    id_has_imm = 1'b1;
                    id_imm_type = 2'b00;
                    id_is_load = 1'b1;
                    id_alu_op = 5'b00000; // ADD for address calculation
                end
                7'b0100011: begin // Store instructions
                    id_mem_write = 1'b1;
                    id_has_imm = 1'b1;
                    id_imm_type = 2'b10;
                    id_alu_op = 5'b00000; // ADD for address calculation
                end
                7'b1100011: begin // Branch instructions
                    id_pc_sel = id_is_equal ? 2'b01 : 2'b00;
                    id_alu_op = 5'b01111; // Equality test
                end
                7'b1101111: begin // JAL
                    id_reg_write = 1'b1;
                    id_pc_sel = 2'b10;
                end
                7'b1100111: begin // JALR
                    id_reg_write = 1'b1;
                    id_pc_sel = 2'b11;
                    id_has_imm = 1'b1;
                    id_imm_type = 2'b00;
                end
                default: begin
                    // NOP or unsupported instruction
                end
            endcase
        end
        
        // Extract register addresses
        id_rd = if_inst[11:7];
        id_rs1 = if_inst[19:15];
        id_rs2 = if_inst[24:20];
    end
    
    // Pipeline Stage Instantiations
    
    // Instruction Fetch (IF) Stage
    stage_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .PC_TYPE_NUM(PC_TYPE_NUM)
    ) if_stage (
        .clk(clk),
        .reset(reset),
        .stall(global_stall),
        .pc_sel(id_pc_sel),
        .bra_addr(id_bra_addr),
        .jal_addr(id_jal_addr),
        .jar_addr(id_jar_addr),
        .d_pc(if_pc),
        .d_pc4(if_pc4),
        .d_inst_word(if_inst),
        .inst_valid(if_inst_valid),
        .inst_buffer_empty(if_inst_buffer_empty),
        .inst_buffer_full(if_inst_buffer_full)
    );
    
    // Instruction Decode (ID) Stage
    stage_id #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .REG_NUM(REG_NUM)
    ) id_stage (
        .clk(clk),
        .reset(reset),
        .interrupt(interrupt),
        .stall(global_stall),
        .w_en(mm_reg_write),
        .w_en_gpu(gpu_write_en),
        .has_imm(id_has_imm),
        .imm_type(id_imm_type),
        .pc4(if_pc4),
        .pc(if_pc),
        .w_result(wb_data),
        .w_result_gpu(gpu_write_data),
        .ex_pro(ex_forward_data),
        .mm_pro(mm_forward_data),
        .mm_mem(mm_mem_forward_data),
        .inst_word(if_inst),
        .load_rd(exmm_rd),
        .is_load(id_is_load),
        .w_rd(mm_rd),
        .w_rd_gpu(gpu_write_addr),
        .rs_gpu(gpu_read_addr),
        .ex_pro_rs(ex_forward_rd),
        .mm_pro_rs(mm_forward_rd),
        .mm_mem_rs(mm_mem_forward_rd),
        .is_equal(id_is_equal),
        .read_out_gpu(id_read_out_gpu),
        .read_out_a(id_read_out_a),
        .read_out_b(id_read_out_b),
        .bra_addr(id_bra_addr),
        .jal_addr(id_jal_addr),
        .jar_addr(id_jar_addr)
    );
    
    // ID/EX Pipeline Register
    reg_id_to_ex #(
        .DATA_WIDTH(DATA_WIDTH)
    ) idex_reg (
        .clk(clk),
        .rst(reset),
        .reg_write_in(id_reg_write),
        .mem_read_in(id_mem_read),
        .mem_write_in(id_mem_write),
        .alu_op_in(id_alu_op[3:0]),
        .rs1_data_in(id_read_out_a),
        .rs2_data_in(id_read_out_b),
        .imm_in(id_read_out_b), // Immediate selected via mux in ID stage
        .rd_in(id_rd),
        .rs1_in(id_rs1),
        .rs2_in(id_rs2),
        .reg_write_out(idex_reg_write),
        .mem_read_out(idex_mem_read),
        .mem_write_out(idex_mem_write),
        .alu_op_out(idex_alu_op),
        .rs1_data_out(idex_rs1_data),
        .rs2_data_out(idex_rs2_data),
        .imm_out(idex_imm),
        .rd_out(idex_rd),
        .rs1_out(idex_rs1),
        .rs2_out(idex_rs2)
    );
    
    // Execute (EX) Stage
    pl_stage_exe #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ex_stage (
        .ea(idex_rs1_data),
        .eb(idex_rs2_data),
        .epc4(if_pc4), // For JAL/JALR instructions
        .ealuc(idex_alu_op),
        .ecall(1'b0), // System call signal (not implemented)
        .eal(ex_alu_result)
    );
    
    // EX/MM Pipeline Register
    reg_ex_to_mm #(
        .DATA_WIDTH(DATA_WIDTH)
    ) exmm_reg (
        .clk(clk),
        .rst(reset),
        .reg_write_in(idex_reg_write),
        .mem_read_in(idex_mem_read),
        .mem_write_in(idex_mem_write),
        .alu_result_in(ex_alu_result),
        .write_data_in(idex_rs2_data), // Store data
        .rd_in(idex_rd),
        .reg_write_out(exmm_reg_write),
        .mem_read_out(exmm_mem_read),
        .mem_write_out(exmm_mem_write),
        .alu_result_out(exmm_alu_result),
        .write_data_out(exmm_write_data),
        .rd_out(exmm_rd)
    );
    
    // Memory (MM) Stage
    mm_stage #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) mm_stage_inst (
        .clk(clk),
        .rst(reset),
        .ex_mem_alu_result(exmm_alu_result),
        .ex_mem_write_data(exmm_write_data),
        .ex_mem_rd(exmm_rd),
        .ex_mem_mem_read(exmm_mem_read),
        .ex_mem_mem_write(exmm_mem_write),
        .ex_mem_reg_write(exmm_reg_write),
        .mem_addr(), // Connected to dmem_addr above
        .mem_write_data(), // Connected to dmem_write_data above
        .mem_read(), // Connected to dmem_read above
        .mem_write(), // Connected to dmem_write above
        .mem_read_data(dmem_read_data),
        .mem_wb_mem_data(mm_mem_data),
        .mem_wb_alu_result(mm_alu_result),
        .mem_wb_rd(mm_rd),
        .mem_wb_reg_write(mm_reg_write)
    );
    
    // Write Back (WB) Stage
    pl_stage_wb #(
        .DATA_WIDTH(DATA_WIDTH)
    ) wb_stage (
        .walu(mm_alu_result),
        .wmem(mm_mem_data),
        .wmem2reg(exmm_mem_read), // Use read signal to select memory data
        .wdata(wb_data)
    );
    
    // GPU/Coprocessor interface (simplified - not fully connected)
    assign gpu_write_en = 1'b0;
    assign gpu_write_addr = 5'b0;
    assign gpu_write_data = {DATA_WIDTH{1'b0}};
    assign gpu_read_addr = 5'b0;

endmodule
