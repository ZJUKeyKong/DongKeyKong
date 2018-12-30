`timescale 1ns / 1ps

module top(
	input wire clk,
	input wire rst,
	input wire [4:0] btn,
	// input wire ps2c,
	// input wire ps2d,
	output wire [3:0] r, g, b,
	output wire hs, vs,
	output wire SEG_CLK,
    output wire SEG_SOUT,
    output wire SEG_PEN,
    output wire SEG_CLRN
    );
	wire [31:0] clk_div;

	wire [31:0] seg_data;
	
	//assign seg_data = 32'h02_46_8A_CE;
	assign seg_data = {2'b00, mario_x, 3'b000, mario_y, 3'b000, btn};

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

	// key2state get_movement(.clk(clk), .rst(1'b0), .ps2c(ps2c), .ps2d(ps2d), .move_state(movement));

	Seg7_driver NumberDisplay(.clk(clk), .seg_clk(clk_div[20]), .data(seg_data),
			.SEG_CLK(SEG_CLK), .SEG_SOUT(SEG_SOUT), .SEG_PEN(SEG_PEN), .SEG_CLRN(SEG_CLRN));

	state_fsm StateControl(.clk(clk), .start(start), .restart(restart), .over(over), .success(success), .state(cur_state));

	wire [9:0] mario_x;
	wire [8:0] mario_y;
	wire [2:0] mario_state;
	wire [3:0] mario_animation;
	wire [9:0] mario_relative_x;
    wire [8:0] mario_relative_y;

    assign mario_relative_x = 30 + x - mario_x;
    assign mario_relative_y = 40 + y - mario_y;

	mario myMario(.clk(clk_div[20]), 
				  .rst(cur_state == GAME_INITIAL), 
				  .start(cur_state == GAME_RUNNING), 
				  .over(cur_state == GAME_OVER), 
				  .keydown(btn_out), 
				  .x(mario_x), .y(mario_y), 
				  .state(mario_state), 
				  .animation_state(mario_animation));

	wire [9:0] kong_x;
	wire [8:0] kong_y;
	wire kong_state;
	wire [1:0] kong_animation;
	wire [9:0] kong_relative_x;
	wire [8:0] kong_relative_y;

	assign kong_relative_x = 60 + x - kong_x;
	assign kong_relative_y = 80 + y - kong_y;

	kong myKong(.clk(clk_div[20]),
				.rst(cur_state == GAME_INITIAL), 
				.start(cur_state == GAME_RUNNING), 
				.over(cur_state == GAME_OVER),
				.x(kong_x), .y(kong_y),
				.state(kong_state),
				.animation_state(kong_animation));

	wire [9:0] queue_x;
	wire [8:0] queue_y;
	wire queue_state;
	wire queue_animation;
	wire [9:0] queue_relative_x;
	wire [8:0] queue_relative_y;

	assign queue_relative_x = 30 + x - queue_x;
	assign queue_relative_y = 50 + y - queue_y;

	queue myQueue(.clk(clk_div[20]),
				  .rst(cur_state == GAME_INITIAL), 
				  .start(cur_state == GAME_RUNNING), 
				  .over(cur_state == GAME_OVER),
				  .x(queue_x), .y(queue_y),
				  .state(queue_state),
				  .animation_state(queue_animation));

	wire [9:0] barrel_x;
	wire [8:0] barrel_y;
	wire [1:0] barrel_state;
    wire [2:0] barrel_animation;
	wire [9:0] barrel_relative_x;
	wire [8:0] barrel_relative_y;

	assign barrel_relative_x = 20 + x - barrel_x;
	assign barrel_relative_y = 30 + y - barrel_y;

	barrel myBarrel(.clk(clk_div[20]),
				    .rst(cur_state == GAME_INITIAL), 
				    .start(cur_state == GAME_RUNNING), 
				    .over(cur_state == GAME_OVER),
					.x(barrel_x), .y(barrel_y),
					.state(barrel_state),
					.animation_state(barrel_animation));

	wire [15:0] background_img;
	wire [11:0] mario_img;
	wire [11:0] kong_img;
	wire [11:0] queue_img;
	wire [11:0] barrel_img;

	// assign background_img = 12'h0F_0;
	color GetBackground(.clk(clk), .cx(9'd320), .cy(8'd240), .posX(x), .posY(y), .ocolor(background_img));
	debugblock Mariocolor(.clk(clk_div[1]), .cx(mario_x), .cy(mario_y), .posX(x), .posY(y), .state(mario_state), .ocolor(mario_img));
	debugkong Kongcolor(.clk(clk_div[1]), .cx(kong_x), .cy(kong_y), .posX(x), .posY(y), .state(kong_state), .animation_state(kong_animation), .ocolor(kong_img));
	debugqueue Queuecolor(.clk(clk_div[1]), .cx(queue_x), .cy(queue_y), .posX(x), .posY(y), .state(queue_state), .animation_state(queue_animation), .ocolor(queue_img));
	debugbarrel Barrelcolor(.clk(clk_div[1]), .cx(barrel_x), .cy(barrel_y), .posX(x), .posY(y), .state(barrel_state), .animation_state(barrel_animation), .ocolor(barrel_img));
	// display_scene SceneDisplay(.clk(clk), .scene_clk(clk_div[20]),
	// 						   .x(x), .y(y), .cur_state(cur_state), 
	// 						   .color(background_img));

	always@ (posedge clk) begin
		case (cur_state)
			GAME_INITIAL: begin
				vga_data <= 12'hF0_0;
			end
			GAME_RUNNING: begin
				if(mario_relative_x >= 0 & mario_relative_x < 60 & mario_relative_y >= 0 & mario_relative_y < 80) begin
					vga_data <= mario_img;
				end
				else if(kong_relative_x >= 0 & kong_relative_x < 120 & kong_relative_y >= 0 & kong_relative_y < 160) begin
					vga_data <= kong_img;
				end
				else if(queue_relative_x >= 0 & queue_relative_x < 60 & queue_relative_y >= 0 & queue_relative_y < 100) begin
					vga_data <= queue_img;
				end
				else if(barrel_relative_x >= 0 & barrel_relative_x < 40 & barrel_relative_y >= 0 & barrel_relative_y < 60) begin
					vga_data <= barrel_img;
				end
				else if (background_img == 16'hFF_FF)begin
					vga_data <= 12'h00_0;
				end
				else begin
					vga_data <= background_img[15:4];
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
