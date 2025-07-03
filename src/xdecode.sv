module xdecode #(parameter SIZE = 4)(
    input  wire [SIZE-1:0] addr,
    output reg  [(1<<SIZE)-1:0] loc
);
    always @(*) begin
        loc = 0;
        loc[addr] = 1'b1;
    end
endmodule
