// 5-bit add / subtract
module adderSubtractor (
    input  logic [4:0] A,
    input  logic [4:0] B,
    input  logic       ctr,   // 0 = add, 1 = subtract (A - B)
    output logic [4:0] out
);
    always_comb begin
        if (ctr) out = A - B;
        else     out = A + B;
    end
endmodule