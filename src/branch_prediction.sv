module branch_prediction (parameter PC_TYPE_NUM = 4, PREDICTOR_REG_SIZE = 2) (
    input  wire                           clk,
    input  wire                           reset,
    input  wire                           stall,
    input  wire                           is_branch,
    input  wire                           pre_is_branch,
    input  wire                           buffer_active,
    input  wire                           pc_match,
    input  wire [$clog2(PC_TYPE_NUM)-1:0] pc_sel,
    output wire                           branch_prediction
);
    localparam PC_BRANCH = 2'b10;

    wire branched = (pc_sel == PC_BRANCH);

    typedef enum reg [STATE_WIDTH-1:0] {
        STRONGLY_AGAINST = 2'b00;
        WEAKLY_AGAINST   = 2'b01;
        WEAKLY_FOR       = 2'b10;
        STRONGLY_FOR     = 2'b11;
    } predictor_state_t;

    predictor_state_t [PREDICTOR_REG_SIZE-1:0] current_predictor, next_predictor;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_predictor <= {PREDICTOR_REG_SIZE{1'b0}};
        end else if (stall) begin
            current_predictor <= current_predictor;
        end else begin
            current_predictor <= next_predictor;
        end
    end

    always_comb begin
        next_predictor = current_predictor;
        case (current_predictor)
            STRONGLY_AGAINST: begin
                if (buffer_active) begin
                    if (is_branch) begin
                        if (pc_match) begin
                            next_predictor = WEAKLY_AGAINST;
                        end
                    end
                end else begin
                    if (pre_is_branch) begin 
                        if (branched) begin
                            next_predictor = WEAKLY_AGAINST;
                        end
                    end
                end
            end
            WEAKLY_AGAINST: begin
                if (buffer_active) begin
                    if (is_branch) begin
                        if (pc_match) begin
                            next_predictor = WEAKLY_FOR;
                        end else begin
                            next_predictor = STRONGLY_AGAINST;
                        end
                    end
                end else begin
                    if (pre_is_branch) begin
                        if (branched) begin
                            next_predictor = WEAKLY_FOR;
                        end else begin
                            next_predictor = STRONGLY_AGAINST;
                        end
                    end
                end
            end
            WEAKLY_FOR: begin
                if (buffer_active) begin
                    if (is_branch) begin
                        if (pc_match) begin
                            next_predictor = STRONGLY_FOR;
                        end else begin
                            next_predictor = WEAKLY_AGAINST;
                        end
                    end
                end else begin
                    if (pre_is_branch) begin
                        if (branched) begin
                            next_predictor = STRONGLY_FOR;
                        end else begin
                            next_predictor = WEAKLY_AGAINST;
                        end
                    end
                end
            end
            STRONGLY_FOR: begin
                if (buffer_active) begin
                    if (is_branch) begin
                        if (!pc_match) begin
                            next_predictor = WEAKLY_FOR;
                        end
                    end
                end else begin
                    if (pre_is_branch) begin
                        if (!branched) begin
                            next_predictor = WEAKLY_FOR;
                        end
                    end
                end
            end
        endcase
    end

    assign branch_prediction = current_predictor[1];

endmodule
