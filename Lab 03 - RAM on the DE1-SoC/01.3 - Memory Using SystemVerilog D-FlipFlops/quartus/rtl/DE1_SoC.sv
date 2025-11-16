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
  logic [6:0] hex0, hex1, hex2, hex3, hex4, hex5; 
  logic       w;                 
  logic [3:0] val;              
  logic [4:0] addr;             
  logic       clk;              

  // Instantiate  
  DE1_SoC dut (
    .LEDR(out),
    .HEX0(hex0), .HEX1(hex1), .HEX2(hex2), .HEX3(hex3), .HEX4(hex4), .HEX5(hex5),
    .KEY({3'b111, clk}),               
    .SW({w, addr, val})               
  );

  // Local clock generation (drives KEY[0])
  parameter CLOCK_PERIOD = 100;
  initial begin
    clk = 1'b0;
    forever #(CLOCK_PERIOD/2) clk = ~clk;
  end

  // Stimulus
  initial begin
    // init
    w    = 1'b0;          // deassert write
    val  = 4'b0000;
    addr = 5'b00000;

    repeat (2) @(posedge clk);

    // WRITE: 4'b1100 to address 00001 (pulse w high for one cycle)
    addr = 5'b00001;
    val  = 4'b1100;
    @(posedge clk);
    w = 1'b1; @(posedge clk); w = 1'b0;

    // WRITE: 4'b1000 to address 00011
    addr = 5'b00011;
    val  = 4'b1000;
    @(posedge clk);
    w = 1'b1; @(posedge clk); w = 1'b0;

    // READBACK: set address and let dout appear on LEDR[3:0]
    addr = 5'b00001;
    @(posedge clk);
    @(posedge clk);

    $stop;
  end
endmodule
