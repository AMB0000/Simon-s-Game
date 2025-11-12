module lfsr (
    input wire clk,
    input wire rst_n,
    input wire tick,
    output wire [7:0] data_out
);

    reg [7:0] lfsr_reg;

    wire feedback_bit;
    assign feedback_bit = lfsr_reg[7] ^ lfsr_reg[5] ^ lfsr_reg[4] ^ lfsr_reg[3];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr_reg <= 8'hA1;
        end else if (tick) begin
            lfsr_reg <= {feedback_bit, lfsr_reg[7:1]};
        end
    end

    assign data_out = lfsr_reg;

endmodule
