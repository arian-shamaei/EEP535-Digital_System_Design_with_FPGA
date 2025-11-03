module cyber_player (clk, reset, enable, threshold, press);
  input  logic       clk;
  input  logic       reset;
  input  logic       enable;
  input  logic [9:0] threshold;
  output logic       press;

  logic [9:0] rnd;
  logic       gt, gt_d, en_d;

  // LFSR only advances when enabled 
  lfsr10       u_lfsr (.clk(clk), .reset(reset), .enable(enable), .q(rnd));
  comparator10 u_cmp  (.A(threshold), .B(rnd), .gt(gt)); // TRUE when threshold > rnd

  // Track previous values every cycle
  always_ff @(posedge clk) begin
    if (reset) begin
      gt_d <= 1'b0;
      en_d <= 1'b0;
    end else begin
      gt_d <= gt;     // avoid stale edges
      en_d <= enable; // remember prior enable state
    end
  end

  // Pulse only when (a) enable is asserted now and was also asserted last cycle,
  // and (b) gt rose this cycle.
  assign press = (enable & en_d) ? (gt & ~gt_d) : 1'b0;
endmodule
