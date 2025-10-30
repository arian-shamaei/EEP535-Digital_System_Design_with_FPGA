module hazard_lights (clk, reset, in, out);
  input  logic clk, reset;
  input  logic [1:0]  in;
  output logic [2:0]  out;

  // State variable
  enum { ozo, zoz, zzo, ozz } ps, ns;

  // Next-state logic
  always_comb begin
    case (ps)
      ozo: ns = zoz;
      zoz: 
        if      (~in[1] & ~in[0]) ns = ozo;
        else if (~in[1] &  in[0]) ns = ozz;
        else if (in[1] & ~in[0])  ns = zzo;
        else                      ns = ozo;
      ozz: 
        if      ((~in[1] & ~in[0]) | (in[1] & ~in[0]))   ns = zoz;
        else if (~in[1] &  in[0])                        ns = zzo;
        else                                             ns = ozz;
      zzo: 
        if      ((~in[1] & ~in[0]) | (~in[1] &  in[0]))  ns = zoz;
        else if (in[1] & ~in[0])                         ns = ozz;
        else                                             ns = zzo;
    endcase
  end

  // Output logic
  assign out[2] = ((ps == zoz) & ~in[1]) | ((ps == zzo) &  in[1]);
  assign out[1] =  (ps == ozo)
                 | ((ps == ozo) & ~in[1])
                 | ((ps == zzo) & ~in[1])
                 | ((ps == ozz) & ~in[0]);
  assign out[0] = ((ps == zoz) &  ~in[0]) | ((ps == ozz) &  in[0]);

  // State register
  always_ff @(posedge clk) begin
    if (reset) ps <= ozo;
    else       ps <= ns;
  end
endmodule

	
	
	
	
	
	

module hazard_lights_testbench();
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