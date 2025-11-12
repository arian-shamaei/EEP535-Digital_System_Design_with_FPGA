module DE1_SoC (LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW);
	output logic [9:0] LEDR;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	//input logic CLOCK_50;
	

	
	ram32x4 RAM (
		.addr(SW[8:4]),
		.clk(KEY[0]),
		.din(SW[3:0]),
		.w(SW[9]),
		.dout(LEDR[3:0])
	);
	
	seg7 hex5 (.val({3'b000, SW[8]}), .seg(HEX5));	// address 1
	seg7 hex4 (.val(SW[7:4]), .seg(HEX4)); 			// address 2
	seg7 hex2 (.val(SW[3:0]), .seg(HEX2)); 			// din
	seg7 hex0 (.val(LEDR[3:0]), .seg(HEX0)); 			// dout
	
	// unused
	seg7 hex3 (.val(4'hF), .seg(HEX3)); 			
	seg7 hex1 (.val(4'hF), .seg(HEX1)); 			
	
		
endmodule





 
module DE1_SoC_testbench ();
  logic [9:0] out;
  logic       w;
  logic [3:0] val;
  logic [4:0] addr;
  logic       CLOCK_50;

  
  DE1_SoC dut (
    .LEDR(out),
    .KEY({3'b111, w}),       
    .SW({1'b0, val, addr}),
    .CLOCK_50(CLOCK_50)
  );

  parameter CLOCK_PERIOD = 100;

  
  initial begin
    CLOCK_50 = 1'b0;
    forever #(CLOCK_PERIOD/2) CLOCK_50 = ~CLOCK_50;
  end


  initial begin
    // init
    w    = 1'b1;      
    val  = 4'b0000;
    addr = 5'b00000;

    repeat (2) @(posedge CLOCK_50);

    // WRITE: 4'b1100 to address 00001
    addr = 5'b00001;
    val  = 4'b1100;
    @(posedge CLOCK_50);      

    w = 1'b0;                 
    @(posedge CLOCK_50);
    w = 1'b1;

	 // WRITE: 4'b1000 to address 00011
    addr = 5'b00011;
    val  = 4'b1000;
    @(posedge CLOCK_50);      

    w = 1'b0;                 
    @(posedge CLOCK_50);
    w = 1'b1;
	 
	 
    // READBACK 
    addr = 5'b00001;
    @(posedge CLOCK_50);      
    @(posedge CLOCK_50);     

    $stop;
  end
endmodule
