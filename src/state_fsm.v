`timescale 1ns / 1ps
/*
Game state finish state machine
Game have 4 state to determine which scene to display
*/
module state_fsm(
    input wire clk,
    input wire start,
    input wire restart,
    input wire over,
    input wire success,
    output reg [1:0] state
    );

    localparam GAME_INITIAL = 2'b00,  //Game state
               GAME_RUNNING = 2'b01,
               GAME_OVER    = 2'b10,
               GAME_SUCCESS = 2'b11;

    reg [1:0] next_state;

    initial begin  //initialize
        next_state = GAME_INITIAL;
    end

    always @ (posedge clk) begin
        state <= next_state;
    end

    always@ (*) begin  //Game state tranform
        next_state = state;
        case (state)
            GAME_INITIAL: begin
                if (start & ~restart)
                    next_state = GAME_RUNNING;
            end
            GAME_RUNNING: begin
                if (over) begin
                    next_state = GAME_OVER;
                end
                else if (restart) begin
                    next_state = GAME_INITIAL;
                end
                else if (success) begin
                    next_state = GAME_SUCCESS;
                end
            end
            GAME_OVER: begin
                if (restart) begin
                    next_state = GAME_INITIAL;
                end
            end
            GAME_SUCCESS: begin
                if(restart) begin
                    next_state = GAME_INITIAL;
                end
            end
        endcase
    end

endmodule