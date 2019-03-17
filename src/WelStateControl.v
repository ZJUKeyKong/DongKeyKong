`timescale 1ns / 1ps

module WelStateControl(
	 input wire clk,
	 input wire start,
	 input wire [4:0] movement,
    output reg [1:0] state
    );
	
	localparam Welcome_choice1 = 2'b00,
              Welcome_choice2 = 2'b01,
              Acknowledge   =   2'b10,
				  StartRunning  =   2'b11; 
				  
	reg [1:0] next_state;
	
	initial begin
	next_state <= 2'b00;
	end
	
	always @ (posedge clk) begin
        state <= next_state;
   end
	
	always@ (*) begin
		if(start == 1)begin 
			  next_state = state;
			  case (state)
					Welcome_choice1: 
					begin
						 if (movement[4]) next_state = StartRunning;
						 else if(movement[3]) next_state = Welcome_choice2; 
					end
					Welcome_choice2:
					begin
						 if (movement[4]) next_state = Acknowledge;
						 else if (movement[0]) next_state = Welcome_choice1;
					end
					Acknowledge: 
					begin
						 if (movement[1]) next_state = Welcome_choice2;
					end
			  endcase
		 end
		 else next_state = Welcome_choice1;
    end
	 
endmodule
