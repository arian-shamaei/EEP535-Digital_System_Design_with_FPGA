//This module regulates what happens when a User presses one of the input buttons (e.g., Key3, Key0, etc.)

module userInput(Button, Clock, Reset, userInput);
	
	input logic Clock, Reset, Button;
	output logic userInput;
	
	logic ps, ns;

	//The following block ensures that when a user presses an input button and keeps it pressed that it only counts as one "press"
	//This avoids cheating by just keeping a button pressed to win the game.  
	always_comb begin 
		case(ps)
		//What to do when present state (ps) is 0 (no user input has just been received) 
		1'b0:					

			if (~Button)   		ns = 1'b0; //If user button is not pressed, remain in state 0
			else 			ns = 1'b1; //If user button is pressed, go to state 1
								
		
		//What to do when present state (ps) is 1 (user input has just been received)  
		1'b1:					
			if (Button)			ns = 1'b1; //If user button remains pressed, remain in state 1
			else 				ns = 1'b0; //If user button is not pressed go to state 0
		endcase
	end
	
	assign userInput = ((Button) & ps == 1'b0); 
	
		always_ff @ (posedge Clock) begin // at the positive edge of the clock, do the following
			if (Reset) begin
				ps <= 1'b0; //If reset is activated (=1) go to state 0 at the positive edge of the clock
			end 
			else begin
				ps <= ns; //If reset is not activated (=0) go to the next state according to the case statements above
			end
		end

endmodule
	
module userInput_testbench();
	logic Clock, Reset, Button;
	logic userInput;
		
	userInput dut (.*);
	parameter CLOCK_PERIOD = 100;
		
	initial begin 
		Clock <= 0;
		forever #(CLOCK_PERIOD/2) Clock <= ~Clock; //Sets the duty cycle of the clock to 50% (Clock changes state halfway through its period)
	end
		
	initial begin
		@(posedge Clock); //lets an active (positive) edge of the clock go by without defining Reset or Button
		Reset <= 1; Button <= 0;	@(posedge Clock);  //Tests state where reset is active and input button is not pressed
						@(posedge Clock);  //Waits an additional clock cycle before changing inputs 
		Reset <= 0; Button <= 1;	@(posedge Clock);  //Tests state where reset is inactive and input button is pressed
						@(posedge Clock);  //Waits an additional clock cycle before changing inputs 
		Button <= 0;			@(posedge Clock);  //Reset remains in active; user is no longer pressing button
						@(posedge Clock);  //Waits an additional clock cycle before changing inputs 
		Button <= 1;			@(posedge Clock);  //Reset remains in active; user is pressing button again
						@(posedge Clock);  //Waits an additional clock cycle before changing inputs 
		Reset <= 1; 			@(posedge Clock);  //Reset becomes active; user is still pressing button
		Reset <=0;			@(posedge Clock);  //Reset becomes inactive; user is still pressing button
	
	 $stop; // End the simulation.
 	end
endmodule
