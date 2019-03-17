`timescale 1ns / 1ps

module W_choicecolor(
	 input wire clk,
    input wire[9:0] x,//scan signal from vgac
    input wire[8:0] y,//scan signal from vgac
    input wire[9:0] posx,//the position of the left-up corner
    input wire[8:0] posy,//the position of the left-up corner
	 input wire isplay,
    output reg[15:0] color,//the data reading from IP core
	 output wire is_display
    );
	 localparam[9:0] width = 72;
    localparam[8:0] height = 40;
	 
    wire[15:0] data;
    wire[12:0] address;
    
    assign is_display = (x >= posx & x < posx + width & y >= posy  & y < posy + height) & isplay;
    assign address = (y - posy) * width + (x - posx);
	
	 CHOICE m0(.spo(data),.a(address));
    
    always @(posedge clk)
    begin
        if(is_display)begin
           color <= data;
		  end
        else color <= 16'hffff;
    end

endmodule
