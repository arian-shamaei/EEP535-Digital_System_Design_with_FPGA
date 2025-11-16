module edge_pulse (clk, reset, sig, rising);
	input logic clk, reset, sig;
	output logic rising;
	
	logic q;
	always_ff @(posedge clk) begin
		if (reset) q <= 1'b0;
		else		  q <= sig;
	end
	assign rising = sig & ~q;
endmodule