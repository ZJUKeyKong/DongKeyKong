`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/30 16:16:05
// Design Name: 
// Module Name: new_driver
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Keyboard(
	input wire clk_25MHz,
	input wire PS2Clk,
	input wire PS2Data,
	output reg upKeyState,
	output reg downKeyState,
	output reg leftKeyState,
	output reg rightKeyState,
	output reg spaceKeyState);

	wire debouncePS2Clk;
	Debounce m_Debounce(.debounceClk(clk_25MHz), .button(PS2Clk), .debounceButton(debouncePS2Clk));
	
	initial begin upKeyState = 1'b0; downKeyState = 1'b0; leftKeyState = 1'b0; rightKeyState = 1'b0; spaceKeyState = 1'b0; end
	
	reg [7:0] key;
	reg extendFlag, endFlag;
	initial begin extendFlag = 1'b0; endFlag = 1'b0; end
	
	reg [3:0] cnt;
	initial cnt = 4'd0;
	//nege to show that we have already pressStateed
	always @(negedge debouncePS2Clk) begin
		if (cnt >= 4'd1 && cnt <= 4'd8) key[cnt - 1] =  PS2Data;
		cnt = cnt + 4'd1;
		if (cnt == 4'd11) begin
			cnt = 4'd0;
			//extend to indicate the space
			if (key == 8'hE0) extendFlag = 1'b1;
			else if (key == 8'hF0) endFlag = 1'b1;
			else begin
			//assigning state
			//negative logic
				if (key == 8'h1d && extendFlag == 1'b0) upKeyState = ~endFlag;
				else if (key == 8'h1b && extendFlag == 1'b0) downKeyState = ~endFlag;
				else if (key == 8'h1c && extendFlag == 1'b0) leftKeyState = ~endFlag;
				else if (key == 8'h23 && extendFlag == 1'b0) rightKeyState = ~endFlag;
				else if (key == 8'h29 && extendFlag == 1'b0) spaceKeyState = ~endFlag;
				extendFlag = 1'b0;
				endFlag = 1'b0;
			end
		end
	end

endmodule