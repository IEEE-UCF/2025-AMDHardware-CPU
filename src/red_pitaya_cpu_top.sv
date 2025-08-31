module red_pitaya_cpu_top #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter REG_NUM = 32,
    parameter CPU_CLK_DIV = 2  // Divide 125MHz by 2 for 62.5MHz CPU clock
)(
    // Red Pitaya 125MHz system clock
    input  logic                      clk_125,
    input  logic                      rstn_i,        // Active low reset from PS
    
    // LED outputs for debugging
    output logic [7:0]                led_o,
    
    // External memory interface (simplified for now)
    output logic                      mem_req_o,
    output logic [ADDR_WIDTH-1:0]     mem_addr_o,
    output logic [DATA_WIDTH-1:0]     mem_wdata_o,
    output logic                      mem_we_o,
    input  logic [DATA_WIDTH-1:0]     mem_rdata_i,
    input  logic                      mem_ready_i,
    
    // Debug outputs
    output logic [ADDR_WIDTH-1:0]     debug_pc,
    output logic                      debug_stall,
    output logic                      debug_interrupt
);

    // Clock and reset management
    logic cpu_clk;
    logic cpu_rst_n;
    logic [3:0] reset_sync;
    
    // Generate CPU clock from 125MHz
    clock_divider #(
        .DIV_FACTOR(CPU_CLK_DIV)
    ) cpu_clk_div (
        .clk_in(clk_125),
        .rst_n(rstn_i),
        .clk_out(cpu_clk)
    );
    
    // Synchronize reset to CPU clock domain
    always_ff @(posedge cpu_clk or negedge rstn_i) begin
        if (!rstn_i) begin
            reset_sync <= '0;
        end else begin
            reset_sync <= {reset_sync[2:0], 1'b1};
        end
    end
    assign cpu_rst_n = reset_sync[3];
    
    // Internal memory interfaces
    logic [ADDR_WIDTH-1:0]    imem_addr;
    logic [INST_WIDTH-1:0]    imem_read_data;
    logic                     imem_read;
    logic                     imem_ready;
    
    logic [ADDR_WIDTH-1:0]    dmem_addr;
    logic [DATA_WIDTH-1:0]    dmem_write_data;
    logic                     dmem_read;
    logic                     dmem_write;
    logic [DATA_WIDTH-1:0]    dmem_read_data;
    logic                     dmem_ready;
    
    // Interrupt signal (can be connected to PS later)
    logic interrupt;
    assign interrupt = 1'b0;  // No interrupts for now
    
    // Instantiate CPU top
    cpu_top #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .REG_NUM(REG_NUM)
    ) cpu_core (
        .clk(cpu_clk),
        .rst_n(cpu_rst_n),
        .interrupt(interrupt),
        
        // Instruction Memory Interface
        .imem_addr(imem_addr),
        .imem_read_data(imem_read_data),
        .imem_read(imem_read),
        .imem_ready(imem_ready),
        
        // Data Memory Interface
        .dmem_addr(dmem_addr),
        .dmem_write_data(dmem_write_data),
        .dmem_read(dmem_read),
        .dmem_write(dmem_write),
        .dmem_read_data(dmem_read_data),
        .dmem_ready(dmem_ready)
    );
    
    // Instantiate memory system
    memory_system #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .MEM_SIZE(65536),  // 64KB for testing
        .BURST_SIZE(4)
    ) mem_sys (
        .clk(cpu_clk),
        .rst_n(cpu_rst_n),
        
        // Instruction Port
        .imem_addr(imem_addr),
        .imem_read_data(imem_read_data),
        .imem_read(imem_read),
        .imem_ready(imem_ready),
        
        // Data Port
        .dmem_addr(dmem_addr),
        .dmem_write_data(dmem_write_data),
        .dmem_read(dmem_read),
        .dmem_write(dmem_write),
        .dmem_read_data(dmem_read_data),
        .dmem_ready(dmem_ready)
    );
    
    // Debug outputs
    assign debug_pc = imem_addr;
    assign debug_stall = 1'b0;  // Connect to actual stall signal from CPU
    assign debug_interrupt = interrupt;
    
    // LED outputs for basic debugging
    always_ff @(posedge cpu_clk or negedge cpu_rst_n) begin
        if (!cpu_rst_n) begin
            led_o <= 8'b0;
        end else begin
            // Show lower bits of PC on LEDs for visual feedback
            led_o <= imem_addr[9:2];  // Show instruction address bits
        end
    end
    
    // External memory interface (simplified pass-through for now)
    assign mem_req_o = dmem_read | dmem_write;
    assign mem_addr_o = dmem_addr;
    assign mem_wdata_o = dmem_write_data;
    assign mem_we_o = dmem_write;

endmodule