// This solves button debouncing
module button_sync (clk, reset, din, dout);
	input logic clk, reset;
	input logic din;
	output logic dout;
	
	logic s0, s1;

	always_ff @(posedge clk) begin
		if (reset) begin
			s0 <= 1'b0;
			s1 <= 1'b0;
		end else begin // ensure button is synced with use input
			s0 <= din;
			s1 <= s0;
		end
	end
	assign dout = s1;
endmodule
	