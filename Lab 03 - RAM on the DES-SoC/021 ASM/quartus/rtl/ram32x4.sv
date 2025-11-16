

module ram32x4 (clk, w, addr, din, dout);
	output logic [3:0] dout;
	input logic [3:0] din;
	input logic [4:0] addr;
	input logic w, clk;
	
	// set up memory structure
	logic [3:0] memory_array [31:0];
	
	always_ff @(posedge clk) begin
		dout <= memory_array[addr];
		if (w)
			memory_array[addr] <= din;
	end
endmodule
	
	