`timescale 1ns / 1ps


module mario(
    input wire clk,
    input wire rst,
    input wire start,
    input wire over,
    input wire [4:0] keydown,
    output reg [9:0] x,
    output reg [8:0] y,
    output reg [2:0] state,
    output reg [3:0] animation_state
    );

    localparam MARIO_INITIAL  = 3'b000,
               MARIO_FLYING   = 3'b001,
               MARIO_JUMPING  = 3'b010,
               MARIO_WALKING  = 3'b011,
               MARIO_STANDING = 3'b100,
               MARIO_DYING    = 3'b101,
               MARIO_CLAMPING = 3'b110;

    localparam MARIO_STAND       = 4'b0000,
               MARIO_WALK_LEFT1  = 4'b0001,
               MARIO_WALK_LEFT2  = 4'b0010,
               MARIO_WALK_MID    = 4'b0011,
               MARIO_WALK_RIGHT1 = 4'b0100,
               MARIO_WALK_RIGHT2 = 4'b0101,
               MARIO_FLY_LEFT    = 4'b0110,
               MARIO_FLY_RIGHT   = 4'b0111,
               MARIO_CLAMP1      = 4'b1000,
               MARIO_CLAMP2      = 4'b1001,
               MARIO_DIE1        = 4'b1010,
               MARIO_DIE2        = 4'b1011,
               MARIO_DIE3        = 4'b1100,
               MARIO_DIE4        = 4'b1101;

    localparam TOP_BOARD = 9'd50,
               BOTTOM_BOARD = 9'd430,
               LEFT_BOARD = 10'd50,
               RIGHT_BOARD = 10'd590;
    
    localparam MARIO_INITIAL_X = 136,
               MARIO_INITIAL_Y = 438;

    localparam MOVSPEED_X = 3'd5,
               MOVSPEED_Y = 3'd5,
               CLAMPSPEED = 3'd3,
               ACCELERATION_Y = 1'b1;

//--------------------  to write ----------------------

    // localparam COLLATION_LEFT = 1'b0,
    //            COLLATION_RIGHT = 1'b0,
    //            COLLATION_UP = 1'b0,
    //            COLLATION_DOWN = 1'b1;

    // localparam KEYUP = 1'b0,
    //            KEYDOWN = 1'b0,
    //            KEYJUMP = 1'b0,
    //            KEYLEFT = 1'b0,
    //            KEYRIGHT = 1'b0;

    // localparam EN_CLAMP_DOWN = 1'b0,
    //            EN_CLAMP_UP = 1'b0;

//--------------------  finished ----------------------

    wire COLLATION_LEFT, COLLATION_RIGHT, COLLATION_DOWN, COLLATION_UP;
    
    wire KEYUP, KEYDOWN, KEYLEFT, KEYRIGHT, KEYJUMP;

    wire EN_CLAMP_DOWN, EN_CLAMP_UP;

    assign COLLATION_RIGHT = x >= RIGHT_BOARD;
    assign COLLATION_LEFT  = x <= LEFT_BOARD;
    assign COLLATION_DOWN  = y >= BOTTOM_BOARD;
    assign COLLATION_UP    = y <= TOP_BOARD;

    // localparam up =4'b0001, 
    //            left = 4'b0010, 
    //            right = 4'b0011, 
    //            down = 4'b0100, 
    //            jump = 4'b1000;

    assign KEYUP    = keydown[0];
    assign KEYLEFT  = keydown[1];
    assign KEYRIGHT = keydown[2];
    assign KEYDOWN  = keydown[3];
    assign KEYJUMP  = keydown[4];

    assign EN_CLAMP_UP   = (x > 300 && x < 400);
    assign EN_CLAMP_DOWN = (x > 300 && x < 400);

//--------------------    End    ----------------------

    reg signed [9:0] SPEED_X;
    reg signed [8:0] SPEED_Y;

    reg [2:0] next_state;
    reg [4:0] animation_counter;
    
    initial begin
        x = MARIO_INITIAL_X;
        y = MARIO_INITIAL_Y;
        SPEED_X = 0;
        SPEED_Y = 0;
        state = MARIO_INITIAL;
        next_state = MARIO_INITIAL;
        animation_state = MARIO_STAND;
        animation_counter = 0;
    end

    always@ (posedge clk) begin
        state <= next_state;
        case (state)
            MARIO_INITIAL: begin
                x <= MARIO_INITIAL_X;
                y <= MARIO_INITIAL_Y;
            end
            MARIO_JUMPING: begin
                SPEED_Y <= -MOVSPEED_Y;
            end
            MARIO_FLYING: begin
                animation_counter <= animation_counter + 1'b1;
                if(y + SPEED_Y < TOP_BOARD) begin
                    y <= TOP_BOARD;
                    SPEED_Y <= 0;
                end
                else if(y + SPEED_Y > BOTTOM_BOARD) begin
                    y <= BOTTOM_BOARD;
                    SPEED_Y <= 0;
                end
                else y <= y + SPEED_Y;
                if(x + SPEED_X < LEFT_BOARD) begin
                    x <= LEFT_BOARD;
                    SPEED_X <= 0;
                end
                else if(x + SPEED_X > RIGHT_BOARD) begin
                    x <= RIGHT_BOARD;
                    SPEED_X <= 0;
                end
                else x <= x + SPEED_X;
                SPEED_Y <= SPEED_Y + ACCELERATION_Y;
            end
            MARIO_WALKING: begin
                animation_counter <= animation_counter + 1'b1;
                SPEED_Y <= 0;
                if(KEYLEFT) SPEED_X <= -MOVSPEED_X;
                else SPEED_X <= MOVSPEED_X;
                if(x + SPEED_X < LEFT_BOARD)
                    x <= LEFT_BOARD;
                else if(x + SPEED_X > RIGHT_BOARD)
                    x <= RIGHT_BOARD;
                else x <= x + SPEED_X;
            end
            MARIO_STANDING: begin
                SPEED_X <= 0;
                SPEED_Y <= 0;
            end
            MARIO_DYING: begin
                SPEED_X <= 0;
                SPEED_Y <= 0;
            end
            MARIO_CLAMPING: begin
                SPEED_X <= 0;
                SPEED_Y <= 0;
                if(KEYUP | KEYDOWN) begin
                    animation_counter <= animation_counter + 1'b1;
                    if(KEYUP) begin
                        if(y - CLAMPSPEED < TOP_BOARD)
                            y <= TOP_BOARD;
                        else y <= y - CLAMPSPEED;
                    end
                    else begin
                        if(y + CLAMPSPEED > BOTTOM_BOARD)
                            y <= BOTTOM_BOARD;
                        else y <= y + CLAMPSPEED;
                    end
                end
            end
        endcase
    end

    always@ (*) begin
        case(state)
            MARIO_FLYING: begin
                if(SPEED_X > 0) animation_state = MARIO_FLY_RIGHT;
                else animation_state = MARIO_FLY_LEFT;
            end
            MARIO_WALKING: begin
                if(SPEED_X > 0) begin
                    case (animation_counter[2:1])
                        2'b00: animation_state = MARIO_WALK_RIGHT1;
                        2'b01: animation_state = MARIO_WALK_MID;
                        2'b10: animation_state = MARIO_WALK_RIGHT2;
                        2'b11: animation_state = MARIO_WALK_MID;
                    endcase
                end
                else begin
                    case (animation_counter[2:1])
                        2'b00: animation_state = MARIO_WALK_LEFT1;
                        2'b01: animation_state = MARIO_WALK_MID;
                        2'b10: animation_state = MARIO_WALK_LEFT2;
                        2'b11: animation_state = MARIO_WALK_MID;
                    endcase
                end
            end
            MARIO_DYING: begin
                case (animation_counter[2:1])
                    2'b00: animation_state = MARIO_DIE1;
                    2'b01: animation_state = MARIO_DIE2;
                    2'b10: animation_state = MARIO_DIE3;
                    2'b11: animation_state = MARIO_DIE4;
                endcase
            end
            MARIO_CLAMPING: begin
                if(KEYDOWN | KEYUP) begin
                    case (animation_counter[2:1])
                        2'b00: animation_state = MARIO_CLAMP1;
                        2'b01: animation_state = MARIO_CLAMP1;
                        2'b10: animation_state = MARIO_CLAMP2;
                        2'b11: animation_state = MARIO_CLAMP2;
                    endcase
                end
                // else animation_state = MARIO_CLAMP1;
            end
            default: animation_state = MARIO_STAND;
        endcase
    end

    always@ (*) begin
        next_state = state;
        case(state)
            MARIO_INITIAL: begin
                if(start & (~rst)) next_state = MARIO_STANDING;
                else next_state = MARIO_INITIAL;
            end
            MARIO_JUMPING: begin
                if(rst) next_state = MARIO_INITIAL;
                else if(over) next_state = MARIO_DYING;
                else next_state = MARIO_FLYING;
            end
            MARIO_FLYING: begin
                if(rst) next_state = MARIO_INITIAL;
                else if(over) next_state = MARIO_DYING;
                else if(COLLATION_DOWN & (SPEED_Y >= 0)) next_state = MARIO_STANDING;
                else next_state = MARIO_FLYING;
            end
            MARIO_WALKING: begin
                if(rst) next_state = MARIO_INITIAL;
                else if(over) next_state = MARIO_DYING;
                else if(~COLLATION_DOWN) next_state = MARIO_FLYING;
                else if(KEYJUMP) next_state = MARIO_JUMPING;
                else if(KEYUP & EN_CLAMP_UP) next_state = MARIO_CLAMPING;
                else if(KEYDOWN & EN_CLAMP_DOWN) next_state = MARIO_CLAMPING;
                else if((~KEYLEFT) & (~KEYRIGHT)) next_state = MARIO_STANDING;
                else next_state = MARIO_WALKING;
            end
            MARIO_STANDING: begin
                if(rst) begin
                    next_state = MARIO_INITIAL;
                end
                else if(over) begin
                    next_state = MARIO_DYING;
                end
                else if(~COLLATION_DOWN) begin
                    next_state = MARIO_FLYING;
                end
                else if(KEYJUMP) begin
                    next_state = MARIO_JUMPING;
                end
                else if(KEYUP & EN_CLAMP_UP) begin
                    next_state = MARIO_CLAMPING;
                end
                else if(KEYDOWN & EN_CLAMP_DOWN) begin
                    next_state = MARIO_CLAMPING;
                end
                else if(KEYLEFT | KEYRIGHT) begin
                    next_state = MARIO_WALKING;
                end
                else next_state = MARIO_STANDING;
            end
            MARIO_DYING: begin
                if(rst) begin
                    next_state = MARIO_INITIAL;
                end
                else next_state = MARIO_DYING;
            end
            MARIO_CLAMPING: begin
                if(rst) begin
                    next_state = MARIO_INITIAL;
                end
                else if(over) begin
                    next_state = MARIO_DYING;
                end
                else if(COLLATION_DOWN & (KEYLEFT | KEYRIGHT | KEYJUMP)) begin
                    if(KEYLEFT | KEYRIGHT)
                        next_state = MARIO_WALKING;
                    else
                        next_state = MARIO_JUMPING;
                end
                else next_state = MARIO_CLAMPING;
            end
        endcase
    end

endmodule