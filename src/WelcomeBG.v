`timescale 1ns / 1ps

module WelcomeBG(
	 input wire clk,
	 input wire[1:0] state,
    input wire[9:0] x,
    input wire[8:0] y, 
    output wire[11:0] color
    );
	 localparam Welcome_choice1 = 2'b00,
               Welcome_choice2 = 2'b01,
               Acknowledge   =   2'b10;
	 
	 wire[11:0] data[1:0];
	 W_background1 (.clk(clk),.state(state[0]),.x(x),.y(y),.color(data[0]));
	 W_background2 (.clk(clk),.x(x),.y(y),.color(data[1]));
	 
	 assign color = state[1] ? data[1] : data[0] ;
	 
endmodule
