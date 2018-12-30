`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/30 21:14:34
// Design Name: 
// Module Name: barrelColor
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


module barrelColor(
    input wire clk,
    input wire[9:0] col,//scan signal from vgac
    input wire[8:0] row,//scan signal from vgac
    input wire[9:0] posx,//the position of the left-up corner of Mario(col)
    input wire[8:0] posy,//the position of the left-up corner of Mario(row)
    input wire[2:0] animate_state,
    output reg[15:0] color//the data reading from IP core
    );
    
    localparam[9:0] fall_width = 42, roll_width = 32;
    localparam[8:0] fall_height = 24, roll_height = 24;
    localparam[2:0] BARREL_ROLL1 = 3'b000,
                    BARREL_ROLL2 = 3'b001,
                    BARREL_ROLL3 = 3'b010,
                    BARREL_ROLL4 = 3'b011,
                    BARREL_FALL1 = 3'b100,
                    BARREL_FALL2 = 3'b101;
                    
    wire is_display;
    wire[9:0] address;
    wire[15:0] data[5:0];
    assign is_display = animate_state[2] ? (col >= posx & col < posx + fall_width & row >= posy & row < posy + roll_height) :
     (col >= posx & col < posx + roll_width & row >= posy & row < posy + roll_height); 
    assign address = animate_state[2] ? (row - posy) * fall_width + col - posx : (row - posy) * roll_width + col - posx;
     
    BARREL_ROLL1_img m0(.a(address), .spo(data[0]));
    BARREL_ROLL2_img m1(.a(address), .spo(data[1]));
    BARREL_ROLL3_img m2(.a(address), .spo(data[2]));
    BARREL_ROLL4_img m3(.a(address), .spo(data[3]));
    BARREL_FALL1_img m4(.a(address), .spo(data[4]));
    BARREL_FALL2_img m5(.a(address), .spo(data[5]));
     
    always @(posedge clk)
    begin
        if(is_display)
            case(animate_state)
                BARREL_ROLL1:
                    color <= data[0];
                BARREL_ROLL2:
                    color <= data[1];
                BARREL_ROLL3:
                    color <= data[2];
                BARREL_ROLL4:
                    color <= data[3];
                BARREL_FALL1:
                    color <= data[4];
                BARREL_FALL2:
                    color <= data[5];
                default:
                    color <= 16'hffff;
            endcase
        else color <= 16'hffff;
     end
endmodule
