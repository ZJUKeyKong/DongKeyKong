`timescale 1ns / 1ps

module display_scene(
	input wire clk,
    input wire scene_clk,
    input wire x,
    input wire y,
    input wire cur_state,
    output wire [11:0] color
    );

    localparam GAME_INITIAL = 2'b00,
               GAME_RUNNING = 2'b01,
               GAME_OVER    = 2'b10,
               GAME_SUCCESS = 2'b11;



endmodule