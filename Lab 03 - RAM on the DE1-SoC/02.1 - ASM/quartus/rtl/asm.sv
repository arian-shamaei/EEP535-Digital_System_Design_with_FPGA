module asm #(parameter WIDTH = 4)
(
    input  logic        clk,
    input  logic        reset_n,     // active-low reset
    input  logic        s,           // start/continue
    input  logic [8:0]  addr
    output logic        done,        // high in S3
    output logic [3:0]  result       // final popcount
);


	// ram is used to load A
    logic [3:0] ram_dout;

    ram32x4 u_ram (
        .addr (addr),
        .clk  (clk),
        .din  (4'h0),
        .w    (1'b0),
        .dout (ram_dout)
    );

    // shift right module setup
    logic        sr_start, sr_reset, sr_done;
    logic [7:0]  sr_valueIn;
    logic [3:0]  sr_result;

    // assign RAM output into the low 4 bits
    assign result     = sr_result;

    shiftRight u_shiftRight (
        .start   (sr_start),
        .reset   (sr_reset),
        .valueIn (addr),
        .clk     (clk),
        .result  (sr_result),
        .done    (sr_done)
    );

    // state machine
    typedef enum logic [1:0] {LOAD=2'b00, S1=2'b01, S2=2'b10, S3=2'b11}  ps, ns

    always_comb begin
        ns       = ps;         // default
        done     = 1'b0;
        sr_start = 1'b0;
        sr_reset = 1'b0;

        case (ps)

            // Load A
            LOAD: begin
                sr_reset = ~reset_n;   // initialize right Shift
                if (s)
                    ns = S1;
            end

            // S1: result == 0
            S1: begin
                sr_reset = 1'b1;       // load valueIn + clear popcount
                if (s)  ns = S2;
                else    ns = LOAD;
            end

            // S2: right shift
            S2: begin
                sr_start = 1'b1;       // run shiftRight
                if (sr_done) begin     // if A == 0
                    if (s) ns = S3;
                    else   ns = LOAD;
                end
            end

            // S3: Done
            S3: begin
                done = 1'b1;
                if (!s) ns = LOAD;
            end

            default: ns = LOAD;
        endcase
    end

    // state registers
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            ps <= LOAD;
        else
            ps <= ns;
    end

endmodule







`timescale 1ns/1ps

module asm_tb;

  logic clk, reset_n;
  logic        s;
  logic [4:0]  addr;
  logic        done;
  logic [3:0]  result;

 
  asm dut (
    .clk     (clk),
    .reset_n (reset_n),
    .s       (s),
    .addr    (addr),
    .done    (done),
    .result  (result)
  );

  // clk
  localparam int TCLK = 10;
  initial clk = 1'b0;
  always #(TCLK/2) clk = ~clk;

  // I like to think in terms of images being A
  logic [3:0] img [0:31];

  // static temps for force
  int          idx;
  logic [3:0]  din_tmp;

  // pop count is amount of 1s in a word
  function automatic [3:0] pop4(input logic [3:0] x);
    return x[0] + x[1] + x[2] + x[3];
  endfunction

  // program RAM
  task automatic prog_dut_ram_all;
    int i;
    s = 1'b0;                 
    @(posedge clk);

    for (i = 0; i < 32; i++) begin
      addr    = i[4:0];
      idx     = i;
      din_tmp = img[idx];

      force dut.u_ram.din = din_tmp;
      force dut.u_ram.w   = 1'b1;
      @(posedge clk);
      force dut.u_ram.w   = 1'b0;
      @(posedge clk);
    end

    release dut.u_ram.din;
    release dut.u_ram.w;
  endtask

  // test run
  task automatic run_one(input int a);
    logic [3:0] expt;
    addr = a[4:0];

    @(posedge clk);  
    s = 1'b1;                 // start the ASM (LOAD → S1 → S2 → S3)
    wait (done === 1'b1);     // wait for shiftRight to finish

    @(posedge clk);

    expt = pop4(img[a]);

    if (result !== expt)
      $error("ADDR %0d: expected %0d for A=0x%0h, got %0d",
              a, expt, img[a], result);

    s = 1'b0;                 // drop s → FSM returns to LOAD
    @(posedge clk);
  endtask

  // stimulus
  initial begin
    // default contents: img[i] = i[3:0]
    for (int i = 0; i < 32; i++)
      img[i] = i[3:0];

    // Reset
    s = 1'b0;
    addr = '0;
    reset_n = 1'b0; repeat (3) @(posedge clk);
    reset_n = 1'b1; @(posedge clk);

    // Program RAM
    prog_dut_ram_all();

    // Run tests
    run_one(0);
    run_one(1);
    run_one(2);
    run_one(3);
    run_one(4);
    run_one(5);
    run_one(10);
    run_one(15);
    run_one(31);

    $display("All tests completed.");
    $finish;
  end

endmodule









