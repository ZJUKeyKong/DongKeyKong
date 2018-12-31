`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/30 20:56:51
// Design Name: 
// Module Name: characterColor
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


module characterColor(
    input wire clk,
    input wire[3:0] mario_state,
    input wire[1:0] kong_state,
    input wire queue_state,
    //input wire[2:0] barrel_state,
    input wire[9:0] col, mario_posx, queue_posx, kong_posx,// barrel_posx,
    input wire[8:0] row, mario_posy, queue_posy, kong_posy,// barrel_posy,
    output wire[11:0] color
    );
    
    localparam[15:0] white = 16'hffff, black = 16'h0000;
    wire[15:0] mcolor, kcolor, qcolor;//, bcolor;
    assign color = &mcolor ? (&qcolor ? (&kcolor ? black : kcolor[15:4]) : qcolor[15:4]) : mcolor[15:4]; 
    //wire[15:0] bcolor;
    kongColor kong(.clk(clk),.color(kcolor), .row(row), .col(col), .animate_state(kong_state), .posx(kong_posx), .posy(kong_posy));
    queueColor queue(.clk(clk),.color(qcolor), .row(row), .col(col), .animate_state(queue_state), .posx(queue_posx), .posy(queue_posy));
    marioColor mario(.clk(clk),.color(mcolor), .row(row), .col(col), .animate_state(mario_state), .posx(mario_posx), .posy(mario_posy));
    //barrelColor barrel(.clk(clk), .color(bcolor), .row(row), .col(col), .animate_state(barrel_state), .posx(barrel_posx), .posy(barrel_posy));

endmodule
