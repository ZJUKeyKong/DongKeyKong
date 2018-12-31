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
			   height = 480,
			   oil_width = 42,
			   oil_height = 38,
			   kongside_width = 52,
			   kongside_height = 78;

	// localparam TOP_BOARD = 9'd50,
    //            BOTTOM_BOARD = 9'd430,
    //            LEFT_BOARD = 10'd50,
    //            RIGHT_BOARD = 10'd590;

	wire [15:0] load, oil_load, kongside_load;
	wire [18:0] address;
	wire [10:0] oil_address;
	wire [11:0] kongside_address;
	wire [9:0] relative_x, oil_relative_x, kongside_relative_x;
	wire [8:0] relative_y, oil_relative_y, kongside_relative_y;
	
	assign relative_x = (width  >> 1) + posX - cx;
    assign relative_y = (height >> 1) + posY - cy;
	assign address = relative_y * width + relative_x;

	assign oil_relative_x = posX - 580;
	assign oil_relative_y = posY - 423;
	assign oil_address = oil_relative_y * oil_width + oil_relative_x;

	assign kongside_relative_x = posX - 0;
	assign kongside_relative_y = posY - 37;
	assign kongside_address = kongside_relative_y * kongside_width + kongside_relative_x;

	backgroundimg load_color(.clka(clk), .addra(address), .douta(load));
	oil_img m1(.a(oil_address), .spo(oil_load));
	kongside_img m2(.a(kongside_address), .spo(kongside_load));
	
	always@(posedge clk) begin
		if(oil_relative_x >= 0 && oil_relative_x < oil_width && oil_relative_y >= 0 && oil_relative_y < oil_height) ocolor = oil_load;
		else if(kongside_relative_x >= 0 && kongside_relative_x < kongside_width && kongside_relative_y >= 0 && kongside_relative_y < kongside_height) ocolor = kongside_load;
		else if(relative_x >= 0 & relative_x < width & relative_y >= 0 & relative_y < height) ocolor = load;
		else ocolor = 12'hFF_FF;
	end

endmodule