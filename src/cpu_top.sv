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
    
    // Pipeline Registers - All 32-bit addresses
    logic [ADDR_WIDTH-1:0]   if_id_pc;
    logic [ADDR_WIDTH-1:0]   if_id_pc4;
    logic [INST_WIDTH-1:0]   if_id_inst;
    logic                    if_id_valid;
    
    logic [ADDR_WIDTH-1:0]   id_ex_pc;
    logic [DATA_WIDTH-1:0]   id_ex_rs1_data;
    logic [DATA_WIDTH-1:0]   id_ex_rs2_data;
    logic [DATA_WIDTH-1:0]   id_ex_imm;
    logic [4:0]              id_ex_rd;
    logic [4:0]              id_ex_rs1;
    logic [4:0]              id_ex_rs2;
    logic [4:0]              id_ex_alu_op;
    logic                    id_ex_alu_src;
    logic                    id_ex_mem_read;
    logic                    id_ex_mem_write;
    logic                    id_ex_reg_write;
    logic                    id_ex_branch;
    logic                    id_ex_jump;
    logic                    id_ex_valid;
    logic [2:0]              id_ex_funct3;
    
    logic [DATA_WIDTH-1:0]   ex_mem_alu_result;
    logic [DATA_WIDTH-1:0]   ex_mem_rs2_data;
    logic [4:0]              ex_mem_rd;
    logic                    ex_mem_mem_read;
    logic                    ex_mem_mem_write;
    logic                    ex_mem_reg_write;
    logic                    ex_mem_valid;
    logic [2:0]              ex_mem_funct3;
    
    logic [DATA_WIDTH-1:0]   mem_wb_alu_result;
    logic [DATA_WIDTH-1:0]   mem_wb_mem_data;
    logic [4:0]              mem_wb_rd;
    logic                    mem_wb_reg_write;
    logic                    mem_wb_mem_to_reg;
    logic                    mem_wb_valid;
    
    // Control signals
    logic                    stall_if;
    logic                    stall_id;
    logic                    stall_ex;
    logic                    stall_mem;
    logic                    flush_if;
    logic                    flush_id;
    logic                    flush_ex;
    
    // Branch/Jump signals
    logic                    branch_taken;
    logic [ADDR_WIDTH-1:0]   branch_target;
    logic                    jump_taken;
    logic [ADDR_WIDTH-1:0]   jump_target;
    
    // Hazard detection
    logic                    data_hazard;
    logic                    load_use_hazard;
    logic                    control_hazard;
    
    // Forwarding signals
    logic [1:0]              forward_a;
    logic [1:0]              forward_b;
    
    // Combined stall signal
    logic                    global_stall;
    assign global_stall = stall_if || stall_id || stall_ex || stall_mem || 
                         !imem_ready || !dmem_ready || cp_stall_external;
    
    // Debug outputs
    assign debug_pc = if_id_pc;
    assign debug_stall = global_stall;
    assign debug_state = {flush_ex, flush_id, flush_if, global_stall};
    assign cp_instruction_out = if_id_inst;
    
    // Simple coprocessor detection
    always_comb begin
        cp_instruction_detected = 1'b0;
        if (if_id_valid) begin
            case (if_id_inst[6:0])
                7'b1110011, // System
                7'b1010011, // FP
                7'b0001011, // Custom-0
                7'b0101011: // Custom-1
                    cp_instruction_detected = 1'b1;
                default:
                    cp_instruction_detected = 1'b0;
            endcase
        end
    end
    
    // Generate byte enables based on memory operation type
    always_comb begin
        dmem_byte_enable = 4'hF;  // Default: full word
        if (ex_mem_mem_write || ex_mem_mem_read) begin
            case (ex_mem_funct3)
                3'b000: dmem_byte_enable = 4'h1;  // SB/LB
                3'b001: dmem_byte_enable = 4'h3;  // SH/LH
                3'b010: dmem_byte_enable = 4'hF;  // SW/LW
                default: dmem_byte_enable = 4'hF;
            endcase
        end
    end
    
    // Pipeline IF Stage
    pipeline_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .INST_WIDTH(INST_WIDTH)
    ) u_if (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall_if || global_stall),
        .flush(flush_if),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .jump_taken(jump_taken),
        .jump_target(jump_target),
        .imem_addr(imem_addr),
        .imem_read_data(imem_read_data),
        .imem_read(imem_read),
        .imem_ready(imem_ready),
        .if_id_pc(if_id_pc),
        .if_id_pc4(if_id_pc4),
        .if_id_inst(if_id_inst),
        .if_id_valid(if_id_valid)
    );
    
    // Pipeline ID Stage
    pipeline_id #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .REG_NUM(REG_NUM)
    ) u_id (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall_id || global_stall),
        .flush(flush_id),
        .if_id_pc(if_id_pc),
        .if_id_pc4(if_id_pc4),
        .if_id_inst(if_id_inst),
        .if_id_valid(if_id_valid),
        .wb_data(mem_wb_mem_to_reg ? mem_wb_mem_data : mem_wb_alu_result),
        .wb_rd(mem_wb_rd),
        .wb_reg_write(mem_wb_reg_write),
        .id_ex_pc(id_ex_pc),
        .id_ex_rs1_data(id_ex_rs1_data),
        .id_ex_rs2_data(id_ex_rs2_data),
        .id_ex_imm(id_ex_imm),
        .id_ex_rd(id_ex_rd),
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .id_ex_alu_op(id_ex_alu_op),
        .id_ex_alu_src(id_ex_alu_src),
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_mem_write(id_ex_mem_write),
        .id_ex_reg_write(id_ex_reg_write),
        .id_ex_branch(id_ex_branch),
        .id_ex_jump(id_ex_jump),
        .id_ex_valid(id_ex_valid),
        .id_ex_funct3(id_ex_funct3),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .jump_taken(jump_taken),
        .jump_target(jump_target)
    );
    
    // Pipeline EX Stage
    pipeline_ex #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_ex (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall_ex || global_stall),
        .flush(flush_ex),
        .id_ex_pc(id_ex_pc),
        .id_ex_rs1_data(id_ex_rs1_data),
        .id_ex_rs2_data(id_ex_rs2_data),
        .id_ex_imm(id_ex_imm),
        .id_ex_rd(id_ex_rd),
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .id_ex_alu_op(id_ex_alu_op),
        .id_ex_alu_src(id_ex_alu_src),
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_mem_write(id_ex_mem_write),
        .id_ex_reg_write(id_ex_reg_write),
        .id_ex_valid(id_ex_valid),
        .id_ex_funct3(id_ex_funct3),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .ex_mem_alu_result(ex_mem_alu_result),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_mem_data(mem_wb_mem_data),
        .ex_mem_alu_result_out(ex_mem_alu_result),
        .ex_mem_rs2_data(ex_mem_rs2_data),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_mem_read(ex_mem_mem_read),
        .ex_mem_mem_write(ex_mem_mem_write),
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_valid(ex_mem_valid),
        .ex_mem_funct3(ex_mem_funct3)
    );
    
    // Pipeline MEM Stage
    pipeline_mem #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_mem (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall_mem || global_stall),
        .ex_mem_alu_result(ex_mem_alu_result),
        .ex_mem_rs2_data(ex_mem_rs2_data),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_mem_read(ex_mem_mem_read),
        .ex_mem_mem_write(ex_mem_mem_write),
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_valid(ex_mem_valid),
        .dmem_addr(dmem_addr),
        .dmem_write_data(dmem_write_data),
        .dmem_read(dmem_read),
        .dmem_write(dmem_write),
        .dmem_read_data(dmem_read_data),
        .dmem_ready(dmem_ready),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_mem_data(mem_wb_mem_data),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_mem_to_reg(mem_wb_mem_to_reg),
        .mem_wb_valid(mem_wb_valid)
    );
    
    // Hazard Detection Unit
    hazard_detection_unit #(
        .REG_ADDR_WIDTH(5)
    ) u_hazard (
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_rd(id_ex_rd),
        .if_id_rs1(if_id_inst[19:15]),
        .if_id_rs2(if_id_inst[24:20]),
        .branch_taken(branch_taken),
        .jump_taken(jump_taken),
        .cp_stall(cp_instruction_detected && cp_stall_external),
        .stall_if(stall_if),
        .stall_id(stall_id),
        .stall_ex(stall_ex),
        .stall_mem(stall_mem),
        .flush_if(flush_if),
        .flush_id(flush_id),
        .flush_ex(flush_ex),
        .load_use_hazard(load_use_hazard),
        .control_hazard(control_hazard)
    );
    
    // Forwarding Unit
    forwarding_unit #(
        .REG_ADDR_WIDTH(5)
    ) u_forward (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

endmodule

// Fixed Pipeline IF Stage
module pipeline_if #(
    parameter ADDR_WIDTH = 32,
    parameter INST_WIDTH = 32
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    stall,
    input  logic                    flush,
    input  logic                    branch_taken,
    input  logic [ADDR_WIDTH-1:0]   branch_target,
    input  logic                    jump_taken,
    input  logic [ADDR_WIDTH-1:0]   jump_target,
    
    output logic [ADDR_WIDTH-1:0]   imem_addr,
    input  logic [INST_WIDTH-1:0]   imem_read_data,
    output logic                    imem_read,
    input  logic                    imem_ready,
    
    output logic [ADDR_WIDTH-1:0]   if_id_pc,
    output logic [ADDR_WIDTH-1:0]   if_id_pc4,
    output logic [INST_WIDTH-1:0]   if_id_inst,
    output logic                    if_id_valid
);

    logic [ADDR_WIDTH-1:0] pc_reg;
    logic [ADDR_WIDTH-1:0] pc_next;
    
    // PC update logic
    always_comb begin
        if (jump_taken)
            pc_next = jump_target;
        else if (branch_taken)
            pc_next = branch_target;
        else if (!stall)
            pc_next = pc_reg + 4;
        else
            pc_next = pc_reg;
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_reg <= 32'h0;
        end else if (!stall || branch_taken || jump_taken) begin
            pc_reg <= pc_next;
        end
    end
    
    // Memory interface
    assign imem_addr = pc_reg;
    assign imem_read = 1'b1;
    
    // Pipeline register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            if_id_pc <= '0;
            if_id_pc4 <= '0;
            if_id_inst <= 32'h00000013; // NOP
            if_id_valid <= 1'b0;
        end else if (!stall) begin
            if_id_pc <= pc_reg;
            if_id_pc4 <= pc_reg + 4;
            if_id_inst <= imem_ready ? imem_read_data : 32'h00000013;
            if_id_valid <= imem_ready;
        end
    end

