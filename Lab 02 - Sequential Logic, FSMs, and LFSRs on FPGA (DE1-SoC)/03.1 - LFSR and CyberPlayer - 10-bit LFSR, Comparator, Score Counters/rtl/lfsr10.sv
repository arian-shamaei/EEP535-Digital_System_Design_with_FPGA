// 10-bit LFSR (10 bit random number generator
module lfsr10 (
  input  logic clk,
  input  logic reset,
  input  logic enable,
  output logic [9:0] q
);
  logic [9:0] r;
	always_ff @(posedge clk) begin
	  if (reset) begin
		 r <= 10'b0000000001;   // non-all-1s seed
	  end else if (enable) begin
		 // XNOR of taps [9] and [6]
		 r <= { r[8:0], ~(r[9] ^ r[6]) };
	  end
	end

  assign q = r;
endmodule

