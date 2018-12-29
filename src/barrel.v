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

    localparam TOP_BOARD = 9'd50,
               BOTTOM_BOARD = 9'd430,
               LEFT_BOARD = 10'd50,
               RIGHT_BOARD = 10'd590;
    
    localparam BARREL_INITIAL_X = 250,
               BARREL_INITIAL_Y = 150;

    localparam MOVSPEED_X = 3'd3,
               MOVSPEED_Y = 3'd3,
               ACCELERATION_Y = 1'b1;

    wire COLLATION_LEFT, COLLATION_RIGHT, COLLATION_DOWN;

    wire EN_FALL;

    assign COLLATION_RIGHT = x >= RIGHT_BOARD;
    assign COLLATION_LEFT  = x <= LEFT_BOARD;
    assign COLLATION_DOWN  = y >= BOTTOM_BOARD;
    assign COLLATION_UP    = y <= TOP_BOARD;

    assign EN_FALL = 1'b1;

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
                if(x + SPEED_X > RIGHT_BOARD) begin
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
                if(y + SPEED_Y > BOTTOM_BOARD) begin
                    y <= BOTTOM_BOARD;
                end
                else if(y + SPEED_Y < TOP_BOARD) begin
                    y <= TOP_BOARD;
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