endmodule

// Fixed Pipeline MEM Stage
module pipeline_mem #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    stall,
    
    input  logic [DATA_WIDTH-1:0]   ex_mem_alu_result,
    input  logic [DATA_WIDTH-1:0]   ex_mem_rs2_data,
    input  logic [4:0]              ex_mem_rd,
    input  logic                    ex_mem_mem_read,
    input  logic                    ex_mem_mem_write,
    input  logic                    ex_mem_reg_write,
    input  logic                    ex_mem_valid,
    
    output logic [ADDR_WIDTH-1:0]   dmem_addr,
    output logic [DATA_WIDTH-1:0]   dmem_write_data,
    output logic                    dmem_read,
    output logic                    dmem_write,
    input  logic [DATA_WIDTH-1:0]   dmem_read_data,
    input  logic                    dmem_ready,
    
    output logic [DATA_WIDTH-1:0]   mem_wb_alu_result,
    output logic [DATA_WIDTH-1:0]   mem_wb_mem_data,
    output logic [4:0]              mem_wb_rd,
    output logic                    mem_wb_reg_write,
    output logic                    mem_wb_mem_to_reg,
    output logic                    mem_wb_valid
);

    // Memory interface
    assign dmem_addr = ex_mem_alu_result;
    assign dmem_write_data = ex_mem_rs2_data;
    assign dmem_read = ex_mem_mem_read && ex_mem_valid;
    assign dmem_write = ex_mem_mem_write && ex_mem_valid;
    
    // Pipeline register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_wb_alu_result <= '0;
            mem_wb_mem_data <= '0;
            mem_wb_rd <= '0;
            mem_wb_reg_write <= '0;
            mem_wb_mem_to_reg <= '0;
            mem_wb_valid <= '0;
        end else if (!stall) begin
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_mem_data <= dmem_read_data;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_reg_write <= ex_mem_reg_write;
            mem_wb_mem_to_reg <= ex_mem_mem_read;
            mem_wb_valid <= ex_mem_valid;
        end
    end

