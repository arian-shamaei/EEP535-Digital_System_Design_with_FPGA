// Compares two numbers and returns 1 if A is gt B.
module comparator10 (A, B, gt);
  input  logic [9:0] A;
  input  logic [9:0] B;
  output logic       gt;

  always_comb begin
    gt = (A > B);
  end
endmodule

