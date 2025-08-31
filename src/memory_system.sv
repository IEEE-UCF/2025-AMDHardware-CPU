module memory_system #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter MEM_SIZE = 65536,    // 64KB total memory
    parameter BURST_SIZE = 4        // Burst size for future AXI implementation
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
    output logic [DATA_WIDTH-1:0]   dmem_read_data,
    output logic                    dmem_ready
);

    // Memory organization
    // Split memory into instruction and data regions for Harvard architecture
    localparam IMEM_SIZE = MEM_SIZE / 2;  // Half for instructions
    localparam DMEM_SIZE = MEM_SIZE / 2;  // Half for data
    
    // Memory arrays
    logic [INST_WIDTH-1:0] inst_mem [0:IMEM_SIZE/4-1];  // 32-bit words
    logic [DATA_WIDTH-1:0] data_mem [0:DMEM_SIZE/8-1];  // 64-bit words
    
    // Memory initialization
    initial begin
        // Initialize instruction memory
        for (int i = 0; i < IMEM_SIZE/4; i++) begin
            inst_mem[i] = 32'h00000013; // NOP (ADDI x0, x0, 0)
        end
        
        // Load test program
        inst_mem[0] = 32'h00000013;  // NOP
        inst_mem[1] = 32'h00A00093;  // ADDI x1, x0, 10
        inst_mem[2] = 32'h01400113;  // ADDI x2, x0, 20
        inst_mem[3] = 32'h002081B3;  // ADD x3, x1, x2
        inst_mem[4] = 32'h00308233;  // ADD x4, x1, x3
        inst_mem[5] = 32'h004102B3;  // ADD x5, x2, x4
        inst_mem[6] = 32'h00000073;  // ECALL
        
        // Initialize data memory
        for (int i = 0; i < DMEM_SIZE/8; i++) begin
            data_mem[i] = 64'h0;
        end
    end
    
    // Instruction fetch logic
    logic [ADDR_WIDTH-1:0] imem_addr_reg;
    logic imem_read_reg;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            imem_read_data <= '0;
            imem_ready <= 1'b0;
            imem_addr_reg <= '0;
            imem_read_reg <= 1'b0;
        end else begin
            imem_addr_reg <= imem_addr;
            imem_read_reg <= imem_read;
            
            if (imem_read) begin
                // Check if address is within instruction memory range
                if (imem_addr < IMEM_SIZE) begin
                    // Word-aligned access (ignore lower 2 bits)
                    imem_read_data <= inst_mem[imem_addr[31:2]];
                    imem_ready <= 1'b1;
                end else begin
                    // Invalid address - return NOP
                    imem_read_data <= 32'h00000013;
                    imem_ready <= 1'b1;
                end
            end else begin
                imem_ready <= 1'b0;
            end
        end
    end
    
    // Data memory access logic
    logic [ADDR_WIDTH-1:0] dmem_addr_reg;
    logic [DATA_WIDTH-1:0] dmem_write_data_reg;
    logic dmem_read_reg;
    logic dmem_write_reg;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dmem_read_data <= '0;
            dmem_ready <= 1'b0;
            dmem_addr_reg <= '0;
            dmem_write_data_reg <= '0;
            dmem_read_reg <= 1'b0;
            dmem_write_reg <= 1'b0;
        end else begin
            dmem_addr_reg <= dmem_addr;
            dmem_write_data_reg <= dmem_write_data;
            dmem_read_reg <= dmem_read;
            dmem_write_reg <= dmem_write;
            
            // Default
            dmem_ready <= 1'b0;
            
            // Handle write requests
            if (dmem_write) begin
                // Check if address is within data memory range
                if (dmem_addr < DMEM_SIZE) begin
                    // Double-word aligned access (ignore lower 3 bits)
                    data_mem[dmem_addr[31:3]] <= dmem_write_data;
                    dmem_ready <= 1'b1;
                end else begin
                    // Invalid address - ignore write
                    dmem_ready <= 1'b1;
                end
            end
            // Handle read requests
            else if (dmem_read) begin
                // Check if address is within data memory range
                if (dmem_addr < DMEM_SIZE) begin
                    // Double-word aligned access
                    dmem_read_data <= data_mem[dmem_addr[31:3]];
                    dmem_ready <= 1'b1;
                end else begin
                    // Invalid address - return zero
                    dmem_read_data <= '0;
                    dmem_ready <= 1'b1;
                end
            end
        end
    end
    
    // Performance counters for debugging
    logic [31:0] imem_access_count;
    logic [31:0] dmem_read_count;
    logic [31:0] dmem_write_count;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            imem_access_count <= '0;
            dmem_read_count <= '0;
            dmem_write_count <= '0;
        end else begin
            if (imem_read && imem_ready)
                imem_access_count <= imem_access_count + 1;
            if (dmem_read && dmem_ready)
                dmem_read_count <= dmem_read_count + 1;
            if (dmem_write && dmem_ready)
                dmem_write_count <= dmem_write_count + 1;
        end
    end
    
    // Assertions for verification
    `ifdef FORMAL
        // Ensure ready signals are only asserted after valid requests
        always @(posedge clk) begin
            if (imem_ready)
                assert(imem_read_reg);
            if (dmem_ready)
                assert(dmem_read_reg || dmem_write_reg);
        end
        
        // Ensure memory accesses are aligned
        always @(posedge clk) begin
            if (imem_read)
                assert(imem_addr[1:0] == 2'b00);  // Word aligned
            if (dmem_read || dmem_write)
                assert(dmem_addr[2:0] == 3'b000); // Double-word aligned
        end
    `endif
    
    // Synthesis directives for Red Pitaya
    `ifdef SYNTHESIS
        // Infer Block RAM for Xilinx devices
        (* ram_style = "block" *) logic [INST_WIDTH-1:0] inst_mem_synth [0:IMEM_SIZE/4-1];
        (* ram_style = "block" *) logic [DATA_WIDTH-1:0] data_mem_synth [0:DMEM_SIZE/8-1];
    `endif

