module tugowar (clk, reset, in, out, done, winner);
  input  logic clk, reset;
  input  logic [1:0] in;       // in[1]=left pulse, in[0]=right pulse (1-cycle)
  output logic [8:0] out;
  output logic [1:0] winner;   // player 1: 01, player 2: 10
  output logic done;           // 1 when someone won

  logic [8:0] cur;             // current position (drives LEDs)
  logic       dir;             // 1 = shift right, 0 = shift left

  localparam [8:0] CENTER = 9'b000010000;
  localparam [8:0] LEFT_E = 9'b100000000;
  localparam [8:0] RGHT_E = 9'b000000001;

  wire press_left  =  in[1] & ~in[0];
  wire press_right = ~in[1] &  in[0];

  enum { init, left, right, win } ps, ns;

  // Next-state
  always_comb begin
    ns   = ps; // default
    dir  = 1'b0;
    done = 1'b0;

    case (ps)
      init: begin
        if (press_left)       begin ns = left;  dir = 1'b0; end
        else if (press_right) begin ns = right; dir = 1'b1; end
      end

      left: begin
        if (press_right)      begin ns = right; dir = 1'b1; end
        else if (press_left) begin
          dir = 1'b0;
          if (cur == LEFT_E) begin
            ns   = win;
            done = 1'b1;  // <-- win only on extra press at edge
          end
        end
      end

      right: begin
        if (press_left)       begin ns = left;  dir = 1'b0; end
        else if (press_right) begin
          dir = 1'b1;
          if (cur == RGHT_E) begin
            ns   = win;
            done = 1'b1;  // <-- win only on extra press at edge
          end
        end
      end

      win: begin
        ns   = win;
        done = 1'b1;
      end
    endcase
  end

  // Position / winner registers
  always_ff @(posedge clk) begin
    if (reset) begin
      cur    <= CENTER; // default
      winner <= 2'b00;
    end else begin
      case (ps)
        init: begin
          winner <= 2'b00;
          if (press_left  && cur != LEFT_E) cur <= cur << 1;
          if (press_right && cur != RGHT_E) cur <= cur >> 1;
        end

        left: begin
          // move left on left press; allow immediate tug back on right press
          if (press_left  && cur != LEFT_E) cur <= cur << 1;
          if (press_right && cur != RGHT_E) cur <= cur >> 1;

          // set winner ONLY when pressing at the edge (same cycle as done)
          if (press_left && cur == LEFT_E)  winner <= 2'b01;
        end

        right: begin
          // move right on right press; allow immediate tug back on left press
          if (press_right && cur != RGHT_E) cur <= cur >> 1;
          if (press_left  && cur != LEFT_E) cur <= cur << 1;

          // set winner ONLY when pressing at the edge (same cycle as done)
          if (press_right && cur == RGHT_E) winner <= 2'b10;
        end

        win: begin
          cur <= cur; // hold
        end
      endcase
    end
  end

  assign out = cur;

  // State register
  always_ff @(posedge clk) begin
    if (reset) ps <= init;
    else       ps <= ns;
  end
endmodule



module tugowar_testbench();
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