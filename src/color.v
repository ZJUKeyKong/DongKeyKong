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
	input wire [8:0] cy,
	input wire [9:0] cx,
	input wire [8:0] posY,
	input wire [9:0] posX,
	output reg [15:0] ocolor
    );

	localparam width = 640,
			   height = 480;

	// localparam TOP_BOARD = 9'd50,
    //            BOTTOM_BOARD = 9'd430,
    //            LEFT_BOARD = 10'd50,
    //            RIGHT_BOARD = 10'd590;

	wire [15:0] load;
	wire [18:0] address;
	wire [9:0] relative_x;
	wire [8:0] relative_y;
	
	assign relative_x = (width  >> 1) + posX - cx;
    assign relative_y = (height >> 1) + posY - cy;
	assign address = relative_y * width + relative_x;

	backgroundimg2 load_color(.clka(clk), .addra(address), .douta(load));
	
	always@(posedge clk) begin
		if(relative_x >= 0 & relative_x < width & relative_y >= 0 & relative_y < height) ocolor = load;
		else ocolor = 12'hFF_F;
	end

endmodule