endmodule

// Future AXI Interface Wrapper for Red Pitaya Integration
// This will be needed to connect to the ZYNQ Processing System
module memory_system_axi_wrapper #(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 32,
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter MEM_SIZE = 65536
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
    output logic [DATA_WIDTH-1:0]              dmem_read_data,
    output logic                               dmem_ready
);

    // TODO: Implement AXI4-Lite state machine for Red Pitaya integration
    // This will handle:
    // 1. AXI protocol conversion
    // 2. Address translation between CPU and ZYNQ memory space
    // 3. Data width conversion (32-bit AXI to 64-bit CPU)
    // 4. Burst handling for improved performance
    
    // For now, instantiate the basic memory system
    memory_system #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .MEM_SIZE(MEM_SIZE)
    ) mem_sys (
        .clk(s_axi_aclk),
        .rst_n(s_axi_aresetn),
        .imem_addr(imem_addr),
        .imem_read_data(imem_read_data),
        .imem_read(imem_read),
        .imem_ready(imem_ready),
        .dmem_addr(dmem_addr),
        .dmem_write_data(dmem_write_data),
        .dmem_read(dmem_read),
        .dmem_write(dmem_write),
        .dmem_read_data(dmem_read_data),
        .dmem_ready(dmem_ready)
    );
    
    // Tie off AXI signals for now
    assign s_axi_awready = 1'b1;
    assign s_axi_wready = 1'b1;
    assign s_axi_bresp = 2'b00;
    assign s_axi_bvalid = s_axi_wvalid && s_axi_awvalid;
    assign s_axi_arready = 1'b1;
    assign s_axi_rdata = 32'h0;
    assign s_axi_rresp = 2'b00;
    assign s_axi_rvalid = s_axi_arvalid;

endmodule