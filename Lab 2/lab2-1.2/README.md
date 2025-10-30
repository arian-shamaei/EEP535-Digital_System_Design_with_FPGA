# Hazard Lights FSM – DE1-SoC Implementation

This project implements an automotive-style **hazard/turn-signal light controller** on the **DE1-SoC FPGA board** using:

* A **4-state finite state machine (FSM)**
* A **clock divider** to slow the 50 MHz clock to a human-visible blinking rate
* Real-time mode switching using SW[1:0]
* LEDR[2:0] to display the animated lighting pattern

---

# 1. System Overview

The system accepts two switch inputs:

| SW[1] | SW[0] | Meaning            |
| ----- | ----- | ------------------ |
| 0     | 0     | Calm (idle)        |
| 0     | 1     | Right → Left sweep |
| 1     | 0     | Left → Right sweep |
| 1     | 1     | Undefined / ignore |

The output controls a 3-LED bar:

```
LEDR[2:0]  →  [Left, Middle, Right]
```

The LEDs animate left-to-right or right-to-left depending on the input mode.

---

# 2. State Machine Design

The FSM uses **four Moore states**, each representing one LED pattern:

| State | Pattern (LEDR[2:0]) | Meaning   |
| ----- | ------------------- | --------- |
| ozo   | 0 1 0               | Center on |
| zoz   | 1 0 1               | Ends on   |
| zzo   | 0 0 1               | Right on  |
| ozz   | 1 1 0               | Left on   |

### State Diagram 

```
             +----------------------+
             |                      |
             v                      |
        +---------+    (A)     +---------+
        |   ozo   | ----------> |   zoz   |
        +---------+             +---------+
             ^   ^                 |   ^
             |   |                 |   |
         (D)|   |(B)           (H)|   |(E)
             |   |                 |   |
        +---------+    (F)     +---------+
        |   zzo   | <---------- |   ozz   |
        +---------+             +---------+
                ^                 |
                |                 |
                +-----------------+
                       (G)
```

Arrows A–H represent transitions determined by SW[1:0].

### Transition Rules 

* `00` → Calm: system cycles through **ozo → zoz → ozo**
* `01` → R→L: cycles **zzo → ozz → zoz → zzo**
* `10` → L→R: cycles **ozz → zzo → zoz → ozz**

---

# 3. Truth Table Summary



```
PS1 PS0 | SW1 SW0 || out[2:0] | NS1 NS0
---------------------------------------
 0   0  |  0   0  || 010      | 0   1
 0   0  |  0   1  || 010      | 0   1
 0   0  |  1   0  || 010      | 0   1

 0   1  |  0   0  || 101      | 0   0
 0   1  |  0   1  || 100      | 1   1
 0   1  |  1   0  || 001      | 1   0

 1   0  |  0   0  || 010      | 0   1
 1   0  |  0   1  || 010      | 0   1
 1   0  |  1   0  || 100      | 1   1

 1   1  |  0   0  || 010      | 0   1
 1   1  |  0   1  || 001      | 1   0
 1   1  |  1   0  || 010      | 0   1
```



---

# 4. Output Logic (Derived Expressions)

From the handwritten Boolean simplifications:

### **out[2]**

```
out[2] = (ps == zoz AND ~in[1])
       | (ps == zzo AND  in[1])
```

### **out[1]**

```
out[1] = (ps == ozo)
       | (ps == ozo AND ~in[1])
       | (ps == zzo AND ~in[1])
       | (ps == ozz AND ~in[0])
```

### **out[0]**

```
out[0] = (ps == zoz AND ~in[0])
       | (ps == ozz AND  in[0])
```

These match the SystemVerilog `assign` statements in the final implementation.

---

# 5. Clock Divider

The DE1-SoC uses a **50 MHz oscillator**, far too fast to visualize LED animation.
A simple binary counter divides the clock:

```
divided_clocks[n] = CLOCK_50 / 2^(n+1)
```

Examples:

| Bit | Frequency |                        |
| --- | --------- | ---------------------- |
| 23  | ~3 Hz     |                        |
| 24  | ~1.5 Hz   |                        |
| 25  | ~0.75 Hz  | ← used in this project |

### Clock Divider Diagram

```
50 MHz → [binary counter] → divided_clocks[25] → 0.75 Hz clock
```

---

# 6. SystemVerilog Code Summary

### **hazard_lights.sv**

FSM with four states, next-state logic, and Boolean output logic.

### **clock_divider.sv**

Simple 32-bit counter producing multiple divided clocks.

### **DE1_SoC.sv** (Top level)

* Reads SW[1:0] as FSM inputs
* SW[9] = async reset
* div_clk[25] used as slow clock
* Outputs LEDR[2:0]

---

# 7. Resource Usage (Quartus Summary)

```
Logic utilization     : 16 ALMs (<1%)
Registers             : 28
Pins used             : 67
DSP / BRAM            : 0
Clock networks        : 1
Device                : 5CSEMA5F31C6 (Cyclone V)
Timing                : MET
```

The design is extremely lightweight.

---

# 8. How to Run on DE1-SoC

1. Load project into Quartus
2. Compile → ensure zero errors
3. Program board with `.sof`
4. Set switches:

   * **SW9 = DOWN** (reset inactive)
   * **SW[1:0]** selects animation mode
5. Observe LEDR[2:0] animate according to selected mode

---


# 9. Conclusion

This project demonstrates a clean, hardware-accurate implementation of a 4-state FSM used to animate hazard/turn-signal lights on the DE1-SoC. The logic was derived by hand from truth tables and state diagrams and implemented in synthesizable SystemVerilog.
