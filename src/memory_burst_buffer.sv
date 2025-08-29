module memory_burst_buffer #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter BURST_SIZE = 4,  // Number of words in a burst
    parameter BUFFER_DEPTH = 8 // Size of the internal buffer
)(
    // Clock and reset
    input  logic                    clk,
    input  logic                    rst_n,
    
    // CPU/processor interface
    input  logic                    cpu_req_valid,
    output logic                    cpu_req_ready,
    input  logic [ADDR_WIDTH-1:0]   cpu_req_addr,
    input  logic                    cpu_req_we,
    input  logic [DATA_WIDTH-1:0]   cpu_req_wdata,
    input  logic [DATA_WIDTH/8-1:0] cpu_req_be,    // Byte enable
    
    output logic                    cpu_resp_valid,
    input  logic                    cpu_resp_ready,
    output logic [DATA_WIDTH-1:0]   cpu_resp_rdata,
    
    // Memory controller interface
    output logic                    mem_req_valid,
    input  logic                    mem_req_ready,
    output logic [ADDR_WIDTH-1:0]   mem_req_addr,
    output logic                    mem_req_we,
    output logic [DATA_WIDTH-1:0]   mem_req_wdata,
    output logic [DATA_WIDTH/8-1:0] mem_req_be,
    output logic [$clog2(BURST_SIZE)-1:0] mem_req_burst_len,
    
    input  logic                    mem_resp_valid,
    output logic                    mem_resp_ready,
    input  logic [DATA_WIDTH-1:0]   mem_resp_rdata
);

    // Internal buffer for read/write data
    logic [DATA_WIDTH-1:0] buffer [BUFFER_DEPTH-1:0];
    logic [DATA_WIDTH/8-1:0] buffer_be [BUFFER_DEPTH-1:0]; // Store byte enables
    logic [$clog2(BUFFER_DEPTH):0] buffer_count;
    logic [$clog2(BUFFER_DEPTH)-1:0] read_ptr, write_ptr;
    
    // State machine states
    typedef enum logic [2:0] {
        IDLE,
        COLLECT_REQUESTS,
        ISSUE_BURST,
        RECEIVE_BURST,
        RETURN_DATA
    } state_t;
    
    state_t current_state, next_state;
    
    // Burst tracking
    logic [ADDR_WIDTH-1:0] burst_base_addr;
    logic [$clog2(BURST_SIZE):0] burst_count;
    logic burst_write_mode;
    
    // Sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            buffer_count <= '0;
            read_ptr <= '0;
            write_ptr <= '0;
            burst_count <= '0;
            burst_base_addr <= '0;
            burst_write_mode <= 1'b0;
            // Initialize buffer_be array
            for (int i = 0; i < BUFFER_DEPTH; i++) begin
                buffer_be[i] <= '0;
            end
        end else begin
            current_state <= next_state;
            
            // Buffer management logic based on state
            case (current_state)
                IDLE: begin
                    // Reset pointers when idle
                    read_ptr <= '0;
                    write_ptr <= '0;
                    buffer_count <= '0;
                end
                
                COLLECT_REQUESTS: begin
                    // Store incoming requests if in collection phase
                    if (cpu_req_valid && cpu_req_ready) begin
                        if (buffer_count == 0) begin
                            // First request sets the mode and base address
                            burst_base_addr <= cpu_req_addr;
                            burst_write_mode <= cpu_req_we;
                        end
                        
                        if (cpu_req_we) begin
                            buffer[write_ptr] <= cpu_req_wdata;
                        end
                        buffer_be[write_ptr] <= cpu_req_be;
                        
                        write_ptr <= (write_ptr == BUFFER_DEPTH-1) ? '0 : write_ptr + 1;
                        buffer_count <= buffer_count + 1;
                    end
                end
                
                ISSUE_BURST: begin
                    // Once burst is accepted, prepare to receive responses
                    if (mem_req_valid && mem_req_ready) begin
                        burst_count <= mem_req_burst_len + 1;
                    end
                end
                
                RECEIVE_BURST: begin
                    // Store incoming read data
                    if (mem_resp_valid && mem_resp_ready && !burst_write_mode) begin
                        buffer[write_ptr] <= mem_resp_rdata;
                        write_ptr <= (write_ptr == BUFFER_DEPTH-1) ? '0 : write_ptr + 1;
                        burst_count <= burst_count - 1;
                    end else if (burst_write_mode) begin
                        // For write bursts, just count down acknowledgments
                        if (mem_resp_valid && mem_resp_ready) begin
                            burst_count <= burst_count - 1;
                        end
                    end
                end
                
                RETURN_DATA: begin
                    // Return data to CPU and manage buffer
                    if (cpu_resp_valid && cpu_resp_ready) begin
                        read_ptr <= (read_ptr == BUFFER_DEPTH-1) ? '0 : read_ptr + 1;
                        buffer_count <= buffer_count - 1;
                    end
                end
            endcase
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (cpu_req_valid) begin
                    next_state = COLLECT_REQUESTS;
                end
            end
            
            COLLECT_REQUESTS: begin
                // Move to issue burst when we have enough requests or hit an address boundary
                if (buffer_count == BURST_SIZE || 
                   (cpu_req_valid && buffer_count > 0 && 
                    (cpu_req_addr != burst_base_addr + buffer_count*(DATA_WIDTH/8) || 
                     cpu_req_we != burst_write_mode))) begin
                    next_state = ISSUE_BURST;
                end
            end
            
            ISSUE_BURST: begin
                if (mem_req_valid && mem_req_ready) begin
                    next_state = RECEIVE_BURST;
                end
            end
            
            RECEIVE_BURST: begin
                if (burst_count == 0) begin
                    next_state = RETURN_DATA;
                end
            end
            
            RETURN_DATA: begin
                if (buffer_count == 0) begin
                    next_state = IDLE;
                end
            end
        endcase
    end
    
    // Output assignments
    assign cpu_req_ready = (current_state == COLLECT_REQUESTS && buffer_count < BUFFER_DEPTH);
    
    assign cpu_resp_valid = (current_state == RETURN_DATA && buffer_count > 0);
    assign cpu_resp_rdata = buffer[read_ptr];
    
    assign mem_req_valid = (current_state == ISSUE_BURST);
    assign mem_req_addr = burst_base_addr;
    assign mem_req_we = burst_write_mode;
    assign mem_req_wdata = buffer[read_ptr];
    assign mem_req_be = buffer_be[read_ptr]; // Use stored byte enables
    assign mem_req_burst_len = buffer_count - 1; // Burst length is 0-based (0 means 1 transfer)
    
    assign mem_resp_ready = (current_state == RECEIVE_BURST);

endmodule