endmodule

// Add missing modules
module hazard_detection_unit #(
    parameter REG_ADDR_WIDTH = 5
)(
    input  logic                        id_ex_mem_read,
    input  logic [REG_ADDR_WIDTH-1:0]  id_ex_rd,
    input  logic [REG_ADDR_WIDTH-1:0]  if_id_rs1,
    input  logic [REG_ADDR_WIDTH-1:0]  if_id_rs2,
    input  logic                        branch_taken,
    input  logic                        jump_taken,
    input  logic                        cp_stall,
    
    output logic                        stall_if,
    output logic                        stall_id,
    output logic                        stall_ex,
    output logic                        stall_mem,
    output logic                        flush_if,
    output logic                        flush_id,
    output logic                        flush_ex,
    output logic                        load_use_hazard,
    output logic                        control_hazard
);

    // Load-use hazard detection
    always_comb begin
        load_use_hazard = id_ex_mem_read && 
                         ((id_ex_rd == if_id_rs1 && if_id_rs1 != 0) ||
                          (id_ex_rd == if_id_rs2 && if_id_rs2 != 0));
        
        control_hazard = branch_taken || jump_taken;
        
        // Stall logic
        stall_if = load_use_hazard || cp_stall;
        stall_id = load_use_hazard || cp_stall;
        stall_ex = cp_stall;
        stall_mem = cp_stall;
        
        // Flush logic
        flush_if = control_hazard;
        flush_id = control_hazard;
        flush_ex = control_hazard || load_use_hazard;
    end

endmodule

module forwarding_unit #(
    parameter REG_ADDR_WIDTH = 5
)(
    input  logic [REG_ADDR_WIDTH-1:0]  id_ex_rs1,
    input  logic [REG_ADDR_WIDTH-1:0]  id_ex_rs2,
    input  logic [REG_ADDR_WIDTH-1:0]  ex_mem_rd,
    input  logic                        ex_mem_reg_write,
    input  logic [REG_ADDR_WIDTH-1:0]  mem_wb_rd,
    input  logic                        mem_wb_reg_write,
    
    output logic [1:0]                  forward_a,
    output logic [1:0]                  forward_b
);

    always_comb begin
        // Forward A logic
        if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1)
            forward_a = 2'b10; // Forward from EX/MEM
        else if (mem_wb_reg_write && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs1)
            forward_a = 2'b01; // Forward from MEM/WB
        else
            forward_a = 2'b00; // No forwarding
        
        // Forward B logic
        if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2)
            forward_b = 2'b10; // Forward from EX/MEM
        else if (mem_wb_reg_write && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs2)
            forward_b = 2'b01; // Forward from MEM/WB
        else
            forward_b = 2'b00; // No forwarding
    end

endmodule