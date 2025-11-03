module seg7 (bcd, leds);
  input  logic [2:0] bcd;
  output logic [6:0] leds [5:0];

  always_comb begin
    case (bcd)
      3'b000: begin // CABLE
        leds[5] = 7'b0111001; // C
        leds[4] = 7'b1110111; // A
        leds[3] = 7'b1111100; // b
        leds[2] = 7'b0111000; // L
        leds[1] = 7'b1111001; // E
        leds[0] = 7'b0000000; // space
      end
      3'b001: begin // FUDGE
        leds[5] = 7'b1110001; // F
        leds[4] = 7'b0111110; // U
        leds[3] = 7'b1011110; // D
        leds[2] = 7'b1111101; // G
        leds[1] = 7'b1111001; // E
        leds[0] = 7'b0000000; // space
      end
      3'b010: begin // BREAD
        leds[5] = 7'b1111100; // b
        leds[4] = 7'b1010000; // r
        leds[3] = 7'b1111001; // E
        leds[2] = 7'b1110111; // A
        leds[1] = 7'b1011110; // D
        leds[0] = 7'b0000000; // space
      end
      3'b011: begin // CHAIR
        leds[5] = 7'b0111001; // C
        leds[4] = 7'b1110110; // H
        leds[3] = 7'b1110111; // A
        leds[2] = 7'b0110000; // I
        leds[1] = 7'b1010000; // r
        leds[0] = 7'b0000000; // space
      end
      3'b100: begin // BEAMS
        leds[5] = 7'b1111100; // b
        leds[4] = 7'b1111001; // E
        leds[3] = 7'b1110111; // A
        leds[2] = 7'b0110111; // M
        leds[1] = 7'b1101101; // S
        leds[0] = 7'b0000000; // space
      end
      3'b111: begin // FLUID
        leds[5] = 7'b1110001; // F
        leds[4] = 7'b0111000; // L
        leds[3] = 7'b0111110; // U
        leds[2] = 7'b0110000; // I
        leds[1] = 7'b1011110; // D
        leds[0] = 7'b0000000; // space
      end
      default: begin
        leds[5] = 7'bx;
        leds[4] = 7'bx;
        leds[3] = 7'bx;
        leds[2] = 7'bx;
        leds[1] = 7'bx;
        leds[0] = 7'bx;
      end
    endcase
  end
endmodule
