`timescale 1ns / 1ps

module debugblock(
	input wire clk,
    input wire [9:0] cx,
    input wire [8:0] cy,
	input wire [8:0] posY,
	input wire [9:0] posX,
    input wire [2:0] state,
	output reg [11:0] ocolor
    );

	// wire[23:0] load;
	// wire[11:0] address;

	localparam height = 64;
	localparam width = 64;

	localparam TOP_BOARD = 9'd50,
               BOTTOM_BOARD = 9'd430,
               LEFT_BOARD = 10'd50,
               RIGHT_BOARD = 10'd590;
    localparam MARIO_INITIAL  = 3'b000,
               MARIO_FLYING   = 3'b001,
               MARIO_JUMPING  = 3'b010,
               MARIO_WALKING  = 3'b011,
               MARIO_STANDING = 3'b100,
               MARIO_DYING    = 3'b101,
               MARIO_CLAMPING = 3'b110;

    wire [9:0] relative_x;
    wire [8:0] relative_y;

    assign relative_x = 30 + posX - cx;
    assign relative_y = 40 + posY - cy;
	//IP core storing the image
	// img2 load_color(.a(address), .spo(load));
	// assign address = (row - posY) * width + (col - posX);
	always@(posedge clk)
	begin
		if(relative_x >= 0 && relative_x <= 60 && relative_y >= 0 && relative_y <= 80) begin
            ocolor = {state[2], state[2], state[2], state[2], state[1], state[1], state[1], state[1], state[0], state[0], state[0], state[0]};
        end
		else ocolor = 12'hFF_F;
	end

endmodule