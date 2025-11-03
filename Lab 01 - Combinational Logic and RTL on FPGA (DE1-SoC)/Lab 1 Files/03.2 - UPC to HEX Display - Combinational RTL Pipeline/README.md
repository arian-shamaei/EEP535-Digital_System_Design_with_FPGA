This section extends the Lab 2 UPC checker on the DE1‑SoC by adding a product description
  on HEX5..HEX0 to catch UPC sticker swaps. 

Purpose

- Design, simulate, and implement basic combinational logic on the DE1-SoC board, driving LEDs and six seven-segment displays from slide switches. Verify behavior in ModelSim and on hardware.

Hardware

- Board: Terasic DE1-SoC (Intel Cyclone V 5CSEMA5F31C6)
- I/O used: SW[9:0] (inputs), KEY[3:0] (inputs), LEDR[9:0] (outputs), HEX5..HEX0 (outputs)
- Seven-seg displays are active-low; patterns are inverted at the top level before driving the board.

Design Overview

- Top-level: rtl/DE1_SoC.sv:1
  - Control bits from switches: U = SW[9], P = SW[8], C = SW[7], mode M = SW[0].
  - LED logic:
    - LEDR[1] = U | (P & C)
    - LEDR[0] = (~P & ~M) | (U & ~M)
  - Display logic: rtl/seg7.sv:1 decodes {U,P,C} to fixed words across HEX5..HEX0, then the top level inverts to active-low.

Seven-Segment Mapping (by {U,P,C})

- 000 → CABLE
- 001 → FUDGE
- 010 → BREAD
- 011 → CHAIR
- 100 → BEAMS
- 111 → FLUID
- others → don’t care (all segments X)

Files and Flow

- Sources: rtl/ (DE1_SoC.sv, seg7.sv, mux2_1.sv, mux4_1.sv)
- Constraints: constraints/DE1_SoC.sdc (timing); device/pin assignments in quartus/DE1_SoC.qsf
- Quartus project: open quartus/DE1_SoC.qpf; build outputs in quartus/build/ (DE1_SoC.sof, reports)
- Simulation: sim/modelsim/runlab.do compiles ../rtl/* and runs DE1_SoC_testbench

