// This was AI generated, I did not want to go through each case.

module seg7_digit (
  input  logic [3:0] val,
  output logic [6:0] seg
);
  always_comb begin
    unique case (val)
      4'd0: seg = 7'b1111111;
      4'd1: seg = 7'b1111001;
      4'd2: seg = 7'b0100100;
      4'd3: seg = 7'b1111001;
      4'd4: seg = 7'b0110011;
      4'd5: seg = 7'b1011011;
      4'd6: seg = 7'b1011111;
      4'd7: seg = 7'b1110000;
      4'd8: seg = 7'b1111111;
      4'd9: seg = 7'b1111111;
      default: seg = 7'b1111111; 
    endcase
  end
endmodule