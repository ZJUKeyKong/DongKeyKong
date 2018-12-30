`timescale 1ns / 1ps


module barrel(
    input wire clk,
    input wire rst,
    input wire start,
    input wire over,
    output reg [9:0] x,
    output reg [8:0] y,
    output reg [1:0] state,
    output reg [2:0] animation_state
    );

    localparam BARREL_INITIAL = 2'b00,
               BARREL_ROLLING = 2'b01,
               BARREL_FALLING = 2'b10;

    localparam BARREL_ROLL1 = 3'b000,
               BARREL_ROLL2 = 3'b001,
               BARREL_ROLL3 = 3'b010,
               BARREL_ROLL4 = 3'b011,
               BARREL_FALL1 = 3'b100,
               BARREL_FALL2 = 3'b101;

    localparam TOP_BOARD = 9'd5,
               BOTTOM_BOARD = 9'd461,
               LEFT_BOARD = 10'd5,
               RIGHT_BOARD = 10'd640;

    localparam land0lx = 10'd250,
               land0ly = 9'd53,
               land0rx = 10'd388,
               land0ry = 9'd70,
               land1lx = 10'd0,
               land1ly = 9'd114,
               land1rx = 10'd593,
               land1ry = 9'd133,
               land2lx = 10'd46,
               land2ly = 9'd169,
               land2rx = 10'd640,
               land2ry = 9'd187,
               land3lx = 10'd0,
               land3ly = 9'd243,
               land3rx = 10'd592,
               land3ry = 9'd261,
               land4lx = 10'd45,
               land4ly = 9'd315,
               land4rx = 10'd640,
               land4ry = 9'd334,
               land5lx = 10'd0,
               land5ly = 9'd388,
               land5rx = 10'd592,
               land5ry = 9'd406,
               land6lx = 10'd0,
               land6ly = 9'd461,
               land6rx = 10'd640,
               land6ry = 9'd479;
    
    localparam BARREL_INITIAL_X = 10'd203,
               BARREL_INITIAL_Y =  9'd91;

    localparam BARREL_FALL_WIDTH  = 42,
               BARREL_FALL_HEIGHT = 24,
               BARREL_ROLL_WIDTH  = 32,
               BARREL_ROLL_HEIGHT = 24;

    localparam MOVSPEED_X = 3'd3,
               MOVSPEED_Y = 3'd3,
               ACCELERATION_Y = 1'b1;

    wire COLLATION_LEFT, COLLATION_RIGHT, COLLATION_DOWN;

    wire EN_FALL;

    assign COLLATION_DOWN = (y + BARREL_FALL_HEIGHT >= BOTTOM_BOARD) | 
                            ((x < land0rx & x + BARREL_FALL_WIDTH > land0lx) & (y + BARREL_FALL_HEIGHT >= land0ly & y + BARREL_FALL_HEIGHT <= land0ry)) |
                            ((x < land1rx & x + BARREL_FALL_WIDTH > land1lx) & (y + BARREL_FALL_HEIGHT >= land1ly & y + BARREL_FALL_HEIGHT <= land1ry)) |
                            ((x < land2rx & x + BARREL_FALL_WIDTH > land2lx) & (y + BARREL_FALL_HEIGHT >= land2ly & y + BARREL_FALL_HEIGHT <= land2ry)) |
                            ((x < land3rx & x + BARREL_FALL_WIDTH > land3lx) & (y + BARREL_FALL_HEIGHT >= land3ly & y + BARREL_FALL_HEIGHT <= land3ry)) |
                            ((x < land4rx & x + BARREL_FALL_WIDTH > land4lx) & (y + BARREL_FALL_HEIGHT >= land4ly & y + BARREL_FALL_HEIGHT <= land4ry)) |
                            ((x < land5rx & x + BARREL_FALL_WIDTH > land5lx) & (y + BARREL_FALL_HEIGHT >= land5ly & y + BARREL_FALL_HEIGHT <= land5ry)) |
                            ((x < land6rx & x + BARREL_FALL_WIDTH > land6lx) & (y + BARREL_FALL_HEIGHT >= land6ly & y + BARREL_FALL_HEIGHT <= land6ry));

    assign EN_FALL = 1'b0;

//--------------------    End    ----------------------

    reg signed [9:0] SPEED_X;
    reg signed [8:0] SPEED_Y;

    reg [2:0] next_state;
    reg [4:0] animation_counter;
    
    initial begin
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
            BARREL_ROLLING: begin
                if(x + BARREL_ROLL_WIDTH + SPEED_X > RIGHT_BOARD) begin
                    x <= RIGHT_BOARD;
                end
                else if(x + SPEED_X < LEFT_BOARD) begin
                    x <= LEFT_BOARD;
                end
                else begin
                    x <= x + SPEED_X;
                end
                SPEED_Y <= 0;
                if(COLLATION_RIGHT) SPEED_X <= -MOVSPEED_X;
                else if(COLLATION_LEFT) SPEED_X <= MOVSPEED_X;
                animation_counter <= animation_counter + 1'b1;
            end
            BARREL_FALLING: begin
                if(y + BARREL_FALL_HEIGHT + SPEED_Y > BOTTOM_BOARD) begin
                    y <= BOTTOM_BOARD - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + BARREL_FALL_HEIGHT + SPEED_Y > land0ly & y + BARREL_FALL_HEIGHT + SPEED_Y < land0ry) & (x + SPEED_X < land0rx & x + SPEED_X + BARREL_ROLL_WIDTH > land0lx)) begin
                    y <= land0ly - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + BARREL_FALL_HEIGHT + SPEED_Y > land1ly & y + BARREL_FALL_HEIGHT + SPEED_Y < land1ry) & (x + SPEED_X < land1rx & x + SPEED_X + BARREL_ROLL_WIDTH > land1lx)) begin
                    y <= land1ly - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + BARREL_FALL_HEIGHT + SPEED_Y > land2ly & y + BARREL_FALL_HEIGHT + SPEED_Y < land2ry) & (x + SPEED_X < land2rx & x + SPEED_X + BARREL_ROLL_WIDTH > land2lx)) begin
                    y <= land2ly - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + BARREL_FALL_HEIGHT + SPEED_Y > land3ly & y + BARREL_FALL_HEIGHT + SPEED_Y < land3ry) & (x + SPEED_X < land3rx & x + SPEED_X + BARREL_ROLL_WIDTH > land3lx)) begin
                    y <= land3ly - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + BARREL_FALL_HEIGHT + SPEED_Y > land4ly & y + BARREL_FALL_HEIGHT + SPEED_Y < land4ry) & (x + SPEED_X < land4rx & x + SPEED_X + BARREL_ROLL_WIDTH > land4lx)) begin
                    y <= land4ly - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + BARREL_FALL_HEIGHT + SPEED_Y > land5ly & y + BARREL_FALL_HEIGHT + SPEED_Y < land5ry) & (x + SPEED_X < land5rx & x + SPEED_X + BARREL_ROLL_WIDTH > land5lx)) begin
                    y <= land5ly - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else if((y + BARREL_FALL_HEIGHT + SPEED_Y > land6ly & y + BARREL_FALL_HEIGHT + SPEED_Y < land6ry) & (x + SPEED_X < land6rx & x + SPEED_X + BARREL_ROLL_WIDTH > land6lx)) begin
                    y <= land6ly - BARREL_FALL_HEIGHT;
                    SPEED_Y <= 0;
                end
                else begin
                    y <= y + SPEED_Y;
                end
                // SPEED_X <= 0;
                SPEED_Y <= SPEED_Y + ACCELERATION_Y;
                animation_counter <= animation_counter + 1'b1;
            end
        endcase
    end

    always@ (*) begin
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

    always@ (*) begin
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
                else next_state = BARREL_ROLLING;
            end
            BARREL_FALLING: begin
                if(rst) next_state = BARREL_INITIAL;
                else if(over) next_state = BARREL_INITIAL;
                else if(COLLATION_DOWN) next_state = BARREL_ROLLING;
                else next_state = BARREL_FALLING;
            end
        endcase
    end

endmodule