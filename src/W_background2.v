`timescale 1ns / 1ps

module W_background2(
	 input wire clk,
    input wire[9:0] x,
    input wire[8:0] y, 
    output wire[11:0] color
    );
	 localparam[15:0] white = 16'hffff, black = 16'h0000;
	 localparam hint_posx = 208,
					hint_posy = 420;
	 
	 wire[15:0] data[1:0];
	 wire[1:0] control;
	 
	 reg[11:0] nextcolor;
	 assign color = nextcolor;
	 
	 wire [31:0] clk_div;
	 clkdiv WelClk(.clk(clk), .clk_div(clk_div));
	 
    W_ACKNOWLEDGE 	 m0(.clk(clk),.color(data[0]),.is_display(control[0]), .x(x), .y(y), .isplay(1'b1), 		  .posx(1'b0), 	  .posy(1'b0));
	 W_Hint2			  	 m1(.clk(clk),.color(data[1]),.is_display(control[1]), .x(x), .y(y), .isplay(clk_div[26]),  .posx(hint_posx), .posy(hint_posy));
	 
	 always@(*)begin
	 if(control[1])nextcolor <= data[1][15:4];
	 else if(control[0])nextcolor <= data[0][15:4];
	 else nextcolor <= black;
	 end
	 
endmodule
