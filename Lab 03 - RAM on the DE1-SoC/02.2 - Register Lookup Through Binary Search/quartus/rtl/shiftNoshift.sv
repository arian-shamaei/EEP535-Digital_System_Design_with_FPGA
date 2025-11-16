// shift right until LSB == 1, then hold
module shiftNoshift (
    input  logic [4:0] dataIn,
    output logic [4:0] dataOut
);
    always_comb begin
        if (dataIn[0])       // already 1 in LSB → hold
            dataOut = dataIn;
        else
            dataOut = {1'b0, dataIn[4:1]}; // logical >> 1
    end
endmodule