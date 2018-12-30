module kongColor(
    input wire clk,
    input wire[9:0] col,//scan signal from vgac
    input wire[8:0] row,//scan signal from vgac
    input wire[9:0] posx,//the position of the left-up corner of Mario(col)
    input wire[8:0] posy,//the position of the left-up corner of Mario(row)
    input wire[3:0] animate_state,
    output reg[15:0] color//the data reading from IP core
);

    localparam[1:0] KONG_NORMAL = 2'b00,
                    KONG_GET    = 2'b01,
                    KONG_HOLD   = 2'b10,
                    KONG_DROP = 2'b11;
    localparam[9:0] width = 112;
    localparam[8:0] height = 72;

    wire is_display;
    wire[15:0] data[3:0];
    wire[12:0] address;
    
    assign is_display = col >= posx & col < posx + width & row >= posy  & row < posy + height;
    assign address = (row - posy) * width + (col - posx);

    KONG_NORMAL_img m0(.spo(data[0]), .a(address));
    KONG_GET_img m1(.spo(data[1]), .a(address));
    KONG_HOLD_img m2(.spo(data[2]), .a(address));
    KONG_DROP_img m3(.spo(data[3]), .a(address));
    
    always @(posedge clk)
    begin
        if(is_display)
            case (animate_state)
              KONG_NORMAL: 
                color <= data[0];
              KONG_GET:
                color <= data[1];
              KONG_HOLD:
                color <= data[2];
              KONG_DROP:
                color <= data[3];
              default: 
                color <= 16'hffff;
            endcase
        else color <= 16'hffff;
    end
endmodule // 
