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

    localparam TOP_BOARD = 9'd5,
               BOTTOM_BOARD = 9'd461,
               LEFT_BOARD = 10'd5,
               RIGHT_BOARD = 10'd640;
    
    localparam land0lx = 10'd250,
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
    
    localparam ladder0lx = 10'd341,
               ladder0ly =  9'd15,
               ladder0rx = 10'd351,
               ladder0ry =  9'd81,
               ladder1lx = 10'd543,
               ladder1ly =  9'd77,
               ladder1rx = 10'd553,
               ladder1ry =  9'd163,
               ladder2lx = 10'd50,
               ladder2ly =  9'd159,
               ladder2rx = 10'd60,
               ladder2ry =  9'd252,
               ladder3lx = 10'd548,
               ladder3ly =  9'd248,
               ladder3rx = 10'd558,
               ladder3ry =  9'd342,
               ladder4lx = 10'd55,
               ladder4ly =  9'd338,
               ladder4rx = 10'd65,
               ladder4ry =  9'd427;

    localparam MARIO_INITIAL_X = 10'd450,
               MARIO_INITIAL_Y = 9'd425;

    localparam MARIO_HEIGHT = 9'd36,
	           MARIO_WIDTH  = 10'd34;

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

    assign COLLATION_RIGHT = (x + MARIO_WIDTH  >= RIGHT_BOARD) |
                             (y < land0ry & y + MARIO_HEIGHT > land0ly) & (x + MARIO_WIDTH >= land0lx & x + MARIO_WIDTH <= land0rx) |
                             (y < land1ry & y + MARIO_HEIGHT > land1ly) & (x + MARIO_WIDTH >= land1lx & x + MARIO_WIDTH <= land1rx) |
                             (y < land2ry & y + MARIO_HEIGHT > land2ly) & (x + MARIO_WIDTH >= land2lx & x + MARIO_WIDTH <= land2rx) |
                             (y < land3ry & y + MARIO_HEIGHT > land3ly) & (x + MARIO_WIDTH >= land3lx & x + MARIO_WIDTH <= land3rx) |
                             (y < land4ry & y + MARIO_HEIGHT > land4ly) & (x + MARIO_WIDTH >= land4lx & x + MARIO_WIDTH <= land4rx) |
                             (y < land5ry & y + MARIO_HEIGHT > land5ly) & (x + MARIO_WIDTH >= land5lx & x + MARIO_WIDTH <= land5rx);
    assign COLLATION_LEFT  = (x <= LEFT_BOARD) |
                             ((y < land0ry & y + MARIO_HEIGHT > land0ly) & (x >= land0lx & x <= land0rx)) |
                             ((y < land1ry & y + MARIO_HEIGHT > land1ly) & (x >= land1lx & x <= land1rx)) |
                             ((y < land2ry & y + MARIO_HEIGHT > land2ly) & (x >= land2lx & x <= land2rx)) |
                             ((y < land3ry & y + MARIO_HEIGHT > land3ly) & (x >= land3lx & x <= land3rx)) |
                             ((y < land4ry & y + MARIO_HEIGHT > land4ly) & (x >= land4lx & x <= land4rx)) |
                             ((y < land5ry & y + MARIO_HEIGHT > land5ly) & (x >= land5lx & x <= land5rx));
    assign COLLATION_DOWN  = (y + MARIO_HEIGHT >= BOTTOM_BOARD) | 
                             ((x < land0rx & x + MARIO_WIDTH > land0lx) & (y + MARIO_HEIGHT >= land0ly & y + MARIO_HEIGHT <= land0ry)) |
                             ((x < land1rx & x + MARIO_WIDTH > land1lx) & (y + MARIO_HEIGHT >= land1ly & y + MARIO_HEIGHT <= land1ry)) |
                             ((x < land2rx & x + MARIO_WIDTH > land2lx) & (y + MARIO_HEIGHT >= land2ly & y + MARIO_HEIGHT <= land2ry)) |
                             ((x < land3rx & x + MARIO_WIDTH > land3lx) & (y + MARIO_HEIGHT >= land3ly & y + MARIO_HEIGHT <= land3ry)) |
                             ((x < land4rx & x + MARIO_WIDTH > land4lx) & (y + MARIO_HEIGHT >= land4ly & y + MARIO_HEIGHT <= land4ry)) |
                             ((x < land5rx & x + MARIO_WIDTH > land5lx) & (y + MARIO_HEIGHT >= land5ly & y + MARIO_HEIGHT <= land5ry));
    assign COLLATION_UP    = (y <= TOP_BOARD) |
                             ((x < land0rx & x + MARIO_WIDTH > land0lx) & (y >= land0ly & y <= land0ry)) |
                             ((x < land1rx & x + MARIO_WIDTH > land1lx) & (y >= land1ly & y <= land1ry)) |
                             ((x < land2rx & x + MARIO_WIDTH > land2lx) & (y >= land2ly & y <= land2ry)) |
                             ((x < land3rx & x + MARIO_WIDTH > land3lx) & (y >= land3ly & y <= land3ry)) |
                             ((x < land4rx & x + MARIO_WIDTH > land4lx) & (y >= land4ly & y <= land4ry)) |
                             ((x < land5rx & x + MARIO_WIDTH > land5lx) & (y >= land5ly & y <= land5ry));

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

    assign EN_CLAMP_UP   = (x > 300 && x < 400) | 
                           (x >= ladder0lx & x <= ladder0rx & y > ladder0ly & y < ladder0ry) |
                           (x >= ladder1lx & x <= ladder1rx & y > ladder1ly & y < ladder1ry) |
                           (x >= ladder2lx & x <= ladder2rx & y > ladder2ly & y < ladder2ry) |
                           (x >= ladder3lx & x <= ladder3rx & y > ladder3ly & y < ladder3ry) |
                           (x >= ladder4lx & x <= ladder4rx & y > ladder4ly & y < ladder4ry);
    assign EN_CLAMP_DOWN = (x > 300 && x < 400) |
                           (x >= ladder0lx & x <= ladder0rx & y > ladder0ly & y < ladder0ry) |
                           (x >= ladder1lx & x <= ladder1rx & y > ladder1ly & y < ladder1ry) |
                           (x >= ladder2lx & x <= ladder2rx & y > ladder2ly & y < ladder2ry) |
                           (x >= ladder3lx & x <= ladder3rx & y > ladder3ly & y < ladder3ry) |
                           (x >= ladder4lx & x <= ladder4rx & y > ladder4ly & y < ladder4ry);

