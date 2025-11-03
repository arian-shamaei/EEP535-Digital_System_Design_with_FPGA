; Create work library
vlib work

; Compile RTL (relative paths)
vlog ../../rtl/button_sync.sv
vlog ../../rtl/edge_pulse.sv
vlog ../../rtl/clock_divider.sv
vlog ../../rtl/seg7_digit.sv
vlog ../../rtl/tugowar.sv
vlog ../../rtl/lfsr10.sv
vlog ../../rtl/comparator10.sv
vlog ../../rtl/cyber_player.sv
vlog ../../rtl/DE1_SoC.sv

; Simulate DE1_SoC testbench
vsim -voptargs="+acc" -t 1ps -lib work DE1_SoC_testbench

; Wave setup
do wave_part3.do

view wave
view structure
view signals

run -all

