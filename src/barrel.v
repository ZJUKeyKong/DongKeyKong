`timescale 1ns / 1ps
/*
Barrel state machine.
Barrel have 3 state and 6 animation.
Mind the position of each land and ladder.
*/

module barrel(
    input wire clk,  //clock signal
    input wire rst,  //reset signal
    input wire start,//start signal
    input wire over, //over  signal
    output reg [9:0] x,  //barrel position x
    output reg [8:0] y,  //barrel position y
    output reg [1:0] state,  //barrel state
    output reg [2:0] animation_state  //barrel animation
    );

    localparam BARREL_INITIAL = 2'b00,  //barrel_inital state
               BARREL_ROLLING = 2'b01,  //barrel rolling state
               BARREL_FALLING = 2'b10;  //barrel falling state

    localparam BARREL_ROLL1 = 3'b000,   //4 roll state
               BARREL_ROLL2 = 3'b001,
               BARREL_ROLL3 = 3'b010,
               BARREL_ROLL4 = 3'b011,
               BARREL_FALL1 = 3'b100,   //2 fall state
               BARREL_FALL2 = 3'b101;

    localparam TOP_BOARD = 9'd5,        //map border
               BOTTOM_BOARD = 9'd461,
               LEFT_BOARD = 10'd5,
               RIGHT_BOARD = 10'd640;

    localparam land0lx = 10'd250,   //land info
               land0ly =  9'd53,
               land0rx = 10'd388,
               land0ry =  9'd70,
               land1lx = 10'd0,
               land1ly =  9'd115,
               land1rx = 10'd591,
               land1ry =  9'd131,
               land2lx = 10'd49,
               land2ly =  9'd197,
               land2rx = 10'd640,
               land2ry =  9'd213,
               land3lx = 10'd0,
               land3ly =  9'd286,
               land3rx = 10'd591,
               land3ry =  9'd302,
               land4lx = 10'd49,
               land4ly =  9'd376,
               land4rx = 10'd640,
               land4ry =  9'd393,
               land5lx = 10'd0,
               land5ly =  9'd461,
               land5rx = 10'd640,
               land5ry =  9'd479;

    localparam ladder0lx = 10'd337,  //ladder info
               ladder0ly =  9'd27,
               ladder0rx = 10'd347,
               ladder0ry =  9'd48,
               ladder1lx = 10'd539,
               ladder1ly =  9'd89,
               ladder1rx = 10'd549,
               ladder1ry =  9'd109,
               ladder2lx = 10'd46,
               ladder2ly =  9'd171,
               ladder2rx = 10'd56,
               ladder2ry =  9'd191,
               ladder3lx = 10'd544,
               ladder3ly =  9'd260,
               ladder3rx = 10'd554,
               ladder3ry =  9'd280,
               ladder4lx = 10'd51,
               ladder4ly =  9'd350,
               ladder4rx = 10'd61,
               ladder4ry =  9'd371;
    
    localparam BARREL_INITIAL_X = 10'd203,  //barrel initial pos
               BARREL_INITIAL_Y =  9'd90;

    localparam BARREL_FALL_WIDTH  = 10'd42,  //barrel size define
               BARREL_FALL_HEIGHT = 9'd24,
               BARREL_ROLL_WIDTH  = 10'd32,
               BARREL_ROLL_HEIGHT = 9'd24;

    localparam MOVSPEED_X = 3'd1,  //barrel movement define
               MOVSPEED_Y = 3'd1,
               accumulate_Y = 1'b0;

    wire COLLATION_DOWN;
    wire EN_FALL;
    wire [31:0] randnumber;
    wire RAND_MATCH;

    //collision check
    assign COLLATION_DOWN = (y + BARREL_FALL_HEIGHT >= BOTTOM_BOARD) | 
                            ((x < land0rx & x + BARREL_FALL_WIDTH > land0lx) & (y + BARREL_FALL_HEIGHT >= land0ly & y + BARREL_FALL_HEIGHT <= land0ry)) |
                            ((x < land1rx & x + BARREL_FALL_WIDTH > land1lx) & (y + BARREL_FALL_HEIGHT >= land1ly & y + BARREL_FALL_HEIGHT <= land1ry)) |
                            ((x < land2rx & x + BARREL_FALL_WIDTH > land2lx) & (y + BARREL_FALL_HEIGHT >= land2ly & y + BARREL_FALL_HEIGHT <= land2ry)) |
                            ((x < land3rx & x + BARREL_FALL_WIDTH > land3lx) & (y + BARREL_FALL_HEIGHT >= land3ly & y + BARREL_FALL_HEIGHT <= land3ry)) |
                            ((x < land4rx & x + BARREL_FALL_WIDTH > land4lx) & (y + BARREL_FALL_HEIGHT >= land4ly & y + BARREL_FALL_HEIGHT <= land4ry)) |
                            ((x < land5rx & x + BARREL_FALL_WIDTH > land5lx) & (y + BARREL_FALL_HEIGHT >= land5ly & y + BARREL_FALL_HEIGHT <= land5ry));

    //ladder check
    assign EN_FALL = (x >= ladder0lx & x <= ladder0rx & y >= ladder0ly & y <= ladder0ry) |
                     (x >= ladder1lx & x <= ladder1rx & y >= ladder1ly & y <= ladder1ry) |
                     (x >= ladder2lx & x <= ladder2rx & y >= ladder2ly & y <= ladder2ry) |
                     (x >= ladder3lx & x <= ladder3rx & y >= ladder3ly & y <= ladder3ry) |
                     (x >= ladder4lx & x <= ladder4rx & y >= ladder4ly & y <= ladder4ry);

    //check ladder fall or land fall
    rand_gen m20(.clk(clk), .rand(randnumber));
    assign RAND_MATCH = randnumber[3:2] == 2'b10;

//--------------------    End    ----------------------

    reg signed [10:0] SPEED_X;
	reg signed [9:0] SPEED_Y;

    reg [1:0] next_state;
    reg [4:0] animation_counter;
    
    initial begin  //initalize
        x = BARREL_INITIAL_X;
        y = BARREL_INITIAL_Y;
        SPEED_X = MOVSPEED_X;
        SPEED_Y = 0;
        state = BARREL_INITIAL;
        next_state = BARREL_INITIAL;
        animation_state = BARREL_ROLL1;
        animation_counter = 0;
    end

    always@ (posedge clk) begin
        state <= next_state;
        case (state)
            BARREL_INITIAL: begin
                x <= BARREL_INITIAL_X;
                y <= BARREL_INITIAL_Y;
                SPEED_X <= MOVSPEED_X;
                SPEED_Y <= 0;
            end
            BARREL_ROLLING: begin  //check map border
                if(x + BARREL_ROLL_WIDTH + SPEED_X > RIGHT_BOARD) begin
                    x <= RIGHT_BOARD - BARREL_ROLL_WIDTH;
                    SPEED_X <= -MOVSPEED_X;
                end
                else if(x + SPEED_X < LEFT_BOARD) begin
                    x <= LEFT_BOARD;
                    SPEED_X <= MOVSPEED_X;
                end
                else begin
                    x <= x + SPEED_X;
                end
                SPEED_Y <= 0;
                animation_counter <= animation_counter + 1'b1;
            end
            BARREL_FALLING: begin  //check collision with land
                if(y + BARREL_FALL_HEIGHT + SPEED_Y > BOTTOM_BOARD) begin
                    y <= BOTTOM_BOARD - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + BARREL_FALL_HEIGHT + SPEED_Y > land0ly & y + BARREL_FALL_HEIGHT + SPEED_Y < land0ry) & (x + SPEED_X < land0rx & x + SPEED_X + BARREL_ROLL_WIDTH > land0lx) & (~EN_FALL)) begin
                    y <= land0ly - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + BARREL_FALL_HEIGHT + SPEED_Y > land1ly & y + BARREL_FALL_HEIGHT + SPEED_Y < land1ry) & (x + SPEED_X < land1rx & x + SPEED_X + BARREL_ROLL_WIDTH > land1lx) & (~EN_FALL)) begin
                    y <= land1ly - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + BARREL_FALL_HEIGHT + SPEED_Y > land2ly & y + BARREL_FALL_HEIGHT + SPEED_Y < land2ry) & (x + SPEED_X < land2rx & x + SPEED_X + BARREL_ROLL_WIDTH > land2lx) & (~EN_FALL)) begin
                    y <= land2ly - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + BARREL_FALL_HEIGHT + SPEED_Y > land3ly & y + BARREL_FALL_HEIGHT + SPEED_Y < land3ry) & (x + SPEED_X < land3rx & x + SPEED_X + BARREL_ROLL_WIDTH > land3lx) & (~EN_FALL)) begin
                    y <= land3ly - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + BARREL_FALL_HEIGHT + SPEED_Y > land4ly & y + BARREL_FALL_HEIGHT + SPEED_Y < land4ry) & (x + SPEED_X < land4rx & x + SPEED_X + BARREL_ROLL_WIDTH > land4lx) & (~EN_FALL)) begin
                    y <= land4ly - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + BARREL_FALL_HEIGHT + SPEED_Y > land5ly & y + BARREL_FALL_HEIGHT + SPEED_Y < land5ry) & (x + SPEED_X < land5rx & x + SPEED_X + BARREL_ROLL_WIDTH > land5lx) & (~EN_FALL)) begin
                    y <= land5ly - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else begin  //fall by speed
                    y <= y + SPEED_Y;
                end
                // SPEED_X <= 0;
                SPEED_Y <= MOVSPEED_Y;  //speed when fall
                animation_counter <= animation_counter + 1'b1;
            end
        endcase
    end

    always@ (*) begin  //animation state switch to form animation
        case(state)
            BARREL_FALLING: begin
                case (animation_counter[4])
                    1'b1: animation_state = BARREL_FALL1;
                    1'b0: animation_state = BARREL_FALL2;
                endcase
            end
            default: begin
                case (animation_counter[4:3])
                    2'b00: animation_state = BARREL_ROLL1;
                    2'b01: animation_state = BARREL_ROLL2;
                    2'b10: animation_state = BARREL_ROLL3;
                    2'b11: animation_state = BARREL_ROLL4;
                endcase
            end
        endcase
    end

    always@ (*) begin  //barrel state transform
        next_state = state;
        case(state)
            BARREL_INITIAL: begin
                if(start & (~rst)) next_state = BARREL_ROLLING;
                else next_state = BARREL_INITIAL;
            end
            BARREL_ROLLING: begin
                if(rst) next_state = BARREL_INITIAL;
                else if(over) next_state = BARREL_INITIAL;
                else if(~COLLATION_DOWN) next_state = BARREL_FALLING;
                else if(EN_FALL & RAND_MATCH) next_state = BARREL_FALLING;
                else next_state = BARREL_ROLLING;
            end
            BARREL_FALLING: begin
                if(rst) next_state = BARREL_INITIAL;
                else if(over) next_state = BARREL_INITIAL;
                else if(EN_FALL) next_state = BARREL_FALLING;
                else if(COLLATION_DOWN) next_state = BARREL_ROLLING;
                else next_state = BARREL_FALLING;
            end
        endcase
    end

endmodule