`timescale 1ns / 1ps

module W_titlecolor(
	 input wire clk,
    input wire[9:0] x,//scan signal from vgac
    input wire[8:0] y,//scan signal from vgac
    input wire[9:0] posx,//the position of the left-up corner
    input wire[8:0] posy,//the position of the left-up corner
	 input wire isplay,
    output reg[15:0] color,//the data reading from IP core
	 output is_display
    );
	 localparam[9:0] width = 430;
    localparam[8:0] height = 92;
	 
	 wire is_display;
    wire[15:0] data;
    wire[15:0] address;
    
    assign is_display = (x >= posx & x < posx + width & y >= posy  & y < posy + height) & isplay;
    assign address = (y - posy) * width + (x - posx);

	 TITLE m0(.spo(data),.a(address));
    
    always @(posedge clk)
    begin
        if(is_display)
            color <= data;
        else color <= 16'hffff;
    end
	 


endmodule
