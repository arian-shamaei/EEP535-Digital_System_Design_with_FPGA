typedef enum logic [2:0] {
    S_IDLE,
    S_WAIT_ADDR,
    S_WAIT_RAM,
    S_COMPARE,
    S_UPDATE,
    S_DONE
} state_t;

module binsearch (
    input  logic        CLOCK_50,
    input  logic        Reset,
    input  logic        Start,
    input  logic [7:0]  a,
    output logic [4:0]  Loc,
    output logic        Found,
    output logic        Done
);
    localparam int SIZE = 32;
    localparam logic [4:0] MID = 5'd16;
    localparam logic [4:0] MAX_ADDR = 5'd31;
    localparam logic [4:0] DELTA_INIT = 5'b10000;

    state_t ps, ns;

    logic [4:0] ptr_cur;
    logic [4:0] ptr_addr;
    logic [4:0] delta_reg;
    logic [5:0] iter_reg;

    logic [7:0] ram_q;
    logic [7:0] reg_ptr;

    logic [4:0] ptr_addr_next;
    logic [4:0] delta_next;
    logic [5:0] iter_next;
    logic       found_next;
    logic [4:0] loc_next;

    logic [4:0] delta_shifted;
    logic [4:0] delta_step;
    logic [4:0] adder_B;
    logic       adder_is_sub;
    logic [4:0] adder_result;

    shiftNoshift u_delta_stepper (
        .dataIn  (delta_reg),
        .dataOut (delta_shifted)
    );

    assign delta_step = (delta_shifted == 5'd0) ? 5'd1 : delta_shifted;

    adderSubtractor u_ptr_math (
        .A   (ptr_cur),
        .B   (adder_B),
        .ctr (adder_is_sub),
        .out (adder_result)
    );

    ram32x8 rom (
        .address (ptr_addr),
        .clock   (CLOCK_50),
        .data    (8'b0),
        .wren    (1'b0),
        .q       (ram_q)
    );

    binsearch_ctrl #(
        .SIZE      (SIZE),
        .MID       (MID),
        .MAX_ADDR  (MAX_ADDR),
        .DELTA_INIT(DELTA_INIT)
    ) ctrl (
        .Start        (Start),
        .a            (a),
        .reg_ptr      (reg_ptr),
        .ptr_cur      (ptr_cur),
        .ptr_addr     (ptr_addr),
        .delta_reg    (delta_reg),
        .delta_step   (delta_step),
        .iter_reg     (iter_reg),
        .Found        (Found),
        .Loc          (Loc),
        .ps           (ps),
        .adder_result (adder_result),
        .ptr_next     (ptr_addr_next),
        .delta_next   (delta_next),
        .iter_next    (iter_next),
        .found_next   (found_next),
        .loc_next     (loc_next),
        .adder_B      (adder_B),
        .adder_is_sub (adder_is_sub),
        .ns           (ns)
    );

    always_ff @(posedge CLOCK_50) begin
        if (Reset) begin
            ps        <= S_IDLE;
            ptr_cur   <= MID;
            ptr_addr  <= MID;
            delta_reg <= DELTA_INIT;
            iter_reg  <= 6'd0;
            Found     <= 1'b0;
            Loc       <= 5'd0;
            reg_ptr   <= 8'd0;
        end else begin
            ps        <= ns;
            ptr_addr  <= ptr_addr_next;
            delta_reg <= delta_next;
            iter_reg  <= iter_next;
            Found     <= found_next;
            Loc       <= loc_next;

            if (ps == S_WAIT_RAM) begin
                reg_ptr <= ram_q;
                ptr_cur <= ptr_addr;
            end
        end
    end

    assign Done = (ps == S_DONE);

endmodule














module binsearch_ctrl #(
    parameter int SIZE = 32,
    parameter logic [4:0] MID = 5'd16,
    parameter logic [4:0] MAX_ADDR = 5'd31,
    parameter logic [4:0] DELTA_INIT = 5'b10000
) (
    input  logic        Start,
    input  logic [7:0]  a,
    input  logic [7:0]  reg_ptr,
    input  logic [4:0]  ptr_cur,
    input  logic [4:0]  ptr_addr,
    input  logic [4:0]  delta_reg,
    input  logic [4:0]  delta_step,
    input  logic [5:0]  iter_reg,
    input  logic        Found,
    input  logic [4:0]  Loc,
    input  state_t      ps,
    input  logic [4:0]  adder_result,
    output logic [4:0]  ptr_next,
    output logic [4:0]  delta_next,
    output logic [5:0]  iter_next,
    output logic        found_next,
    output logic [4:0]  loc_next,
    output logic [4:0]  adder_B,
    output logic        adder_is_sub,
    output state_t      ns
);
    always_comb begin
        logic [4:0] ptr_candidate;
        logic [5:0] ptr_sum_ext;
        logic       direction_is_sub;
        logic       stuck;

        ns           = ps;
        ptr_next     = ptr_addr;
        delta_next   = delta_reg;
        iter_next    = iter_reg;
        found_next   = Found;
        loc_next     = Loc;
        adder_B      = 5'd0;
        adder_is_sub = 1'b0;

        case (ps)
            S_IDLE: begin
                if (Start) begin
                    ptr_next   = MID;
                    delta_next = DELTA_INIT;
                    iter_next  = 6'd0;
                    found_next = 1'b0;
                    loc_next   = 5'd0;
                    ns         = S_WAIT_ADDR;
                end
            end

            S_WAIT_ADDR: begin
                ns = S_WAIT_RAM;
            end

            S_WAIT_RAM: begin
                ns = S_COMPARE;
            end

            S_COMPARE: begin
                if (a == reg_ptr) begin
                    found_next = 1'b1;
                    loc_next   = ptr_cur;
                    ns         = S_DONE;
                end else if (iter_reg >= SIZE) begin
                    found_next = 1'b0;
                    loc_next   = 5'd0;
                    ns         = S_DONE;
                end else begin
                    ns = S_UPDATE;
                end
            end

            S_UPDATE: begin
                direction_is_sub = (a < reg_ptr);
                adder_B          = delta_step;
                adder_is_sub     = direction_is_sub;

                ptr_candidate = ptr_cur;
                ptr_sum_ext   = {1'b0, ptr_cur} + {1'b0, delta_step};

                if (direction_is_sub) begin
                    if (ptr_cur <= delta_step)
                        ptr_candidate = 5'd0;
                    else
                        ptr_candidate = adder_result;
                end else begin
                    if (ptr_sum_ext >= SIZE)
                        ptr_candidate = MAX_ADDR;
                    else
                        ptr_candidate = adder_result;
                end

                stuck      = (ptr_candidate == ptr_cur);
                delta_next = delta_step;
                iter_next  = iter_reg + 6'd1;

                if ((iter_next >= SIZE) || stuck) begin
                    found_next = 1'b0;
                    loc_next   = 5'd0;
                    ns         = S_DONE;
                end else begin
                    ptr_next = ptr_candidate;
                    ns       = S_WAIT_ADDR;
                end
            end

            S_DONE: begin
                if (!Start) begin
                    ns = S_IDLE;
                end
            end
        endcase
    end
endmodule


`timescale 1ns/1ps

module binsearch_tb;

  localparam int SIZE  = 32;
  localparam int WIDTH = 5;

  // DUT I/O
  logic        CLOCK_50;
  logic        Reset;
  logic        Start;
  logic [7:0]  a;
  logic [4:0]  Loc;
  logic        Found;
  logic        Done;

  // DUT
  binsearch dut (
    .CLOCK_50 (CLOCK_50),
    .Reset    (Reset),
    .Start    (Start),
    .a        (a),
    .Loc      (Loc),
    .Found    (Found),
    .Done     (Done)
  );

  // clock: 100 MHz (10 ns period)
  initial CLOCK_50 = 1'b0;
  always  #5 CLOCK_50 = ~CLOCK_50;

  // Reference memory loaded from MIF
  logic [7:0] mem [0:SIZE-1];
  string mif_path = "../../memory/my_sorted_array.mif";
  bit    mif_loaded;
  bit    in_content;

  initial begin
    int fd;
    string line, token;
    int addr, data;
    in_content = 1'b0;
    mem = '{default:8'd0};
    fd = $fopen(mif_path, "r");
    if (fd == 0) begin
      $fatal(1, "Unable to open %s", mif_path);
    end

    // Skip header until CONTENT
    while (!$feof(fd) && !in_content) begin
      if (!$fgets(line, fd)) break;
      if ($sscanf(line, "%s", token) == 1 && (token == "CONTENT" || token == "content")) begin
        in_content = 1;
      end
    end
    if (!in_content) begin
      $fatal(1, "CONTENT block not found in %s", mif_path);
    end

    // Read address/data pairs
    while (!$feof(fd)) begin
      if (!$fgets(line, fd)) break;
      if ($sscanf(line, "%s", token) == 1 && (token == "END;" || token == "END")) begin
        break;
      end
      if ($sscanf(line, " %d : %b ;", addr, data) == 2) begin
        if (addr >= 0 && addr < SIZE) begin
          mem[addr] = data[7:0];
        end
      end
    end
    $fclose(fd);
    mif_loaded = 1'b1;
  end

  // returns index of a in mem, or -1 if not present
  function automatic int find_in_mem (input logic [7:0] val);
    for (int idx = 0; idx < SIZE; idx++) begin
      if (mem[idx] == val)
        return idx;
    end
    return -1;
  endfunction

  // reset task
  task automatic do_reset;
    begin
      Reset = 1'b1;
      Start = 1'b0;
      a     = 8'd0;
      repeat (3) @(posedge CLOCK_50);
      Reset = 1'b0;
      @(posedge CLOCK_50);
    end
  endtask

  task automatic run_search(input string label, input logic [7:0] key);
    int expected_loc;
    bit expected_found;
    begin
      do_reset();
      $display("%s: search key=0x%0h", label, key);
// synopsys translate_off
      if (label == "On-mem test #1 (addr 0)") begin : monitor_block
        fork
          begin
            int step = 0;
            while (dut.ps != S_DONE) begin
              @(posedge CLOCK_50);
              if (dut.ps == S_COMPARE) begin
                $display("    step %0d: ptr_cur=%0d ptr_addr=%0d delta=%0d iter=%0d reg_ptr=0x%0h a=0x%0h cmp=%0b",
                         step, dut.ptr_cur, dut.ptr_addr, dut.delta_reg, dut.iter_reg, dut.reg_ptr, dut.a, (dut.a > dut.reg_ptr));
                step++;
              end
            end
          end
        join_none;
      end
// synopsys translate_on
      a     = key;
      Start = 1'b1;
      @(posedge CLOCK_50);
      Start = 1'b0;
      wait (dut.ps == S_DONE);
      @(posedge CLOCK_50);
// synopsys translate_off
      if (label == "On-mem test #1 (addr 0)") begin
        disable monitor_block;
      end
// synopsys translate_on
      expected_loc   = find_in_mem(key);
      expected_found = (expected_loc != -1);
      $display("  -> Found=%0b Loc=%0d (expected Loc=%0d) ptr_cur=%0d ptr_addr=%0d delta=%0d iter=%0d reg_ptr=0x%0h",
               Found, Loc, expected_loc, dut.ptr_cur, dut.ptr_addr, dut.delta_reg, dut.iter_reg, dut.reg_ptr);
      if (Found !== expected_found) begin
        $error("Found mismatch for key 0x%0h", key);
      end
      if (expected_found && (Loc !== expected_loc[4:0])) begin
        $error("Location mismatch for key 0x%0h (expected %0d)", key, expected_loc);
      end
    end
  endtask

  localparam logic [4:0] ON_ADDRS [0:4]  = '{0, 3, 10, 16, 25};
  localparam logic [4:0] OFF_ADDRS[0:4]  = '{8, 9, 12, 20, 30};

  // stimulus
  initial begin
    logic [7:0] on_vals [0:4];
    logic [7:0] off_vals[0:4];
    logic [7:0] rand_val;
    int idx;

    Reset = 1'b0;
    Start = 1'b0;
    a     = 8'd0;

    wait (mif_loaded);

    for (idx = 0; idx < 5; idx++) begin
      on_vals[idx]  = mem[ON_ADDRS[idx]];
      off_vals[idx] = mem[OFF_ADDRS[idx]] + 8'd1;
    end

    for (idx = 0; idx < 5; idx++) begin
      run_search($sformatf("On-mem test #%0d (addr %0d)", idx+1, ON_ADDRS[idx]), on_vals[idx]);
    end

    for (idx = 0; idx < 5; idx++) begin
      run_search($sformatf("Off-mem test #%0d (addr %0d + 1)", idx+1, OFF_ADDRS[idx]), off_vals[idx]);
    end

    for (idx = 0; idx < 5; idx++) begin
      rand_val = $urandom_range(0, 255);
      run_search($sformatf("Random test #%0d", idx+1), rand_val);
    end

    $display("Simulation finished");
    $stop;
  end

  // Assertions
  property p_reset_init;
    @(posedge CLOCK_50)
      Reset |-> (dut.ptr_cur == (SIZE/2) &&
                 dut.ptr_addr == (SIZE/2) &&
                 dut.delta_reg == 5'b10000 &&
                 dut.iter_reg == 6'd0);
  endproperty
  assert property (p_reset_init)
    else $error("RESET init failed: ptr/delta/iter not correct");

  property p_ptr_in_range;
    @(posedge CLOCK_50)
      (dut.ptr_cur < SIZE) && (dut.ptr_addr < SIZE);
  endproperty
  assert property (p_ptr_in_range)
    else $error("ptr out of range (>=%0d)", SIZE);

  property p_found_means_equal;
    @(posedge CLOCK_50)
      Found |-> (a == dut.reg_ptr);
  endproperty
  assert property (p_found_means_equal)
    else $error("Found=1 but a != reg_ptr");

  int  expected_loc;
  bit  expected_found;
  always_comb begin
    if (mif_loaded) begin
      expected_loc   = find_in_mem(a);
      expected_found = (expected_loc != -1);
    end else begin
      expected_loc   = -1;
      expected_found = 1'b0;
    end
  end

  property p_done_correct;
    @(posedge CLOCK_50)
      (dut.ps == S_DONE) |->
        (Found == expected_found) &&
        (!Found || (Loc == expected_loc[4:0]));
  endproperty
  assert property (p_done_correct)
    else $error("Result in DONE does not match reference memory");

endmodule
