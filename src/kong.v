`timescale 1ns / 1ps

module kong(
    input wire clk,
    input wire rst,
    input wire start,
    input wire over,
    output wire [9:0] x,
    output wire [8:0] y,
    output reg state,
    output reg [1:0] animation_state
    );

    localparam KONG_INITIAL = 1'b0,
               KONG_PLAYING = 1'b1;

    localparam KONG_NORMAL = 2'b00,
               KONG_GET    = 2'b01,
               KONG_HOLD   = 2'b10,
               KONG_DROP   = 2'b11;
    
    localparam KONG_INITIAL_X = 127,
               KONG_INITIAL_Y = 79;
    
    reg next_state;
    reg [6:0] animation_counter;

    assign x = KONG_INITIAL_X;
    assign y = KONG_INITIAL_Y;
    
    initial begin
        state = KONG_INITIAL;
        next_state = KONG_INITIAL;
        animation_state = KONG_NORMAL;
        animation_counter = 0;
    end

    always@ (posedge clk) begin
        state <= next_state;
    end

    always@ (posedge clk) begin
        case(state)
            KONG_INITIAL: begin
                animation_state = KONG_NORMAL;
            end
            KONG_PLAYING: begin
                case (animation_counter[6:4])
                    3'b101: animation_state = KONG_GET;
                    3'b110: animation_state = KONG_HOLD;
                    3'b111: animation_state = KONG_DROP;
                    default: animation_state = KONG_NORMAL;
                endcase
                animation_counter <= animation_counter + 1'b1;
            end
        endcase
    end

    always@ (*) begin
        next_state = state;
        case(state)
            KONG_INITIAL: begin
                if(start & (~rst)) next_state = KONG_PLAYING;
                else next_state = KONG_INITIAL;
            end
            KONG_PLAYING: begin
                if(rst | over) next_state = KONG_INITIAL;
                else next_state = KONG_PLAYING;
            end
        endcase
    end

endmodule