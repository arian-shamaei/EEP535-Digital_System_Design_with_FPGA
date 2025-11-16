; Basic wave configuration for Part 3
onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -divider {Clocks & Reset}
add wave -radix unsigned sim:/DE1_SoC_testbench/CLOCK_50
add wave sim:/DE1_SoC_testbench/dut/clk_game
add wave sim:/DE1_SoC_testbench/dut/reset
add wave sim:/DE1_SoC_testbench/dut/soft_reset

add wave -divider {Inputs}
add wave sim:/DE1_SoC_testbench/KEY
add wave sim:/DE1_SoC_testbench/SW
add wave sim:/DE1_SoC_testbench/dut/cyber_thresh
add wave sim:/DE1_SoC_testbench/dut/cyber_press

add wave -divider {Core}
add wave -radix hex sim:/DE1_SoC_testbench/dut/leds_9
add wave sim:/DE1_SoC_testbench/dut/done
add wave sim:/DE1_SoC_testbench/dut/winner

add wave -divider {Scores}
add wave sim:/DE1_SoC_testbench/dut/score_left
add wave sim:/DE1_SoC_testbench/dut/score_right

TreeUpdate [SetDefaultTree]
