// This module gets a noisy button input and gives output a single-cycle pulse.
module button_debouncer (
    input wire clk,
    input wire rst_n,
    input wire btn_in,
    output reg btn_pulse
);

    localparam DEBOUNCE_MAX = 50_000;
    reg [15:0] counter_reg;
    
    reg [1:0] sync_ff;
    reg debounced_level;
    reg last_debounced_level;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter_reg <= 0;
            sync_ff <= 2'b00;
            debounced_level <= 1'b0;
            last_debounced_level <= 1'b0;
            btn_pulse <= 1'b0;
        end else begin
            btn_pulse <= 1'b0;


            sync_ff <= {sync_ff[0], btn_in};
            
            if (counter_reg == DEBOUNCE_MAX) begin
                counter_reg <= 0;
                last_debounced_level <= debounced_level;
                
                if (sync_ff == 2'b11) begin
                    debounced_level <= 1'b1;
                    if (last_debounced_level == 1'b0) begin
                        btn_pulse <= 1'b1;
                    end
                end else if (sync_ff == 2'b00) begin
                    debounced_level <= 1'b0;
                end
            end else begin
                counter_reg <= counter_reg + 1;
            end
        end
    end
    
endmodule
