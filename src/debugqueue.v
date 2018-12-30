`timescale 1ns / 1ps

module debugqueue(
	input wire clk,
    input wire [9:0] cx,
    input wire [8:0] cy,
	input wire [8:0] posY,
	input wire [9:0] posX,
    input wire state,
    input wire animation_state,
	output reg [11:0] ocolor
    );

	// wire[23:0] load;
	// wire[11:0] address;

	localparam height = 50;
	localparam width = 44;

    localparam QUEUE_INITIAL = 1'b0,
               QUEUE_PLAYING = 1'b1;

    localparam QUEUE_LEFT  = 1'b0,
               QUEUE_RIGHT = 1'b1;

    wire [9:0] relative_x;
    wire [8:0] relative_y;

    assign relative_x = (width  >> 1) + posX - cx;
    assign relative_y = (height >> 1) + posY - cy;
	// IP core storing the image
	// img2 load_color(.a(address), .spo(load));
	// assign address = (row - posY) * width + (col - posX);
	always@(posedge clk)
	begin
		if(state == QUEUE_PLAYING && relative_x >= 0 && relative_x <= width && relative_y >= 0 && relative_y <= height) begin
            case (animation_state)
                QUEUE_LEFT:  ocolor = 12'hF0_0;
                QUEUE_RIGHT: ocolor = 12'h00_F;
                default: ocolor = 12'h00_0;
            endcase
        end
		else ocolor = 12'hFF_F;
	end

endmodule