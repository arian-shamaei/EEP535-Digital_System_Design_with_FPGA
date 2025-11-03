module DE1_SoC (
  CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW
);
  input  logic CLOCK_50; // 50MHz Clock 
  output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  output logic [9:0] LEDR;
  input  logic [3:0] KEY; // True when not pressed, False when pressed
  input  logic [9:0] SW;

  // reset switch (hard reset)
  logic reset;
  assign reset = SW[9];

  // Clocking: use divided_clocks[15] on FPGA, CLOCK_50 for simulation
  parameter bit SIMULATION = 1'b0; // 1 for sim, 0 for board
  logic [31:0] divided_clocks;
  logic        clk_game;

  clock_divider u_cdiv (.clock(CLOCK_50), .reset(reset), .divided_clocks(divided_clocks));
  assign clk_game = (SIMULATION) ? CLOCK_50 : divided_clocks[15];

  // Raw button inputs (active-high when pressed)
  logic        cyber_press;
  logic        raw_left;
  assign raw_left = cyber_press;       // cyber (left)
  logic        raw_right;
  assign raw_right = ~KEY[0];          // human (right)

  // Synchronize buttons into clk_game domain
  logic sync_left, sync_right;
  button_sync u_syncL (.clk(clk_game), .reset(reset), .din(raw_left),  .dout(sync_left));
  button_sync u_syncR (.clk(clk_game), .reset(reset), .din(raw_right), .dout(sync_right)); 

  // 1-cycle edge pulse for human button
  logic pulse_right_human;
  edge_pulse u_edgeR (.clk(clk_game), .reset(reset), .sig(sync_right), .rising(pulse_right_human));

  // Cyber player
  logic [9:0]  cyber_thresh;
  assign cyber_thresh = {1'b0, SW[8:0]};  // 10-bit unsigned from switches (0..511)


  parameter integer CYBER_RATE_POW = 9; 
  logic [CYBER_RATE_POW-1:0] cyber_div;
  always_ff @(posedge clk_game) begin
    if (reset) begin
      cyber_div <= '0;
    end else begin
      cyber_div <= cyber_div + {{(CYBER_RATE_POW-1){1'b0}}, 1'b1};
    end
  end

  cyber_player u_cyber (
    .clk       (clk_game),
    .reset     (reset),
    .enable    (1'b1),
    .threshold (cyber_thresh),
    .press     (cyber_press)
  );

  // send pulses to core
  logic [1:0] in_pulse;   

  // Core game engine
  logic [8:0] leds_9;
  logic       done;
  logic [1:0] winner;
  logic       soft_reset;

  tugowar u_core (.clk(clk_game), .reset(reset | soft_reset), .in(in_pulse), .out(leds_9), .done(done), .winner(winner));

  assign LEDR[9:1] = leds_9;
  // Scoreboard: track cyber(left) and human(right) scores across rounds
  logic [2:0] score_left, score_right;
  scoreboard u_score (
    .clk   (clk_game),
    .reset (reset),
    .done  (done),
    .winner(winner),
    .score_left (score_left),
    .score_right(score_right)
  );

  
  
  // Soft reset after win (hold-off then restart)
  parameter integer SOFT_HOLDOFF = 16'd1000; // cycles of clk_game to display winner
  logic       done_q;
  logic [15:0] soft_cnt;
  always_ff @(posedge clk_game) begin
    if (reset) begin
      done_q     <= 1'b0;
      soft_cnt   <= 16'd0;
      soft_reset <= 1'b0;
    end else begin
      done_q <= done;
      // default deassert after a pulse
      if (soft_reset) soft_reset <= 1'b0;

      // Start hold-off when done rises
      if (done & ~done_q) begin
        soft_cnt <= 16'd0;
      end else if (done) begin
        if (soft_cnt < SOFT_HOLDOFF) begin
          soft_cnt <= soft_cnt + 16'd1;
        end else begin
          soft_reset <= 1'b1; // one-cycle pulse
        end
      end else begin
        soft_cnt <= 16'd0;
      end
    end
  end



  
  

  // MATCH OVER LOCK
  wire match_over = (score_left == 3'b111) || (score_right == 3'b111);

  // When the match is over, freeze inputs to the core
  assign in_pulse = match_over ? 2'b00 : {cyber_press, pulse_right_human};

  // LEDR[0] indicates finished: per-round done OR match over
  assign LEDR[0] = done | match_over;

  // Seven-seg displays
  // HEX0: show winner indicator per round (unchanged)
  logic [3:0] hex0_val;
  assign hex0_val = (winner == 2'b01 && done) ? 4'd1 :
                    (winner == 2'b10 && done) ? 4'd2 : 4'hF; // blank when not done
  seg7_digit u_hex0 (.val(hex0_val), .seg(HEX0));

  // Keep HEX1/HEX2/HEX3 blank
  seg7_digit u_hex1_blank (.val(4'hF), .seg(HEX1));
  seg7_digit u_hex2_blank (.val(4'hF), .seg(HEX2));
  seg7_digit u_hex3_blank (.val(4'hF), .seg(HEX3));

  // SCOREBOARD DISPLAY:
  //   HEX5 = cyber (left) score
  //   HEX4 = human (right) score
  seg7_digit u_hex5_score (.val({1'b0, score_left}),  .seg(HEX5));
  seg7_digit u_hex4_score (.val({1'b0, score_right}), .seg(HEX4));
  
 
  
  

endmodule


module DE1_SoC_testbench();
  logic CLOCK_50;
  logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  logic [9:0] LEDR;
  logic [3:0] KEY;
  logic [9:0] SW;
  
  DE1_SoC #(.SIMULATION(1)) dut (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);

  // Set up a simulated clock
  parameter CLOCK_PEROID=20;
  initial begin
    CLOCK_50 <= 0;
    forever #(CLOCK_PEROID/2) CLOCK_50 <= ~CLOCK_50;
  end

  // Simple smoke test: reset, then enable cyber and let it play, then tap human
  initial begin
    repeat(2) @(posedge CLOCK_50);
    // reset
    SW      <= '0;
    KEY     <= '1; // not pressed
    SW[9]   <= 1; repeat(2) @(posedge CLOCK_50);
    SW[9]   <= 0; repeat(10) @(posedge CLOCK_50);

    // enable cyber and set mid-level threshold
    SW[8]   <= 1'b1; // CYBER_EN (not used explicitly here, but threshold still applies)
    SW[7:0] <= 8'd128;
    repeat(500) @(posedge CLOCK_50);

    // tap human button a few times (KEY[0] active low)
    KEY[0] <= 0; repeat(1) @(posedge CLOCK_50);
    KEY[0] <= 1; repeat(5) @(posedge CLOCK_50);
    KEY[0] <= 0; repeat(1) @(posedge CLOCK_50);
    KEY[0] <= 1; repeat(1000) @(posedge CLOCK_50);

    $stop;
  end
endmodule
