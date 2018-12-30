module top(input wire clk,
input wire ps2c, ps2d,
output wire[3:0] r,
output wire[3:0] g,
output wire[3:0] b,
output wire hs,vs,
//output wire seg_clk,	//串行移位时钟
//output wire seg_sout,	//七段显示数据(串行输出)
//output wire SEG_PEN,	//七段码显示刷新使能
//output wire seg_clrn,
output wire[5:0] led
);

localparam[3:0] up =4'b0001, left = 4'b0010, right = 4'b0011, down = 4'b0100, jump = 4'b1000, stop = 4'b0000;

reg[31:0] clk_div;
wire[8:0] posy;
wire[9:0] posx;
wire done;
wire[7:0] data;
reg[31:0] dis_data;
wire[4:0] movement;

assign led[3:0] = movement;
initial begin
    clk_div = 0;
    dis_data = 0;
end

wire[15:0] color;
wire[8:0] row;
wire[9:0] col;
wire[3:0] as;
reg temp;
key2state get_movement(.clk(clk), .rst(1'b0), .ps2c(ps2c), .ps2d(ps2d), .move_state(movement));
mario mario(.clk(clk_div[21]), .x(posx), .y(posy), .animation_state(as), .start(1'b1), .rst(1'b0), .over(1'b0), .keydown(movement));
marioColor color_m(.clk(clk), .row(row), .col(col), .posx(posx), .posy(posy), .color(color), .animate_state(as));

vgac vga_m(.d_in(color[15:4]), .vga_clk(clk_div[1]), .clrn(1'b1), .row_addr(row), .col_addr(col), .r(r), .g(g), .b(b), .hs(hs), .vs(vs), .rdn());

always @(posedge clk)
begin
    clk_div = clk_div + 1;
end


endmodule