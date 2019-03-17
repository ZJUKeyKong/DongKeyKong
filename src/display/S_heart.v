`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:41:33 01/11/2019 
// Design Name: 
// Module Name:    S_heart 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module S_heart(
    input wire clk,
    input wire[9:0] x,//scan signal from vgac
    input wire[8:0] y,//scan signal from vgac
    input wire[9:0] posx,//the position of the left-up corner
    input wire[8:0] posy,//the position of the left-up corner
	 input wire isplay,
    output reg[11:0] color,
	 output wire is_display
    );
	 localparam[9:0] width = 45;
    localparam[8:0] height = 43;
	 
    wire[15:0] data;
    wire[15:0] address;
    
    assign is_display = (x >= posx & x < posx + width & y >= posy  & y < posy + height) & isplay;
    assign address = (y - posy) * width + (x - posx);

	 HEART m0(.spo(data), .a(address));
    
    always @(posedge clk)
    begin
        if(is_display)begin
           color <= data[15:4];
		  end
        else color <= 16'hfff;
    end


endmodule
