module DE1_SoC (
  CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW
);
  input  logic        CLOCK_50;
  input  logic [3:0]  KEY;          
  input  logic [9:0]  SW;
  output logic [9:0]  LEDR;
  output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;


  logic [4:0] loc;
  logic       found;
  logic       done;
  logic [7:0] cycle_count;

  // sync inputs to CLOCK_50 
  logic [9:0] sw_q;
  logic       sw9_prev;
  logic       start_pulse;
  logic [3:0] key_q0;
  always_ff @(posedge CLOCK_50) begin
    sw_q   <= SW;
    key_q0 <= KEY;
    sw9_prev <= sw_q[9];
  end

  assign start_pulse = sw_q[9] & ~sw9_prev;

  // reset (KEY0 on board is active-low)
  logic reset;            
  assign reset = ~key_q0[0];

  // Binary Search ASM
  binsearch assm (
    .a      (sw_q[7:0]),
    .Start  (start_pulse),
    .Reset  (reset),
    .CLOCK_50(CLOCK_50),
    .Loc    (loc),
    .Found  (found),
    .Done   (done)
  );

  // count how many cycles between each Start and Done
  cycle_counter u_cycle_counter (
    .clk    (CLOCK_50),
    .reset  (reset),
    .start  (start_pulse),
    .done   (done),
    .cycles (cycle_count)
  );

  // decimal digits for location (only when found)
  logic [3:0] loc_tens;
  logic [3:0] loc_ones;
  logic [4:0] loc_dec;
  logic [7:0] cyc_dec;
  logic [3:0] cyc_tens;
  logic [3:0] cyc_ones;
  logic        loc_blank;
  always_comb begin
    loc_dec  = loc;
    loc_tens = 4'hF;
    loc_ones = 4'hF;
    cyc_dec  = cycle_count;
    cyc_tens = (cyc_dec / 10) % 10;
    cyc_ones = cyc_dec % 10;
    loc_blank = ~found;
    if (found) begin
      loc_tens = loc_dec / 10;
      loc_ones = loc_dec % 10;
    end
  end
  
  // outputs
  assign LEDR[9] = found;
  assign LEDR[0] = 1'b0;
  assign LEDR[1] = 1'b0;
  assign LEDR[2] = 1'b0;
  assign LEDR[3] = 1'b0;
  assign LEDR[4] = 1'b0;
  assign LEDR[5] = 1'b0;
  assign LEDR[6] = 1'b0;
  assign LEDR[7] = 1'b0;
  assign LEDR[8] = 1'b0;

  // Location hex on HEX0/HEX1 (blank when not found)
  logic [3:0] loc_hex_hi;
  logic [3:0] loc_hex_lo;
  assign loc_hex_lo = found ? loc[3:0]        : 4'hF;
  assign loc_hex_hi = found ? {3'b000, loc[4]}: 4'hF;
  // Location in decimal on HEX2/HEX3 (blank when not found); cycle counter on HEX4/HEX5
  seg7 h0 (.val(loc_hex_lo),      .blank(loc_blank), .seg(HEX0)); // Loc LSB (hex) or off
  seg7 h1 (.val(loc_hex_hi),      .blank(loc_blank), .seg(HEX1)); // Loc MSB (hex) or off
  seg7 h2 (.val(loc_ones),        .blank(loc_blank), .seg(HEX2)); // loc ones digit (decimal/off)
  seg7 h3 (.val(loc_tens),        .blank(loc_blank), .seg(HEX3)); // loc tens digit (decimal/off)
  seg7 h4 (.val(cyc_ones),        .blank(1'b0),      .seg(HEX4)); // cycle count ones (decimal)
  seg7 h5 (.val(cyc_tens),        .blank(1'b0),      .seg(HEX5)); // cycle count tens  (decimal)

endmodule

module cycle_counter (
  input  logic       clk,
  input  logic       reset,
  input  logic       start,
  input  logic       done,
  output logic [7:0] cycles
);
  logic       measuring;
  logic [7:0] counter;

  always_ff @(posedge clk) begin
    if (reset) begin
      measuring <= 1'b0;
      counter   <= 8'd0;
      cycles    <= 8'd0;
    end else begin
      if (start) begin
        measuring <= 1'b1;
        counter   <= 8'd0;
      end else if (measuring && !done) begin
        counter <= counter + 8'd1;
      end

      if (measuring && done) begin
        measuring <= 1'b0;
        cycles    <= counter;
      end
    end
  end
endmodule















`timescale 1ns/1ps
module DE1_SoC_tb;
  localparam int    SIZE     = 32;
  localparam string MIF_PATH = "../../memory/my_sorted_array.mif";

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

  // 50 MHz clock (20 ns period)
  initial CLOCK_50 = 1'b0;
  always  #10 CLOCK_50 = ~CLOCK_50;

  // Reference memory image (used to verify HEX/LED outputs)
  logic [7:0] mem [0:SIZE-1];
  bit         mif_loaded;
  initial begin
    int fd;
    string line, token;
    int addr, data;
    bit in_content;

    fd = $fopen(MIF_PATH, "r");
    if (fd == 0) $fatal(1, "Unable to open %s", MIF_PATH);
    in_content = 1'b0;

    while (!$feof(fd) && !in_content) begin
      if (!$fgets(line, fd)) break;
      if ($sscanf(line, "%s", token) == 1 && (token == "CONTENT" || token == "content"))
        in_content = 1'b1;
    end
    if (!in_content) $fatal(1, "CONTENT block missing in %s", MIF_PATH);

    while (!$feof(fd)) begin
      if (!$fgets(line, fd)) break;
      if ($sscanf(line, "%s", token) == 1 && (token == "END;" || token == "END"))
        break;
      if ($sscanf(line, " %d : %b ;", addr, data) == 2) begin
        if ((addr >= 0) && (addr < SIZE))
          mem[addr] = data[7:0];
      end
    end
    $fclose(fd);
    mif_loaded = 1'b1;
  end

  function automatic int find_in_mem(input logic [7:0] key);
    for (int i = 0; i < SIZE; i++) begin
      if (mem[i] == key) return i;
    end
    return -1;
  endfunction

  function automatic [3:0] seg_to_nibble(input logic [6:0] seg);
    case (seg)
      7'b1000000: seg_to_nibble = 4'd0;
      7'b1111001: seg_to_nibble = 4'd1;
      7'b0100100: seg_to_nibble = 4'd2;
      7'b0110000: seg_to_nibble = 4'd3;
      7'b0011001: seg_to_nibble = 4'd4;
      7'b0010010: seg_to_nibble = 4'd5;
      7'b0000010: seg_to_nibble = 4'd6;
      7'b1111000: seg_to_nibble = 4'd7;
      7'b0000000: seg_to_nibble = 4'd8;
      7'b0010000: seg_to_nibble = 4'd9;
      7'b0001000: seg_to_nibble = 4'hA;
      7'b0000011: seg_to_nibble = 4'hB;
      7'b1000110: seg_to_nibble = 4'hC;
      7'b0100001: seg_to_nibble = 4'hD;
      7'b0000110: seg_to_nibble = 4'hE;
      7'b0001110: seg_to_nibble = 4'hF;
      7'b1111111: seg_to_nibble = 4'hF;
      default:    seg_to_nibble = 4'hF;
    endcase
  endfunction

  task automatic hw_reset;
    begin
      SW       = 10'd0;
      KEY      = 4'b1111;
      KEY[0]   = 1'b0;              // KEY0 is active-low reset
      repeat (3) @(posedge CLOCK_50);
      KEY[0]   = 1'b1;
      @(posedge CLOCK_50);
    end
  endtask

  task automatic drive_start(input logic [7:0] key);
    begin
      SW[7:0] = key;
      SW[9]   = 1'b0;
      @(posedge CLOCK_50);
      SW[9]   = 1'b1;
      @(posedge CLOCK_50);
      SW[9]   = 1'b0;
    end
  endtask

  task automatic run_case(input string label, input logic [7:0] key);
    int expected_loc;
    bit expected_found;
    logic [3:0] hi_digit;
    logic [3:0] lo_digit;
    int loc_from_hex;
    begin
      expected_loc   = find_in_mem(key);
      expected_found = (expected_loc != -1);

      $display("%s: search key=0x%0h", label, key);
      drive_start(key);
      wait (dut.assm.ps == 3'd5);
      @(posedge CLOCK_50);
      wait (dut.assm.ps == 3'd0);

      lo_digit     = seg_to_nibble(HEX2);          // ones place (decimal/off)
      hi_digit     = seg_to_nibble(HEX3);          // tens place (decimal/off)

      if (hi_digit == 4'hF && lo_digit == 4'hF) begin
        loc_from_hex = -1; // show as off
      end else begin
        loc_from_hex = (hi_digit * 10) + lo_digit;
      end

      $display("  -> LEDR9=%0b Loc_HEX=%0d (expected %0d)", LEDR[9], loc_from_hex, expected_loc);

      if (LEDR[9] !== expected_found)
        $error("LEDR[9] mismatch for key 0x%0h (expected %0b)", key, expected_found);

      if (expected_found) begin
        if (loc_from_hex !== expected_loc)
          $error("HEX loc mismatch for key 0x%0h (expected %0d)", key, expected_loc);
      end else begin
        if (!(hi_digit == 4'hF && lo_digit == 4'hF))
          $error("HEX loc should be off when value not found (key 0x%0h)", key);
      end
    end
  endtask

  localparam logic [4:0] ON_ADDRS [0:4]  = '{0, 3, 10, 16, 25};
  localparam logic [4:0] OFF_ADDRS[0:4]  = '{8, 9, 12, 20, 30};

  initial begin
    logic [7:0] on_vals [0:4];
    logic [7:0] off_vals[0:4];
    logic [7:0] rand_val;

    wait (mif_loaded);
    hw_reset();

    for (int i = 0; i < 5; i++) begin
      on_vals[i]  = mem[ON_ADDRS[i]];
      off_vals[i] = mem[OFF_ADDRS[i]] + 8'd1;
    end

    for (int i = 0; i < 5; i++) begin
      run_case($sformatf("On-mem test #%0d (addr %0d)", i+1, ON_ADDRS[i]), on_vals[i]);
    end

    for (int i = 0; i < 5; i++) begin
      run_case($sformatf("Off-mem test #%0d (addr %0d + 1)", i+1, OFF_ADDRS[i]), off_vals[i]);
    end

    for (int i = 0; i < 5; i++) begin
      rand_val = $urandom_range(0, 255);
      run_case($sformatf("Random test #%0d", i+1), rand_val);
    end

    $display("DE1_SoC top-level tests completed");
    $finish;
  end
endmodule

