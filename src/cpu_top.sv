module cpu_top #(
    parameter ADDR_WIDTH = 32,  // Changed to 32-bit for Zynq
    parameter DATA_WIDTH = 64,
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
    output logic [7:0]                dmem_byte_enable,  // Added for partial writes
    input  logic [DATA_WIDTH-1:0]    dmem_read_data,
    input  logic                      dmem_ready,
    
    // Coprocessor Interface (for external connection)
    output logic                      cp_instruction_detected,
    output logic [INST_WIDTH-1:0]     cp_instruction_out,
    input  logic                      cp_stall_external,
    
    // Debug/Status Interface
    output logic [ADDR_WIDTH-1:0]    debug_pc,
    output logic                      debug_stall,
    output logic [3:0]               debug_state
);
    
    // Pipeline Registers - Using 32-bit addresses
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
    logic [2:0]              id_ex_funct3;  // Added for memory operations
    
    logic [DATA_WIDTH-1:0]   ex_mem_alu_result;  // Keep 64-bit for data
    logic [DATA_WIDTH-1:0]   ex_mem_rs2_data;
    logic [4:0]              ex_mem_rd;
    logic                    ex_mem_mem_read;
    logic                    ex_mem_mem_write;
    logic                    ex_mem_reg_write;
    logic                    ex_mem_valid;
    logic [2:0]              ex_mem_funct3;  // For byte/halfword/word selection
    
    logic [DATA_WIDTH-1:0]   mem_wb_alu_result;
    logic [DATA_WIDTH-1:0]   mem_wb_mem_data;
    logic [4:0]              mem_wb_rd;
    logic                    mem_wb_reg_write;
    logic                    mem_wb_mem_to_reg;
    logic                    mem_wb_valid;
    
    // Write-back signals
    logic [DATA_WIDTH-1:0]   wb_data;
    
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
    
    // Hazard detection signals
    logic                    data_hazard;
    logic                    load_use_hazard;
    logic                    control_hazard;
    
    // Forwarding signals
    logic [1:0]              forward_a;
    logic [1:0]              forward_b;
    
    // Coprocessor signals
    logic                    cp_stall;
    logic [DATA_WIDTH-1:0]   cp_result;
    logic                    cp_result_valid;
    
    // Combined stall signal
    logic                    global_stall;
    assign global_stall = stall_if || stall_id || stall_ex || stall_mem || cp_stall || cp_stall_external;
    
    // Debug outputs
    assign debug_pc = if_id_pc;
    assign debug_stall = global_stall;
    assign debug_state = {flush_ex, flush_id, flush_if, global_stall};
    assign cp_instruction_out = if_id_inst;
    
    // Generate byte enables based on memory operation type
    always_comb begin
        dmem_byte_enable = 8'hFF;  // Default: full word
        if (ex_mem_mem_write || ex_mem_mem_read) begin
            case (ex_mem_funct3)
                3'b000: dmem_byte_enable = 8'h01;  // SB/LB
                3'b001: dmem_byte_enable = 8'h03;  // SH/LH
                3'b010: dmem_byte_enable = 8'h0F;  // SW/LW
                3'b011: dmem_byte_enable = 8'hFF;  // SD/LD
                default: dmem_byte_enable = 8'hFF;
            endcase
        end
    end
    
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
        .wb_data(wb_data),
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
    
    pipeline_mem #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_mem (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall_mem || global_stall),
        .ex_mem_alu_result(ex_mem_alu_result[ADDR_WIDTH-1:0]),  // Truncate to address width
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
    
    pipeline_wb #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_wb (
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_mem_data(mem_wb_mem_data),
        .mem_wb_mem_to_reg(mem_wb_mem_to_reg),
        .wb_data(wb_data)
    );
    
    hazard_detection_unit #(
        .REG_ADDR_WIDTH(5)
    ) u_hazard (
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_rd(id_ex_rd),
        .if_id_rs1(if_id_inst[19:15]),
        .if_id_rs2(if_id_inst[24:20]),
        .branch_taken(branch_taken),
        .jump_taken(jump_taken),
        .cp_stall(cp_stall || cp_stall_external),
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
    
    coprocessor_system #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INST_WIDTH(INST_WIDTH)
    ) u_coproc (
        .clk(clk),
        .rst_n(rst_n),
        .instruction(id_ex_valid ? if_id_inst : 32'h0),
        .rs1_data(id_ex_rs1_data),
        .rs2_data(id_ex_rs2_data),
        .pc(id_ex_pc),
        .interrupt(interrupt),
        .cp_result(cp_result),
        .cp_result_valid(cp_result_valid),
        .cp_stall(cp_stall),
        .cp_detected(cp_instruction_detected)
    );

endmodule

// Updated pipeline_id to include funct3 output
module pipeline_id #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter REG_NUM = 32
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    stall,
    input  logic                    flush,
    
    input  logic [ADDR_WIDTH-1:0]   if_id_pc,
    input  logic [ADDR_WIDTH-1:0]   if_id_pc4,
    input  logic [INST_WIDTH-1:0]   if_id_inst,
    input  logic                    if_id_valid,
    
    input  logic [DATA_WIDTH-1:0]   wb_data,
    input  logic [4:0]              wb_rd,
    input  logic                    wb_reg_write,
    
    output logic [ADDR_WIDTH-1:0]   id_ex_pc,
    output logic [DATA_WIDTH-1:0]   id_ex_rs1_data,
    output logic [DATA_WIDTH-1:0]   id_ex_rs2_data,
    output logic [DATA_WIDTH-1:0]   id_ex_imm,
    output logic [4:0]              id_ex_rd,
    output logic [4:0]              id_ex_rs1,
    output logic [4:0]              id_ex_rs2,
    output logic [4:0]              id_ex_alu_op,
    output logic                    id_ex_alu_src,
    output logic                    id_ex_mem_read,
    output logic                    id_ex_mem_write,
    output logic                    id_ex_reg_write,
    output logic                    id_ex_branch,
    output logic                    id_ex_jump,
    output logic                    id_ex_valid,
    output logic [2:0]              id_ex_funct3,
    
    output logic                    branch_taken,
    output logic [ADDR_WIDTH-1:0]   branch_target,
    output logic                    jump_taken,
    output logic [ADDR_WIDTH-1:0]   jump_target
);

    // Register file
    logic [DATA_WIDTH-1:0] registers [0:REG_NUM-1];
    logic [DATA_WIDTH-1:0] rs1_data, rs2_data;
    
    // Decode signals
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [4:0] rs1, rs2, rd;
    logic [DATA_WIDTH-1:0] imm;
    
    assign opcode = if_id_inst[6:0];
    assign rd = if_id_inst[11:7];
    assign funct3 = if_id_inst[14:12];
    assign rs1 = if_id_inst[19:15];
    assign rs2 = if_id_inst[24:20];
    assign funct7 = if_id_inst[31:25];
    
    // Register file
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < REG_NUM; i++)
                registers[i] <= '0;
        end else if (wb_reg_write && wb_rd != 0) begin
            registers[wb_rd] <= wb_data;
        end
    end
    
    assign rs1_data = (rs1 == 0) ? '0 : registers[rs1];
    assign rs2_data = (rs2 == 0) ? '0 : registers[rs2];
    
    // Immediate generation - adjusted for 32-bit addresses
    always_comb begin
        case (opcode)
            7'b0010011, 7'b0000011, 7'b1100111: // I-type
                imm = {{(DATA_WIDTH-12){if_id_inst[31]}}, if_id_inst[31:20]};
            7'b0100011: // S-type
                imm = {{(DATA_WIDTH-12){if_id_inst[31]}}, if_id_inst[31:25], if_id_inst[11:7]};
            7'b1100011: // B-type
                imm = {{(DATA_WIDTH-13){if_id_inst[31]}}, if_id_inst[31], if_id_inst[7], if_id_inst[30:25], if_id_inst[11:8], 1'b0};
            7'b0110111, 7'b0010111: // U-type
                imm = {{(DATA_WIDTH-32){if_id_inst[31]}}, if_id_inst[31:12], 12'b0};
            7'b1101111: // J-type
                imm = {{(DATA_WIDTH-21){if_id_inst[31]}}, if_id_inst[31], if_id_inst[19:12], if_id_inst[20], if_id_inst[30:21], 1'b0};
            default: 
                imm = '0;
        endcase
    end
    
    // Control signals
    logic reg_write, mem_read, mem_write, alu_src, branch, jump;
    logic [4:0] alu_op;
    
    always_comb begin
        // Default values
        reg_write = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        alu_src = 1'b0;
        alu_op = 5'b0;
        branch = 1'b0;
        jump = 1'b0;
        
        case (opcode)
            7'b0110011: begin // R-type
                reg_write = 1'b1;
                alu_op = {funct7[5], funct3, funct7[0]};
            end
            7'b0010011: begin // I-type ALU
                reg_write = 1'b1;
                alu_src = 1'b1;
                alu_op = {1'b0, funct3, 1'b0};
            end
            7'b0000011: begin // Load
                reg_write = 1'b1;
                mem_read = 1'b1;
                alu_src = 1'b1;
                alu_op = 5'b00000; // ADD
            end
            7'b0100011: begin // Store
                mem_write = 1'b1;
                alu_src = 1'b1;
                alu_op = 5'b00000; // ADD
            end
            7'b1100011: begin // Branch
                branch = 1'b1;
                alu_op = {2'b01, funct3};
            end
            7'b1101111: begin // JAL
                reg_write = 1'b1;
                jump = 1'b1;
            end
            7'b1100111: begin // JALR
                reg_write = 1'b1;
                jump = 1'b1;
                alu_src = 1'b1;
            end
            7'b0110111, 7'b0010111: begin // LUI, AUIPC
                reg_write = 1'b1;
                alu_src = 1'b1;
                alu_op = (opcode == 7'b0010111) ? 5'b00001 : 5'b00010;
            end
        endcase
    end
    
    // Branch logic
    always_comb begin
        branch_taken = 1'b0;
        branch_target = if_id_pc + imm[ADDR_WIDTH-1:0];
        
        if (branch && if_id_valid) begin
            case (funct3)
                3'b000: branch_taken = (rs1_data == rs2_data); // BEQ
                3'b001: branch_taken = (rs1_data != rs2_data); // BNE
                3'b100: branch_taken = ($signed(rs1_data) < $signed(rs2_data)); // BLT
                3'b101: branch_taken = ($signed(rs1_data) >= $signed(rs2_data)); // BGE
                3'b110: branch_taken = (rs1_data < rs2_data); // BLTU
                3'b111: branch_taken = (rs1_data >= rs2_data); // BGEU
                default: branch_taken = 1'b0;
            endcase
        end
    end
    
    // Jump logic
    always_comb begin
        jump_taken = jump && if_id_valid;
        if (opcode == 7'b1100111) // JALR
            jump_target = (rs1_data + imm) & ~32'h1;  // 32-bit address
        else // JAL
            jump_target = if_id_pc + imm[ADDR_WIDTH-1:0];
    end
    
    // Pipeline register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            id_ex_pc <= '0;
            id_ex_rs1_data <= '0;
            id_ex_rs2_data <= '0;
            id_ex_imm <= '0;
            id_ex_rd <= '0;
            id_ex_rs1 <= '0;
            id_ex_rs2 <= '0;
            id_ex_alu_op <= '0;
            id_ex_alu_src <= '0;
            id_ex_mem_read <= '0;
            id_ex_mem_write <= '0;
            id_ex_reg_write <= '0;
            id_ex_branch <= '0;
            id_ex_jump <= '0;
            id_ex_valid <= '0;
            id_ex_funct3 <= '0;
        end else if (!stall) begin
            id_ex_pc <= if_id_pc;
            id_ex_rs1_data <= rs1_data;
            id_ex_rs2_data <= rs2_data;
            id_ex_imm <= imm;
            id_ex_rd <= rd;
            id_ex_rs1 <= rs1;
            id_ex_rs2 <= rs2;
            id_ex_alu_op <= alu_op;
            id_ex_alu_src <= alu_src;
            id_ex_mem_read <= mem_read;
            id_ex_mem_write <= mem_write;
            id_ex_reg_write <= reg_write;
            id_ex_branch <= branch;
            id_ex_jump <= jump;
            id_ex_valid <= if_id_valid && !branch_taken && !jump_taken;
            id_ex_funct3 <= funct3;
        end
    end

endmodule

// Updated pipeline_ex to pass through funct3
module pipeline_ex #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    stall,
    input  logic                    flush,
    
    input  logic [ADDR_WIDTH-1:0]   id_ex_pc,
    input  logic [DATA_WIDTH-1:0]   id_ex_rs1_data,
    input  logic [DATA_WIDTH-1:0]   id_ex_rs2_data,
    input  logic [DATA_WIDTH-1:0]   id_ex_imm,
    input  logic [4:0]              id_ex_rd,
    input  logic [4:0]              id_ex_rs1,
    input  logic [4:0]              id_ex_rs2,
    input  logic [4:0]              id_ex_alu_op,
    input  logic                    id_ex_alu_src,
    input  logic                    id_ex_mem_read,
    input  logic                    id_ex_mem_write,
    input  logic                    id_ex_reg_write,
    input  logic                    id_ex_valid,
    input  logic [2:0]              id_ex_funct3,
    
    input  logic [1:0]              forward_a,
    input  logic [1:0]              forward_b,
    input  logic [DATA_WIDTH-1:0]   ex_mem_alu_result,
    input  logic [DATA_WIDTH-1:0]   mem_wb_alu_result,
    input  logic [DATA_WIDTH-1:0]   mem_wb_mem_data,
    
    output logic [DATA_WIDTH-1:0]   ex_mem_alu_result_out,
    output logic [DATA_WIDTH-1:0]   ex_mem_rs2_data,
    output logic [4:0]              ex_mem_rd,
    output logic                    ex_mem_mem_read,
    output logic                    ex_mem_mem_write,
    output logic                    ex_mem_reg_write,
    output logic                    ex_mem_valid,
    output logic [2:0]              ex_mem_funct3
);

    logic [DATA_WIDTH-1:0] alu_a, alu_b, alu_result;
    
    // Forwarding muxes
    always_comb begin
        case (forward_a)
            2'b00: alu_a = id_ex_rs1_data;
            2'b01: alu_a = mem_wb_alu_result;
            2'b10: alu_a = ex_mem_alu_result;
            default: alu_a = id_ex_rs1_data;
        endcase
        
        case (forward_b)
            2'b00: alu_b = id_ex_alu_src ? id_ex_imm : id_ex_rs2_data;
            2'b01: alu_b = id_ex_alu_src ? id_ex_imm : mem_wb_alu_result;
            2'b10: alu_b = id_ex_alu_src ? id_ex_imm : ex_mem_alu_result;
            default: alu_b = id_ex_alu_src ? id_ex_imm : id_ex_rs2_data;
        endcase
    end
    
    // ALU
    always_comb begin
        case (id_ex_alu_op)
            5'b00000: alu_result = alu_a + alu_b; // ADD
            5'b00001: alu_result = alu_a - alu_b; // SUB
            5'b00010: alu_result = alu_a & alu_b; // AND
            5'b00011: alu_result = alu_a | alu_b; // OR
            5'b00100: alu_result = alu_a ^ alu_b; // XOR
            5'b00101: alu_result = alu_a << alu_b[5:0]; // SLL
            5'b00110: alu_result = alu_a >> alu_b[5:0]; // SRL
            5'b00111: alu_result = $signed(alu_a) >>> alu_b[5:0]; // SRA
            5'b01000: alu_result = ($signed(alu_a) < $signed(alu_b)) ? 64'h1 : 64'h0; // SLT
            5'b01001: alu_result = (alu_a < alu_b) ? 64'h1 : 64'h0; // SLTU
            default: alu_result = alu_a + alu_b;
        endcase
    end
    
    // Pipeline register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            ex_mem_alu_result_out <= '0;
            ex_mem_rs2_data <= '0;
            ex_mem_rd <= '0;
            ex_mem_mem_read <= '0;
            ex_mem_mem_write <= '0;
            ex_mem_reg_write <= '0;
            ex_mem_valid <= '0;
            ex_mem_funct3 <= '0;
        end else if (!stall) begin
            ex_mem_alu_result_out <= alu_result;
            ex_mem_rs2_data <= id_ex_rs2_data;
            ex_mem_rd <= id_ex_rd;
            ex_mem_mem_read <= id_ex_mem_read;
            ex_mem_mem_write <= id_ex_mem_write;
            ex_mem_reg_write <= id_ex_reg_write;
            ex_mem_valid <= id_ex_valid;
            ex_mem_funct3 <= id_ex_funct3;
        end
    end

endmodule

// Updated pipeline_mem with correct address width
module pipeline_mem #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    stall,
    
    input  logic [ADDR_WIDTH-1:0]   ex_mem_alu_result,  // Now 32-bit address
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
            mem_wb_alu_result <= {32'b0, ex_mem_alu_result};  // Zero-extend address to 64-bit
            mem_wb_mem_data <= dmem_read_data;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_reg_write <= ex_mem_reg_write;
            mem_wb_mem_to_reg <= ex_mem_mem_read;
            mem_wb_valid <= ex_mem_valid;
        end
    end

endmodule