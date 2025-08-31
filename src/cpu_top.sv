module cpu_top #(
    parameter ADDR_WIDTH = 32,  // Fixed at 32-bit for Zynq
    parameter DATA_WIDTH = 32,  // 32-bit data for efficiency
    parameter INST_WIDTH = 32,
    parameter REG_NUM = 32
)(
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic                      interrupt,
    
    // Instruction Memory Interface
    output logic [ADDR_WIDTH-1:0]    imem_addr,
    input  logic [INST_WIDTH-1:0]    imem_read_data,
    output logic                      imem_read,
    input  logic                      imem_ready,
    
    // Data Memory Interface
    output logic [ADDR_WIDTH-1:0]    dmem_addr,
    output logic [DATA_WIDTH-1:0]    dmem_write_data,
    output logic                      dmem_read,
    output logic                      dmem_write,
    output logic [3:0]                dmem_byte_enable,  // Reduced to 4 bytes for 32-bit
    input  logic [DATA_WIDTH-1:0]    dmem_read_data,
    input  logic                      dmem_ready,
    
    // Coprocessor Interface
    output logic                      cp_instruction_detected,
    output logic [INST_WIDTH-1:0]     cp_instruction_out,
    input  logic                      cp_stall_external,
    
    // Debug/Status Interface
    output logic [ADDR_WIDTH-1:0]    debug_pc,
    output logic                      debug_stall,
    output logic [3:0]               debug_state
);
    
    // Pipeline Registers
    logic [ADDR_WIDTH-1:0]   if_pc;
    logic [ADDR_WIDTH-1:0]   if_pc4;
    logic [INST_WIDTH-1:0]   if_inst;
    logic                    if_valid;
    
    logic [ADDR_WIDTH-1:0]   id_pc;
    logic [ADDR_WIDTH-1:0]   id_pc4;
    logic [INST_WIDTH-1:0]   id_inst;
    logic [DATA_WIDTH-1:0]   id_rs1_data;
    logic [DATA_WIDTH-1:0]   id_rs2_data;
    logic [DATA_WIDTH-1:0]   id_imm;
    logic [4:0]              id_rd;
    logic [4:0]              id_rs1;
    logic [4:0]              id_rs2;
    logic [4:0]              id_alu_op;
    logic                    id_alu_src;
    logic                    id_mem_read;
    logic                    id_mem_write;
    logic                    id_reg_write;
    logic                    id_branch;
    logic                    id_jump;
    logic                    id_valid;
    logic [2:0]              id_funct3;
    
    logic [DATA_WIDTH-1:0]   ex_alu_result;
    logic [DATA_WIDTH-1:0]   ex_rs2_data;
    logic [4:0]              ex_rd;
    logic                    ex_mem_read;
    logic                    ex_mem_write;
    logic                    ex_reg_write;
    logic                    ex_valid;
    logic [2:0]              ex_funct3;
    
    logic [DATA_WIDTH-1:0]   mem_alu_result;
    logic [DATA_WIDTH-1:0]   mem_mem_data;
    logic [4:0]              mem_rd;
    logic                    mem_reg_write;
    logic                    mem_mem_to_reg;
    logic                    mem_valid;
    
    logic [DATA_WIDTH-1:0]   wb_data;
    logic [4:0]              wb_rd;
    logic                    wb_reg_write;
    
    // Control signals
    logic                    stall;
    logic                    flush;
    logic                    branch_taken;
    logic [ADDR_WIDTH-1:0]   branch_target;
    logic                    jump_taken;
    logic [ADDR_WIDTH-1:0]   jump_target;
    logic                    is_equal;
    logic [1:0]              pc_sel;
    logic [1:0]              imm_type;
    logic                    has_imm;
    logic                    has_rs1;
    logic                    has_rs2;
    logic                    has_rs3;
    logic                    is_load;
    logic [ADDR_WIDTH-1:0]   bra_addr;
    logic [ADDR_WIDTH-1:0]   jal_addr;
    logic [ADDR_WIDTH-1:0]   jalr_addr;
    logic                    inst_buffer_empty;
    logic                    inst_buffer_full;
    
    // Hazard detection
    logic                    data_hazard;
    logic                    load_use_hazard;
    logic                    control_hazard;
    
    // Combined stall signal
    logic                    global_stall;
    assign global_stall = stall || !imem_ready || !dmem_ready || cp_stall_external;
    
    // Debug outputs
    assign debug_pc = if_pc;
    assign debug_stall = global_stall;
    assign debug_state = {flush, branch_taken, jump_taken, global_stall};
    assign cp_instruction_out = if_inst;
    
    // Control unit for instruction decode
    control_unit #(
        .INST_WIDTH(INST_WIDTH)
    ) u_control (
        .instruction(if_inst),
        .inst_valid(if_valid),
        .reg_write(id_reg_write),
        .mem_read(id_mem_read),
        .mem_write(id_mem_write),
        .alu_op(id_alu_op),
        .alu_src(id_alu_src),
        .imm_type(imm_type),
        .branch(id_branch),
        .jump(id_jump),
        .jalr(),
        .lui(),
        .auipc(),
        .system(cp_instruction_detected),
        .opcode(),
        .funct3(id_funct3),
        .funct7(),
        .rd(id_rd),
        .rs1(id_rs1),
        .rs2(id_rs2)
    );
    
    // Determine control signals based on instruction type
    always_comb begin
        has_imm = id_alu_src || id_mem_read || id_mem_write || id_branch || id_jump;
        has_rs1 = !id_jump; // JAL doesn't use rs1
        has_rs2 = !id_alu_src && !id_mem_read && !id_jump; // Only R-type and branches
        has_rs3 = 1'b0; // No FMA instructions in base ISA
        is_load = id_mem_read;
        
        // PC selection logic
        if (jump_taken)
            pc_sel = 2'b10; // JAL
        else if (branch_taken)
            pc_sel = 2'b01; // Branch
        else if (id_jump && id_alu_src) // JALR
            pc_sel = 2'b11;
        else
            pc_sel = 2'b00; // PC+4
    end
    
    // Branch decision
    always_comb begin
        branch_taken = id_branch && is_equal;
        branch_target = bra_addr;
        jump_taken = id_jump && !id_alu_src; // JAL
        jump_target = jal_addr;
    end
    
    // Generate byte enables based on memory operation type
    always_comb begin
        dmem_byte_enable = 4'hF;  // Default: full word
        if (ex_mem_write || ex_mem_read) begin
            case (ex_funct3)
                3'b000: dmem_byte_enable = 4'h1;  // SB/LB
                3'b001: dmem_byte_enable = 4'h3;  // SH/LH
                3'b010: dmem_byte_enable = 4'hF;  // SW/LW
                default: dmem_byte_enable = 4'hF;
            endcase
        end
    end
    
    // Pipeline IF Stage
    stage_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .PC_TYPE_NUM(4)
    ) u_if (
        .clk(clk),
        .reset(~rst_n),
        .stall(global_stall),
        .inst_w_en(1'b0), // Not writing instructions during runtime
        .inst_w_in('0),
        .pc_sel(pc_sel),
        .bra_addr(bra_addr),
        .jal_addr(jal_addr),
        .jar_addr(jalr_addr),
        .pc(if_pc),
        .pc4(if_pc4),
        .inst_word(if_inst),
        .inst_valid(if_valid),
        .inst_buffer_empty(inst_buffer_empty),
        .inst_buffer_full(inst_buffer_full)
    );
    
    // Connect instruction memory
    assign imem_addr = if_pc;
    assign imem_read = 1'b1;
    assign if_inst = imem_ready ? imem_read_data : 32'h00000013; // NOP if not ready
    
    // Pipeline ID Stage
    stage_id #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .REG_NUM(REG_NUM)
    ) u_id (
        .clk(clk),
        .reset(~rst_n),
        .interrupt(interrupt),
        .stall(global_stall),
        .w_en(wb_reg_write),
        .w_en_gpu(1'b0), // No GPU writes for now
        .has_imm(has_imm),
        .has_rs1(has_rs1),
        .has_rs2(has_rs2),
        .has_rs3(has_rs3),
        .imm_type(imm_type),
        .pc4(if_pc4),
        .pc(if_pc),
        .w_result(wb_data),
        .w_result_gpu('0),
        .ex_pro(ex_alu_result),
        .mm_pro(mem_alu_result),
        .mm_mem(mem_mem_data),
        .inst_word(if_inst),
        .load_rd(ex_rd),
        .is_load(ex_mem_read),
        .w_rd(wb_rd),
        .ex_wr_reg_en(ex_reg_write),
        .mm_wr_reg_en(mem_reg_write),
        .mm_is_load(mem_mem_to_reg),
        .ex_rd(ex_rd),
        .mm_rd(mem_rd),
        .w_rd_gpu('0),
        .rs_gpu('0),
        .is_equal(is_equal),
        .read_out_gpu(),
        .read_out_a(id_rs1_data),
        .read_out_b(id_rs2_data),
        .bra_addr(bra_addr),
        .jal_addr(jal_addr),
        .jar_addr(jalr_addr)
    );
    
    // Store ID stage outputs for EX stage
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            id_pc <= '0;
            id_pc4 <= '0;
            id_inst <= 32'h00000013; // NOP
            id_imm <= '0;
            id_valid <= 1'b0;
            ex_rs2_data <= '0;
        end else if (!global_stall) begin
            id_pc <= if_pc;
            id_pc4 <= if_pc4;
            id_inst <= if_inst;
            id_valid <= if_valid;
            ex_rs2_data <= id_rs2_data; // Pass through for memory writes
            
            // Generate immediate based on instruction type
            case (imm_type)
                2'b00: id_imm <= {{20{if_inst[31]}}, if_inst[31:20]}; // I-type
                2'b01: id_imm <= {{20{if_inst[31]}}, if_inst[31:25], if_inst[11:7]}; // S-type
                2'b10: id_imm <= {if_inst[31:12], 12'b0}; // U-type
                2'b11: id_imm <= {{19{if_inst[31]}}, if_inst[31], if_inst[7], if_inst[30:25], if_inst[11:8], 1'b0}; // B-type
            endcase
        end
    end
    
    // Pipeline EX Stage
    pl_stage_exe #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_ex (
        .ea(id_rs1_data),
        .eb(id_alu_src ? id_imm : id_rs2_data),
        .epc4(id_pc4),
        .ealuc(id_alu_op),
        .ecall(1'b0), // Handle in coprocessor
        .eal(ex_alu_result)
    );
    
    // Pipeline register EX->MEM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_rd <= '0;
            ex_mem_read <= '0;
            ex_mem_write <= '0;
            ex_reg_write <= '0;
            ex_valid <= '0;
            ex_funct3 <= '0;
        end else if (!global_stall) begin
            ex_rd <= id_rd;
            ex_mem_read <= id_mem_read;
            ex_mem_write <= id_mem_write;
            ex_reg_write <= id_reg_write;
            ex_valid <= id_valid;
            ex_funct3 <= id_funct3;
        end
    end
    
    // Pipeline MEM Stage
    mm_stage #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_mem (
        .clk(clk),
        .rst_n(rst_n),
        .ex_mem_alu_result(ex_alu_result),
        .ex_mem_write_data(ex_rs2_data),
        .ex_mem_rd(ex_rd),
        .ex_mem_mem_read(ex_mem_read),
        .ex_mem_mem_write(ex_mem_write),
        .ex_mem_reg_write(ex_reg_write),
        .mem_addr(dmem_addr),
        .mem_write_data(dmem_write_data),
        .mem_read(dmem_read),
        .mem_write(dmem_write),
        .mem_read_data(dmem_read_data),
        .mem_wb_mem_data(mem_mem_data),
        .mem_wb_alu_result(mem_alu_result),
        .mem_wb_rd(mem_rd),
        .mem_wb_reg_write(mem_reg_write)
    );
    
    // Determine if memory or ALU result
    assign mem_mem_to_reg = ex_mem_read;
    
    // Pipeline WB Stage
    pl_stage_wb #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_wb (
        .walu(mem_alu_result),
        .wmem(mem_mem_data),
        .wmem2reg(mem_mem_to_reg),
        .wdata(wb_data)
    );
    
    // WB control signals
    assign wb_rd = mem_rd;
    assign wb_reg_write = mem_reg_write;
    
    // Simple hazard detection
    always_comb begin
        // Load-use hazard
        load_use_hazard = ex_mem_read && 
                         ((ex_rd == id_rs1 && id_rs1 != 0) ||
                          (ex_rd == id_rs2 && id_rs2 != 0));
        
        // Control hazard
        control_hazard = branch_taken || jump_taken;
        
        // Stall logic
        stall = load_use_hazard;
        flush = control_hazard;
    end

endmodule