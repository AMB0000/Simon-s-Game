module clock_divider #(
    parameter CLK_FREQ    = 50_000_000,
    parameter TARGET_FREQ = 1
) (
    input  wire clk,
    input  wire rst_n,
    output reg  tick
);

 
    localparam MAX_COUNT = (CLK_FREQ / TARGET_FREQ) - 1;

    function integer clog2;
        input integer value;
        integer i;
        begin
            clog2 = 0;
            for (i = value-1; i > 0; i = i >> 1)
                clog2 = clog2 + 1;
        end
    endfunction

    localparam COUNTER_WIDTH = clog2(MAX_COUNT+1);

    reg [COUNTER_WIDTH-1:0] counter_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter_reg <= 0;
            tick <= 1'b0;
        end else begin
            tick <= 1'b0;
            if (counter_reg == MAX_COUNT) begin
                counter_reg <= 0;
                tick <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1;
            end
        end
    end

endmodule
