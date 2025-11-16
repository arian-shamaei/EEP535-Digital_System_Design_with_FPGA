# 021 - ASM with Datapath Exercises

Overview
- Practice Algorithmic State Machine (ASM/ASMD) design by implementing small stateful circuits that mix control and datapath (e.g., bit counter).
- Use clearly separated state control, datapath registers, and conditional transitions.

Contents
- `quartus/`: Project files for the ASM exercises.
- `constraints/`: Pin assignments for DE1-SoC I/O.

How to run
- Open and compile the Quartus project.
- Program the board and drive inputs per the lab handout to exercise each ASM design.
- Use HEX/LED outputs to observe state progression and computed results.

What to verify
- State transitions follow the specified ASM chart.
- Datapath updates (counters, shifts, flags) occur in the correct states and yield the expected outputs.
