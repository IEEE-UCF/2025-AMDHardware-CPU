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
    input  logic                     dmem_ready,
    
    // GPU Interface
    output logic                     gpu_op_valid,
    output logic [7:0]               gpu_opcode,
    output logic [DATA_WIDTH-1:0]   gpu_operand_a,
    output logic [DATA_WIDTH-1:0]   gpu_operand_b,
    output logic [DATA_WIDTH-1:0]   gpu_operand_c,
    output logic [ADDR_WIDTH-1:0]   gpu_result_addr,
    output logic [4:0]               gpu_result_reg,
    input  logic                     gpu_ready,
    input  logic                     gpu_result_valid,
    input  logic [DATA_WIDTH-1:0]   gpu_result_data,
    input  logic                     gpu_exception
);

    // Internal pipeline signals
    logic [INST_WIDTH-1:0]   inst_id_ex;
    logic                    inst_valid_id_ex;
    logic [DATA_WIDTH-1:0]   read_data_a_id_ex;
    logic [DATA_WIDTH-1:0]   read_data_b_id_ex;
    logic [ADDR_WIDTH-1:0]   pc_id_ex;
    logic [ADDR_WIDTH-1:0]   pc_if_id;
    logic [DATA_WIDTH-1:0]   id_reg_data1;
    logic [DATA_WIDTH-1:0]   id_reg_data2;
    
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
    logic [DATA_WIDTH-1:0]   cp_dispatcher_result;
    logic                    cp_result_valid;
    logic                    cp_reg_write;
    logic [4:0]              cp_reg_addr;
    logic [DATA_WIDTH-1:0]   cp_reg_data;
    
    // GPU interface signals
    logic                    gpu_queue_full;
    logic                    gpu_queue_empty;
    logic [4:0]              gpu_queue_count;
    logic                    gpu_dequeue_valid;
    logic [7:0]              gpu_op_out;
    logic [DATA_WIDTH-1:0]   gpu_op_a_out;
    logic [DATA_WIDTH-1:0]   gpu_op_b_out;
    logic [DATA_WIDTH-1:0]   gpu_op_c_out;
    logic [ADDR_WIDTH-1:0]   gpu_res_addr_out;
    logic [4:0]              gpu_res_reg_out;
    
    // GPU result buffer signals
    logic                    gpu_buffer_full;
    logic                    gpu_buffer_empty;
    logic [3:0]              gpu_buffer_count;
    logic                    gpu_result_ready;
    logic [DATA_WIDTH-1:0]   gpu_result_data_buf;
    logic [ADDR_WIDTH-1:0]   gpu_result_addr_buf;
    logic [4:0]              gpu_result_reg_buf;
    logic                    gpu_result_exception_buf;
    logic                    gpu_result_ack;
    
    // GPU writeback signals
    logic                    gpu_reg_write_en;
    logic [4:0]              gpu_reg_write_addr;
    logic [DATA_WIDTH-1:0]   gpu_reg_write_data;
    logic                    gpu_mem_write_en;
    logic [ADDR_WIDTH-1:0]   gpu_mem_write_addr;
    logic [DATA_WIDTH-1:0]   gpu_mem_write_data;
    logic [7:0]              gpu_mem_write_strb;
    logic                    gpu_wb_exception;
    logic [ADDR_WIDTH-1:0]   gpu_exception_pc;
    logic                    gpu_wb_stall_request;
    logic                    gpu_wb_busy;
    
    // Internal coprocessor signals between dispatcher and system
    logic                    cp_sys_valid;
    logic [INST_WIDTH-1:0]   cp_sys_instruction;
    logic [DATA_WIDTH-1:0]   cp_sys_data_in;
    logic [1:0]              cp_sys_select;
    logic [DATA_WIDTH-1:0]   cp_sys_data_out;
    logic                    cp_sys_ready;
    logic                    cp_sys_exception;
    
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
    ) coprocessor_sys (
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
    
    // =================
    // GPU Pipeline Modules
    // =================
    
    // GPU Operation Queue
    gpu_op_queue #(
        .QUEUE_DEPTH(16),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .OP_WIDTH(8)
    ) gpu_op_queue_inst (
        .clk(clk),
        .rst_n(rst_n),
        
        // CPU interface - enqueue operations
        .enqueue_valid(gpu_op_valid),
        .gpu_opcode(gpu_opcode),
        .operand_a(gpu_operand_a),
        .operand_b(gpu_operand_b),
        .operand_c(gpu_operand_c),
        .result_addr(gpu_result_addr),
        .result_reg(gpu_result_reg),
        .queue_full(gpu_queue_full),
        
        // GPU interface - dequeue operations
        .dequeue_valid(gpu_dequeue_valid),
        .gpu_op_out(gpu_op_out),
        .op_a_out(gpu_op_a_out),
        .op_b_out(gpu_op_b_out),
        .op_c_out(gpu_op_c_out),
        .res_addr_out(gpu_res_addr_out),
        .res_reg_out(gpu_res_reg_out),
        .gpu_ready(gpu_ready),
        
        // Status
        .queue_count(gpu_queue_count),
        .queue_empty(gpu_queue_empty)
    );
    
    // GPU Result Buffer
    gpu_result_buffer #(
        .BUFFER_DEPTH(8),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) gpu_result_buffer_inst (
        .clk(clk),
        .rst_n(rst_n),
        
        // GPU interface - store results
        .gpu_result_valid(gpu_result_valid),
        .gpu_result_data(gpu_result_data),
        .gpu_result_addr(gpu_res_addr_out), // Use queued address
        .gpu_result_reg(gpu_res_reg_out),   // Use queued register
        .gpu_exception(gpu_exception),
        .buffer_full(gpu_buffer_full),
        
        // CPU writeback interface - retrieve results
        .result_ready(gpu_result_ready),
        .result_data(gpu_result_data_buf),
        .result_addr(gpu_result_addr_buf),
        .result_reg(gpu_result_reg_buf),
        .result_exception(gpu_result_exception_buf),
        .result_ack(gpu_result_ack),
        
        // Status
        .buffer_count(gpu_buffer_count),
        .buffer_empty(gpu_buffer_empty)
    );
    
    // GPU Result Writeback
    gpu_result_wb #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .REG_NUM(REG_NUM)
    ) gpu_result_wb_inst (
        .clk(clk),
        .rst_n(rst_n),
        
        // From GPU result buffer
        .result_ready(gpu_result_ready),
        .result_data(gpu_result_data_buf),
        .result_addr(gpu_result_addr_buf),
        .result_reg(gpu_result_reg_buf),
        .result_exception(gpu_result_exception_buf),
        .result_ack(gpu_result_ack),
        
        // To CPU register file
        .reg_write_en(gpu_reg_write_en),
        .reg_write_addr(gpu_reg_write_addr),
        .reg_write_data(gpu_reg_write_data),
        
        // To memory interface (for memory writes)
        .mem_write_en(gpu_mem_write_en),
        .mem_write_addr(gpu_mem_write_addr),
        .mem_write_data(gpu_mem_write_data),
        .mem_write_strb(gpu_mem_write_strb),
        .mem_write_ready(dmem_ready),
        
        // Exception handling
        .gpu_wb_exception(gpu_wb_exception),
        .exception_pc(gpu_exception_pc),
        
        // Pipeline control
        .pipeline_stall(global_stall),
        .wb_stall_request(gpu_wb_stall_request),
        
        // Status
        .wb_busy(gpu_wb_busy)
    );
    
    // =================
    // Pipeline Control
    // =================
    
    // Pipeline control with coprocessor and GPU stalls
    assign global_stall = id_stall_out | data_hazard_stall | cp_stall_request | gpu_wb_stall_request;
    
    // Connect coprocessor output
    assign cp_data_out = cp_sys_data_out;
    
    // Temporary assignments for missing pipeline signals
    // These should be connected to actual pipeline stage outputs
    assign inst_id_ex = 32'h0;
    assign inst_valid_id_ex = 1'b0;
    assign read_data_a_id_ex = 64'h0;
    assign read_data_b_id_ex = 64'h0;
    assign pc_id_ex = 64'h0;
    assign pc_if_id = 64'h0;
    assign id_reg_data1 = 64'h0;
    assign id_reg_data2 = 64'h0;
    assign id_stall_out = 1'b0;
    assign data_hazard_stall = 1'b0;
    
    // Basic memory interface assignments
    assign imem_addr = 64'h0;
    assign imem_read = 1'b1;
    assign dmem_addr = 64'h0;
    assign dmem_write_data = 64'h0;
    assign dmem_read = 1'b0;
    assign dmem_write = 1'b0;
    
    // GPU interface stub assignments (for testing without actual GPU dispatch logic)
    assign gpu_op_valid = 1'b0;
    assign gpu_opcode = 8'h0;
    assign gpu_operand_a = 64'h0;
    assign gpu_operand_b = 64'h0;
    assign gpu_operand_c = 64'h0;
    assign gpu_result_addr = 64'h0;
    assign gpu_result_reg = 5'h0;

endmodule
