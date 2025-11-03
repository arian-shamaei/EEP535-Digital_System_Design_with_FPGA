//This module compares two ten bit numbers A and B
//And produces an output of 1 if A > B and 0 otherwise
//It also includes a test bench with three scenarios:  A > B, A=B, and A<B

module comparator(A, B, ALargerThanB);

	input logic [9:0] A, B; //ten bit input A and ten bit input B
	output logic ALargerThanB;

	
	always_comb begin
		if (A > B) 
			ALargerThanB = 1;
		 else begin
			ALargerThanB = 0;
		end
	end 
endmodule

//Simulate a subset of possible inputs to the comparator to ensure it works
module comparator_testbench();
	logic [9:0] A, B;
	logic ALargerThanB;
		
	//The (.*) below keeps the names of values to ports and the names of the ports the same
	//(.*) has the same effect as comparator dut (.A(A), .B(B), .ALargerThanB(ALargerThanB))
	comparator dut (.*); 

	
	initial begin
	
	//Simulate a Scenario where A is larger than B; ALargerThanB should be 1
	A = 10'b1110011101; B = 10'b0010011101; #10;
	//Wait ten time units, then

	//Simulate a Scenario where A is < B; ALargerThanB should be 0
	A = 10'b0000000000; B = 10'b1100000000; #10;
	//Wait ten time units, then
	
	Simulate a Scenario where A is = B; ALargerThanB should be 0
	A = 10'b0000000000; B = 10'b0000000000; #10;
	
end

endmodule
