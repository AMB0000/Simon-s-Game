module simon_top (
    input wire CLOCK_50,
    input wire [0:0] KEY,    // KEY[0] is reset
    input wire [3:0] SW,     // SW[3:0] are the 4 game buttons

    output wire [9:0] LEDR,
    output wire [6:0] HEX0   // 7seg
);

    wire rst_n = KEY[0];
    wire tick_100hz;
    
    wire btn_0_pulse;
    wire btn_1_pulse;
    wire btn_2_pulse;
    wire btn_3_pulse;
    wire [7:0] lfsr_out;
    wire mem_write_en;
    wire [5:0] mem_addr;
    wire [1:0] mem_data_in;
    wire [1:0] mem_data_out;
    wire [3:0] game_leds_out;
    wire led_success_out;
    wire led_fail_out;
    wire [3:0] score_out_fsm;

    clock_divider #(
        .CLK_FREQ(50_000_000),
        .TARGET_FREQ(100)
    ) fsm_ticker (
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .tick(tick_100hz) 
    );

    button_debouncer debouncer_0 (.clk(CLOCK_50), .rst_n(rst_n), .btn_in(SW[0]), .btn_pulse(btn_0_pulse));
    button_debouncer debouncer_1 (.clk(CLOCK_50), .rst_n(rst_n), .btn_in(SW[1]), .btn_pulse(btn_1_pulse));
    button_debouncer debouncer_2 (.clk(CLOCK_50), .rst_n(rst_n), .btn_in(SW[2]), .btn_pulse(btn_2_pulse));
    button_debouncer debouncer_3 (.clk(CLOCK_50), .rst_n(rst_n), .btn_in(SW[3]), .btn_pulse(btn_3_pulse));
    
    lfsr lfsr_inst (
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .tick(tick_100hz),
        .data_out(lfsr_out)
    );
    

    pattern_memory mem_inst (
        .clk(CLOCK_50),
        .write_en(mem_write_en),
        .addr(mem_addr),
        .data_in(mem_data_in),
        .data_out(mem_data_out)
    );
    
    game_fsm the_game (
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .tick_100hz(tick_100hz),

        .btn_0_p(btn_0_pulse),
        .btn_1_p(btn_1_pulse),
        .btn_2_p(btn_2_pulse),
        .btn_3_p(btn_3_pulse),

        .lfsr_data(lfsr_out[1:0]),

        .mem_write_en(mem_write_en),
        .mem_addr(mem_addr),
        .mem_data_in(mem_data_in),
        .mem_data_out(mem_data_out),

        .game_leds(game_leds_out),
        .led_success(led_success_out),
        .led_fail(led_fail_out),
        .score_out(score_out_fsm)
    );

    seven_seg score_display (
        .num_in(score_out_fsm),
        .seg_out(HEX0)
    );

    assign LEDR[3:0] = game_leds_out;   // Game LEDs
    assign LEDR[8]   = led_success_out; // Success LED
    assign LEDR[9]   = led_fail_out;    // Fail LED
    assign LEDR[7:4] = 4'b0000;

endmodule