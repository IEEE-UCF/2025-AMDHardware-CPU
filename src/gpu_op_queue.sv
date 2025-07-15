module gpu_op_queue #(
    parameter QUEUE_DEPTH = 16,
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter OP_WIDTH = 8
) (
    input  wire                      clk,
    input  wire                      rst_n,
    
    // CPU interface - enqueue operations
    input  wire                      enqueue_valid,
    input  wire [OP_WIDTH-1:0]       gpu_opcode,
    input  wire [DATA_WIDTH-1:0]     operand_a,
    input  wire [DATA_WIDTH-1:0]     operand_b,
    input  wire [DATA_WIDTH-1:0]     operand_c,
    input  wire [ADDR_WIDTH-1:0]     result_addr,
    input  wire [4:0]                result_reg,
    output wire                      queue_full,
    
    // GPU interface - dequeue operations
    output wire                      dequeue_valid,
    output wire [OP_WIDTH-1:0]       gpu_op_out,
    output wire [DATA_WIDTH-1:0]     op_a_out,
    output wire [DATA_WIDTH-1:0]     op_b_out,
    output wire [DATA_WIDTH-1:0]     op_c_out,
    output wire [ADDR_WIDTH-1:0]     res_addr_out,
    output wire [4:0]                res_reg_out,
    input  wire                      gpu_ready,
    
    // Status
    output wire [$clog2(QUEUE_DEPTH):0] queue_count,
    output wire                      queue_empty
);

    // Queue entry structure
    typedef struct packed {
        logic [OP_WIDTH-1:0]     opcode;
        logic [DATA_WIDTH-1:0]   op_a;
        logic [DATA_WIDTH-1:0]   op_b;
        logic [DATA_WIDTH-1:0]   op_c;
        logic [ADDR_WIDTH-1:0]   result_addr;
        logic [4:0]              result_reg;
    } gpu_op_t;
    
    // Queue storage
    gpu_op_t queue [0:QUEUE_DEPTH-1];
    
    // Queue pointers
    logic [$clog2(QUEUE_DEPTH)-1:0] write_ptr;
    logic [$clog2(QUEUE_DEPTH)-1:0] read_ptr;
    logic [$clog2(QUEUE_DEPTH):0] count;
    
    // Queue status
    assign queue_full = (count == QUEUE_DEPTH);
    assign queue_empty = (count == 0);
    assign queue_count = count;
    
    // Enqueue logic
    wire enqueue_en = enqueue_valid && !queue_full;
    
    // Dequeue logic
    wire dequeue_en = gpu_ready && !queue_empty;
    assign dequeue_valid = !queue_empty;
    
    // Output assignments
    assign gpu_op_out = queue[read_ptr].opcode;
    assign op_a_out = queue[read_ptr].op_a;
    assign op_b_out = queue[read_ptr].op_b;
    assign op_c_out = queue[read_ptr].op_c;
    assign res_addr_out = queue[read_ptr].result_addr;
    assign res_reg_out = queue[read_ptr].result_reg;
    
    // Queue management
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr <= 0;
            read_ptr <= 0;
            count <= 0;
        end else begin
            // Handle enqueue
            if (enqueue_en) begin
                queue[write_ptr] <= '{
                    opcode: gpu_opcode,
                    op_a: operand_a,
                    op_b: operand_b,
                    op_c: operand_c,
                    result_addr: result_addr,
                    result_reg: result_reg
                };
                write_ptr <= ($clog2(QUEUE_DEPTH))'((write_ptr + 1) % QUEUE_DEPTH);
            end
            
            // Handle dequeue
            if (dequeue_en) begin
                read_ptr <= ($clog2(QUEUE_DEPTH))'((read_ptr + 1) % QUEUE_DEPTH);
            end
            
            // Update count
            case ({enqueue_en, dequeue_en})
                2'b10: count <= count + 1;  // Enqueue only
                2'b01: count <= count - 1;  // Dequeue only
                default: ; // No change or both (count stays same)
            endcase
        end
    end

endmodule
