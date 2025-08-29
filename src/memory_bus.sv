// Memory Bus Module - Connects CPU to Memory Subsystem with Burst Support
module memory_bus #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter BURST_SIZE = 4,
    parameter BUFFER_DEPTH = 8,
    parameter CACHE_LINE_SIZE = 64  // bytes
)(
    // Clock and reset
    input  logic                    clk,
    input  logic                    rst_n,
    
    // CPU Instruction Interface
    input  logic [ADDR_WIDTH-1:0]  cpu_imem_addr,
    input  logic                   cpu_imem_read,
    output logic [INST_WIDTH-1:0] cpu_imem_read_data,
    output logic                   cpu_imem_ready,
    
    // CPU Data Interface  
    input  logic [ADDR_WIDTH-1:0]  cpu_dmem_addr,
    input  logic [DATA_WIDTH-1:0]  cpu_dmem_write_data,
    input  logic                   cpu_dmem_read,
    input  logic                   cpu_dmem_write,
    input  logic [DATA_WIDTH/8-1:0] cpu_dmem_be,  // Byte enable
    output logic [DATA_WIDTH-1:0]  cpu_dmem_read_data,
    output logic                   cpu_dmem_ready,
    
    // External Memory Interface (e.g., DDR)
    output logic                   mem_req_valid,
    input  logic                   mem_req_ready,
    output logic [ADDR_WIDTH-1:0]  mem_req_addr,
    output logic                   mem_req_we,
    output logic [DATA_WIDTH-1:0]  mem_req_wdata,
    output logic [DATA_WIDTH/8-1:0] mem_req_be,
    output logic [2:0]             mem_req_burst_len,
    
    input  logic                   mem_resp_valid,
    output logic                   mem_resp_ready,
    input  logic [DATA_WIDTH-1:0]  mem_resp_rdata,
    
    // Internal Memory Interfaces (Optional - for on-chip SRAM)
    output logic [ADDR_WIDTH-1:0]  sram_addr,
    output logic [DATA_WIDTH-1:0]  sram_wdata,
    output logic                   sram_we,
    output logic                   sram_re,
    input  logic [DATA_WIDTH-1:0]  sram_rdata,
    input  logic                   sram_ready
);

    // Address decode parameters
    localparam SRAM_BASE = 64'h0000_0000_0000_0000;
    localparam SRAM_SIZE = 64'h0000_0000_0010_0000;  // 1MB
    localparam DDR_BASE  = 64'h0000_0000_8000_0000;  // 2GB boundary
    
    // Internal signals
    logic                   is_sram_access;
    logic                   is_ddr_access;
    logic                   use_burst_buffer;
    
    // Memory request multiplexing
    logic                   imem_req_valid;
    logic                   dmem_req_valid;
    logic                   current_req_is_instruction;
    
    // Burst buffer signals
    logic                   burst_cpu_req_valid;
    logic                   burst_cpu_req_ready;
    logic [ADDR_WIDTH-1:0]  burst_cpu_req_addr;
    logic                   burst_cpu_req_we;
    logic [DATA_WIDTH-1:0]  burst_cpu_req_wdata;
    logic [DATA_WIDTH/8-1:0] burst_cpu_req_be;
    logic                   burst_cpu_resp_valid;
    logic                   burst_cpu_resp_ready;
    logic [DATA_WIDTH-1:0]  burst_cpu_resp_rdata;
    
    // SRAM access signals
    logic                   sram_req_valid;
    logic                   sram_resp_valid;
    logic [DATA_WIDTH-1:0]  sram_resp_data;
    
    // Address decoding
    always_comb begin
        is_sram_access = (cpu_dmem_addr >= SRAM_BASE && cpu_dmem_addr < (SRAM_BASE + SRAM_SIZE)) ||
                        (cpu_imem_addr >= SRAM_BASE && cpu_imem_addr < (SRAM_BASE + SRAM_SIZE));
        
        is_ddr_access = (cpu_dmem_addr >= DDR_BASE) || (cpu_imem_addr >= DDR_BASE);
        
        // Use burst buffer for DDR accesses to improve efficiency
        use_burst_buffer = is_ddr_access;
    end
    
    // Request arbitration between instruction and data
    always_comb begin
        imem_req_valid = cpu_imem_read && !cpu_dmem_read && !cpu_dmem_write;
        dmem_req_valid = cpu_dmem_read || cpu_dmem_write;
        current_req_is_instruction = imem_req_valid && !dmem_req_valid;
    end
    
    // Burst buffer interface routing
    always_comb begin
        if (use_burst_buffer) begin
            // Route to burst buffer
            burst_cpu_req_valid = dmem_req_valid || imem_req_valid;
            burst_cpu_req_addr = dmem_req_valid ? cpu_dmem_addr : cpu_imem_addr;
            burst_cpu_req_we = cpu_dmem_write;
            burst_cpu_req_wdata = cpu_dmem_write_data;
            burst_cpu_req_be = cpu_dmem_write ? cpu_dmem_be : {(DATA_WIDTH/8){1'b1}};
            burst_cpu_resp_ready = current_req_is_instruction ? 1'b1 : 1'b1; // Always ready for responses
        end else begin
            burst_cpu_req_valid = 1'b0;
            burst_cpu_req_addr = '0;
            burst_cpu_req_we = 1'b0;
            burst_cpu_req_wdata = '0;
            burst_cpu_req_be = '0;
            burst_cpu_resp_ready = 1'b0;
        end
    end
    
    // SRAM interface routing
    always_comb begin
        if (is_sram_access && !use_burst_buffer) begin
            sram_addr = dmem_req_valid ? cpu_dmem_addr : cpu_imem_addr;
            sram_wdata = cpu_dmem_write_data;
            sram_we = cpu_dmem_write;
            sram_re = dmem_req_valid ? cpu_dmem_read : cpu_imem_read;
            sram_req_valid = dmem_req_valid || imem_req_valid;
        end else begin
            sram_addr = '0;
            sram_wdata = '0;
            sram_we = 1'b0;
            sram_re = 1'b0;
            sram_req_valid = 1'b0;
        end
    end
    
    // Response routing logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sram_resp_valid <= 1'b0;
            sram_resp_data <= '0;
        end else begin
            // SRAM response handling (assuming 1-cycle latency)
            sram_resp_valid <= sram_req_valid && sram_ready;
            sram_resp_data <= sram_rdata;
        end
    end
    
    // CPU interface outputs
    always_comb begin
        // Data memory responses
        if (use_burst_buffer) begin
            cpu_dmem_ready = burst_cpu_req_ready || burst_cpu_resp_valid;
            cpu_dmem_read_data = burst_cpu_resp_rdata;
        end else if (is_sram_access) begin
            cpu_dmem_ready = sram_ready;
            cpu_dmem_read_data = sram_rdata;
        end else begin
            cpu_dmem_ready = 1'b0;
            cpu_dmem_read_data = '0;
        end
        
        // Instruction memory responses
        if (use_burst_buffer && current_req_is_instruction) begin
            cpu_imem_ready = burst_cpu_req_ready || burst_cpu_resp_valid;
            cpu_imem_read_data = burst_cpu_resp_rdata[INST_WIDTH-1:0];
        end else if (is_sram_access && current_req_is_instruction) begin
            cpu_imem_ready = sram_ready;
            cpu_imem_read_data = sram_rdata[INST_WIDTH-1:0];
        end else begin
            cpu_imem_ready = 1'b0;
            cpu_imem_read_data = '0;
        end
    end

    // Instantiate memory burst buffer for DDR accesses
    memory_burst_buffer #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .BURST_SIZE(BURST_SIZE),
        .BUFFER_DEPTH(BUFFER_DEPTH)
    ) burst_buffer_inst (
        .clk(clk),
        .rst_n(rst_n),
        
        // CPU interface
        .cpu_req_valid(burst_cpu_req_valid),
        .cpu_req_ready(burst_cpu_req_ready),
        .cpu_req_addr(burst_cpu_req_addr),
        .cpu_req_we(burst_cpu_req_we),
        .cpu_req_wdata(burst_cpu_req_wdata),
        .cpu_req_be(burst_cpu_req_be),
        
        .cpu_resp_valid(burst_cpu_resp_valid),
        .cpu_resp_ready(burst_cpu_resp_ready),
        .cpu_resp_rdata(burst_cpu_resp_rdata),
        
        // Memory controller interface
        .mem_req_valid(mem_req_valid),
        .mem_req_ready(mem_req_ready),
        .mem_req_addr(mem_req_addr),
        .mem_req_we(mem_req_we),
        .mem_req_wdata(mem_req_wdata),
        .mem_req_be(mem_req_be),
        .mem_req_burst_len(mem_req_burst_len),
        
        .mem_resp_valid(mem_resp_valid),
        .mem_resp_ready(mem_resp_ready),
        .mem_resp_rdata(mem_resp_rdata)
    );
    
    // Debug signals (synthesis ignore)
    `ifdef DEBUG_MEMORY_BUS
    always_ff @(posedge clk) begin
        if (burst_cpu_req_valid && burst_cpu_req_ready) begin
            $display("Memory Bus: %s access to 0x%h, data=0x%h", 
                     burst_cpu_req_we ? "WRITE" : "READ", 
                     burst_cpu_req_addr, 
                     burst_cpu_req_wdata);
        end
        
        if (sram_req_valid && sram_ready) begin
            $display("Memory Bus: SRAM %s access to 0x%h", 
                     sram_we ? "WRITE" : "READ", 
                     sram_addr);
        end
    end
    `endif

endmodule
