// Scoreboard: tracks left (cyber) and right (human) scores.
// Increments once per round using `winner` codes from tugowar:
//   winner == 2'b01 -> left wins
//   winner == 2'b10 -> right wins
// Scores saturate at 3'd7 and only clear on hard reset.
module scoreboard (
  input  logic       clk,
  input  logic       reset,      // hard reset (SW9)
  input  logic       done,       // round complete (level-high after a win)
  input  logic [1:0] winner,     // 2'b01 = left(cyber), 2'b10 = right(human)
  output logic [2:0] score_left, // left/cyber score (0..7)
  output logic [2:0] score_right // right/human score (0..7)
);

  logic done_q;
  logic pending_inc; // set on done rising; commit increment next cycle when winner is valid

  wire  done_rise  = done & ~done_q;
  wire  match_over = (score_left == 3'd7) || (score_right == 3'd7);

  always_ff @(posedge clk) begin
    if (reset) begin
      score_left   <= 3'd0;
      score_right  <= 3'd0;
      done_q       <= 1'b0;
      pending_inc  <= 1'b0;
    end else begin
      done_q <= done;

      // Arm on rising edge of done
      if (done_rise && !match_over)
        pending_inc <= 1'b1;

      // Commit exactly once, one cycle after rising done (winner has been registered)
      if (pending_inc) begin
        if (done) begin
          case (winner)
            2'b01: if (score_left  != 3'd7) score_left  <= score_left  + 3'd1;
            2'b10: if (score_right != 3'd7) score_right <= score_right + 3'd1;
            default: /* no change */;
          endcase
        end
        pending_inc <= 1'b0;
      end
    end
  end

endmodule
