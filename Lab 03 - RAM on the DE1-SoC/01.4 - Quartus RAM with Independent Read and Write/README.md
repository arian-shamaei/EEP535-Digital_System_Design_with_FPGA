# 01.4 - Quartus RAM with Independent Read and Write

Overview
- Configure a Quartus-generated RAM with separate read and write addresses to explore dual-port style access.
- Demonstrate writing new data while simultaneously reading another address using DE1-SoC I/O.

Contents
- `quartus/`: Project with the independent read/write RAM IP.
- `constraints/`: Pin assignments for switches, keys, and HEX displays.

How to run
- Open and compile the Quartus project; regenerate IP if asked.
- Map SW to read/write addresses and data per the lab handout; use KEY for write enable.
- Observe HEX outputs for both the addressed data and any changes after writes.

What to verify
- Writes occur only when enabled and affect the correct write address.
- Reads reflect the selected read address even while writes target a different address.

