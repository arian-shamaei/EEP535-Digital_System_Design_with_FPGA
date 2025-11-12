module DE1_SoC (KEY, LEDR, SW, CLOCK_50);
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input logic CLOCK_50;
	
	ram32x4 RAM (
		.address(SW[4:0]),
		.clock(CLOCK_50),
		.data(SW[8:5]),
		.wren(~KEY[0]),
		.q(LEDR[3:0])
	);

		
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
