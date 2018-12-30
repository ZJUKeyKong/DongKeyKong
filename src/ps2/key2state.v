//Send ps2 port and clk to this module
//This module will return the state for movement
module key2state(
    input wire clk,rst,
    input wire ps2c, ps2d,
    output wire[4:0] move_state
);
    wire[7:0] data;
    wire[7:0] key;
    wire[4:0] state;
    
    reg[1:0] clk_25mhz;
    initial begin
        clk_25mhz <= 2'b00;
    end
    always @(posedge clk)
        clk_25mhz  = clk_25mhz + 2'b01;

    Keyboard m0(.clk_25MHz(clk_25mhz[1]), .PS2Clk(ps2c), .PS2Data(ps2d),
     .upKeyState(move_state[0]), .downKeyState(move_state[3]), .leftKeyState(move_state[1]),
      .rightKeyState(move_state[2]), .spaceKeyState(move_state[4]));
    
endmodule