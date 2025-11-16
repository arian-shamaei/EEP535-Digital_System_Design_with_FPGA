# 012 - Quartus Library RAM Module

Overview
- Instantiate the Quartus on-chip RAM IP (e.g., 32x4) on the DE1-SoC.
- Initialize contents from a `.mif` file and exercise read/write via board switches, showing outputs on HEX.

Contents
- `quartus/`: Project using the generated RAM IP core.
- `constraints/`: Pin assignments for DE1-SoC I/O.

How to run
- Open the Quartus project, regenerate IP if prompted, then compile.
- Program the board; use SW for address/data and KEY for write enable per the lab handout.
- Observe HEX to confirm initialized contents and that writes take effect on subsequent reads.

What to verify
- Compilation succeeds with the IP core.
- At power-up the RAM reflects `.mif` initialization.
- Manual writes update the addressed locations and display correctly.
