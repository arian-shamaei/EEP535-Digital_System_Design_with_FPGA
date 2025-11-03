# 03 — LFSR & CyberPlayer: 10‑bit LFSR, Comparator, Score Counters

1. Overview

Extend Tug‑of‑War by adding score counters, a 10‑bit LFSR for pseudo‑randomness, a 10‑bit comparator, and a tunable cyber‑player. Slow the game clock for playability.

2. Features

- Two 3‑bit per‑player score counters (0..7) with game/field reset distinctions.
- 10‑bit LFSR using approved XNOR taps (Appendix B).
- 10‑bit unsigned comparator (`A > B`).
- Cyber‑player: generates button presses based on `SW[8:0]` vs. LFSR.

3. Block Diagram

```mermaid
flowchart LR
  CDIV[clock_divider] --> CLK[Game Clock]
  LFSR[LFSR 10b] --> CMP
  SW[SW8..0 (extended to 10b)] --> CMP
  CMP[Comparator A>B] --> CPU_BTN[Cyber Left Edge]
  CPU_BTN --> TOW[Tug-of-War]
  USER_BTN[Right Player Edge] --> TOW
  TOW --> SCORE[Score Counters] --> HEX[HEX Displays]
```

4. Directory Structure

- `rtl/lfsr10.sv` — 10‑bit LFSR.
- `rtl/cmp10.sv` — 10‑bit comparator.
- `rtl/score3.sv` — 3‑bit counter.
- `rtl/cyber_player.sv` — compares LFSR vs. switches to emit edges.
- `DE1_SoC.sv` — Integration with Tug‑of‑War and displays.
- `sim/` — TBs for each module + top.

5. Module Descriptions

- `lfsr10(clk, reset, q[9:0])` — maximal‑length sequence with given taps.
- `cmp10(a[9:0], b[9:0], gt)` — unsigned compare.
- `score3(clk, reset, inc, q[2:0])` — increment on win; roll/hold after 7 as spec allows.
- `cyber_player(clk, reset, sw_val[9:0], lfsr[9:0], edge)` — produce press edges.

6. Interface Specification

- `lfsr10`: `clk` (in), `reset` (in), `q[9:0]` (out).
- `cmp10`: `a[9:0]`, `b[9:0]` (in), `gt` (out).
- `score3`: `clk`, `reset`, `inc` (in), `q[2:0]` (out).
- `cyber_player`: `clk`, `reset`, `sw_val[9:0]`, `lfsr[9:0]` (in), `edge` (out pulse).

7. Timing Diagrams

- LFSR: show state shift per `clk`.
- Comparator: show `gt` toggling as A/B cross.
- Cyber‑player: edge pulses aligned to game clock.

8. Finite State Machine (FSM) Description

- Cyber‑player may be a simple combinational comparator with edge generation; counters are sequential with simple two‑state (hold/increment) behavior.

9. Parameterization

- Game clock select via `whichClock` (e.g., bit 15 ≈ 768 Hz).
- LFSR taps fixed by table; could expose as parameters.

10. Reset Behavior

- Global reset clears scores and playfield; win event only resets playfield.

11. Clocking Requirements

- Entire game clocks from `divided_clocks[N]` for board; `CLOCK_50` for simulation.

12. Build / Simulation Instructions

- Simulate each module; then the integrated top including score and cyber‑player.
- Program board; tune difficulty via `SW[8:0]` threshold.

13. Testbench Architecture

- Directed tests for comparator truth table and counter increments.
- LFSR: sanity over many cycles to ensure no lock‑up.

14. Verification Plan

- Verify scoring increments on wins; max at 7; playfield resets on win.
- Verify cyber‑press rate increases as `SW` threshold rises.

15. Synthesis Notes

- Ensure LFSR feedback uses XOR/XNOR taps that infer well on Cyclone V.

16. Known Issues / Limitations

- LFSR excludes all‑1s; sequence length depends on taps.

17. License

- MIT.

18. Acknowledgments

- EEP 535 materials; Xilinx XAPP 052 for tap references.

