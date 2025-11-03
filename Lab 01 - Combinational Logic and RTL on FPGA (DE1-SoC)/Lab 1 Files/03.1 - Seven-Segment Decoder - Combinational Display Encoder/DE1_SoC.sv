module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	
	//assign HEX0 = 7'b1111111;
	//assign HEX1 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX5 = 7'b1111111;
	
	
	logic [6:0] HEX0_RAW, HEX1_RAW;
	
	seg7 hx1 (.bcd(SW[7:4]), .leds(HEX1_RAW));
	seg7 hx0 (.bcd(SW[3:0]), .leds(HEX0_RAW));
	
	assign HEX1 = ~HEX1_RAW;
	assign HEX0 = ~HEX0_RAW;
	



endmodule


module DE1_SoC_testbench();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW);
	
	integer i;
	initial begin
		SW[9] = 1'b0;
		SW[8] = 1'b0;
		for(i = 0; i <256; i++) begin
			SW[7:0] = i; 
			#10;
		end
	end
endmodule