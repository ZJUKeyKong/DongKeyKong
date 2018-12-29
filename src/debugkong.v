`timescale 1ns / 1ps

module debugkong(
	input wire clk,
    input wire [9:0] cx,
    input wire [8:0] cy,
	input wire [8:0] posY,
	input wire [9:0] posX,
    input wire state,
    input wire [1:0] animation_state,
	output reg [11:0] ocolor
    );

	// wire[23:0] load;
	// wire[11:0] address;

	localparam height = 160;
	localparam width = 120;

    localparam KONG_INITIAL = 1'b0,
               KONG_PLAYING = 1'b1;
    
    localparam KONG_NORMAL = 2'b00,
               KONG_GET    = 2'b01,
               KONG_HOLD   = 2'b10,
               KONG_DROP   = 2'b11;

    wire [9:0] relative_x;
    wire [8:0] relative_y;

    assign relative_x = 60 + posX - cx;
    assign relative_y = 80 + posY - cy;
	//IP core storing the image
	// img2 load_color(.a(address), .spo(load));
	// assign address = (row - posY) * width + (col - posX);
	always@(posedge clk)
	begin
		if(state == KONG_PLAYING && relative_x >= 0 && relative_x <= width && relative_y >= 0 && relative_y <= height) begin
            case (animation_state)
                KONG_NORMAL: ocolor = 12'h0F_F;
                KONG_GET: ocolor = 12'h00_F;
                KONG_HOLD: ocolor = 12'h0F_0;
                KONG_DROP: ocolor = 12'hF0_0;
                default: ocolor = 12'h00_0;
            endcase
        end
		else ocolor = 12'hFF_F;
	end

endmodule