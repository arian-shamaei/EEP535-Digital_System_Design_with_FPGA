# EEP 535 Labs - FPGA Digital Systems with DE1-SoC

This repository organizes lab materials and student projects for EEP 535. Labs target the Terasic DE1-SoC FPGA board using Quartus Prime Lite and ModelSim.

## Index

- Lab 01 - Combinational Logic and RTL on FPGA (DE1-SoC)
  - Path: `Lab 01 - Combinational Logic and RTL on FPGA (DE1-SoC)`
  - Focus: Combinational RTL, K-Maps, seven-segment display encoding, simulation-first flow.
  - Sublabs (under `Lab 1 Files`):
    - `01.3 - Combinational MUX Design and Simulation (ModelSim)` - 2:1 and 4:1 MUX design/sim.
    - `02.1 - Two-Digit Equality Checker - Combinational RTL on DE1-SoC` - Switch-driven equality.
    - `02.2 - UPC Feature Detector - Multi-Level Logic (K-Maps)` - Discounted/Stolen detector.
    - `03.1 - Seven-Segment Decoder - Combinational Display Encoder` - seg7 decoder and demo.
    - `03.2 - UPC to HEX Display - Combinational RTL Pipeline` - Multi-display text mapping.

- Lab 02 - Sequential Logic, FSMs, and LFSRs on FPGA (DE1-SoC)
  - Path: `Lab 02 - Sequential Logic, FSMs, and LFSRs on FPGA (DE1-SoC)`
  - Focus: FSMs, input synchronization, clock division, LFSR pseudo-randomness, game integration.
  - Sublabs:
    - `01.1 - Sequential FSMs - Mealy Detector (DE1-SoC)` - Mealy sequence detector integration.
    - `01.2 - Hazard Lights FMS` - Hazard Lights LED sequencer (clock divider + reset).
    - `02.1 - Communicating Sequential Logic - Tug-of-War with Synchronizers` - Modular game FSMs.
    - `03.1 - LFSR and CyberPlayer - 10-bit LFSR, Comparator, Score Counters` - CyberWar integration.

- Lab 03 - RAM on the DE1-SoC
  - Path: `Lab 03 - RAM on the DE1-SoC`
  - Focus: FPGA RAM implementations using Quartus IP, flip-flop-based memory, dual-port variants, and datapath/ASM exercises.
  - Sublabs:
    - `01.2 - Quartus Library RAM Module`
    - `01.3 - Memory Using SystemVerilog D-FlipFlops`
    - `01.4 - Quartus RAM with Independent Read and Write`
    - `02.1 - ASM`
    - `02.2 - Register Lookup Through Binary Search`

## Tooling

- Quartus Prime Lite (Cyclone V device support)
- ModelSim/Questa (Intel FPGA Edition)

## Getting Started

1. Open a sublab folder in Quartus; review its README for details.
2. Simulate in ModelSim; then compile and program DE1-SoC for hardware demos.

## License

Unless otherwise noted in a subfolder, content is provided under the MIT License.