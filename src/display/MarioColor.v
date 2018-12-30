`timescale 1ns / 1ps

module marioColor(
    input wire clk,
    input wire[9:0] col,//scan signal from vgac
    input wire[8:0] row,//scan signal from vgac
    input wire[9:0] posx,//the position of the left-up corner of Mario(col)
    input wire[8:0] posy,//the position of the left-up corner of Mario(row)
    input wire[3:0] animate_state,
    output reg[15:0] color//the data reading from IP core
    );
    
    wire is_display;
    wire[15:0] data[14:0];
    wire[10:0] address;
    localparam[9:0] width = 34;
    localparam[8:0] height = 36;
    localparam[3:0] MARIO_STAND       = 4'b0000,
                    MARIO_WALK_LEFT1  = 4'b0001,
                    MARIO_WALK_LEFT2  = 4'b0010,
                    MARIO_WALK_LEFT3  = 4'b0011,
                    MARIO_WALK_RIGHT1 = 4'b0100,
                    MARIO_WALK_RIGHT2 = 4'b0101,
                    MARIO_WALK_RIGHT3 = 4'b1110,
                    MARIO_FLY_LEFT    = 4'b0110,
                    MARIO_FLY_RIGHT   = 4'b0111,
                    MARIO_CLAMP1      = 4'b1000,
                    MARIO_CLAMP2      = 4'b1001,
                    MARIO_DIE1        = 4'b1010,
                    MARIO_DIE2        = 4'b1011,
                    MARIO_DIE3        = 4'b1100,
                    MARIO_DIE4        = 4'b1101;
                    
    //is the scan signal in range
    assign is_display = col >= posx & col < posx + width & row >= posy  & row < posy + height;
    assign address = (row - posy) * width + (col - posx);
    
    //ROM from which the module loads color
    MARIO_STAND_img m0(.a(address), .spo(data[0]));
    MARIO_WALK_LEFT1_img m1(.a(address), .spo(data[1]));
    MARIO_WALK_LEFT2_img m2(.a(address), .spo(data[2]));
    MARIO_WALK_LEFT3_img m3(.a(address), .spo(data[3]));
    MARIO_WALK_RIGHT1_img m4(.a(address), .spo(data[4]));
    MARIO_WALK_RIGHT2_img m5(.a(address), .spo(data[5]));
    MARIO_WALK_RIGHT3_img m14(.a(address), .spo(data[14]));
    MARIO_FLY_LEFT_img m6(.a(address), .spo(data[6]));
    MARIO_FLY_RIGHT_img m7(.a(address), .spo(data[7]));
    MARIO_CLAMP1_img m8(.a(address), .spo(data[8]));
    MARIO_CLAMP2_img m9(.a(address), .spo(data[9]));
    MARIO_DIE1_img m10(.a(address), .spo(data[10]));
    MARIO_DIE2_img m11(.a(address), .spo(data[11]));
    MARIO_DIE3_img m12(.a(address), .spo(data[12]));
    MARIO_DIE4_img m13(.a(address), .spo(data[13]));
    
    always @(posedge clk)
    begin
        if(is_display)
            case(animate_state)
                MARIO_STAND:
                    color <= data[0];
                MARIO_WALK_LEFT1:
                    color <= data[1];
                MARIO_WALK_LEFT2:
                    color <= data[2];
                MARIO_WALK_LEFT3:
                    color <= data[3];
                MARIO_WALK_RIGHT1:
                    color <= data[4];
                MARIO_WALK_RIGHT2:
                    color <= data[5];
                MARIO_WALK_RIGHT3:
                    color <= data[14];
                MARIO_FLY_LEFT:
                    color <= data[6];
                MARIO_FLY_RIGHT:
                    color <= data[7];
                MARIO_CLAMP1:
                    color <= data[8];
                MARIO_CLAMP2:
                    color <= data[9];
                MARIO_DIE1:
                    color <= data[10];
                MARIO_DIE2:
                    color <= data[11];
                MARIO_DIE3:
                    color <= data[12];
                MARIO_DIE4:
                    color <= data[13];
            endcase
        else color <= 16'hffff;
    end
endmodule
