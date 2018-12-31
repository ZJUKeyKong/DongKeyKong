`timescale 1ns / 1ps

module top(
	input wire clk,
	input wire ps2c,
	input wire ps2d,
	output wire [3:0] r, g, b,
	output wire hs, vs,
	output wire SEG_CLK,
    output wire SEG_SOUT,
    output wire SEG_PEN,
    output wire SEG_CLRN
    );
	wire [31:0] clk_div;

	wire [31:0] seg_data;
	
	wire [4:0] movement;

	assign seg_data = {2'b00, mario_x, 3'b000, mario_y, 3'b000, movement};

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

	VGA_driver VGADisplay(.vga_clk(clk_div[1]), .data(vga_data), 
						   .x(x), .y(y), .hs(hs), .vs(vs),
						   .r(r), .g(g), .b(b));

	key2state get_movement(.clk(clk), .rst(1'b0), .ps2c(ps2c), .ps2d(ps2d), .move_state(movement));

	Seg7_driver NumberDisplay(.clk(clk), .seg_clk(clk_div[20]), .data(seg_data),
			.SEG_CLK(SEG_CLK), .SEG_SOUT(SEG_SOUT), .SEG_PEN(SEG_PEN), .SEG_CLRN(SEG_CLRN));

	state_fsm StateControl(.clk(clk), .start(start), .restart(restart), .over(over), .success(success), .state(cur_state));

	localparam queue_width  	  = 44,
           	   queue_height 	  = 50,
               kong_height  	  = 72,
	           kong_width   	  = 112,
               mario_height 	  = 36,
	           mario_width        = 34,
			   BARREL_FALL_WIDTH  = 42,
               BARREL_FALL_HEIGHT = 24,
               BARREL_ROLL_WIDTH  = 32,
               BARREL_ROLL_HEIGHT = 24;

	wire [9:0] barrel_width;
	wire [8:0] barrel_height;

	wire [9:0] mario_x;
	wire [8:0] mario_y;
	wire [2:0] mario_state;
	wire [3:0] mario_animation;
	wire [9:0] mario_relative_x;
    wire [8:0] mario_relative_y;

    assign mario_relative_x = x - mario_x;
    assign mario_relative_y = y - mario_y;

	mario myMario(.clk(clk_div[20]), 
				  .rst(cur_state == GAME_INITIAL), 
				  .start(cur_state == GAME_RUNNING), 
				  .over(cur_state == GAME_OVER), 
				  .keydown(movement), 
				  .x(mario_x), .y(mario_y), 
				  .state(mario_state), 
				  .animation_state(mario_animation),
				  .COLLATION_LEFT(colleft),
				  .COLLATION_RIGHT(colright),
				  .COLLATION_DOWN(coldown),
				  .COLLATION_UP(colup));

	wire [9:0] kong_x;
	wire [8:0] kong_y;
	wire kong_state;
	wire [1:0] kong_animation;
	wire [9:0] kong_relative_x;
	wire [8:0] kong_relative_y;

	assign kong_relative_x = (kong_width  >> 1) + x - kong_x;
	assign kong_relative_y = (kong_height >> 1) + y - kong_y;

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

	assign queue_relative_x = (queue_width  >> 1) + x - queue_x;
	assign queue_relative_y = (queue_height >> 1) + y - queue_y;

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

	assign barrel_relative_x = x - barrel_x;
	assign barrel_relative_y = y - barrel_y;

	assign barrel_width  = (barrel_animation[2] == 0) ?  BARREL_ROLL_WIDTH : BARREL_FALL_WIDTH;
	assign barrel_height = (barrel_animation[2] == 0) ? BARREL_ROLL_HEIGHT : BARREL_FALL_HEIGHT;

	barrel myBarrel(.clk(clk_div[20]),
				    .rst(cur_state == GAME_INITIAL), 
				    .start(cur_state == GAME_RUNNING), 
				    .over((cur_state == GAME_OVER) | (barrel_x > 560 & barrel_y > 410)),
					.x(barrel_x), .y(barrel_y),
					.state(barrel_state),
					.animation_state(barrel_animation));

	wire [15:0] background_img;
	wire [11:0] character_img;

	characterColor Charactercolor(.clk(clk_div[1]), 
								  .mario_state(mario_animation), .kong_state(kong_animation),
								  .queue_state(queue_animation), .barrel_state(barrel_animation),
								  .col(x), .mario_posx(mario_x), .queue_posx(queue_x - (queue_width >> 1)),
								  .kong_posx(kong_x - (kong_width >> 1)), .barrel_posx(barrel_x),
								  .row(y), .mario_posy(mario_y), .queue_posy(queue_y - (queue_height >> 1)),
								  .kong_posy(kong_y - (kong_height >> 1)), .barrel_posy(barrel_y),
								  .color(character_img));
	color GetBackground(.clk(clk), .cx(9'd320), .cy(8'd240), .posX(x), .posY(y), .ocolor(background_img));

	always@ (posedge clk) begin
		case (cur_state)
			GAME_INITIAL: begin
				vga_data <= 12'hF0_0;
			end
			GAME_RUNNING: begin
				if(character_img != 12'h00_0) begin
					vga_data <= character_img;
				end
				else if (background_img == 16'hFF_FF)begin
					vga_data <= 12'h00_0;
				end
				else begin
					vga_data <= background_img[15:4];
				end
			end
			GAME_OVER: begin
				vga_data <= background_img[15:4];
			end
			GAME_SUCCESS: begin
				vga_data <= 12'h00_F;
			end
		endcase
	end

endmodule
