module top(input wire clk,
input wire ps2c, ps2d,
output wire[3:0] r,
output wire[3:0] g,
output wire[3:0] b,
output wire hs,vs,
output wire seg_clk,	
output wire seg_sout,	
output wire SEG_PEN,	
output wire seg_clrn,
output wire[5:0] led
);

localparam[3:0] up =4'b0001, left = 4'b0010, right = 4'b0011, down = 4'b0100, jump = 4'b1000, stop = 4'b0000;

reg[31:0] clk_div;
reg[8:0] posy;
reg[9:0] posx;
wire done;
wire[7:0] data;
reg[7:0] data_temp;
reg[31:0] dis_data;
reg[2:0] sample_state;
reg ready_to_push;
wire[3:0] movement;

assign led[3:0] = movement;
initial begin
    ready_to_push = 1'b0;
    clk_div = 0;
    posx = 0;
    posy = 0;
    sample_state = 0;
    dis_data = 0;
end

wire[11:0] color;
wire[8:0] row;
wire[9:0] col;

vgac vga_m(.d_in(color), .vga_clk(clk_div[1]), .clrn(1'b1), .row_addr(row), .col_addr(col), .r(r), .g(g), .b(b), .hs(hs), .vs(vs), .rdn());
//ps2 ps2_m(.clk(clk), .reset(1'b0), .rx_en(1'b1), .ps2d(ps2d), .ps2c(ps2c), .rx_done_tick(done), .dout(data));
//myps2_new ps2_m(.clk(clk), .rst(1'b0), .ps2d(ps2d), .ps2c(ps2c), .ready(done), .data(data));

color color_m(.clk(clk), .row(row), .col(col), .posX(posx),.posY(posy), .ocolor(color));

key2state get_movement(.clk(clk), .rst(1'b0), .ps2c(ps2c), .ps2d(ps2d), .move_state(movement), .out(data));

SSeg7_Dev seg7(.clk(clk), .rst(1'b0), .Start(clk_div[20]), .SW0(1'b1), .flash(1'b0),
     .Hexs(dis_data),  .point(8'h00), .LES(8'hff), 
     .seg_clk(seg_clk), .seg_sout(seg_sout), .SEG_PEN(SEG_PEN), .seg_clrn(seg_clrn));

always @(posedge clk)
begin
    clk_div = clk_div + 1;
end

always @(posedge clk_div[18])
begin
    case({1'b0, movement[2:0]})
        up:
            posy <= posy == 0 ? 480 : posy - 1;
        down: 
            posy <= posy == 480 ? 0 : posy + 1;
        left:
            posx <= posx == 0 ? 640 : posx - 1;
        right:
            posx <= posx == 640 ? 0 : posx + 1;
        default :
        begin
        end
    endcase 
end

always @(posedge done)
begin
    dis_data = {dis_data[23:0], data[7:0]};
end

endmodule