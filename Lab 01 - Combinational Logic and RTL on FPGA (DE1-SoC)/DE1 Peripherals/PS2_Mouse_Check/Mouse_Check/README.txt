README

This Quartus project is provided to allow EE271 Students to test mice to determine
if they are PS2 compatible and will work with the DE1-SoC board.

To test a mouse:
1) Compile provided project
2) Program the FPGA
3) Plug in the mouse
4) Press KEY0 to send the start signal to the mouse
5) Press mouse buttons and move the mouse around 
	a) if your mouse works, you will see LEDR0 and LEDR1 turn on when you press buttons
	   you will also see HEX0 and HEX1 display the values of the bins for movement of 
	   the mouse
	b) if you do not see any LEDs or values on the HEX displays, your mouse is likely not
	   PS2 compatible
6) If you want to test an additional mouse, plug in the new mouse and press KEY1 to reset 
   the system, and repeat from Step 4.
	