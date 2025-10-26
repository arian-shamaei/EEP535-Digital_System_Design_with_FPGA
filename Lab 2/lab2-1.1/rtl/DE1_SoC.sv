module DE1_SoC (
  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW
);
  output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  output logic [9:0] LEDR;
  input  logic [3:0] KEY;
  input  logic [9:0] SW;

  logic [6:0] HEX_RAW [5:0];
  logic U, P, C, M;

  assign U = SW[9];
  assign P = SW[8];
  assign C = SW[7];
  assign M = SW[0];

  assign LEDR[1] = U | (P & C);
  assign LEDR[0] = (~P & ~M) | (U & ~M);

  seg7 display_inst (.bcd({U,P,C}), .leds(HEX_RAW));

  assign HEX5 = ~HEX_RAW[5];
  assign HEX4 = ~HEX_RAW[4];
  assign HEX3 = ~HEX_RAW[3];
  assign HEX2 = ~HEX_RAW[2];
  assign HEX1 = ~HEX_RAW[1];
  assign HEX0 = ~HEX_RAW[0];

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