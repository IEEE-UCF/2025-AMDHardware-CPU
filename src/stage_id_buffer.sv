module stage_id_buffer #(parameter INST_WIDTH = 32, BUFFER_DEPTH = 16)(
    input  wire                  clk,          
    input  wire                  reset,  
    input  wire                  buffer_reset,      
    input  wire                  write_en,
    input  wire                  read_en,
    input  wire [INST_WIDTH-1:0] inst_in,
    input  wire [ADDR_WIDTH-1:0] pc_in,
    output wire [INST_WIDTH-1:0] inst_out,
    output wire [ADDR_WIDTH-1:0] pc_out,
    output wire [ADDR_WIDTH-1:0] pc_next,
    output wire                  is_empty,
    output wire                  is_full,
    output wire                  has_next
);
    reg [INST_WIDTH-1:0] inst_buffer       [0:BUFFER_DEPTH-1];
    reg [ADDR_WIDTH-1:0] pc_buffer         [0:BUFFER_DEPTH-1];
    // reg [INST_WIDTH-1:0] inst_next;

    reg  [$clog2(BUFFER_DEPTH):0] write_ptr;
    reg  [$clog2(BUFFER_DEPTH):0] read_ptr;
    wire [$clog2(BUFFER_DEPTH):0] read_next;

    assign read_next = read_ptr + 1;
    
    // Status flags
    wire is_empty_flag;
    wire is_full_flag;
    wire lower_bits_equal;
    wire upper_bit_equal;

    assign lower_bits_equal = (write_ptr[$clog2(BUFFER_DEPTH)-1:0] == read_ptr[$clog2(BUFFER_DEPTH)-1:0]); // Checks for same buffer position
    assign upper_bit_equal  = (write_ptr[BUFFER_DEPTH] == read_ptr[BUFFER_DEPTH]); // Checks if pointers have looped over or not
    assign is_empty_flag    = (upper_bit_equal & lower_bits_equal); // If same pos but not looped over, must be empty
    assign is_full_flag     = (~upper_bit_equal & lower_bits_equal); // If same pos but looped over, must be full (Circular buffer)
    // If next read pos less than next write pos or read_next and write_ptr are on different sides of circular queue
    assign has_next = (read_next < write_ptr) || (read_next[$clog2(BUFFER_DEPTH)] ^ write_ptr[$clog2(BUFFER_DEPTH)]);

    // Combinatorial logic to control read and write operations
        // Pre-fetch buffer: Predicts which instruction needs to come next
        // Decode queue: Performs some decode work during queue fill

    always @(posedge clk or posedge reset or posedge buffer_reset) begin
        if (reset || buffer_reset) begin
            // Reset logic
            write_ptr <= 0;
            read_ptr  <= 0;
        end else begin
            // Read operation
            if (read_en && !is_empty_flag) begin
                read_ptr <= read_next;
            end
            // Write operation
            if (write_en && !is_full_flag) begin
                inst_buffer[write_ptr[$clog2(BUFFER_DEPTH)-1:0]]       <= inst_in;
                pc_buffer[write_ptr[$clog2(BUFFER_DEPTH)-1:0]]         <= pc_in;
                write_ptr <= write_ptr + 1;
            end
        end
    end

    assign inst_out       = inst_buffer[read_ptr[$clog2(BUFFER_DEPTH)-1:0]];
    assign pc_out         = pc_buffer[read_ptr[$clog2(BUFFER_DEPTH)-1:0]];
    assign pc_next        = pc_buffer[read_next[$clog2(BUFFER_DEPTH)-1:0]];

    assign is_empty = is_empty_flag;
    assign is_full = is_full_flag;
endmodule
