module queueColor(
    input wire clk,
    input wire[9:0] col,//scan signal from vgac
    input wire[8:0] row,//scan signal from vgac
    input wire[9:0] posx,//the position of the left-up corner of Mario(col)
    input wire[8:0] posy,//the position of the left-up corner of Mario(row)
    input wire animate_state,
    output reg[15:0] color//the data reading from IP core
);

    localparam[0:0] QUEUE_LEFT = 1'b0,
                    QUEUE_RIGHT = 1'b1;
    localparam[9:0] width = 44;
    localparam[8:0] height = 50;

    wire is_display;
    wire[15:0] data[1:0];
    wire[11:0] address;
    //To judge whether Queen is displayed on the pixel being scanned
    assign is_display = col >= posx & col < posx + width & row >= posy  & row < posy + height;
   //Calculate the address for reading data from ROM storing the image for Queen
    assign address = (row - posy) * width + (col - posx);

    QUEUE_LEFT_img m1(.spo(data[0]), .a(address));
    QUEUE_RIGHT_img m0(.spo(data[1]), .a(address));
    
    always @(posedge clk)
    begin
        if(is_display)
	  //Decide what color is displayed on screen according to the animate_state of Queen
            case (animate_state)
              QUEUE_LEFT: 
                color <= data[0];
              QUEUE_RIGHT:
                color <= data[1];
              default: 
                color <= 16'hffff;
            endcase
        else color <= 16'hffff;
    end
endmodule // 
