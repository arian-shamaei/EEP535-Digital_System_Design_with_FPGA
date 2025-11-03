# Lab 01 — Combinational Logic and RTL on FPGA (DE1‑SoC)

1. Overview

High-level description of what the module/system does.
- Introduces DE1‑SoC hardware, Quartus Prime Lite, and ModelSim.
- Designs and simulates combinational logic and high‑level (RTL) Verilog.
- Drives LEDs and seven‑segment displays directly from switch inputs.

2. Features

- Combinational RTL examples: `mux2_1`, `mux4_1`, equality checkers, decoders.
- Logic minimization with K‑Maps for multi‑level logic (UPC detector).
- Seven‑segment display encoder (`seg7`) and multi‑digit display integration.
- Simulation-first workflow with ModelSim; FPGA bring‑up on DE1‑SoC.

3. Block Diagram

```mermaid
flowchart LR
  SW[Board Switches] --> Logic[Combinational RTL]\n(mux/decoder/equality)
  Logic --> LEDR[LEDs]
  SW --> SegIn[seg7 Encoders]
  SegIn --> HEX[HEX0..HEX5]
```

4. Directory Structure

- `Lab 1 Files/01.3 - Combinational MUX Design and Simulation (ModelSim)`: `mux2_1`, `mux4_1` and testbench.
- `Lab 1 Files/02.1 - Two-Digit Equality Checker - Combinational RTL on DE1-SoC`: switch-driven equality checker.
- `Lab 1 Files/02.2 - UPC Feature Detector - Multi-Level Logic (K-Maps)`: minimized UPC detector.
- `Lab 1 Files/03.1 - Seven-Segment Decoder - Combinational Display Encoder`: `seg7` modules and demo top.
- `Lab 1 Files/03.2 - UPC to HEX Display - Combinational RTL Pipeline`: multi‑display text/pictogram mapping.

5. Module Descriptions

- `mux2_1`: 2:1 multiplexer; selects between two inputs by `sel`.
- `mux4_1`: 4:1 multiplexer; selects one of four inputs via 2‑bit select.
- `seg7`: BCD‑to‑7‑segment decoder (0–9) with default don’t‑care.
- `DE1_SoC` (Lab 1 tops): Maps board I/O; routes switches to logic and HEX.

6. Interface Specification

- `mux2_1(a, b, sel, y)`
  - `a,b`: 1‑bit inputs; `sel`: 1‑bit select; `y`: 1‑bit output.
- `mux4_1(d0..d3, s1, s0, y)`
  - `d0..d3`: 1‑bit inputs; `s1,s0`: selects; `y`: 1‑bit output.
- `seg7(bcd[3:0], leds[6:0])`
  - `bcd`: 4‑bit digit; `leds`: active‑high 7‑segment lines (gfedcba).
- `DE1_SoC(HEX[5:0], LEDR[9:0], KEY[3:0], SW[9:0])`
  - Maps `SW` to logic; drives `LEDR`/`HEX` outputs.

7. Timing Diagrams

- Combinational designs have zero-cycle latency in simulation; physical propagation delay depends on fitter.
- For testbenches, show input changes followed by immediate output updates in waveforms.

8. Finite State Machine (FSM) Description

- Lab 1 focuses on combinational logic; no FSMs required in these tasks.

9. Parameterization

- Use parameters only as needed (e.g., vector widths); `seg7` has fixed mapping for 0–9.

10. Reset Behavior

- Purely combinational modules: no reset. Top files may zero HEX by default assignments.

11. Clocking Requirements

- No clocks used in combinational tasks. Simulation uses `#` delays in testbenches only.

12. Build / Simulation Instructions

- ModelSim / Questa: Compile RTL + testbench; run; capture waveforms.
- Quartus + ModelSim: Use Quartus to manage files; launch ModelSim simulation.
- Vivado/Verilator: Not used in this lab.

13. Testbench Architecture

- Stimulus: `initial` blocks with for‑loops to iterate inputs.
- Checks: Visual comparison via waveforms; optional `$display` asserts.
- Coverage: Ensure all select/data combinations are exercised.

14. Verification Plan

- MUX: All input/select permutations produce expected `y`.
- Equality Checker: Only the target two digits assert `LEDR[0]`.
- seg7: Digits 0–9 match expected segment patterns; default is don’t‑care.

15. Synthesis Notes

- Use `default: 'bx` for don’t‑care to enable optimization.
- Multi‑level UPC detector: minimize using K‑Maps for fewer LUTs.

16. Known Issues / Limitations

- `seg7` maps only decimal digits by default; hex A–F not included.
- Board orientation and active polarity may vary with constraints.

17. License

- MIT License (unless repository LICENSE specifies otherwise).

18. Acknowledgments

- Course staff and materials for EEP 535. Terasic DE1‑SoC references.

