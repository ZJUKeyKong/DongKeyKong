`timescale 1ns / 1ps

module kong(
    input wire clk,  //clock signal
    input wire rst,  //reset signal
    input wire start,//start signal
    input wire over, //over signal
    output wire [9:0] x,  //kong position
    output wire [8:0] y,  //kong position
    output reg [3:0] drop_count,  //Determine the barrel id to drop
    output reg state,   //kong state
    output reg [1:0] animation_state  //kong animation
    );

    localparam KONG_INITIAL = 1'b0,  //kong two state
               KONG_PLAYING = 1'b1;

    localparam KONG_NORMAL = 2'b00,  //kong four animation
               KONG_GET    = 2'b01,
               KONG_HOLD   = 2'b10,
               KONG_DROP   = 2'b11;
    
    localparam KONG_INITIAL_X = 127,  //kong position
               KONG_INITIAL_Y = 79;
    
    reg next_state;
    reg [7:0] animation_counter;

    reg [10:0] clk_div;

    assign x = KONG_INITIAL_X;
    assign y = KONG_INITIAL_Y;
    
    initial begin  //initalize
        state = KONG_INITIAL;
        next_state = KONG_INITIAL;
        animation_state = KONG_NORMAL;
        drop_count = 0;
        clk_div = 0;
        animation_counter = 0;
    end

    always@ (posedge clk) begin
        state <= next_state;
        clk_div <= clk_div + 1'b1;  //self clock
    end

    always@ (posedge clk_div[5]) begin  //kong animation state switch
        case(state)
            KONG_INITIAL: begin
                animation_state = KONG_NORMAL;
            end
            KONG_PLAYING: begin
                case(animation_state)
                    KONG_GET: begin
                        animation_state = KONG_HOLD;
                    end
                    KONG_HOLD: begin
                        animation_state = KONG_DROP;
                    end
                    KONG_DROP: begin
                        animation_state = KONG_NORMAL;
                        drop_count = drop_count + 1'b1;  //drop barrel when display drop animate
                    end
                    KONG_NORMAL: begin
                        if(animation_counter[2:0] == 3'b101) begin
                            animation_counter = 0;
                            animation_state = KONG_GET;
                        end
                        else begin
                            animation_counter = animation_counter + 1'b1;
                        end
                    end
                endcase
            end
        endcase
    end

    always@ (*) begin  //kong state transform
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