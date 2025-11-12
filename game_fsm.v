module game_fsm (
    input wire clk,
    input wire rst_n,
    input wire tick_100hz,

    input wire btn_0_p,
    input wire btn_1_p,
    input wire btn_2_p,
    input wire btn_3_p,

    input wire [1:0] lfsr_data,

    output reg mem_write_en,
    output reg [5:0] mem_addr,
    output reg [1:0] mem_data_in,
    input wire [1:0] mem_data_out,

    output reg [3:0] game_leds,
    output reg led_success,
    output reg led_fail,
    output reg [3:0] score_out
);

    localparam S_IDLE        = 4'b0000;
    localparam S_LEVEL_UP    = 4'b0001;
    localparam S_SHOW_DELAY  = 4'b0010;
    localparam S_SHOW_LED_ON = 4'b0011;
    localparam S_SHOW_LED_OFF= 4'b0100;
    localparam S_WAIT_INPUT  = 4'b0101;
    localparam S_CHECK_INPUT = 4'b0110;
    localparam S_SUCCESS     = 4'b0111;
    localparam S_FAIL        = 4'b1000;
    localparam S_FAIL_WAIT   = 4'b1001;

    reg [3:0] current_state;
    reg [7:0] timer_reg;
    reg [5:0] score_reg;
    reg [5:0] index_reg;
    reg [1:0] expected_color;

    wire any_btn_p = btn_0_p || btn_1_p || btn_2_p || btn_3_p;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S_IDLE;
            timer_reg     <= 0;
            score_reg     <= 0;
            index_reg     <= 0;
            mem_write_en  <= 1'b0;
            mem_addr      <= 0;
            mem_data_in   <= 0;
            game_leds     <= 4'b0000;
            led_success   <= 1'b0;
            led_fail      <= 1'b0;
            score_out     <= 0;
        end else if (tick_100hz) begin
            mem_write_en <= 1'b0;
            led_success  <= 1'b0;
            led_fail     <= 1'b0;

            case (current_state)

                S_IDLE: begin
                    game_leds <= 4'b0000;
                    if (any_btn_p) begin
                        score_reg <= 0;
                        index_reg <= 0;
                        current_state <= S_LEVEL_UP;
                    end
                end

                S_LEVEL_UP: begin
                    mem_data_in  <= lfsr_data;
                    mem_addr     <= score_reg;
                    mem_write_en <= 1'b1;
                    score_reg    <= score_reg + 1;
                    index_reg    <= 0;
                    timer_reg    <= 0;
                    current_state <= S_SHOW_DELAY;
                end

                S_SHOW_DELAY: begin
                    if (timer_reg == 50) begin
                        current_state <= S_SHOW_LED_ON;
                    end else begin
                        timer_reg <= timer_reg + 1;
                    end
                end

                S_SHOW_LED_ON: begin
                    mem_addr <= index_reg;
                    expected_color <= mem_data_out;
                    case (mem_data_out)
                        2'b00: game_leds <= 4'b0001;
                        2'b01: game_leds <= 4'b0010;
                        2'b10: game_leds <= 4'b0100;
                        2'b11: game_leds <= 4'b1000;
                    endcase
                    timer_reg <= 0;
                    current_state <= S_SHOW_LED_OFF;
                end

                S_SHOW_LED_OFF: begin
                    if (timer_reg == 50) begin
                        game_leds <= 4'b0000;
                        if (index_reg == score_reg - 1) begin
                            index_reg <= 0;
                            current_state <= S_WAIT_INPUT;
                        end else begin
                            index_reg <= index_reg + 1;
                            current_state <= S_SHOW_LED_ON;
                        end
                    end else begin
                        timer_reg <= timer_reg + 1;
                    end
                end

                S_WAIT_INPUT: begin
                    if (any_btn_p) begin
                        mem_addr <= index_reg;
                        current_state <= S_CHECK_INPUT;
                    end
                end

                S_CHECK_INPUT: begin
                    expected_color <= mem_data_out;
                    if ((btn_0_p && mem_data_out != 2'b00) ||
                        (btn_1_p && mem_data_out != 2'b01) ||
                        (btn_2_p && mem_data_out != 2'b10) ||
                        (btn_3_p && mem_data_out != 2'b11)) begin
                        current_state <= S_FAIL;
                    end else begin
                        if (index_reg == score_reg - 1) begin
                            current_state <= S_SUCCESS;
                        end else begin
                            index_reg <= index_reg + 1;
                            current_state <= S_WAIT_INPUT;
                        end
                    end
                end

                S_SUCCESS: begin
                    led_success <= 1'b1;
                    timer_reg <= 0;
                    score_out <= score_reg[3:0];
                    current_state <= S_LEVEL_UP;
                end

                S_FAIL: begin
                    led_fail <= 1'b1;
                    game_leds <= 4'b1111;
                    timer_reg <= 0;
                    score_reg <= 0;
                    score_out <= 0;
                    current_state <= S_FAIL_WAIT;
                end

                S_FAIL_WAIT: begin
                    led_fail <= 1'b1;
                    game_leds <= (timer_reg[3]) ? 4'b1111 : 4'b0000;
                    if (timer_reg == 100) begin
                        current_state <= S_IDLE;
                    end else begin
                        timer_reg <= timer_reg + 1;
                    end
                end

                default: begin
                    current_state <= S_IDLE;
                end

            endcase
        end
    end
endmodule
