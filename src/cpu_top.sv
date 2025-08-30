// CPU Top Module with Coprocessor Integration
module cpu_top #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter REG_NUM = 32,
    parameter PC_TYPE_NUM = 4,
    parameter IMM_TYPE_NUM = 4
)(
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic                      interrupt,
    
    // Instruction Memory Interface
    output logic [ADDR_WIDTH-1:0]   imem_addr,
    input  logic [INST_WIDTH-1:0]   imem_read_data,
    output logic                     imem_read,
    input  logic                     imem_ready,
    
    // Data Memory Interface
    output logic [ADDR_WIDTH-1:0]   dmem_addr,
    output logic [DATA_WIDTH-1:0]   dmem_write_data,
    output logic                     dmem_read,
    output logic                     dmem_write,
    input  logic [DATA_WIDTH-1:0]   dmem_read_data,
    input  logic                     dmem_ready
);

    // Internal pipeline signals
    // IF stage signals
    logic [ADDR_WIDTH-1:0]   pc_current;
    logic [ADDR_WIDTH-1:0]   pc_plus4;
    logic [INST_WIDTH-1:0]   inst_fetched;
    logic                    inst_valid;
    logic                    if_stall;
    
    // ID stage signals  
    logic [INST_WIDTH-1:0]   inst_id_ex;
    logic                    inst_valid_id_ex;
    logic [DATA_WIDTH-1:0]   read_data_a_id_ex;
    logic [DATA_WIDTH-1:0]   read_data_b_id_ex;
    logic [ADDR_WIDTH-1:0]   pc_id_ex;
    logic [ADDR_WIDTH-1:0]   pc_if_id;
    logic [DATA_WIDTH-1:0]   id_reg_data1;
    logic [DATA_WIDTH-1:0]   id_reg_data2;
    logic                    is_equal;
    logic [ADDR_WIDTH-1:0]   bra_addr;
    logic [ADDR_WIDTH-1:0]   jal_addr;
    logic [ADDR_WIDTH-1:0]   jar_addr;
    
    // EX stage signals
    logic [DATA_WIDTH-1:0]   alu_result;
    logic [4:0]              alu_ctrl;
    logic                    ecall_signal;
    
    // MEM stage signals
    logic [DATA_WIDTH-1:0]   mem_read_data_out;
    logic [4:0]              mem_rd_addr;
    logic                    mem_reg_write;
    
    // WB stage signals
    logic [DATA_WIDTH-1:0]   wb_data;
    logic                    wb_mem2reg;
    
    // Control signals
    logic [1:0]              pc_sel;
    logic                    reg_write;
    logic                    mem_read;
    logic                    mem_write;
    logic                    mem_to_reg;
    
    // Pipeline control signals
    logic                    global_stall;
    logic                    id_stall_out;
    logic                    data_hazard_stall;
    
    // Coprocessor interface signals
    logic                    cp_valid;
    logic [INST_WIDTH-1:0]   cp_instruction;
    logic [DATA_WIDTH-1:0]   cp_data_in;
    logic [1:0]              cp_select;
    logic [DATA_WIDTH-1:0]   cp_data_out;
    logic                    cp_ready;
    logic                    cp_exception;
    logic                    cp_instruction_detected;
    logic                    cp_stall_request;
    logic                    cp_result_valid;
    logic                    cp_reg_write;
    logic [4:0]              cp_reg_addr;
    logic [DATA_WIDTH-1:0]   cp_reg_data;
    
    // Internal coprocessor signals between dispatcher and system
    logic                    cp_sys_valid;
    logic [INST_WIDTH-1:0]   cp_sys_instruction;
    logic [DATA_WIDTH-1:0]   cp_sys_data_in;
    logic [1:0]              cp_sys_select;
    logic [DATA_WIDTH-1:0]   cp_sys_data_out;
    logic                    cp_sys_ready;
    logic                    cp_sys_exception;
    
    // Dispatcher internal result signal
    logic [DATA_WIDTH-1:0]   cp_dispatcher_result;
    
    // System control signals
    logic                    trap_enable;
    logic [DATA_WIDTH-1:0]   trap_vector;
    logic [ADDR_WIDTH-1:0]   physical_addr_cp;
    logic                    translation_valid;
    logic                    page_fault;
    logic                    debug_halt_request;
    logic                    cache_flush;
    logic                    cache_invalidate;
    
    // Floating point register interface
    logic                    fp_reg_write;
    logic [4:0]              fp_reg_waddr;
    logic [DATA_WIDTH-1:0]   fp_reg_wdata;
    logic [4:0]              fp_reg_raddr1;
    logic [4:0]              fp_reg_raddr2;
    logic [DATA_WIDTH-1:0]   fp_reg_rdata1;
    logic [DATA_WIDTH-1:0]   fp_reg_rdata2;

    // Coprocessor Dispatcher
    dispatcher #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .CP_NUM(3)
    ) dispatcher_inst (
        .clk(clk),
        .rst_n(rst_n),
        .instruction(inst_id_ex),
        .inst_valid(inst_valid_id_ex),
        .rs1_data(read_data_a_id_ex),
        .rs2_data(read_data_b_id_ex),
        .pc(pc_id_ex),
        .pipeline_stall(global_stall),
        .cp_valid(cp_sys_valid),
        .cp_instruction(cp_sys_instruction),
        .cp_data_in(cp_sys_data_in),
        .cp_select(cp_sys_select),
        .cp_data_out(cp_sys_data_out),
        .cp_ready(cp_sys_ready),
        .cp_exception(cp_sys_exception),
        .cp_instruction_detected(cp_instruction_detected),
        .cp_stall_request(cp_stall_request),
        .cp_exception_out(/* unused */),
        .cp_result(cp_dispatcher_result),
        .cp_result_valid(cp_result_valid),
        .cp_reg_write(cp_reg_write),
        .cp_reg_addr(cp_reg_addr),
        .cp_reg_data(cp_reg_data)
    );
    
    // Coprocessor System
    coprocessor_system #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .CP_NUM(3)
    ) coprocessor_inst (
        .clk(clk),
        .rst_n(rst_n),
        .cp_valid(cp_sys_valid),
        .cp_instruction(cp_sys_instruction),
        .cp_data_in(cp_sys_data_in),
        .cp_select(cp_sys_select),
        .cp_data_out(cp_sys_data_out),
        .cp_ready(cp_sys_ready),
        .cp_exception(cp_sys_exception),
        .interrupt_pending(interrupt),
        .pc_current(pc_if_id),
        .virtual_addr(dmem_addr),
        .current_instruction(inst_id_ex),
        .mem_addr(dmem_addr),
        .mem_data(dmem_write_data),
        .mem_write(dmem_write),
        .inst_valid(inst_valid_id_ex),
        .trap_enable(trap_enable),
        .trap_vector(trap_vector),
        .physical_addr(physical_addr_cp),
        .translation_valid(translation_valid),
        .page_fault(page_fault),
        .debug_halt_request(debug_halt_request),
        .cache_flush(cache_flush),
        .cache_invalidate(cache_invalidate),
        .external_debug_req(1'b0),
        .page_table_base(64'h0),
        .vm_enable(1'b0),
        .fp_reg_write(fp_reg_write),
        .fp_reg_waddr(fp_reg_waddr),
        .fp_reg_wdata(fp_reg_wdata),
        .fp_reg_raddr1(fp_reg_raddr1),
        .fp_reg_raddr2(fp_reg_raddr2),
        .fp_reg_rdata1(fp_reg_rdata1),
        .fp_reg_rdata2(fp_reg_rdata2)
    );

    // Floating Point Register File (32 registers, 64-bit each)
    register_bank_cpu #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_NUM(32)
    ) fp_register_bank (
        .clk(clk),
        .reset(~rst_n),
        .write_addr(fp_reg_waddr),
        .data_in(fp_reg_wdata),
        .write_en(fp_reg_write),
        .read_addr_a(fp_reg_raddr1),
        .read_addr_b(fp_reg_raddr2),
        .data_out_a(fp_reg_rdata1),
        .data_out_b(fp_reg_rdata2)
    );
    
    // ===== PIPELINE STAGES =====
    
    // IF Stage - Instruction Fetch
    stage_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .PC_TYPE_NUM(PC_TYPE_NUM)
    ) if_stage (
        .clk(clk),
        .reset(~rst_n),
        .stall(global_stall),
        .inst_w_en(1'b0),           // No instruction memory writes for now
        .inst_w_in(32'h0),
        .pc_sel(pc_sel),
        .bra_addr(bra_addr),
        .jal_addr(jal_addr),
        .jar_addr(jar_addr),
        .pc(pc_current),
        .pc4(pc_plus4),
        .inst_word(inst_fetched),
        .inst_valid(inst_valid),
        .inst_buffer_empty(/* unused */),
        .inst_buffer_full(/* unused */)
    );
    
    // ID Stage - Instruction Decode
    stage_id #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .REG_NUM(REG_NUM)
    ) id_stage (
        .clk(clk),
        .reset(~rst_n),
        .interrupt(interrupt),
        .stall(global_stall),
        .w_en(reg_write),
        .w_en_gpu(cp_reg_write),
        .has_imm(1'b0),             // Control signal from control unit
        .has_rs1(1'b1),
        .has_rs2(1'b1),
        .has_rs3(1'b0),
        .imm_type(2'b00),
        .pc4(pc_plus4),
        .pc(pc_current),
        .w_result(wb_data),
        .w_result_gpu(cp_reg_data),
        .ex_pro(alu_result),        // Forwarding from EX stage
        .mm_pro(mem_read_data_out), // Forwarding from MEM stage
        .mm_mem(mem_read_data_out),
        .inst_word(inst_fetched),
        .load_rd(5'b0),             // From hazard detection
        .is_load(mem_read),
        .w_rd(mem_rd_addr),
        .w_rd_gpu(cp_reg_addr),
        .rs_gpu(5'b0),
        .ex_pro_rs(5'b0),           // Register addresses for forwarding
        .mm_pro_rs(5'b0),
        .mm_mem_rs(5'b0),
        .ex_wr_reg_en(reg_write),   // Bypass control signals
        .mm_wr_reg_en(mem_reg_write),
        .mm_is_load(mem_read),
        .ex_rd(inst_id_ex[11:7]),   // Destination register addresses
        .mm_rd(mem_rd_addr),
        .is_equal(is_equal),
        .read_out_gpu(/* unused */),
        .read_out_a(read_data_a_id_ex),
        .read_out_b(read_data_b_id_ex),
        .bra_addr(bra_addr),
        .jal_addr(jal_addr),
        .jar_addr(jar_addr)
    );
    
    // EX Stage - Execute (ALU)
    stage_ex #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ex_stage (
        .ea(read_data_a_id_ex),
        .eb(read_data_b_id_ex),
        .epc4(pc_plus4),
        .ealuc(alu_ctrl),
        .ecall(ecall_signal),
        .eal(alu_result)
    );
    
    // MEM Stage - Memory Access
    mm_stage #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) mem_stage (
        .clk(clk),
        .rst_n(rst_n),
        .ex_mem_alu_result(alu_result),
        .ex_mem_write_data(read_data_b_id_ex),
        .ex_mem_rd(inst_fetched[11:7]),     // rd field from instruction
        .ex_mem_mem_read(mem_read),
        .ex_mem_mem_write(mem_write),
        .ex_mem_reg_write(reg_write),
        .mem_addr(dmem_addr),
        .mem_write_data(dmem_write_data),
        .mem_read(dmem_read),
        .mem_write(dmem_write),
        .mem_wb_mem_data(mem_read_data_out),
        .mem_wb_alu_result(/* unused - use alu_result directly */),
        .mem_wb_rd(mem_rd_addr),
        .mem_wb_reg_write(mem_reg_write)
    );
    
    // WB Stage - Write Back
    stage_wb #(
        .DATA_WIDTH(DATA_WIDTH)
    ) wb_stage (
        .walu(alu_result),
        .wmem(mem_read_data_out),
        .wmem2reg(mem_to_reg),
        .wdata(wb_data)
    );
    
    // ===== CONTROL UNIT (PLACEHOLDER) =====
    // TODO: Add proper control unit to generate control signals
    assign alu_ctrl = 5'b00000;        // ADD operation by default
    assign ecall_signal = 1'b0;
    assign pc_sel = 2'b00;             // PC+4 by default
    assign reg_write = 1'b1;           // Enable register writes
    assign mem_read = 1'b0;            // No memory reads by default  
    assign mem_write = 1'b0;           // No memory writes by default
    assign mem_to_reg = 1'b0;          // Use ALU result by default
    
    // Pipeline control with coprocessor stalls
    assign global_stall = id_stall_out | data_hazard_stall | cp_stall_request;
    assign if_stall = global_stall;
    
    // Connect instruction memory interface
    assign imem_addr = pc_current;
    assign imem_read = 1'b1;
    
    // Pipeline register updates
    assign inst_id_ex = inst_fetched;
    assign inst_valid_id_ex = inst_valid;
    assign pc_id_ex = pc_current;
    assign pc_if_id = pc_current;
    
    // Connect coprocessor output
    assign cp_data_out = cp_sys_data_out;
    
    // Remaining pipeline control signals (TODO: connect to proper control unit)
    assign id_stall_out = 1'b0;
    assign data_hazard_stall = 1'b0;

endmodule
