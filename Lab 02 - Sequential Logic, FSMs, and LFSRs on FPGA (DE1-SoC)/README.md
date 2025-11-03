# Lab 02 — Sequential Logic, FSMs, and LFSRs on FPGA (DE1‑SoC)

1. Overview

Design, simulate, and integrate sequential logic on DE1‑SoC: Mealy FSMs, communicating modular FSMs with input synchronization, and LFSR‑based pseudo‑random generators integrated into an interactive game.

2. Features

- Mealy sequence detector and Hazard Lights sequencer.
- Modular “Tug‑of‑War” with edge‑detected user inputs and two‑DFF synchronizers.
- 10‑bit LFSR, 10‑bit comparator, per‑player score counters, and a tunable cyber‑player.
- Clock division for human‑visible rates; direct 50 MHz operation where specified.

3. Block Diagram

```mermaid
flowchart TB
  subgraph FSMs
    S1[Mealy Detector]
    HL[Hazard Lights]
    TOW[Tug-of-War Modular FSMs]
  end
  CDIV[clock_divider] -->|divided_clocks[x]| TOW
  CLOCK50[CLOCK_50] --> S1
  CLOCK50 --> HL
  INP[KEY/SW + 2-DFF Sync + Edge Detect] --> TOW
  LFSR[LFSR 10-bit] --> CMP[Comparator 10-bit]
  SW9[SW switches] --> CMP
  CMP --> TOW
  S1 --> OUT1[LED/HEX]
  HL --> OUT2[LEDs]
  TOW --> OUT3[LEDR/HEX0]
```

4. Directory Structure

- `01 - Sequential FSMs - Mealy Detector (DE1-SoC)`: Simple Mealy FSM and board integration.
- `011 - Hazard Lights FMS`: Hazard Lights LED sequencer project.
- `02 - Communicating Sequential Logic - Tug-of-War with Synchronizers`: Modular FSM game.
- `03 - LFSR and CyberPlayer - 10-bit LFSR, Comparator, Score Counters`: CyberWar integration.

5. Module Descriptions

- `simple(clk, reset, w, out)`: Mealy sequence detector with three states.
- `clock_divider(clock, reset, divided_clocks)`: 32‑bit counter exposing divided clocks.
- `hazard_lights(...)`: Directional/calm LED sequencer with reset.
- `edge_detect(...)`: Detects rising edges of debounced, synchronized keys.
- `sync_2ff(clk, d, q)`: Two‑DFF synchronizer for metastability mitigation.
- `lfsr10(clk, reset, q[9:0])`: 10‑bit LFSR using approved XNOR taps.
- `cmp10(a[9:0], b[9:0], gt)`: Unsigned comparator, high when `a > b`.
- `score3(clk, reset, inc, q[2:0])`: 3‑bit up‑counter with win threshold at 7.

6. Interface Specification

- `simple`: `clk` (in), `reset` (in), `w` (in), `out` (out, 1 when in `got_two`).
- `clock_divider`: `clock` (in, 50 MHz), `reset` (in), `divided_clocks[31:0]` (out).
- `hazard_lights`: `clk` (in), `reset` (in), wind inputs, three LED outputs.
- `sync_2ff`: `clk` (in), `d` (in async), `q` (out sync).
- `edge_detect`: `clk` (in), `din` (in), `rise` (out one‑cycle pulse).
- `lfsr10`: `clk` (in), `reset` (in), `q[9:0]` (out state).
- `cmp10`: `a[9:0]` (in), `b[9:0]` (in), `gt` (out).
- `score3`: `clk` (in), `reset` (in), `inc` (in), `q[2:0]` (out).

7. Timing Diagrams

- Mealy detector: show `w` vs. state vs. `out` over several cycles.
- Edge detection: demonstrate one‑cycle pulse on button rising edge.
- LFSR: show bit‑sequence advancement per `clk`.

8. Finite State Machine (FSM) Description

- `simple`: states `{none, got_one, got_two}` with transitions on `w`.
- `hazard_lights`: small looped sequences per wind mode with synchronous reset.
- Tug‑of‑War lights: each light FSM ≤4 states managing on/off transfer.

9. Parameterization

- `whichClock` selects divided clock bit for board operation.
- LFSR taps fixed per Appendix B; could be parameterized if needed.

10. Reset Behavior

- Synchronous resets in examples (`always_ff @ (posedge clk)`).
- Global reset via `SW[9]` where used.

11. Clocking Requirements

- Use `CLOCK_50` for simulation topologies unless intentionally slowed.
- Board demos may use `divided_clocks[N]` (e.g., `[15]` ~768 Hz).
- CDC: synchronize KEY inputs with two DFFs; then edge‑detect.

12. Build / Simulation Instructions

- ModelSim/Questa: compile `rtl` + `*_testbench.sv`; run; save waveforms.
- Quartus+ModelSim: manage projects, pin assignments, simulate, program.
- Vivado/Verilator: not used for this course flow.

13. Testbench Architecture

- Stimulus: clock gen, resets, input sequences per module.
- Assertions: check one‑hot light behavior; score increments; `gt` correctness.
- Coverage: state/transition coverage for FSMs; range coverage for LFSR outputs (spot‑check).

14. Verification Plan

- Mealy/Hazard: transition coverage + output checks.
- Tug‑of‑War: single‑press moves; no repeats per press; win detection.
- LFSR/Comparator: non‑stuck sequence; comparator truth for sampled pairs.

15. Synthesis Notes

- Subtract clock divider resources when reporting FSM size.
- Keep fan‑in modest to map well to Cyclone V LUTs.

16. Known Issues / Limitations

- LFSR excludes all‑1s state; sequence length depends on taps.
- Button bounce not modeled; edge‑detect assumes debounced or adequately filtered input after sync.

17. License

- MIT (unless repository LICENSE overrides).

18. Acknowledgments

- Course staff and references cited in lab handouts (including Xilinx XAPP 052 for LFSR taps).

