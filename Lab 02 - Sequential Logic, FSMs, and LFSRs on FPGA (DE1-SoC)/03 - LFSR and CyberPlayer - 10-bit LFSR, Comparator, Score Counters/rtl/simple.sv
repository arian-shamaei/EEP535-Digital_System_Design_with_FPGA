module simple (clk, reset, w, out);
	input logic clk, reset, w;
	output logic out;
	
	// State varible
	enum { none, got_one, got_two } ps, ns;
	// Next state  logic
	always_comb begin
		case (ps)
			none: if (w) ns = got_one;
				else ns = none;
			got_one: if (w) ns = got_two;
				else ns = none;
			got_two: if (w) ns = got_two;
				else ns = none;
		endcase
	end
	// Output logic 
	assign out = (ps ==got_two);
	// DFFs
	always_ff @ (posedge clk) begin
		if (reset)
			ps <= none;
		else
			ps <= ns;
	end
endmodule
	

module simple_testbench();
	logic clk, reset, w;
	logic out;
	simple dut (clk, reset, w, out);
	// Set up clock
	parameter CLOCK_PEROID=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PEROID/2) clk <= ~clk;
	end
	initial begin
						@(posedge clk);
		reset <= 1; @(posedge clk); // start FMS with reset
		reset <= 0; w <= 0; @(posedge clk);
						@(posedge clk);
						@(posedge clk);
						@(posedge clk);
			 w <= 1; @(posedge clk);
			 w <= 0; @(posedge clk);
			 w <= 1; @(posedge clk);
							@(posedge clk);
							@(posedge clk);
							@(posedge clk);
			 w <= 0; @(posedge clk);
							@(posedge clk);
			 $stop;
	end
endmodule