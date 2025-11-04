module DE1_SoC (KEY, LEDR, SW, CLOCK_50);
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input logic CLOCK_50;
	
	ram32x4 RAM (
		.address(SW[4:0]),
		.clock(CLOCK_50),
		.data(SW[8:5]),
		.wren(~KEY[0]),
		.q(LEDR[3:0])
	);
	
		
endmodule


 

//module DE1_SoC_testbench ();
//	output logic [9:0] LEDR;
//	input logic [3:0] KEY;
//	input logic [9:0] SW;
//	input logic CLOCK_50;
//	
//	
//	DE1_SoC dut (
//		.LEDR(LEDR),
//		.KEY(KEY),
//		.SW(SE),
//		.CLOCK_50(CLOCK_50)
//	);
//	
//	parameter CLOCK_PERIOD = 100;
//	initial begin
//		clock_50 <= 0;
//		forever #(CLOCK_PEROID/2) CLOCK_50 <= ~CLOCK_50;
//	end
//	
//// testing
//initial begin
//	repeat(1) @ (posedge CLOCK_50);
//	// Test case 1: 
//	LEDR 