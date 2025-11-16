module shiftRight (start, reset, valueIn, clk, result, done);

	input logic start, reset;
	input logic [7:0] valueIn;
	output logic [3:0] result;
	logic [7:0] valueOut;
	input logic clk;
	enum { waiting, running, finished} ps, ns;
	output logic done;
	
	always_comb begin
		case(ps) 
			waiting: begin
				if(~start) ns = waiting;
				else ns = running;
				done = 0;
			end
			
			running: begin
				done = 0;
				if(valueOut== 0) begin
					ns = finished;
				end
				else begin
					ns = running;
				end
			end
			
			finished: begin
				done = 1;
				if(start) begin
					ns = finished;
				end
				else ns = waiting;
			end
				
			default: begin
				ns = waiting;
            done = 'x;
			end
			
		endcase

	end
	
	
	
	always_ff @(posedge clk) begin
		if(reset) begin
			ps <= waiting;
			valueOut = 0;
			result = 0;
			
		end
		else if(ns == waiting) begin
			ps <= ns;
			valueOut = valueIn;
			result = 0;
		end
		else if(ns == running)begin
			ps <= ns;
			result <= result + valueOut[0];
			valueOut <= {1'b0,valueOut[7:1]};
		end
		else if (ns == finished) begin
			ps<=ns;
		end
	end
	
	
endmodule 

module shiftRight_testbench(); 

	logic start, reset, clk, done; 
	logic [7:0] valueIn; 
	logic [3:0] result; 

	shiftRight dut (start, reset, valueIn, clk, result, done); 

	// Set up a simulated clock. 
	parameter CLOCK_PERIOD=100; 

	initial begin 
		clk <= 0; 
	
		//Forever toggle the clock 
		forever #(CLOCK_PERIOD/2) clk <= ~clk; 
	end 

	// Set up the inputs to the design. Each line is a clock cycle. 
	initial begin 
						@(posedge clk); 
		reset <= 1; @(posedge clk); // Always reset FSMs at start 
		reset <= 0; @(posedge clk); 
		start <= 0; @(posedge clk);
						@(posedge clk); 
		valueIn <= 8'b00001111;	@(posedge clk); 
						@(posedge clk); 
		start <= 1; @(posedge clk);
						@(posedge clk);
						@(posedge clk);
						@(posedge clk);
						@(posedge clk);
						@(posedge clk);
						@(posedge clk);
						@(posedge clk);
						@(posedge clk);
		start <= 0; @(posedge clk);
						@(posedge clk);
						@(posedge clk);
						@(posedge clk);
						@(posedge clk);
		

		$stop; // End the simulation. 
	end 
endmodule 