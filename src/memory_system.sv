module memory_system #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter INST_WIDTH = 32,
    parameter MEM_SIZE = 65536, // 64KB memory
    parameter BURST_SIZE = 4
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

    
    // Unified memory array (can be split into I$ and D$ later)
    logic [7:0] memory [0:MEM_SIZE-1];
    
    // Initialize memory with some test program
    initial begin
        // Initialize all memory to 0
        for (int i = 0; i < MEM_SIZE; i++) begin
            memory[i] = 8'h00;
        end
        
        // Load a simple test program at address 0
        // NOP
        {memory[3], memory[2], memory[1], memory[0]} = 32'h00000013;
        // ADDI x1, x0, 10
        {memory[7], memory[6], memory[5], memory[4]} = 32'h00A00093;
        // ADDI x2, x0, 20
        {memory[11], memory[10], memory[9], memory[8]} = 32'h01400113;
        // ADD x3, x1, x2
        {memory[15], memory[14], memory[13], memory[12]} = 32'h002081B3;
        // SW x3, 0(x0)
        {memory[19], memory[18], memory[17], memory[16]} = 32'h00302023;
        // LW x4, 0(x0)
        {memory[23], memory[22], memory[21], memory[20]} = 32'h00002203;
        // BEQ x3, x4, 8
        {memory[27], memory[26], memory[25], memory[24]} = 32'h00418463;
        // JAL x5, 16
        {memory[31], memory[30], memory[29], memory[28]} = 32'h010002EF;
    end
    
    logic [INST_WIDTH-1:0] imem_data_reg;
    logic imem_ready_reg;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            imem_data_reg <= 32'h00000013; // NOP
            imem_ready_reg <= 1'b0;
        end else begin
            if (imem_read) begin
                // Read 4 bytes for instruction
                logic [ADDR_WIDTH-1:0] addr;
                addr = imem_addr & {{(ADDR_WIDTH-16){1'b0}}, 16'hFFFC}; // Align to 4 bytes
                
                if (addr < MEM_SIZE - 3) begin
                    imem_data_reg <= {memory[addr+3], memory[addr+2], memory[addr+1], memory[addr]};
                    imem_ready_reg <= 1'b1;
                end else begin
                    imem_data_reg <= 32'h00000013; // NOP for out of bounds
                    imem_ready_reg <= 1'b1;
                end
            end else begin
                imem_ready_reg <= 1'b0;
            end
        end
    end
    
    assign imem_read_data = imem_data_reg;
    assign imem_ready = imem_ready_reg;
    
    // Burst buffer state machine
    typedef enum logic [2:0] {
        IDLE,
        READ_SINGLE,
        READ_BURST,
        WRITE_SINGLE,
        WRITE_BURST,
        COMPLETE
    } mem_state_t;
    
    mem_state_t mem_state, mem_next_state;
    
    logic [DATA_WIDTH-1:0] dmem_data_reg;
    logic dmem_ready_reg;
    logic [2:0] burst_count;
    logic [ADDR_WIDTH-1:0] burst_addr;
    
    // State machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_state <= IDLE;
            burst_count <= '0;
            burst_addr <= '0;
        end else begin
            mem_state <= mem_next_state;
            
            case (mem_state)
                READ_BURST, WRITE_BURST: begin
                    if (burst_count < BURST_SIZE - 1) begin
                        burst_count <= burst_count + 1;
                        burst_addr <= burst_addr + 8;
                    end else begin
                        burst_count <= '0;
                    end
                end
                default: begin
                    burst_count <= '0;
                    burst_addr <= dmem_addr;