//--------------------    End    ----------------------

    reg signed [9:0] SPEED_X;
    reg signed [8:0] SPEED_Y;

    reg [2:0] next_state;
    reg [4:0] animation_counter;
    reg last_direction;
    
    initial begin
        x = MARIO_INITIAL_X;
        y = MARIO_INITIAL_Y;
        SPEED_X = 0;
        SPEED_Y = 0;
        state = MARIO_INITIAL;
        next_state = MARIO_INITIAL;
        animation_state = MARIO_STAND;
        animation_counter = 0;
        last_direction = 1'b1;
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
                else if((y + SPEED_Y > land0ly & y + SPEED_Y < land0ry) & (x + SPEED_X < land0rx & x + SPEED_X + MARIO_WIDTH > land0lx)) begin
                    y <= land0ry;
                    SPEED_Y <= 0;
                end
                else if((y + SPEED_Y > land1ly & y + SPEED_Y < land1ry) & (x + SPEED_X < land1rx & x + SPEED_X + MARIO_WIDTH > land1lx)) begin
                    y <= land1ry;
                    SPEED_Y <= 0;
                end
                else if((y + SPEED_Y > land2ly & y + SPEED_Y < land2ry) & (x + SPEED_X < land2rx & x + SPEED_X + MARIO_WIDTH > land2lx)) begin
                    y <= land2ry;
                    SPEED_Y <= 0;
                end
                else if((y + SPEED_Y > land3ly & y + SPEED_Y < land3ry) & (x + SPEED_X < land3rx & x + SPEED_X + MARIO_WIDTH > land3lx)) begin
                    y <= land3ry;
                    SPEED_Y <= 0;
                end
                else if((y + SPEED_Y > land4ly & y + SPEED_Y < land4ry) & (x + SPEED_X < land4rx & x + SPEED_X + MARIO_WIDTH > land4lx)) begin
                    y <= land4ry;
                    SPEED_Y <= 0;
                end
                else if((y + SPEED_Y > land5ly & y + SPEED_Y < land5ry) & (x + SPEED_X < land5rx & x + SPEED_X + MARIO_WIDTH > land5lx)) begin
                    y <= land5ry;
                    SPEED_Y <= 0;
                end
                else if(y + MARIO_HEIGHT + SPEED_Y > BOTTOM_BOARD) begin
                    y <= BOTTOM_BOARD - MARIO_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + MARIO_HEIGHT + SPEED_Y > land0ly & y + MARIO_HEIGHT + SPEED_Y < land0ry) & (x + SPEED_X < land0rx & x + SPEED_X + MARIO_WIDTH > land0lx)) begin
                    y <= land0ly - MARIO_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + MARIO_HEIGHT + SPEED_Y > land1ly & y + MARIO_HEIGHT + SPEED_Y < land1ry) & (x + SPEED_X < land1rx & x + SPEED_X + MARIO_WIDTH > land1lx)) begin
                    y <= land1ly - MARIO_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + MARIO_HEIGHT + SPEED_Y > land2ly & y + MARIO_HEIGHT + SPEED_Y < land2ry) & (x + SPEED_X < land2rx & x + SPEED_X + MARIO_WIDTH > land2lx)) begin
                    y <= land2ly - MARIO_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + MARIO_HEIGHT + SPEED_Y > land3ly & y + MARIO_HEIGHT + SPEED_Y < land3ry) & (x + SPEED_X < land3rx & x + SPEED_X + MARIO_WIDTH > land3lx)) begin
                    y <= land3ly - MARIO_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + MARIO_HEIGHT + SPEED_Y > land4ly & y + MARIO_HEIGHT + SPEED_Y < land4ry) & (x + SPEED_X < land4rx & x + SPEED_X + MARIO_WIDTH > land4lx)) begin
                    y <= land4ly - MARIO_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + MARIO_HEIGHT + SPEED_Y > land5ly & y + MARIO_HEIGHT + SPEED_Y < land5ry) & (x + SPEED_X < land5rx & x + SPEED_X + MARIO_WIDTH > land5lx)) begin
                    y <= land5ly - MARIO_HEIGHT;
                    SPEED_Y <= 0;
                end
                else y <= y + SPEED_Y;
                if(x + SPEED_X < LEFT_BOARD) begin
                    x <= LEFT_BOARD;
                    SPEED_X <= 0;
                end
                else if(x + MARIO_WIDTH + SPEED_X > RIGHT_BOARD) begin
                    x <= RIGHT_BOARD - MARIO_WIDTH;
                    SPEED_X <= 0;
                end
                else x <= x + SPEED_X;
                SPEED_Y <= SPEED_Y + ACCELERATION_Y;
            end
            MARIO_WALKING: begin
                animation_counter <= animation_counter + 1'b1;
                SPEED_Y <= 0;
                if(KEYLEFT) begin
                    SPEED_X <= -MOVSPEED_X;
                    last_direction <= 1;
                end
                else if(KEYRIGHT) begin
                    SPEED_X <= MOVSPEED_X;
                    last_direction <= 0;
                end
                else begin
                    SPEED_X <= MOVSPEED_X;
                end
                if(x + SPEED_X < LEFT_BOARD)
                    x <= LEFT_BOARD;
                else if(x + MARIO_WIDTH + SPEED_X > RIGHT_BOARD)
                    x <= RIGHT_BOARD - MARIO_WIDTH;
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
                        if(y + MARIO_HEIGHT + CLAMPSPEED > BOTTOM_BOARD)
                            y <= BOTTOM_BOARD - MARIO_HEIGHT;
                        else y <= y + CLAMPSPEED;
                    end
                end
            end
        endcase
    end

    always@ (*) begin
        case(state)
            MARIO_FLYING: begin
                if(last_direction) animation_state = MARIO_FLY_LEFT;
                else animation_state = MARIO_FLY_RIGHT;
            end
            MARIO_WALKING: begin
                if(SPEED_X > 0) begin
                    case (animation_counter[4:3])
                        2'b00: animation_state = MARIO_WALK_RIGHT1;
                        2'b01: animation_state = MARIO_WALK_RIGHT3;
                        2'b10: animation_state = MARIO_WALK_RIGHT2;
                        2'b11: animation_state = MARIO_WALK_RIGHT3;
                    endcase
                end
                else begin
                    case (animation_counter[4:3])
                        2'b00: animation_state = MARIO_WALK_LEFT1;
                        2'b01: animation_state = MARIO_WALK_LEFT3;
                        2'b10: animation_state = MARIO_WALK_LEFT2;
                        2'b11: animation_state = MARIO_WALK_LEFT3;
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
            default: animation_state = last_direction ? MARIO_WALK_LEFT3 : MARIO_WALK_RIGHT3;
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
                else if(COLLATION_DOWN & KEYJUMP) begin
                    next_state = MARIO_JUMPING;
                end
                else if(KEYLEFT & (~COLLATION_LEFT)) begin
                    next_state = MARIO_WALKING;
                end
                else if(KEYRIGHT & (~COLLATION_RIGHT)) begin
                    next_state = MARIO_WALKING;
                end
                else if(EN_CLAMP_UP | EN_CLAMP_DOWN) begin
                    next_state = MARIO_CLAMPING;
                end
                else begin
                    next_state = MARIO_STANDING;
                end
            end
        endcase
    end

endmodule