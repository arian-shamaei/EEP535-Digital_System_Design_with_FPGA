# 01.3 - Memory Using SystemVerilog D-FlipFlops

Overview
- Build a small RAM purely from SystemVerilog flip-flops (no Quartus IP) to understand behavioral vs. structural memory inference.
- Provide read/write control from board switches and display stored values on HEX.

Contents
- `quartus/`: Project with RTL for the DFF-based memory.
- `constraints/`: Pin assignments for DE1-SoC.

How to run
- Compile the project in Quartus and program the DE1-SoC.
- Use SW for address/data and KEY for write enable as specified in the lab handout.
- Use HEX to confirm current address and data values during reads and after writes.

What to verify
- Functional equivalence to the IP-based RAM for the tested depth/width.
- Writes are stored and read back correctly at all addresses.

