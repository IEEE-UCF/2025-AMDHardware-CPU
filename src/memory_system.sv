module memory_system #(
    parameter ADDR_WIDTH = 32,  // Changed to 32-bit
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter MEM_SIZE = 32768,    // Reduced to 32KB to fit in Zynq BRAM
    parameter BURST_SIZE = 4
)(
    input  logic                    clk,
    input  logic                    rst_n,
    
    // Instruction Port
    input  logic [ADDR_WIDTH-1:0]   imem_addr,
    output logic [INST_WIDTH-1:0]   imem_read_data,
    input  logic                    imem_read,
    output logic                    imem_ready,
    
    // Data Port
    input  logic [ADDR_WIDTH-1:0]   dmem_addr,
    input  logic [DATA_WIDTH-1:0]   dmem_write_data,
    input  logic                    dmem_read,
    input  logic                    dmem_write,
    input  logic [7:0]              dmem_byte_enable,  // Added for partial writes
    output logic [DATA_WIDTH-1:0]   dmem_read_data,
    output logic                    dmem_ready,
    
    // Cache control (for future implementation)
    input  logic                    cache_flush,
    input  logic                    cache_invalidate
);

    // Memory organization - reduced sizes for Zynq-7010
    localparam IMEM_SIZE = 16384;  // 16KB for instructions
    localparam DMEM_SIZE = 16384;  // 16KB for data
    
    // Use block RAM attributes for Xilinx synthesis
    (* ram_style = "block" *) logic [INST_WIDTH-1:0] inst_mem [0:IMEM_SIZE/4-1];
    (* ram_style = "block" *) logic [DATA_WIDTH-1:0] data_mem [0:DMEM_SIZE/8-1];
    
    // Simple cache line buffers (future expansion)
    logic [INST_WIDTH-1:0] icache_line;
    logic [ADDR_WIDTH-1:0] icache_tag;
    logic icache_valid;
    
    logic [DATA_WIDTH-1:0] dcache_line;
    logic [ADDR_WIDTH-1:0] dcache_tag;
    logic dcache_valid;
    
    // Initialize memories with synthesis-compatible method
    `ifdef SYNTHESIS
        initial begin
            $readmemh("inst_mem.hex", inst_mem);
            $readmemh("data_mem.hex", data_mem);
        end
    `else
        // Simulation initialization
        initial begin
            for (int i = 0; i < IMEM_SIZE/4; i++) begin
                inst_mem[i] = 32'h00000013; // NOP
            end
            
            // Simple test program
            inst_mem[0] = 32'h00000013;  // NOP
            inst_mem[1] = 32'h00A00093;  // ADDI x1, x0, 10
            inst_mem[2] = 32'h01400113;  // ADDI x2, x0, 20
            inst_mem[3] = 32'h002081B3;  // ADD x3, x1, x2
            inst_mem[4] = 32'h00308233;  // ADD x4, x1, x3
            inst_mem[5] = 32'h004102B3;  // ADD x5, x2, x4
            inst_mem[6] = 32'h00000073;  // ECALL
            
            for (int i = 0; i < DMEM_SIZE/8; i++) begin
                data_mem[i] = 64'h0;
            end
        end
    `endif
    
    // Instruction fetch with simple cache check
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            imem_read_data <= '0;
            imem_ready <= 1'b0;
            icache_line <= '0;
            icache_tag <= '0;
            icache_valid <= 1'b0;
        end else begin
            if (cache_invalidate || cache_flush) begin
                icache_valid <= 1'b0;
            end
            
            if (imem_read) begin
                // Check cache hit (simplified)
                if (icache_valid && icache_tag == imem_addr[31:2]) begin
                    imem_read_data <= icache_line;
                    imem_ready <= 1'b1;
                end else begin
                    // Cache miss - fetch from memory
                    if (imem_addr < IMEM_SIZE) begin
                        logic [ADDR_WIDTH-1:0] word_addr = {2'b00, imem_addr[31:2]};
                        imem_read_data <= inst_mem[word_addr[15:2]];  // Adjusted indexing
                        icache_line <= inst_mem[word_addr[15:2]];
                        icache_tag <= imem_addr[31:2];
                        icache_valid <= 1'b1;
                        imem_ready <= 1'b1;
                    end else begin
                        imem_read_data <= 32'h00000013; // NOP for out of range
                        imem_ready <= 1'b1;
                    end
                end
            end else begin
                imem_ready <= 1'b0;
            end
        end
    end
    
    // Data memory access with byte enable support
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dmem_read_data <= '0;
            dmem_ready <= 1'b0;
            dcache_line <= '0;
            dcache_tag <= '0;
            dcache_valid <= 1'b0;
        end else begin
            if (cache_invalidate || cache_flush) begin
                dcache_valid <= 1'b0;
            end
            
            dmem_ready <= 1'b0;
            
            // Handle write requests with byte enables
            if (dmem_write) begin
                if (dmem_addr < DMEM_SIZE) begin
                    logic [ADDR_WIDTH-1:0] dword_addr = {3'b000, dmem_addr[31:3]};
                    logic [DATA_WIDTH-1:0] current_data = data_mem[dword_addr[15:3]];
                    logic [DATA_WIDTH-1:0] new_data = current_data;
                    
                    // Apply byte enables
                    for (int i = 0; i < 8; i++) begin
                        if (dmem_byte_enable[i]) begin
                            new_data[i*8 +: 8] = dmem_write_data[i*8 +: 8];
                        end
                    end
                    
                    data_mem[dword_addr[15:3]] <= new_data;
                    dcache_valid <= 1'b0; // Invalidate cache on write
                    dmem_ready <= 1'b1;
                end else begin
                    dmem_ready <= 1'b1; // Ignore out-of-range writes
                end
            end
            // Handle read requests
            else if (dmem_read) begin
                // Check cache hit
                if (dcache_valid && dcache_tag == dmem_addr[31:3]) begin
                    dmem_read_data <= dcache_line;
                    dmem_ready <= 1'b1;
                end else begin
                    // Cache miss
                    if (dmem_addr < DMEM_SIZE) begin
                        logic [ADDR_WIDTH-1:0] dword_addr = {3'b000, dmem_addr[31:3]};
                        dmem_read_data <= data_mem[dword_addr[15:3]];
                        dcache_line <= data_mem[dword_addr[15:3]];
                        dcache_tag <= dmem_addr[31:3];
                        dcache_valid <= 1'b1;
                        dmem_ready <= 1'b1;
                    end else begin
                        dmem_read_data <= '0;
                        dmem_ready <= 1'b1;
                    end
                end
            end
        end
    end
    
    // Performance counters
    logic [31:0] imem_access_count;
    logic [31:0] dmem_read_count;
    logic [31:0] dmem_write_count;
    logic [31:0] icache_hit_count;
    logic [31:0] dcache_hit_count;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            imem_access_count <= '0;
            dmem_read_count <= '0;
            dmem_write_count <= '0;
            icache_hit_count <= '0;
            dcache_hit_count <= '0;
        end else begin
            if (imem_read && imem_ready) begin
                imem_access_count <= imem_access_count + 1;
                if (icache_valid && icache_tag == imem_addr[31:2])
                    icache_hit_count <= icache_hit_count + 1;
            end
            if (dmem_read && dmem_ready) begin
                dmem_read_count <= dmem_read_count + 1;
                if (dcache_valid && dcache_tag == dmem_addr[31:3])
                    dcache_hit_count <= dcache_hit_count + 1;
            end
            if (dmem_write && dmem_ready)
                dmem_write_count <= dmem_write_count + 1;
        end
    end

endmodule

// Complete AXI4-Lite wrapper for Red Pitaya integration
module memory_system_axi_wrapper #(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter MEM_SIZE = 32768
)(
    // AXI4-Lite Clock and Reset
    input  logic                                s_axi_aclk,
    input  logic                                s_axi_aresetn,
    
    // AXI4-Lite Write Address Channel
    input  logic [C_S_AXI_ADDR_WIDTH-1:0]      s_axi_awaddr,
    input  logic [2:0]                         s_axi_awprot,
    input  logic                               s_axi_awvalid,
    output logic                               s_axi_awready,
    
    // AXI4-Lite Write Data Channel
    input  logic [C_S_AXI_DATA_WIDTH-1:0]      s_axi_wdata,
    input  logic [(C_S_AXI_DATA_WIDTH/8)-1:0]  s_axi_wstrb,
    input  logic                               s_axi_wvalid,
    output logic                               s_axi_wready,
    
    // AXI4-Lite Write Response Channel
    output logic [1:0]                         s_axi_bresp,
    output logic                               s_axi_bvalid,
    input  logic                               s_axi_bready,
    
    // AXI4-Lite Read Address Channel
    input  logic [C_S_AXI_ADDR_WIDTH-1:0]      s_axi_araddr,
    input  logic [2:0]                         s_axi_arprot,
    input  logic                               s_axi_arvalid,
    output logic                               s_axi_arready,
    
    // AXI4-Lite Read Data Channel
    output logic [C_S_AXI_DATA_WIDTH-1:0]      s_axi_rdata,
    output logic [1:0]                         s_axi_rresp,
    output logic                               s_axi_rvalid,
    input  logic                               s_axi_rready,
    
    // CPU Memory Interface
    input  logic [ADDR_WIDTH-1:0]              imem_addr,
    output logic [INST_WIDTH-1:0]              imem_read_data,
    input  logic                               imem_read,
    output logic                               imem_ready,
    
    input  logic [ADDR_WIDTH-1:0]              dmem_addr,
    input  logic [DATA_WIDTH-1:0]              dmem_write_data,
    input  logic                               dmem_read,
    input  logic                               dmem_write,
    input  logic [7:0]                         dmem_byte_enable,
    output logic [DATA_WIDTH-1:0]              dmem_read_data,
    output logic                               dmem_ready
);

    // AXI4-Lite state machine
    typedef enum logic [2:0] {
        IDLE,
        WRITE_ADDR,
        WRITE_DATA,
        WRITE_RESP,
        READ_ADDR,
        READ_DATA
    } axi_state_t;
    
    axi_state_t axi_state, axi_next_state;
    
    // Internal registers
    logic [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr_reg;
    logic [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr_reg;
    logic [C_S_AXI_DATA_WIDTH-1:0] axi_wdata_reg;
    logic [(C_S_AXI_DATA_WIDTH/8)-1:0] axi_wstrb_reg;
    logic axi_write_req;
    logic axi_read_req;
    
    // Address decode - map AXI addresses to internal memory
    logic [ADDR_WIDTH-1:0] internal_addr;
    logic is_imem_region;
    logic is_dmem_region;
    
    // Address mapping (customize based on your memory map)
    localparam AXI_IMEM_BASE = 32'h0000_0000;
    localparam AXI_IMEM_SIZE = 32'h0000_4000; // 16KB
    localparam AXI_DMEM_BASE = 32'h0000_4000;
    localparam AXI_DMEM_SIZE = 32'h0000_4000; // 16KB
    
    always_comb begin
        is_imem_region = (axi_state == WRITE_ADDR || axi_state == WRITE_DATA) ? 
                        (axi_awaddr_reg >= AXI_IMEM_BASE && axi_awaddr_reg < AXI_IMEM_BASE + AXI_IMEM_SIZE) :
                        (axi_araddr_reg >= AXI_IMEM_BASE && axi_araddr_reg < AXI_IMEM_BASE + AXI_IMEM_SIZE);
                        
        is_dmem_region = (axi_state == WRITE_ADDR || axi_state == WRITE_DATA) ?
                        (axi_awaddr_reg >= AXI_DMEM_BASE && axi_awaddr_reg < AXI_DMEM_BASE + AXI_DMEM_SIZE) :
                        (axi_araddr_reg >= AXI_DMEM_BASE && axi_araddr_reg < AXI_DMEM_BASE + AXI_DMEM_SIZE);
                        
        if (is_imem_region)
            internal_addr = (axi_state == WRITE_ADDR || axi_state == WRITE_DATA) ? 
                           (axi_awaddr_reg - AXI_IMEM_BASE) : (axi_araddr_reg - AXI_IMEM_BASE);
        else if (is_dmem_region)
            internal_addr = (axi_state == WRITE_ADDR || axi_state == WRITE_DATA) ?
                           (axi_awaddr_reg - AXI_DMEM_BASE) : (axi_araddr_reg - AXI_DMEM_BASE);
        else
            internal_addr = '0;
    end
    
    // AXI state machine
    always_ff @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            axi_state <= IDLE;
            axi_awaddr_reg <= '0;
            axi_araddr_reg <= '0;
            axi_wdata_reg <= '0;
            axi_wstrb_reg <= '0;
            axi_write_req <= '0;
            axi_read_req <= '0;
        end else begin
            axi_state <= axi_next_state;
            
            // Register write address
            if (s_axi_awvalid && s_axi_awready) begin
                axi_awaddr_reg <= s_axi_awaddr;
            end
            
            // Register write data
            if (s_axi_wvalid && s_axi_wready) begin
                axi_wdata_reg <= s_axi_wdata;
                axi_wstrb_reg <= s_axi_wstrb;
            end
            
            // Register read address
            if (s_axi_arvalid && s_axi_arready) begin
                axi_araddr_reg <= s_axi_araddr;
            end
            
            // Handle requests
            case (axi_state)
                WRITE_DATA: axi_write_req <= 1'b1;
                WRITE_RESP: axi_write_req <= 1'b0;
                READ_ADDR: axi_read_req <= 1'b1;
                READ_DATA: axi_read_req <= 1'b0;
                default: begin
                    axi_write_req <= 1'b0;
                    axi_read_req <= 1'b0;
                end
            endcase
        end
    end
    
    // Next state logic
    always_comb begin
        axi_next_state = axi_state;
        
        case (axi_state)
            IDLE: begin
                if (s_axi_awvalid)
                    axi_next_state = WRITE_ADDR;
                else if (s_axi_arvalid)
                    axi_next_state = READ_ADDR;
            end
            
            WRITE_ADDR: begin
                if (s_axi_wvalid)
                    axi_next_state = WRITE_DATA;
            end
            
            WRITE_DATA: begin
                axi_next_state = WRITE_RESP;
            end
            
            WRITE_RESP: begin
                if (s_axi_bready)
                    axi_next_state = IDLE;
            end
            
            READ_ADDR: begin
                axi_next_state = READ_DATA;
            end
            
            READ_DATA: begin
                if (s_axi_rready)
                    axi_next_state = IDLE;
            end
            
            default: axi_next_state = IDLE;
        endcase
    end
    
    // AXI4-Lite output signals
    always_comb begin
        s_axi_awready = (axi_state == IDLE || axi_state == WRITE_ADDR);
        s_axi_wready = (axi_state == WRITE_ADDR || axi_state == WRITE_DATA);
        s_axi_bvalid = (axi_state == WRITE_RESP);
        s_axi_bresp = 2'b00; // OKAY response
        s_axi_arready = (axi_state == IDLE);
        s_axi_rvalid = (axi_state == READ_DATA);
        s_axi_rresp = 2'b00; // OKAY response
    end
    
    // Memory system instance with data width conversion
    logic [DATA_WIDTH-1:0] mem_read_data_64;
    logic [31:0] axi_read_word_select;
    
    memory_system #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .MEM_SIZE(MEM_SIZE)
    ) mem_sys (
        .clk(s_axi_aclk),
        .rst_n(s_axi_aresetn),
        
        // CPU interface (pass through when not using AXI)
        .imem_addr(axi_read_req && is_imem_region ? internal_addr : imem_addr),
        .imem_read_data(imem_read_data),
        .imem_read(axi_read_req && is_imem_region ? 1'b1 : imem_read),
        .imem_ready(imem_ready),
        
        .dmem_addr(axi_write_req && is_dmem_region ? internal_addr : 
                   axi_read_req && is_dmem_region ? internal_addr : dmem_addr),
        .dmem_write_data(axi_write_req ? {32'h0, axi_wdata_reg} : dmem_write_data),
        .dmem_read(axi_read_req && is_dmem_region ? 1'b1 : dmem_read),
        .dmem_write(axi_write_req && is_dmem_region ? 1'b1 : dmem_write),
        .dmem_byte_enable(axi_write_req ? {4'h0, axi_wstrb_reg} : dmem_byte_enable),
        .dmem_read_data(mem_read_data_64),
        .dmem_ready(dmem_ready),
        
        .cache_flush(1'b0),
        .cache_invalidate(1'b0)
    );
    
    // Handle 64-bit to 32-bit data conversion for AXI reads
    always_ff @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            s_axi_rdata <= '0;
        end else if (axi_state == READ_DATA) begin
            if (is_imem_region) begin
                s_axi_rdata <= imem_read_data;
            end else if (is_dmem_region) begin
                // Select appropriate 32-bit word from 64-bit data
                if (axi_araddr_reg[2])
                    s_axi_rdata <= mem_read_data_64[63:32];
                else
                    s_axi_rdata <= mem_read_data_64[31:0];
            end else begin
                s_axi_rdata <= 32'hDEADBEEF; // Invalid address response
            end
        end
    end
    
    // Pass through CPU data when not using AXI
    assign dmem_read_data = mem_read_data_64;

endmodule