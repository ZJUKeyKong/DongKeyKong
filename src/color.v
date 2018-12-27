`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:40:45 12/21/2018 
// Design Name: 
// Module Name:    color 
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
module color(
	input wire clk,
	input wire[8:0] row,
	input wire[9:0] col,
	input wire[8:0] posY,
	input wire[9:0] posX,
	output reg[11:0] ocolor
    );

wire[23:0] load;
wire[11:0] address;

localparam height = 64;
localparam width = 64;


//IP core storing the image
img2 load_color(.a(address), .spo(load));
assign address = (row - posY) * width + (col - posX);
always@(posedge clk)
begin
	if(col >= posX & col < posX + width  & row >=  posY & row < posY + height)
	begin
		ocolor = {load[7:4],load[15:12],load[23:20]};
	end
	else
		ocolor = 12'hfff;
end

endmodule