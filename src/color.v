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
// Additional Comments: Get background color
//
//////////////////////////////////////////////////////////////////////////////////
module color(
	input wire clk,
	input wire [8:0] cy,
	input wire [9:0] cx,
	input wire [8:0] posY,
	input wire [9:0] posX,
	input wire [1:0] game_state,  //Game state to judge which scene to display
	output reg [15:0] ocolor
    );

	localparam width = 640,  //size of each object
			   height = 480,
			   oil_width = 42,
			   oil_height = 38,
			   kongside_width = 52,
			   kongside_height = 78,
			   heart_width = 45,
			   heart_height = 43;

	localparam GAME_INITIAL = 2'b00,  //Game state
               GAME_RUNNING = 2'b01,
               GAME_OVER    = 2'b10,
               GAME_SUCCESS = 2'b11;

	// localparam TOP_BOARD = 9'd50,
    //            BOTTOM_BOARD = 9'd430,
    //            LEFT_BOARD = 10'd50,
    //            RIGHT_BOARD = 10'd590;

	wire [15:0] load, oil_load, kongside_load, heart_load, initial_background_load;
	wire [18:0] address;
	wire [10:0] oil_address;
	wire [11:0] kongside_address;
	wire [10:0] heart_address;
	wire [9:0] relative_x, oil_relative_x, kongside_relative_x, heart_relative_x;
	wire [8:0] relative_y, oil_relative_y, kongside_relative_y, heart_relative_y;
	
	assign relative_x = (width  >> 1) + posX - cx;  //relate position to pick precise pixel
    assign relative_y = (height >> 1) + posY - cy;
	assign address = relative_y * width + relative_x;  //address of pixel in ip core

	assign oil_relative_x = posX - 580;
	assign oil_relative_y = posY - 423;
	assign oil_address = oil_relative_y * oil_width + oil_relative_x;

	assign kongside_relative_x = posX - 0;
	assign kongside_relative_y = posY - 37;
	assign kongside_address = kongside_relative_y * kongside_width + kongside_relative_x;

	assign heart_relative_x = posX - 302;
	assign heart_relative_y = posY;
	assign heart_address = heart_relative_y * heart_width + heart_relative_x;

	backgroundimg load_color(.clka(clk), .addra(address), .douta(load));
	oil_img m1(.a(oil_address), .spo(oil_load));
	kongside_img m2(.a(kongside_address), .spo(kongside_load));
	//heart_img m3(.a(heart_address), .spo(heart_load));
	// start_img m4(.clka(clk), .addra(address), .douta(initial_background_load));
	assign heart_load = 16'hF0_0F;
	assign initial_background_load = 16'hF0_FF;
	
	always@(posedge clk) begin
		case (game_state)
			GAME_INITIAL: begin
				if(relative_x >= 0 & relative_x < width & relative_y >= 0 & relative_y < height)  //current vga scan pos is in object
					ocolor = initial_background_load;
			end
			GAME_SUCCESS: begin
				if(oil_relative_x >= 0 && oil_relative_x < oil_width && oil_relative_y >= 0 && oil_relative_y < oil_height) ocolor = oil_load;
				else if(heart_relative_x >= 0 && heart_relative_x < heart_width && heart_relative_y >= 0 && heart_relative_y < heart_height) ocolor = heart_load;
				else if(kongside_relative_x >= 0 && kongside_relative_x < kongside_width && kongside_relative_y >= 0 && kongside_relative_y < kongside_height) ocolor = kongside_load;
				else if(relative_x >= 0 & relative_x < width & relative_y >= 0 & relative_y < height) ocolor = load;
				else ocolor = 12'hFF_FF;  //FFFF mean transparent image
			end
			default: begin
				if(oil_relative_x >= 0 && oil_relative_x < oil_width && oil_relative_y >= 0 && oil_relative_y < oil_height) ocolor = oil_load;
				else if(kongside_relative_x >= 0 && kongside_relative_x < kongside_width && kongside_relative_y >= 0 && kongside_relative_y < kongside_height) ocolor = kongside_load;
				else if(relative_x >= 0 & relative_x < width & relative_y >= 0 & relative_y < height) ocolor = load;
				else ocolor = 12'hFF_FF;
			end
		endcase
	end

endmodule