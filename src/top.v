`timescale 1ns / 1ps

module top(
	input wire clk,
	input wire rst,
	input wire [4:0] btn,
	
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
               GAME_OVER    = 2'b10,
               GAME_SUCCESS = 2'b11;
	
	wire start, over, restart, success;
	wire [1:0] cur_state;

	assign start = 1'b1;
	assign over = 1'b0;
	assign restart = 1'b0;
	assign success = 1'b0;
	
	wire [9:0] x;
	wire [8:0] y;
	reg [11:0] vga_data;

	clkdiv GenClk(.clk(clk), .clk_div(clk_div));

	wire [4:0] btn_out;

	pbdebounce pbd0(.clk_1ms(clk_div[17]), .button(btn[0]), .pbreg(btn_out[0]));
	pbdebounce pbd1(.clk_1ms(clk_div[17]), .button(btn[1]), .pbreg(btn_out[1]));
	pbdebounce pbd2(.clk_1ms(clk_div[17]), .button(btn[2]), .pbreg(btn_out[2]));
	pbdebounce pbd3(.clk_1ms(clk_div[17]), .button(btn[3]), .pbreg(btn_out[3]));
	pbdebounce pbd4(.clk_1ms(clk_div[17]), .button(btn[4]), .pbreg(btn_out[4]));

	VGA_driver VGADisplay(.vga_clk(clk_div[1]), .data(vga_data), 
						   .x(x), .y(y), .hs(hs), .vs(vs),
						   .r(r), .g(g), .b(b));

	Seg7_driver NumberDisplay(.clk(clk), .seg_clk(clk_div[20]), .data(seg_data),
			.SEG_CLK(SEG_CLK), .SEG_SOUT(SEG_SOUT), .SEG_PEN(SEG_PEN), .SEG_CLRN(SEG_CLRN));

	state_fsm StateControl(.clk(clk), .start(start), .restart(restart), .over(over), .success(success), .state(cur_state));

	wire [9:0] mario_x;
	wire [8:0] mario_y;
	wire [2:0] mario_state;
	wire [3:0] mario_animation;
	wire [9:0] relative_x;
    wire [8:0] relative_y;

    assign relative_x = 30 + x - mario_x;
    assign relative_y = 40 + y - mario_y;

	mario myMario(.clk(clk_div[20]), 
				  .rst(cur_state == GAME_INITIAL), 
				  .start(cur_state == GAME_RUNNING), 
				  .over(cur_state == GAME_OVER), 
				  .keydown(btn_out), 
				  .x(mario_x), .y(mario_y), 
				  .state(mario_state), 
				  .animation_state(mario_animation));

	wire [11:0] background_img;
	wire [11:0] mario_img;

	// assign background_img = 12'h0F_0;
	color GetBackground(.clk(clk_div[1]), .posX(x), .posY(y), .ocolor(background_img));
	debugblock Mariocolor(.clk(clk_div[1]), .cx(mario_x), .cy(mario_y), .posX(x), .posY(y), .state(mario_state), .ocolor(mario_img));

	// display_scene SceneDisplay(.clk(clk), .scene_clk(clk_div[20]),
	// 						   .x(x), .y(y), .cur_state(cur_state), 
	// 						   .color(background_img));

	always@ (posedge clk) begin
		case (cur_state)
			GAME_INITIAL: begin
				vga_data <= 12'hF0_0;
			end
			GAME_RUNNING: begin
				if(relative_x >= 0 & relative_x < 60 & relative_y >= 0 & relative_y < 80) begin
					vga_data <= mario_img;
				end
				else begin
					vga_data <= background_img;
				end
			end
			GAME_OVER: begin
				vga_data <= background_img;
			end
			GAME_SUCCESS: begin
				vga_data <= 12'h00_F;
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
