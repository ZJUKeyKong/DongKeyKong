`timescale 1ns / 1ps

module top(
	input wire clk,
	input wire ps2c,
	input wire ps2d,
	input wire [1:0] SW,
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
	wire [31:0] total_count;
	reg [15:0] tmpsto;

	//assign seg_data = {tmpsto, mario_collision};

	localparam GAME_INITIAL = 2'b00,
               GAME_RUNNING = 2'b01,
               GAME_OVER    = 2'b10,
               GAME_SUCCESS = 2'b11;
	
	wire start, over, restart, success;
	wire [1:0] cur_state;

	assign start = 1'b1;
	//assign over = 1'b0;
	assign restart = SW[1];
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
				  .animation_state(mario_animation));

	wire [9:0] kong_x;
	wire [8:0] kong_y;
	wire kong_state;
	wire [1:0] kong_animation;
	wire [9:0] kong_relative_x;
	wire [8:0] kong_relative_y;

	localparam KONG_DROP = 2'b11;
	reg [3:0] drop_count = 0;

	assign kong_relative_x = (kong_width  >> 1) + x - kong_x;
	assign kong_relative_y = (kong_height >> 1) + y - kong_y;

	wire is_drop;

	kong myKong(.clk(clk_div[20]),
				.rst(cur_state == GAME_INITIAL), 
				.start(cur_state == GAME_RUNNING), 
				.over(cur_state == GAME_OVER),
				.is_drop(is_drop),
				.x(kong_x), .y(kong_y),
				.state(kong_state),
				.animation_state(kong_animation));

	always@ (posedge is_drop) begin
		drop_count <= drop_count + 1'b1;
	end

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

	localparam BARREL_NUM_MAX = 16;
	localparam BARREL_INITIAL = 2'b00,
               BARREL_ROLLING = 2'b01,
               BARREL_FALLING = 2'b10;

	wire [9:0] barrel_x [0:BARREL_NUM_MAX - 1];
	wire [8:0] barrel_y [0:BARREL_NUM_MAX - 1];
	wire [1:0] barrel_state [0:BARREL_NUM_MAX - 1];
	wire [2:0] barrel_animation [0:BARREL_NUM_MAX - 1];
	wire [9:0] barrel_relative_x [0:BARREL_NUM_MAX - 1];
	wire [8:0] barrel_relative_y [0:BARREL_NUM_MAX - 1];
	wire [9:0] barrel_curwidth [0:BARREL_NUM_MAX - 1];
	wire [8:0] barrel_curheight [0:BARREL_NUM_MAX - 1];
	wire [15:0] barrel_color [0:BARREL_NUM_MAX - 1];
	wire [10:0] barrel_count [0:BARREL_NUM_MAX - 1];

	generate
		genvar target_index;
		for(target_index = 0; target_index < BARREL_NUM_MAX; target_index = target_index + 1) begin: barrel_generator
			barrel myBarrel(.clk(clk_div[18]),
							.rst(cur_state == GAME_INITIAL),
							.start((cur_state == GAME_RUNNING) & (target_index == drop_count)),
							.over((cur_state == GAME_OVER) | (barrel_x[target_index] > 560 & barrel_y[target_index] > 410)),
							.x(barrel_x[target_index]), .y(barrel_y[target_index]),
							.state(barrel_state[target_index]),
							.animation_state(barrel_animation[target_index]));
			assign barrel_relative_x[target_index] = x - barrel_x[target_index];
			assign barrel_relative_y[target_index] = y - barrel_y[target_index];
			assign barrel_curwidth[target_index] = barrel_state[target_index] == BARREL_FALLING ? BARREL_FALL_WIDTH : (barrel_state[target_index] == BARREL_ROLLING ? BARREL_ROLL_WIDTH : 0);
			assign barrel_curheight[target_index] = barrel_state[target_index] == BARREL_FALLING ? BARREL_FALL_HEIGHT : (barrel_state[target_index] == BARREL_ROLLING ? BARREL_ROLL_HEIGHT : 0);
			barrelColor myBarrelColor(.clk(clk_div[1]),
									  .col(x), .row(y),
									  .posx(barrel_x[target_index]), .posy(barrel_y[target_index]),
									  .animate_state(barrel_animation[target_index]),
									  .color(barrel_color[target_index]));
			score myScore(.clk(clk_div[1]),
						  .rst(cur_state == GAME_INITIAL),
						  .mario_posx(mario_x), .mario_posy(mario_y),
						  .barrel_posx(barrel_x[target_index]), .barrel_posy(barrel_y[target_index]),
						  .barrel_fall(barrel_animation[target_index][2] == 1'b1),
						  .mario_jumping(mario_state == 3'b001),
						  .count(barrel_count[target_index]));
		end
	endgenerate
	
	assign total_count = (barrel_count[0] + barrel_count[1] + barrel_count[2] + barrel_count[3] + barrel_count[4] + barrel_count[5] + barrel_count[6] + barrel_count[7] + barrel_count[8] + barrel_count[9] + barrel_count[10] + barrel_count[11] + barrel_count[12] + barrel_count[13] + barrel_count[14] + barrel_count[15]);
	
	assign
        seg_data[ 3: 0] = 0,
        seg_data[ 7: 4] = 0,
        seg_data[11: 8] = total_count % 10,
        seg_data[15:12] = total_count/     10 % 10,
        seg_data[19:16] = total_count/    100 % 10,
        seg_data[23:20] = total_count/   1000 % 10,
        seg_data[27:24] = total_count/  10000 % 10,
        seg_data[31:28] = total_count/ 100000 % 10;
 
	reg [BARREL_NUM_MAX - 1 : 0] mario_collision;
	wire collision;
	generate
		genvar coltarget_index;
		for(coltarget_index = 0; coltarget_index < BARREL_NUM_MAX; coltarget_index = coltarget_index + 1) begin: barrel_collision_check
			always@ (*) begin
				mario_collision[coltarget_index] = ((barrel_state[coltarget_index] == BARREL_ROLLING) ||
				(barrel_state[coltarget_index] == BARREL_FALLING)) && 
				((barrel_x[coltarget_index] > mario_x && 
				barrel_x[coltarget_index] < mario_x + mario_width &&
				barrel_y[coltarget_index] > mario_y && 
				barrel_y[coltarget_index] < mario_y + mario_height) ||
				(barrel_x[coltarget_index] + barrel_curwidth[coltarget_index] > mario_x && 
				barrel_x[coltarget_index] + barrel_curwidth[coltarget_index] < mario_x + mario_width &&
				barrel_y[coltarget_index] > mario_y && 
				barrel_y[coltarget_index] < mario_y + mario_height) ||
				(barrel_x[coltarget_index] > mario_x && 
				barrel_x[coltarget_index] < mario_x + mario_width &&
				barrel_y[coltarget_index] + barrel_curheight[coltarget_index] > mario_y && 
				barrel_y[coltarget_index] + barrel_curheight[coltarget_index] < mario_y + mario_height) ||
				(barrel_x[coltarget_index] + barrel_curwidth[coltarget_index] > mario_x && 
				barrel_x[coltarget_index] + barrel_curwidth[coltarget_index] < mario_x + mario_width &&
				barrel_y[coltarget_index] + barrel_curheight[coltarget_index] > mario_y && 
				barrel_y[coltarget_index] + barrel_curheight[coltarget_index] < mario_y + mario_height));
			end
		end
	endgenerate
	
	reg[127:0] collision_sampler;
	initial begin
		collision_sampler <= 128'b0;
	end
	assign collision = |mario_collision;
	assign over = (~SW[0]) & (&collision_sampler);
	
	always @(clk_div[20])
	begin
		collision_sampler <= {collision_sampler[126:0], collision};
	end
	
	always@ (posedge clk) begin
		tmpsto <= collision ? mario_collision : tmpsto ;
	end


	wire [15:0] background_img;
	wire [11:0] character_img;

	characterColor Charactercolor(.clk(clk_div[1]), 
								  .mario_state(mario_animation), .kong_state(kong_animation),
								  .queue_state(queue_animation),// .barrel_state(barrel_animation),
								  .col(x), .mario_posx(mario_x), .queue_posx(queue_x - (queue_width >> 1)),
								  .kong_posx(kong_x - (kong_width >> 1)),// .barrel_posx(barrel_x),
								  .row(y), .mario_posy(mario_y), .queue_posy(queue_y - (queue_height >> 1)),
								  .kong_posy(kong_y - (kong_height >> 1)),// .barrel_posy(barrel_y),
								  .color(character_img));
	color GetBackground(.clk(clk), .cx(9'd320), .cy(8'd240), .posX(x), .posY(y), .ocolor(background_img));

	integer barrel_display_index;

	always@ (posedge clk) begin
		case (cur_state)
			GAME_INITIAL: begin
				vga_data = 12'hF0_0;
			end
			GAME_RUNNING: begin
				vga_data = 12'h00_0;
				if (background_img != 16'hFF_FF)begin
					vga_data = background_img[15:4];
				end
				for(barrel_display_index = 0; barrel_display_index < BARREL_NUM_MAX; barrel_display_index = barrel_display_index + 1) begin
					if(barrel_color[barrel_display_index] != 16'hFF_FF & barrel_state[barrel_display_index] != BARREL_INITIAL) begin
						vga_data = barrel_color[barrel_display_index][15:4];
					end
				end
				if(character_img != 12'h00_0) begin
					vga_data = character_img;
				end
			end
			GAME_OVER: begin
				vga_data = 12'h00_0;
				if (background_img != 16'hFF_FF)begin
					vga_data = background_img[15:4];
				end
				for(barrel_display_index = 0; barrel_display_index < BARREL_NUM_MAX; barrel_display_index = barrel_display_index + 1) begin
					if(barrel_color[barrel_display_index] != 16'hFF_FF & barrel_state[barrel_display_index] != BARREL_INITIAL) begin
						vga_data = barrel_color[barrel_display_index][15:4];
					end
				end
				if(character_img != 12'h00_0) begin
					vga_data = character_img;
				end
			end
			GAME_SUCCESS: begin
				vga_data = 12'h00_F;
			end
		endcase
	end

endmodule
