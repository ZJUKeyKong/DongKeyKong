`timescale 1ns / 1ps

module W_Hint1(
	 input wire clk,
    input wire[9:0] x,//scan signal from vgac
    input wire[8:0] y,//scan signal from vgac
    input wire[9:0] posx,//the position of the left-up corner
    input wire[8:0] posy,//the position of the left-up corner
	 input wire isplay,
    output reg[15:0] color,
	 output wire is_display
    );
	 localparam[9:0] width = 224;
    localparam[8:0] height = 28;
	 
    wire[15:0] data;
    wire[12:0] address;
    
    assign is_display = (x >= posx & x < posx + width & y >= posy  & y < posy + height) & isplay;
    assign address = (y - posy) * width + (x - posx);

	 HINT_1 m0(.spo(data), .a(address));
    
    always @(posedge clk)
    begin
        if(is_display)begin
           color <= data;
		  end
        else color <= 16'hffff;
    end
endmodule
