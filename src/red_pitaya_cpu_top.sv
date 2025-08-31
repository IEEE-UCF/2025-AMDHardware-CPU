module red_pitaya_cpu_top #(
    parameter ADDR_WIDTH = 32,  // Changed to 32-bit
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter REG_NUM = 32,
    parameter CPU_CLK_DIV = 2,  // Divide 125MHz by 2 for 62.5MHz CPU clock
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 32
)(
    // Red Pitaya 125MHz system clock
    input  logic                      clk_125,
    input  logic                      rstn_i,        // Active low reset from PS
    
    // AXI4-Lite interface to PS
    // Write Address Channel
    input  logic [C_S_AXI_ADDR_WIDTH-1:0]      s_axi_awaddr,
    input  logic [2:0]                         s_axi_awprot,
    input  logic                               s_axi_awvalid,
    output logic                               s_axi_awready,
    
    // Write Data Channel
    input  logic [C_S_AXI_DATA_WIDTH-1:0]      s_axi_wdata,
    input  logic [(C_S_AXI_DATA_WIDTH/8)-1:0]  s_axi_wstrb,
    input  logic                               s_axi_wvalid,
    output logic                               s_axi_wready,
    
    // Write Response Channel
    output logic [1:0]                         s_axi_bresp,
    output logic                               s_axi_bvalid,
    input  logic                               s_axi_bready,
    
    // Read Address Channel
    input  logic [C_S_AXI_ADDR_WIDTH-1:0]      s_axi_araddr,
    input  logic [2:0]                         s_axi_arprot,
    input  logic                               s_axi_arvalid,
    output logic                               s_axi_arready,
    
    // Read Data Channel
    output logic [C_S_AXI_DATA_WIDTH-1:0]      s_axi_rdata,
    output logic [1:0]                         s_axi_rresp,
    output logic                               s_axi_rvalid,
    input  logic                               s_axi_rready,
    
    // LED outputs for debugging (connected to Red Pitaya LEDs)
    output logic [7:0]                led_o,
    
    // Optional GPIO for additional debug
    output logic [7:0]                gpio_o,
    input  logic [7:0]                gpio_i,
    
    // Interrupt from PS
    input  logic                      ps_interrupt,
    
    // Debug outputs (can connect to ILA)
    output logic [31:0]               debug_pc,
    output logic                      debug_stall,
    output logic [3:0]                debug_state
);

    // Clock and reset management
    logic cpu_clk;
    logic cpu_rst_n;
    logic [3:0] reset_sync;
    logic pll_locked;
    
    // Use Xilinx MMCM for better clock generation
    // This provides cleaner clock with proper phase alignment
    logic clk_fb;
    logic clk_cpu_unbuf;
    
    `ifdef SYNTHESIS
    MMCME2_BASE #(
        .CLKFBOUT_MULT_F(8.0),     // Multiply to 1GHz
        .CLKOUT0_DIVIDE_F(16.0),   // Divide to 62.5MHz
        .CLKIN1_PERIOD(8.0),       // 125MHz input
        .DIVCLK_DIVIDE(1),
        .CLKOUT0_DUTY_CYCLE(0.5),
        .CLKOUT0_PHASE(0.0),
        .STARTUP_WAIT("FALSE")
    ) mmcm_cpu_clk (
        .CLKIN1(clk_125),
        .CLKFBOUT(clk_fb),
        .CLKFBIN(clk_fb),
        .CLKOUT0(clk_cpu_unbuf),
        .LOCKED(pll_locked),
        .PWRDWN(1'b0),
        .RST(~rstn_i)
    );
    
    BUFG cpu_clk_buf (
        .I(clk_cpu_unbuf),
        .O(cpu_clk)
    );
    `else
    // Simple divider for simulation
    clock_divider #(
        .DIV_FACTOR(CPU_CLK_DIV)
    ) cpu_clk_div (
        .clk_in(clk_125),
        .rst_n(rstn_i),
        .clk_out(cpu_clk)
    );
    assign pll_locked = 1'b1;
    `endif
    
    // Synchronize reset to CPU clock domain with proper timing
    always_ff @(posedge cpu_clk or negedge rstn_i) begin
        if (!rstn_i) begin
            reset_sync <= '0;
        end else begin
            reset_sync <= {reset_sync[2:0], pll_locked};
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
    logic [7:0]               dmem_byte_enable;
    logic [DATA_WIDTH-1:0]    dmem_read_data;
    logic                     dmem_ready;
    
    // Debug signals
    logic                     cpu_interrupt;
    logic                     cp_instruction_detected;
    logic [INST_WIDTH-1:0]    cp_instruction_out;
    logic                     cp_stall_external;
    
    // Synchronize interrupt from PS
    logic [2:0] interrupt_sync;
    always_ff @(posedge cpu_clk or negedge cpu_rst_n) begin
        if (!cpu_rst_n) begin
            interrupt_sync <= '0;
        end else begin
            interrupt_sync <= {interrupt_sync[1:0], ps_interrupt};
        end
    end
    assign cpu_interrupt = interrupt_sync[2];
    
    // CPU Core Instance
    cpu_top #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .REG_NUM(REG_NUM)
    ) cpu_core (
        .clk(cpu_clk),
        .rst_n(cpu_rst_n),
        .interrupt(cpu_interrupt),
        
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
        .dmem_byte_enable(dmem_byte_enable),
        .dmem_read_data(dmem_read_data),
        .dmem_ready(dmem_ready),
        
        // Coprocessor Interface
        .cp_instruction_detected(cp_instruction_detected),
        .cp_instruction_out(cp_instruction_out),
        .cp_stall_external(cp_stall_external),
        
        // Debug Interface
        .debug_pc(debug_pc),
        .debug_stall(debug_stall),
        .debug_state(debug_state)
    );
    
    // Memory System with AXI Wrapper
    memory_system_axi_wrapper #(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .MEM_SIZE(32768)  // 32KB total memory
    ) mem_sys_axi (
        // AXI Clock and Reset
        .s_axi_aclk(clk_125),  // Use PS clock for AXI
        .s_axi_aresetn(rstn_i),
        
        // AXI4-Lite Slave Interface
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        
        // CPU Memory Interface (Clock Domain Crossing needed)
        .imem_addr(imem_addr),
        .imem_read_data(imem_read_data),
        .imem_read(imem_read),
        .imem_ready(imem_ready),
        
        .dmem_addr(dmem_addr),
        .dmem_write_data(dmem_write_data),
        .dmem_read(dmem_read),
        .dmem_write(dmem_write),
        .dmem_byte_enable(dmem_byte_enable),
        .dmem_read_data(dmem_read_data),
        .dmem_ready(dmem_ready)
    );
    
    // Clock Domain Crossing FIFOs (needed between cpu_clk and AXI clk_125)
    // This is simplified - in production you'd want proper async FIFOs
    
    // LED outputs for debugging
    logic [31:0] cycle_counter;
    logic [7:0] led_reg;
    
    always_ff @(posedge cpu_clk or negedge cpu_rst_n) begin
        if (!cpu_rst_n) begin
            cycle_counter <= '0;
            led_reg <= 8'b00000001;
        end else begin
            cycle_counter <= cycle_counter + 1;
            
            // Heartbeat on LED[0]
            led_reg[0] <= cycle_counter[24];  // ~3.7Hz at 62.5MHz
            
            // Show CPU state on other LEDs
            led_reg[1] <= imem_read;
            led_reg[2] <= dmem_read || dmem_write;
            led_reg[3] <= debug_stall;
            led_reg[4] <= cpu_interrupt;
            led_reg[5] <= cp_instruction_detected;
            led_reg[7:6] <= debug_state[1:0];
        end
    end
    
    assign led_o = led_reg;
    
    // GPIO assignments
    assign gpio_o = debug_pc[7:0];  // Show lower PC bits on GPIO
    assign cp_stall_external = gpio_i[0];  // Allow external stall control
    
    // Synthesis attributes for timing constraints
    `ifdef SYNTHESIS
    (* ASYNC_REG = "TRUE" *) logic [2:0] cdc_sync_reg;
    
    // Add false path constraints for CDC
    (* DONT_TOUCH = "TRUE" *) logic cdc_constraint_anchor;
    `endif

endmodule

// Improved clock divider with glitch-free operation
module clock_divider #(
    parameter DIV_FACTOR = 2
)(
    input  logic clk_in,
    input  logic rst_n,
    output logic clk_out
);

    logic [$clog2(DIV_FACTOR)-1:0] counter;
    logic clk_out_reg;
    
    generate
        if (DIV_FACTOR == 1) begin
            // No division needed
            assign clk_out = clk_in;
        end else if (DIV_FACTOR == 2) begin
            // Simple divide by 2
            always_ff @(posedge clk_in or negedge rst_n) begin
                if (!rst_n) begin
                    clk_out_reg <= '0;
                end else begin
                    clk_out_reg <= ~clk_out_reg;
                end
            end
            assign clk_out = clk_out_reg;
        end else begin
            // General divider
            always_ff @(posedge clk_in or negedge rst_n) begin
                if (!rst_n) begin
                    counter <= '0;
                    clk_out_reg <= '0;
                end else begin
                    if (counter == (DIV_FACTOR/2 - 1)) begin
                        counter <= '0;
                        clk_out_reg <= ~clk_out_reg;
                    end else begin
                        counter <= counter + 1;
                    end
                end
            end
            assign clk_out = clk_out_reg;
        end
    endgenerate

endmodule