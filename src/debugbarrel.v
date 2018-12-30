`timescale 1ns / 1ps

module debugbarrel(
	input wire clk,
    input wire [9:0] cx,
    input wire [8:0] cy,
	input wire [8:0] posY,
	input wire [9:0] posX,
    input wire [1:0] state,
    input wire [2:0] animation_state,
	output reg [11:0] ocolor
    );

	localparam BARREL_FALL_WIDTH  = 42,
               BARREL_FALL_HEIGHT = 24,
               BARREL_ROLL_WIDTH  = 32,
               BARREL_ROLL_HEIGHT = 24;

    localparam BARREL_INITIAL = 2'b00,
               BARREL_ROLLING = 2'b01,
               BARREL_FALLING = 2'b10;
    
    localparam BARREL_ROLL1 = 3'b000,
               BARREL_ROLL2 = 3'b001,
               BARREL_ROLL3 = 3'b010,
               BARREL_ROLL4 = 3'b011,
               BARREL_FALL1 = 3'b100,
               BARREL_FALL2 = 3'b101;

    wire [9:0] barrel_width;
	wire [8:0] barrel_height;

    wire [9:0] relative_x;
    wire [8:0] relative_y;

    assign relative_x = posX - cx;
    assign relative_y = posY - cy;

	assign barrel_width  = (animation_state[2] == 0) ?  BARREL_ROLL_WIDTH : BARREL_FALL_WIDTH;
	assign barrel_height = (animation_state[2] == 0) ? BARREL_ROLL_HEIGHT : BARREL_FALL_HEIGHT;
	//IP core storing the image
	// img2 load_color(.a(address), .spo(load));
	// assign address = (row - posY) * width + (col - posX);
	always@(posedge clk)
	begin
		if((state == BARREL_ROLLING || state == BARREL_FALLING) && relative_x >= 0 && relative_x <= barrel_width && relative_y >= 0 && relative_y <= barrel_height) begin
            case (animation_state)
                BARREL_ROLL1: ocolor = 12'h0F_F;
                BARREL_ROLL2: ocolor = 12'h00_F;
                BARREL_ROLL3: ocolor = 12'h0F_0;
                BARREL_ROLL4: ocolor = 12'hF0_0;
                BARREL_FALL1: ocolor = 12'hFF_0;
                BARREL_FALL2: ocolor = 12'hF0_F;
                default: ocolor = 12'h00_0;
            endcase
        end
		else ocolor = 12'hFF_F;
	end

endmodule