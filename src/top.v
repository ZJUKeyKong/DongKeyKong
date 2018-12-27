`timescale 1ns / 1ps

module top(
	input wire clk,
	input wire rst,
	
	output wire [3:0] r, g, b,
	output wire hs, vs,
	output wire SEG_CLK,
    output wire SEG_SOUT,
    output wire SEG_PEN,
    output wire SEG_CLRN
    );
	wire [31:0] clk_div;

	wire [31:0] seg_data;
	
	assign seg_data = 32'h02_46_8A_CE;

	localparam GAME_INITIAL = 2'b00,
               GAME_RUNNING = 2'b01,
               GAME_OVER    = 2'b02;
	
	wire start, over, restart;
	wire [1:0] cur_state;

	assign start = 1'b1;
	assign over = 1'b0;
	assign restart = 1'b0;
	
	wire [9:0] x;
	wire [8:0] y;
	reg [11:0] vga_data;

	clkdiv GenClk(.clk(clk), .clk_div(clk_div));

	VGA_driver VGADisplay(.vga_clk(clk_div[1]), .data(vga_data), 
						   .x(x), y(y), .hs(hs), .vs(vs),
						   .r(r), .g(g), .b(b));

	Seg7_driver NumberDisplay(.clk(clk), .seg_clk(clk_div[20]), .data(seg_data),
			.SEG_CLK(SEG_CLK), .SEG_SOUT(SEG_SOUT), .SEG_PEN(SEG_PEN), .SEG_CLRN(SEG_CLRN));

	state_fsm StateControl(.clk(clk), .start(start), .restart(restart), .over(over), .state(cur_state));

	wire [11:0] background_img;

	assign background_img = 12'h0F_0;

	// display_scene SceneDisplay(.clk(clk), .scene_clk(clk_div[20]),
	// 						   .x(x), .y(y), .cur_state(cur_state), 
	// 						   .color(background_img));

	always@ (posedge clk) begin
		case (cur_state)
			GAME_INITIAL: begin
				vga_data <= 12'hF0_0;
			end
			GAME_RUNNING: begin
				vga_data <= background_img;
			end
			GAME_OVER: begin
				vga_data <= background_img;
			end
		endcase
	end

	/*
	module display_scene(
	input wire clk,
    input wire scene_clk,
    input wire x,
    input wire y,
    input wire cur_state,
    output wire [11:0] color
    );
	*/

endmodule
