`timescale 1ns / 1ps

module W_kongcolor(
	 input wire clk,
    input wire[9:0] x,//scan signal from vgac
    input wire[8:0] y,//scan signal from vgac
    input wire[9:0] posx,//the position of the left-up corner
    input wire[8:0] posy,//the position of the left-up corner
	 input wire animation_state,
	 input wire isplay,
    output reg[15:0] color,//the data reading from IP core
	 output wire is_display
    );
	 localparam[9:0] width = 177;
    localparam[8:0] height = 117;
	 
    wire[15:0] data[1:0];
    wire[15:0] address;
    
    assign is_display = (x >= posx & x < posx + width & y >= posy  & y < posy + height) & isplay;
    assign address = (y - posy) * width + (x - posx);

	 KONG_1 m0(.spo(data[0]),.a(address));
	 KONG_2 m1(.spo(data[1]),.a(address));
    
    always @(posedge clk)
    begin
        if(is_display)
            case (animation_state)
              0: 
                color <= data[0];
              1:
                color <= data[1];
              default: 
                color <= 16'hffff;
				 endcase
        else color <= 16'hffff;
    end


endmodule
