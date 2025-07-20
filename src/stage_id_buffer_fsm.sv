module stage_id_buffer_fsm #(parameter STATE_WIDTH = 2)(
    input  wire                    clk,
    input  wire                    reset,
   
    // Buffer Inputs
    input  wire                    stall,
    input  wire                    buffer_is_empty,
    input  wire                    buffer_is_full,
    input  wire                    inst_valid,
    input  wire                    if_load_stall,

    // Buffer Control
    output reg                     buffer_write_en,
    output reg                     buffer_read_en,
    output reg                     buffer_reset,
    output reg                     if_buffer_stall,

    // Buffer Status
    output reg                     buffer_active,
    output reg                     buffer_sel
    
    // Debug Interface
    // output wire [STATE_WIDTH-1:0] current_state_debug,
    // output wire [STATE_WIDTH-1:0] next_state_debug
);

    // FSM States
    typedef enum reg [STATE_WIDTH-1:0] {
        BUFFER_IDLE = 2'b00;
        BUFFER_RESET = 2'b01;
        BUFFER_WRITE = 2'b10;
        BUFFER_ENABLE = 2'b11;
    } cp_state_t;
    
    cp_state_t current_state, next_state;
    
    // State Register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= BUFFER_IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = current_state;
        case (current_state)
            BUFFER_IDLE: begin
                if (stall) begin
                    next_state = BUFFER_WRITE
                end
            end

            BUFFER_WRITE: begin
                if (!stall) begin
                    next_state = BUFFER_ENABLE
                end
            end
            
            BUFFER_ENABLE: begin
                if (buffer_is_empty || pc_override) begin
                    next_state = BUFFER_RESET
                end
            end

            BUFFER_RESET: begin
                if (stall) begin
                    next_state = BUFFER_WRITE
                end else begin
                    next_state = BUFFER_IDLE
                end
            end
        endcase
    end
    
    // Output control signals
    always_comb begin
        // Default values

        buffer_write_en = 1'b0;
        buffer_read_en  = 1'b0;
        buffer_reset    = 1'b0;
        if_buffer_stall = 1'b0;
        buffer_active   = 1'b0;
        buffer_sel      = 1'b0;

        case (current_state)
            BUFFER_IDLE: begin
                buffer_write_en = stall;
            end
             
            BUFFER_WRITE: begin
                buffer_write_en = !if_load_stall && inst_valid;
                buffer_read_en  = !stall;
                if_buffer_stall = buffer_is_full;
                buffer_active = 1'b1;
            end
            
            BUFFER_ENABLE: begin
                buffer_write_en = !if_load_stall && inst_valid;
                buffer_read_en  = !pc_override;
                if_buffer_stall = buffer_is_full;
                buffer_active = 1'b1;
                buffer_sel = 1'b1;
            end

            BUFFER_RESET: begin
                buffer_write_en = stall;
                buffer_reset = 1'b1;
            end
        endcase
    end

    // assign buffer_active = current_state[1]; // Active during write and enable states
    // assign buffer_sel = current_state[0] & current_state[1] // Select buffer during enable state
    // Debug outputs
    // assign current_state_debug = current_state;
    // assign next_state_debug = next_state;

endmodule
