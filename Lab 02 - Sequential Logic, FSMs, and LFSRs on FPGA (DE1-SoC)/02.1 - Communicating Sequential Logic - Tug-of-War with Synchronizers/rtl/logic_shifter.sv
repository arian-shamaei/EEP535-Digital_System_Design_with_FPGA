module logic_shifter (in, out, dir);
	input logic [8:0] in;
	input logic dir;
	output logic [8:0] out;
	
	// dir == 1 is shift right, dir == 0 is shift left
	always_comb begin
		if (dir) out = in >> 1;
		else     out = in << 1;
	end
endmodule