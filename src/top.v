`timescale 1ns / 1ps

module top(
	input wire clk,
	input wire ps2c,  //ps2 input clock
 	input wire ps2d,  //ps2 input data
	input wire [1:0] SW,  //switch signal
	output wire [3:0] r, g, b,  //vga color
	output wire hs, vs,  //vga scan signal
	output wire SEG_CLK,  //7-segment 
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

	localparam GAME_INITIAL = 2'b00,  //game state define
               GAME_RUNNING = 2'b01,
               GAME_OVER    = 2'b10,
               GAME_SUCCESS = 2'b11;
	
	wire start, over, restart, success;
	wire [1:0] cur_state;

	assign start = W_state[0] & W_state[1];  //start signal judge
	//assign over = 1'b0;
	assign restart = SW[1];  //switch judge
	assign success = mario_y < 30 && (mario_x > 250 && mario_x < 350) && mario_state == 3'b100; //around queen
	
	wire [9:0] x;
	wire [8:0] y;
	reg [11:0] vga_data;

	clkdiv GenClk(.clk(clk), .clk_div(clk_div));  //clk signal

	VGA_driver VGADisplay(.vga_clk(clk_div[1]), .data(vga_data), 
						   .x(x), .y(y), .hs(hs), .vs(vs),
						   .r(r), .g(g), .b(b));

	key2state get_movement(.clk(clk), .rst(1'b0), .ps2c(ps2c), .ps2d(ps2d), .move_state(movement));

	Seg7_driver NumberDisplay(.clk(clk), .seg_clk(clk_div[20]), .data(seg_data),
			.SEG_CLK(SEG_CLK), .SEG_SOUT(SEG_SOUT), .SEG_PEN(SEG_PEN), .SEG_CLRN(SEG_CLRN));

	state_fsm StateControl(.clk(clk), .start(start), .restart(restart), .over(over), .success(success), .state(cur_state));

	localparam queue_width  	  = 44,  //obejct size
           	   queue_height 	  = 50,
               kong_height  	  = 72,
	           kong_width   	  = 112,
               mario_height 	  = 36,
	           mario_width        = 34,
			   BARREL_FALL_WIDTH  = 42,
               BARREL_FALL_HEIGHT = 24,
               BARREL_ROLL_WIDTH  = 32,
               BARREL_ROLL_HEIGHT = 24;

	wire [9:0] barrel_width;  //barrel size changable
	wire [8:0] barrel_height;

	wire [9:0] mario_x;  //object position
	wire [8:0] mario_y;
	wire [2:0] mario_state;
	wire [3:0] mario_animation;
	wire [9:0] mario_relative_x;
    wire [8:0] mario_relative_y;

    assign mario_relative_x = x - mario_x;  //mario relative position
    assign mario_relative_y = y - mario_y;

	mario myMario(.clk(clk_div[20]),   //mario state
				  .rst(cur_state == GAME_INITIAL), 
				  .start(cur_state == GAME_RUNNING), 
				  .over(cur_state == GAME_OVER), 
				  .keydown(movement), 
				  .x(mario_x), .y(mario_y), 
				  .state(mario_state), 
				  .animation_state(mario_animation));

	wire [9:0] kong_x;  //kong position
	wire [8:0] kong_y;
	wire kong_state;  //kong state
	wire [1:0] kong_animation;  //kong animation
	wire [9:0] kong_relative_x;  //kong relative position
	wire [8:0] kong_relative_y;

	localparam KONG_DROP = 2'b11;  //kong drop animation
	reg [3:0] drop_count = 0;

	assign kong_relative_x = (kong_width  >> 1) + x - kong_x;  //kong relative position
	assign kong_relative_y = (kong_height >> 1) + y - kong_y;

	wire is_drop;  //not use

	kong myKong(.clk(clk_div[20]),
				.rst(cur_state == GAME_INITIAL), 
				.start(cur_state == GAME_RUNNING), 
				.over(cur_state == GAME_OVER),
				.is_drop(is_drop),
				.x(kong_x), .y(kong_y),
				.state(kong_state),
				.animation_state(kong_animation));

	always@ (posedge is_drop) begin
		drop_count <= drop_count + 1'b1;  //drop count define the drop barrel id
	end

	wire [9:0] queue_x; //queen position
	wire [8:0] queue_y;
	wire queue_state;  //queen state
	wire queue_animation;
	wire [9:0] queue_relative_x;  //queen relative position
	wire [8:0] queue_relative_y;

	assign queue_relative_x = (queue_width  >> 1) + x - queue_x;  //queen left up corner
	assign queue_relative_y = (queue_height >> 1) + y - queue_y;

	queue myQueue(.clk(clk_div[20]),
				  .rst(cur_state == GAME_INITIAL), 
				  .start(cur_state == GAME_RUNNING), 
				  .over(cur_state == GAME_OVER),
				  .x(queue_x), .y(queue_y),
				  .state(queue_state),
				  .animation_state(queue_animation));

	localparam BARREL_NUM_MAX = 16;  //barrel max number
	localparam BARREL_INITIAL = 2'b00,
               BARREL_ROLLING = 2'b01,
               BARREL_FALLING = 2'b10;

	wire [9:0] barrel_x [0:BARREL_NUM_MAX - 1];  //barrel position
	wire [8:0] barrel_y [0:BARREL_NUM_MAX - 1];
	wire [1:0] barrel_state [0:BARREL_NUM_MAX - 1];  //barrel state
	wire [2:0] barrel_animation [0:BARREL_NUM_MAX - 1];  //barrel animation
	wire [9:0] barrel_relative_x [0:BARREL_NUM_MAX - 1];  //barrrel relative position
	wire [8:0] barrel_relative_y [0:BARREL_NUM_MAX - 1];
	wire [9:0] barrel_curwidth [0:BARREL_NUM_MAX - 1];  //barrel size
	wire [8:0] barrel_curheight [0:BARREL_NUM_MAX - 1];
	wire [15:0] barrel_color [0:BARREL_NUM_MAX - 1];  //barrel image
	wire [10:0] barrel_count [0:BARREL_NUM_MAX - 1];  //barrel score count

	generate  //generate each barrel code
		genvar target_index;
		for(target_index = 0; target_index < BARREL_NUM_MAX; target_index = target_index + 1) begin: barrel_generator
			barrel myBarrel(.clk(clk_div[18]),
							.rst(cur_state == GAME_INITIAL),
							.start((cur_state == GAME_RUNNING) & (target_index == drop_count)),
							.over((cur_state == GAME_OVER) | (barrel_x[target_index] > 560 & barrel_y[target_index] > 410)),
							.x(barrel_x[target_index]), .y(barrel_y[target_index]),
							.state(barrel_state[target_index]),
							.animation_state(barrel_animation[target_index]));
			assign barrel_relative_x[target_index] = x - barrel_x[target_index];  //calculate barrel relative position
			assign barrel_relative_y[target_index] = y - barrel_y[target_index];
			assign barrel_curwidth[target_index] = barrel_state[target_index] == BARREL_FALLING ? BARREL_FALL_WIDTH : (barrel_state[target_index] == BARREL_ROLLING ? BARREL_ROLL_WIDTH : 0);  //calculate barrel size
			assign barrel_curheight[target_index] = barrel_state[target_index] == BARREL_FALLING ? BARREL_FALL_HEIGHT : (barrel_state[target_index] == BARREL_ROLLING ? BARREL_ROLL_HEIGHT : 0);
			barrelColor myBarrelColor(.clk(clk_div[1]),  //barrel image pick
									  .col(x), .row(y),
									  .posx(barrel_x[target_index]), .posy(barrel_y[target_index]),
									  .animate_state(barrel_animation[target_index]),
									  .color(barrel_color[target_index]));
			score myScore(.clk(clk_div[1]),  //score count
						  .rst(cur_state == GAME_INITIAL),
						  .mario_posx(mario_x), .mario_posy(mario_y),
						  .barrel_posx(barrel_x[target_index]), .barrel_posy(barrel_y[target_index]),
						  .barrel_fall(barrel_animation[target_index][2] == 1'b1),
						  .mario_jumping(mario_state == 3'b001),
						  .count(barrel_count[target_index]));
		end
	endgenerate
	
	assign total_count = (barrel_count[0] + barrel_count[1] + barrel_count[2] + barrel_count[3] + barrel_count[4] + barrel_count[5] + barrel_count[6] + barrel_count[7] + barrel_count[8] + barrel_count[9] + barrel_count[10] + barrel_count[11] + barrel_count[12] + barrel_count[13] + barrel_count[14] + barrel_count[15]);  //total score
	
	assign
        seg_data[ 3: 0] = 0,
        seg_data[ 7: 4] = 0,
        seg_data[11: 8] = total_count % 10,
        seg_data[15:12] = total_count/     10 % 10,
        seg_data[19:16] = total_count/    100 % 10,
        seg_data[23:20] = total_count/   1000 % 10,
        seg_data[27:24] = total_count/  10000 % 10,
        seg_data[31:28] = total_count/ 100000 % 10;  //display score in 7-segment
 
	reg [BARREL_NUM_MAX - 1 : 0] mario_collision;  //mario collision with each barrel
	wire collision;
	generate
		genvar coltarget_index;
		for(coltarget_index = 0; coltarget_index < BARREL_NUM_MAX; coltarget_index = coltarget_index + 1) begin: barrel_collision_check
			always@ (*) begin  //collision check
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
	
	reg[127:0] collision_sampler;  //sample the collision state to judge collision more precise
	initial begin
		collision_sampler <= 128'b0;
	end
	assign collision = |mario_collision;
	assign over = (~SW[0]) & ((&collision_sampler) | (mario_x < 183 && mario_y < 114));
	
	always @(clk_div[20])
	begin
		collision_sampler <= {collision_sampler[126:0], collision};
	end
	
	always@ (posedge clk) begin
		tmpsto <= collision ? mario_collision : tmpsto ;
	end


	wire [15:0] background_img;  //get background image
	wire [11:0] character_img;  //get character image

	characterColor Charactercolor(.clk(clk_div[1]), 
								  .mario_state(mario_animation), .kong_state(kong_animation),
								  .queue_state(queue_animation),// .barrel_state(barrel_animation),
								  .col(x), .mario_posx(mario_x), .queue_posx(queue_x - (queue_width >> 1)),
								  .kong_posx(kong_x - (kong_width >> 1)),// .barrel_posx(barrel_x),
								  .row(y), .mario_posy(mario_y), .queue_posy(queue_y - (queue_height >> 1)),
								  .kong_posy(kong_y - (kong_height >> 1)),// .barrel_posy(barrel_y),
								  .color(character_img));
	color GetBackground(.clk(clk), .cx(9'd320), .cy(8'd240), .posX(x), .posY(y), .ocolor(background_img));
	
	
	wire [11:0] W_color;  //welcome image display
	wire [1:0] W_state;  //welcome state
	WelStateControl   Wel00(.clk(clk),.start(cur_state == GAME_INITIAL),.movement(movement),.state(W_state));
	WelcomeBG			Wel01(.clk(clk),.state(W_state),.x(x),.y(y),.color(W_color));
	
	wire [11:0]S_color;  //success image heart
	S_heart			  	Suc(.clk(clk),.color(S_color),.is_display(), .x(x), .y(y), .isplay(1'b1),  .posx(9'd275), .posy(8'd20));
	
	integer barrel_display_index;

	always@ (posedge clk) begin  //display logic
		case (cur_state)
			GAME_INITIAL: begin  //display welcome
				vga_data = W_state;
			end
			GAME_RUNNING: begin  //display when running and handle transparent image pixel 
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
			GAME_OVER: begin  //display background and each object, no barrel
				vga_data = 12'h00_0;
				if (background_img != 16'hFF_FF)begin
					vga_data = background_img[15:4];
				end
				if(character_img != 12'h00_0) begin
					vga_data = character_img;
				end
			end
			GAME_SUCCESS: begin  //display heart to show the success scene
				vga_data = 12'h00_0;
				if (background_img != 16'hFF_FF)begin
					vga_data = background_img[15:4];
				end
				if(character_img != 12'h00_0) begin
					vga_data = character_img;
				end
				if(S_color != 12'hfff)begin
					vga_data = S_color;
				end
			end
		endcase
	end

endmodule
