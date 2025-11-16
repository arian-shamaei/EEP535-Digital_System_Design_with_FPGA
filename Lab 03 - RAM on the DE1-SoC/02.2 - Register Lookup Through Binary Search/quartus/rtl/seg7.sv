module seg7 (
  input  logic [3:0] val,
  output logic [6:0] seg
);
  // Active-low 7-seg encoding
  always_comb begin
    unique case (val)
      4'd0: seg = 7'b1000000;
      4'd1: seg = 7'b1111001;
      4'd2: seg = 7'b0100100;
      4'd3: seg = 7'b0110000;
      4'd4: seg = 7'b0011001;
      4'd5: seg = 7'b0010010;
      4'd6: seg = 7'b0000010;
      4'd7: seg = 7'b1111000;
      4'd8: seg = 7'b0000000;
      4'd9: seg = 7'b0010000;
      4'hA: seg = 7'b0001000; // A
      4'hb: seg = 7'b0000011; // b
      4'hC: seg = 7'b1000110; // C
      4'hd: seg = 7'b0100001; // d
      4'hE: seg = 7'b0000110; // E
      4'hF: seg = 7'b1111111; // blank
      default: seg = 7'b1111111;
    endcase
  end
endmodule
