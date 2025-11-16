module DE1_SoC (
  input  logic        CLOCK_50,
  input  logic [3:0]  KEY,          
  input  logic [9:0]  SW,
  output logic [9:0]  LEDR,
  output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

  // sync inputs to CLOCK_50 (switches + keys)
  logic [9:0] sw_q;
  logic [3:0] key_q0, key_q1;
  always_ff @(posedge CLOCK_50) begin
    sw_q   <= SW;
    key_q0 <= KEY;
    key_q1 <= key_q0;
  end

  // reset and key0 edge
  logic reset;            
  assign reset = ~key_q1[3];

  logic key0_d, key0_rise;
  always_ff @(posedge CLOCK_50) key0_d <= key_q1[0];
  assign key0_rise = (~key0_d) & key_q1[0];

  // write-side
  logic        wren;
  logic [4:0]  wr_addr;
  logic [3:0]  wr_data;
  assign wren     = sw_q[9];
  assign wr_addr  = sw_q[8:4];
  assign wr_data  = sw_q[3:0];

  // read address counter (ticks on KEY0 rising edge)
  logic [4:0] rd_addr;
  logic tick;
  assign tick = key0_rise;

  counter u_cnt (.q(rd_addr), .reset(reset), .clk(tick));

  // memory
  logic [3:0] rd_data;
  ram32x4port2 u_mem (
    .clock      (CLOCK_50),
    .data       (wr_data),
    .rdaddress  (rd_addr),
    .wraddress  (wr_addr),
    .wren       (wren),
    .q          (rd_data)
  );
// outputs
  assign LEDR[3:0] = rd_data;
  assign LEDR[9:4] = 6'b0;

  // hex display wiring
  seg7 h0 (.val(rd_data),             .seg(HEX0));              // read data
  seg7 h1 (.val(wr_data),             .seg(HEX1));              // write data
  seg7 h2 (.val(rd_addr[3:0]),        .seg(HEX2));              // read addr lo
  seg7 h3 (.val({3'b000, rd_addr[4]}),.seg(HEX3));              // read addr hi
  seg7 h4 (.val(wr_addr[3:0]),        .seg(HEX4));              // write addr lo
  seg7 h5 (.val({3'b000, wr_addr[4]}),.seg(HEX5));              // write addr hi

endmodule



module counter (output logic [4:0] q, input logic reset, clk);
  always_ff @(posedge clk) begin
    if (reset) q <= 5'd0;
    else       q <= q + 5'd1;
  end
endmodule




`timescale 1ns/1ps
module DE1_SoC_tb;
  logic        CLOCK_50;
  logic [3:0]  KEY;
  logic [9:0]  SW;
  logic [9:0]  LEDR;
  logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

  DE1_SoC dut (
    .CLOCK_50(CLOCK_50), .KEY(KEY), .SW(SW),
    .LEDR(LEDR), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2),
    .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5)
  );

  // 50 MHz
  initial CLOCK_50 = 0;
  always  #10 CLOCK_50 = ~CLOCK_50; // 20ns -> 50MHz

  // Got this idea from gpt 
  task press(input int idx);
    KEY[idx] = 0; #200; KEY[idx] = 1; #200;
  endtask

  initial begin
    KEY = 4'b1111; // all released (active-low)
    SW  = 10'b0;

    // reset
    press(3);

    // write a few locations: addr=1..3 with data=0xA,0xB,0xC
    SW[9] = 1'b0; // wren low
    repeat (2) @(posedge CLOCK_50);

    // write addr 1 = 0xA
    SW[8:4]=5'd1; SW[3:0]=4'ha; SW[9]=1'b1; repeat(2) @(posedge CLOCK_50);
    SW[9]=1'b0; repeat(1) @(posedge CLOCK_50);

    // write addr 2 = 0xB
    SW[8:4]=5'd2; SW[3:0]=4'hb; SW[9]=1'b1; repeat(2) @(posedge CLOCK_50);
    SW[9]=1'b0; repeat(1) @(posedge CLOCK_50);

    // write addr 3 = 0xC
    SW[8:4]=5'd3; SW[3:0]=4'hc; SW[9]=1'b1; repeat(2) @(posedge CLOCK_50);
    SW[9]=1'b0; repeat(5) @(posedge CLOCK_50);

    // step read counter a few times with KEY0
    repeat (6) press(0);

    #2000 $finish;
  end
endmodule

