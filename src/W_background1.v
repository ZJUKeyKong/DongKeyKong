`timescale 1ns / 1ps

module W_background1(
	 input wire clk,
	 input wire state,
    input wire[9:0] x,
    input wire[8:0] y, 
    output wire[11:0] color
    );
	 localparam[15:0] white = 16'hffff, black = 16'h0000;
	 localparam title_posx = 105,
					title_posy = 10,
					play_posx = 254,
					play_posy = 280,
					ack_posx = 235,
					ack_posy = 340,
					choice1_posx = 160,
					choice1_posy = 260,
					choice2_posx = 140,
					choice2_posy = 320,
					hint_posx = 208,
					hint_posy = 420,
					fireL_posx = 0,
					fireL_posy = 100,
					fireR_posx = 560,
					fireR_posy = 100,
					kong_posx = 232,
					kong_posy = 130;
	 
	 wire[15:0] data[7:0];
	 wire[7:0] control;
	 reg [11:0] nextcolor;
	 
	 assign color = nextcolor;
	 
	 wire [31:0] clk_div;
	 clkdiv WelClk(.clk(clk), .clk_div(clk_div));
	 
    W_titlecolor 	 m0(.clk(clk),.color(data[0]),.is_display(control[0]), .x(x), .y(y), .isplay(1'b1), .posx(title_posx), .posy(title_posy));
	 W_playcolor  	 m1(.clk(clk),.color(data[1]),.is_display(control[1]), .x(x), .y(y), .isplay(state||clk_div[27]),  .posx(play_posx), .posy(play_posy));
	 W_acknowcolor  m2(.clk(clk),.color(data[2]),.is_display(control[2]), .x(x), .y(y), .isplay(~state||clk_div[27]), .posx(ack_posx) , .posy(ack_posy));
	 W_choicecolor  m3(.clk(clk),.color(data[3]),.is_display(control[3]), .x(x), .y(y), .isplay(1'b1), .posx(state ? choice2_posx : choice1_posx) , .posy(state ? choice2_posy : choice1_posy));
	 W_Hint1		 	 m4(.clk(clk),.color(data[4]),.is_display(control[4]), .x(x), .y(y), .isplay(~clk_div[25]), .posx(hint_posx), .posy(hint_posy));
	 
	 W_firecolor 	 m5(.clk(clk),.color(data[5]),.is_display(control[5]), .x(x), .y(y), .isplay(1'b1), .posx(fireL_posx), .posy(fireL_posy), .animation_state(clk_div[23]));
	 W_firecolor 	 m6(.clk(clk),.color(data[6]),.is_display(control[6]), .x(x), .y(y), .isplay(1'b1), .posx(fireR_posx), .posy(fireR_posy), .animation_state(clk_div[23]));
	 W_kongcolor 	 m7(.clk(clk),.color(data[7]),.is_display(control[7]), .x(x), .y(y), .isplay(1'b1), .posx(kong_posx) , .posy(kong_posy) , .animation_state(clk_div[25]));
	 
	 always@(*)begin
	 if(control[0])nextcolor <= data[0][15:4];
	 else if(control[1])nextcolor <= data[1][15:4];
	 else if(control[2])nextcolor <= data[2][15:4];
	 else if(control[3])nextcolor <= data[3][15:4];
	 else if(control[4])nextcolor <= data[4][15:4];
	 else if(control[5])nextcolor <= data[5][15:4];
	 else if(control[6])nextcolor <= data[6][15:4];
	 else if(control[7])nextcolor <= data[7][15:4];
	 else nextcolor <= black;
	 end
	 
endmodule
