module DE1_SoC (
  CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW
);
  input  logic CLOCK_50; // 50MHz Clock 
  output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  output logic [9:0] LEDR;
  input  logic [3:0] KEY; // True when not pressed, False when pressed
  input  logic [9:0] SW;
  
  // reset switch
  logic reset;
  assign reset = SW[9];
  
  // METASTABILITY: take raw input from buttons (they are active high when pressed)
  logic raw_left;
  assign raw_left = ~KEY[3]; // player 2
  logic raw_right;
  assign raw_right = ~KEY[0]; // player 1

  logic sync_left, sync_right;
  button_sync u_syncL (.clk(CLOCK_50), .reset(reset), .din(raw_left), .dout(sync_left));
  button_sync u_syncR (.clk(CLOCK_50), .reset(reset), .din(raw_right), .dout(sync_right)); 
  
  
  // 1-cycle edge pulses per press
  logic pulse_left, pulse_right;
  
  edge_pulse u_edgeL (.clk(CLOCK_50), .reset(reset), .sig(sync_left),  .rising(pulse_left));
  edge_pulse u_edgeR (.clk(CLOCK_50), .reset(reset), .sig(sync_right), .rising(pulse_right));
  logic [1:0] in_pulse;
  assign in_pulse = {pulse_left, pulse_right};


  // hardware assignments
  
  logic [8:0] leds_9;
  logic done;
  logic [1:0] winner;
  
  tugowar u_core (.clk(CLOCK_50), .reset(reset), .in(in_pulse), .out(leds_9), .done(done), .winner(winner));
  
  assign LEDR[9:1] = leds_9;
  assign LEDR[0] = done; // inidicates if game is finished
  
  // ssd
  logic [3:0] hex0_val;
  
  assign hex0_val = (winner == 2'b01) ? 4'd1 : (winner == 2'b10) ? 4'd2 : 7'b0000000;
  
  seg7_digit u_hex0 (.val(hex0_val), .seg(HEX0));
  
  // turn off all other ssd
  
  
  // Generate clk off of CLOCK_50, whichClock picks rate.
  seg7_digit u_hex1_blank (.val(4'hF), .seg(HEX1));
  seg7_digit u_hex2_blank (.val(4'hF), .seg(HEX2));
  seg7_digit u_hex3_blank (.val(4'hF), .seg(HEX3));
  seg7_digit u_hex4_blank (.val(4'hF), .seg(HEX4));
  seg7_digit u_hex5_blank (.val(4'hF), .seg(HEX5));

endmodule








module DE1_SoC_testbench();
	logic CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	
	DE1_SoC dut (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	
	// Set up a simulated clock
	parameter CLOCK_PEROID=100;
	initial begin
		CLOCK_50 <= 0;
		//Forever toggle clock
		forever #(CLOCK_PEROID/2) CLOCK_50 <= ~CLOCK_50;
	end

// Testing
initial begin
	repeat(1) @(posedge CLOCK_50);
	// Always reset FSMs at start
	SW[9] <= 1; repeat(1) @(posedge CLOCK_50);
	// Test case 1: input is 0
	SW[9] <= 0; repeat(1) @(posedge CLOCK_50);
	SW[0] <= 0; repeat(4) @(posedge CLOCK_50);
	// Test case 2: input 1 for 1 cycle
	SW[0] <= 1; repeat(1) @(posedge CLOCK_50);
	SW[0] <= 0; repeat(1) @(posedge CLOCK_50);
	// Test case 3: input 1 for >2 cycles
	SW[0] <= 1; repeat(4) @(posedge CLOCK_50);
	SW[0] <= 0; repeat(2) @(posedge CLOCK_50);
	$step; 
 end
endmodule