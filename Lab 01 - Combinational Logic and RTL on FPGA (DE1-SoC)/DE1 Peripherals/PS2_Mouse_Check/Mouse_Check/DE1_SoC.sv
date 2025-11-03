module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, PS2_CLK, PS2_DAT);

	input logic CLOCK_50; 
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY; 
	input logic [9:0] SW;	
	inout  PS2_CLK;
	inout  PS2_DAT;
		
	wire [3:0] x, y;
	SEG7_LUT d0 (.iDIG(x),.oSEG(HEX0));
	SEG7_LUT d1 (.iDIG(y),.oSEG(HEX1));
			
	ps2 #(
			.WIDTH(10),
			.HEIGHT(10),
			.BIN(100),
			.HYSTERESIS(30))
	U1(
			.start(~KEY[0]),  
			.reset(~KEY[1]),  
			.CLOCK_50(CLOCK_50),  
			.PS2_CLK(PS2_CLK), 
			.PS2_DAT(PS2_DAT), 
			.button_left(LEDR[0]),  
			.button_right(LEDR[1]),  
			.button_middle(LEDR[2]),  
			.bin_x(x),
			.bin_y(y)
			);
		
endmodule
