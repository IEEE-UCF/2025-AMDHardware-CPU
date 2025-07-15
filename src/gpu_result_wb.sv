module gpu_result_wb #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 64,
    parameter REG_NUM = 32
) (
    input  wire                      clk,
    input  wire                      rst_n,
    
    // From GPU result buffer
    input  wire                      result_ready,
    input  wire [DATA_WIDTH-1:0]     result_data,
    input  wire [ADDR_WIDTH-1:0]     result_addr,
    input  wire [4:0]                result_reg,
    input  wire                      result_exception,
    output wire                      result_ack,
    
    // To CPU register file
    output wire                      reg_write_en,
    output wire [4:0]                reg_write_addr,
    output wire [DATA_WIDTH-1:0]     reg_write_data,
    
    // To memory interface (for memory writes)
    output wire                      mem_write_en,
    output wire [ADDR_WIDTH-1:0]     mem_write_addr,
    output wire [DATA_WIDTH-1:0]     mem_write_data,
    output wire [7:0]                mem_write_strb,
    input  wire                      mem_write_ready,
    
    // Exception handling
    output wire                      gpu_wb_exception,
    output wire [ADDR_WIDTH-1:0]     exception_pc,
    
    // Pipeline control
    input  wire                      pipeline_stall,
    output wire                      wb_stall_request,
    
    // Status
    output wire                      wb_busy
);

    // State machine for writeback process
    typedef enum logic [2:0] {
        WB_IDLE,
        WB_REG_WRITE,
        WB_MEM_WRITE,
        WB_EXCEPTION,
        WB_COMPLETE
    } wb_state_t;
    
    wb_state_t current_state, next_state;
    
    // Internal registers
    logic [DATA_WIDTH-1:0]     wb_data;
    logic [ADDR_WIDTH-1:0]     wb_addr;
    logic [4:0]                wb_reg;
    logic                      wb_exception;
    logic                      is_memory_op;
    
    // Decode operation type from address
    // If result_addr is non-zero, it's a memory write
    // If result_reg is non-zero, it's a register write
    assign is_memory_op = (result_addr != 0);
    
    // State machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= WB_IDLE;
            wb_data <= 0;
            wb_addr <= 0;
            wb_reg <= 0;
            wb_exception <= 0;
        end else if (!pipeline_stall) begin
            current_state <= next_state;
            
            // Latch inputs when starting writeback
            if (current_state == WB_IDLE && result_ready) begin
                wb_data <= result_data;
                wb_addr <= result_addr;
                wb_reg <= result_reg;
                wb_exception <= result_exception;
            end
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            WB_IDLE: begin
                if (result_ready) begin
                    if (result_exception) begin
                        next_state = WB_EXCEPTION;
                    end else if (is_memory_op) begin
                        next_state = WB_MEM_WRITE;
                    end else if (result_reg != 0) begin
                        next_state = WB_REG_WRITE;
                    end else begin
                        next_state = WB_COMPLETE;
                    end
                end
            end
            
            WB_REG_WRITE: begin
                next_state = WB_COMPLETE;
            end
            
            WB_MEM_WRITE: begin
                if (mem_write_ready) begin
                    next_state = WB_COMPLETE;
                end
            end
            
            WB_EXCEPTION: begin
                next_state = WB_COMPLETE;
            end
            
            WB_COMPLETE: begin
                next_state = WB_IDLE;
            end
            
            default: next_state = WB_IDLE;
        endcase
    end
    
    // Output logic
    assign wb_busy = (current_state != WB_IDLE);
    assign wb_stall_request = (current_state == WB_MEM_WRITE) && !mem_write_ready;
    
    // Register writeback
    assign reg_write_en = (current_state == WB_REG_WRITE) && (wb_reg != 0);
    assign reg_write_addr = wb_reg;
    assign reg_write_data = wb_data;
    
    // Memory writeback
    assign mem_write_en = (current_state == WB_MEM_WRITE);
    assign mem_write_addr = wb_addr;
    assign mem_write_data = wb_data;
    assign mem_write_strb = 8'hFF; // Full 64-bit write
    
    // Exception handling
    assign gpu_wb_exception = (current_state == WB_EXCEPTION);
    assign exception_pc = wb_addr; // Use address as exception PC context
    
    // Acknowledge result consumption
    assign result_ack = (current_state == WB_COMPLETE);
    
    // Debug/monitoring
    always_ff @(posedge clk) begin
        if (current_state == WB_EXCEPTION) begin
            $display("GPU Writeback Exception at time %t: addr=0x%h, data=0x%h", 
                     $time, wb_addr, wb_data);
        end
    end

endmodule
