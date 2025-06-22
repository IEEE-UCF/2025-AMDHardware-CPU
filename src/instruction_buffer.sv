module instruction_buffer #(parameter INST_WIDTH = 32, BUFFER_DEPTH = 8)(
    input  wire                  clk,          
    input  wire                  reset,        
    input  wire                  write_en,     
    input  wire [INST_WIDTH-1:0] data_in,      
    output wire [INST_WIDTH-1:0] data_out,
    output wire [INST_WIDTH-1:0] data_next,
    output wire                  is_empty,
    output wire                  is_full
);
    reg  [INST_WIDTH-1:0]         inst_buffer [0:BUFFER_DEPTH-1];
    reg  [INST_WIDTH-1:0]         inst_curr;
    reg  [INST_WIDTH-1:0]         inst_next;
    reg  [$clog2(BUFFER_DEPTH):0] write_ptr;
    reg  [$clog2(BUFFER_DEPTH):0] read_ptr;
    wire [$clog2(BUFFER_DEPTH):0] read_next;
    wire                          has_next;

    assign read_next = read_ptr + 1;
    // If next read pos less than next write pos or read_next and write_ptr are on different sides of circular queue
    assign has_next = (read_next < write_ptr) | (read_next[$clog2(BUFFER_DEPTH)] ^ write_ptr[$clog2(BUFFER_DEPTH)];

    // Status flags
    wire is_empty_flag;
    wire is_full_flag;
    wire lower_bits_equal;
    wire upper_bit_equal;

    assign lower_bits_equal = (write_ptr[$clog2(BUFFER_DEPTH)-1:0] == read_ptr[$clog2(BUFFER_DEPTH)-1:0]) // Checks for same buffer position
    assign upper_bit_equal  = (write_ptr[$clog2(BUFFER_DEPTH)] == read_ptr[$clog2(BUFFER_DEPTH)]); // Checks if pointers have looped over or not
    assign is_empty_flag    = (upper_bit_equal & lower_bits_equal); // If same pos but not loop
    // Combinatorial logic to control read and write operations
    always @(posedge clk) begin
        if (reset) begin
            // Reset logic
            write_ptr <= 0;
            read_ptr <= 0;
            inst_curr <= {INST_WIDTH{1'b0}};
            inst_next <= {INST_WIDTH{1'b0}};
        end else begin
            inst_curr <= inst_buffer[read_ptr[$clog2(BUFFER_DEPTH)-1:0]];
            read_ptr <= read_next;
            if (has_next) begin
                inst_next <= inst_buffer[read_next[$clog2(BUFFER_DEPTH)-1:0]];
            end
            else begin
                // Note: When no next, default to reset value
                inst_next <= {INST_WIDTH{1'b0}};
            end
            // Write operation
            if (write_en && ~is_full_flag) begin
                inst_buffer[write_ptr[$clog2(BUFFER_DEPTH)-1:0]] <= data_in;
                write_ptr <= write_ptr + 1;
            end
        end
    end

    assign data_out = inst_curr;
    assign is_empty = is_empty_flag;
    assign is_full = is_full_flag;

endmodule
