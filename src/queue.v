`timescale 1ns / 1ps

module queue(
    input wire clk,
    input wire rst,
    input wire start,
    input wire over,
    output wire [9:0] x,
    output wire [8:0] y,
    output reg state,
    output reg animation_state
    );

    localparam QUEUE_INITIAL = 1'b0,
               QUEUE_PLAYING = 1'b1;

    localparam QUEUE_LEFT  = 1'b0,
               QUEUE_RIGHT = 1'b1;
    
    localparam QUEUE_INITIAL_X = 280,
               QUEUE_INITIAL_Y = 27;
    
    reg next_state;
    reg [4:0] animation_counter;

    assign x = QUEUE_INITIAL_X;
    assign y = QUEUE_INITIAL_Y;
    
    initial begin
        state = QUEUE_INITIAL;
        next_state = QUEUE_INITIAL;
        animation_state = QUEUE_RIGHT;
        animation_counter = 0;
    end

    always@ (posedge clk) begin
        state <= next_state;
    end

    always@ (posedge clk) begin
        case(state)
            QUEUE_INITIAL: begin
                animation_state = QUEUE_RIGHT;
            end
            QUEUE_PLAYING: begin
                case (animation_counter[4])
                    1'b0: animation_state = QUEUE_RIGHT;
                    1'b1: animation_state = QUEUE_LEFT;
                endcase
                animation_counter <= animation_counter + 1'b1;
            end
        endcase
    end

    always@ (*) begin
        next_state = state;
        case(state)
            QUEUE_INITIAL: begin
                if(start & (~rst)) next_state = QUEUE_PLAYING;
                else next_state = QUEUE_INITIAL;
            end
            QUEUE_PLAYING: begin
                if(rst | over) next_state = QUEUE_INITIAL;
                else next_state = QUEUE_PLAYING;
            end
        endcase
    end

endmodule