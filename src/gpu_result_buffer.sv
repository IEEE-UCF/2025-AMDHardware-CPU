module gpu_result_buffer #(
    parameter BUFFER_DEPTH = 8,
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 64
) (
    input  wire                      clk,
    input  wire                      rst_n,
    
    // GPU interface - store results
    input  wire                      gpu_result_valid,
    input  wire [DATA_WIDTH-1:0]     gpu_result_data,
    input  wire [ADDR_WIDTH-1:0]     gpu_result_addr,
    input  wire [4:0]                gpu_result_reg,
    input  wire                      gpu_exception,
    output wire                      buffer_full,
    
    // CPU writeback interface - retrieve results
    output wire                      result_ready,
    output wire [DATA_WIDTH-1:0]     result_data,
    output wire [ADDR_WIDTH-1:0]     result_addr,
    output wire [4:0]                result_reg,
    output wire                      result_exception,
    input  wire                      result_ack,
    
    // Status
    output wire [$clog2(BUFFER_DEPTH):0] buffer_count,
    output wire                      buffer_empty
);

    // Result entry structure
    typedef struct packed {
        logic [DATA_WIDTH-1:0]   data;
        logic [ADDR_WIDTH-1:0]   addr;
        logic [4:0]              reg_addr;
        logic                    exception;
    } gpu_result_t;
    
    // Buffer storage
    gpu_result_t buffer [0:BUFFER_DEPTH-1];
    
    // Buffer pointers
    logic [$clog2(BUFFER_DEPTH)-1:0] write_ptr;
    logic [$clog2(BUFFER_DEPTH)-1:0] read_ptr;
    logic [$clog2(BUFFER_DEPTH):0] count;
    
    // Buffer status
    assign buffer_full = (count == BUFFER_DEPTH);
    assign buffer_empty = (count == 0);
    assign buffer_count = count;
    assign result_ready = !buffer_empty;
    
    // Store logic
    wire store_en = gpu_result_valid && !buffer_full;
    
    // Retrieve logic
    wire retrieve_en = result_ack && !buffer_empty;
    
    // Output assignments
    assign result_data = buffer_empty ? '0 : buffer[read_ptr].data;
    assign result_addr = buffer_empty ? '0 : buffer[read_ptr].addr;
    assign result_reg = buffer_empty ? '0 : buffer[read_ptr].reg_addr;
    assign result_exception = buffer_empty ? 1'b0 : buffer[read_ptr].exception;
    
    // Buffer management
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr <= 0;
            read_ptr <= 0;
            count <= 0;
        end else begin
            // Handle store
            if (store_en) begin
                buffer[write_ptr] <= '{
                    data: gpu_result_data,
                    addr: gpu_result_addr,
                    reg_addr: gpu_result_reg,
                    exception: gpu_exception
                };
                write_ptr <= ($clog2(BUFFER_DEPTH))'((write_ptr + 1) % BUFFER_DEPTH);
            end
            
            // Handle retrieve
            if (retrieve_en) begin
                read_ptr <= ($clog2(BUFFER_DEPTH))'((read_ptr + 1) % BUFFER_DEPTH);
            end
            
            // Update count
            case ({store_en, retrieve_en})
                2'b10: count <= count + 1;  // Store only
                2'b01: count <= count - 1;  // Retrieve only
                default: ; // No change or both (count stays same)
            endcase
        end
    end
    
    // Optional: Overflow handling
    always_ff @(posedge clk) begin
        if (gpu_result_valid && buffer_full) begin
            // Log overflow condition - could trigger interrupt
            $display("Warning: GPU result buffer overflow at time %t", $time);
        end
    end

endmodule
