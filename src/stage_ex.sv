module pl_stage_exe #(parameter DATA_WIDTH = 64)(
    input  wire [DATA_WIDTH-1:0] ea,
    input  wire [DATA_WIDTH-1:0] eb,
    input  wire [DATA_WIDTH-1:0] epc4,
    input  wire [4:0]            ealuc,
    input  wire                  ecall,
    output wire [DATA_WIDTH-1:0] eal
);
    // ALU implementation with important operations
    reg [DATA_WIDTH-1:0] ealu;
    always @(*) begin
        case (ealuc)
            5'b00000: ealu = ea + eb;                        // ADD
            5'b00001: ealu = ea - eb;                        // SUB
            5'b00010: ealu = ea & eb;                        // AND
            5'b00011: ealu = ea | eb;                        // OR
            5'b00100: ealu = ea ^ eb;                        // XOR
            5'b00101: ealu = ~(ea | eb);                     // NOR
            5'b00110: ealu = ~(ea & eb);                     // NAND
            5'b00111: ealu = ea << eb[4:0];                  // Logical shift left
            5'b01000: ealu = ea >> eb[4:0];                  // Logical shift right
            5'b01001: ealu = $signed(ea) >>> eb[4:0];        // Arithmetic shift right
            5'b01010: ealu = ($signed(ea) < $signed(eb)) ? 1 : 0; // Set less than (signed)
            5'b01011: ealu = (ea < eb) ? 1 : 0;              // Set less than (unsigned)
            5'b01100: ealu = ea;                             // Pass-through A
            5'b01101: ealu = eb;                             // Pass-through B
            5'b01110: ealu = ~ea;                            // Bitwise NOT A
            5'b01111: ealu = (ea == eb) ? 1 : 0;             // Equality test
            5'b10000: ealu = (ea != eb) ? 1 : 0;             // Inequality test
            5'b10001: ealu = ea + 1;                         // Increment A
            5'b10010: ealu = ea - 1;                         // Decrement A
            default:  ealu = {DATA_WIDTH{1'b0}};
        endcase
    end

    // 2-to-1 mux for ecall
    assign eal = ecall ? epc4 : ealu;

endmodule