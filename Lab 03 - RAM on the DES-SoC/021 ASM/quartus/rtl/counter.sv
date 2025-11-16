module counter (q, reset, clk);
	output logic [4:0] q;
	input logic reset, clk;

	always_ff @(posedge clk or posedge reset) begin 
	if (reset) 
		q <= 0; // On reset, set to 0 
	else 
		q <= q+1; // Otherwise out = d 
	end 
	
endmodule 