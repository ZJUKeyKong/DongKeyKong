//Send ps2 port and clk to this module
//This module will return the state for movement
//where up =4'b0001, left = 4'b0010, right = 4'b0011, down = 4'b0100, jump = 4'b1000, stop = 4'b0000
//     jump & up = 4'b1001,jump & left = 4'b1010, jump & right = 4'b0011, jump & down = 4'b1100
module key2state(
    input wire clk,rst,
    input wire ps2c, ps2d,
    output wire[3:0] move_state,
    output wire done,
    output wire[7:0] out
);
    wire[7:0] data;
    wire[7:0] key;
    wire[4:0] state;
    assign out = data;
    ps2_keyboard ps2_driver(.ps2_clk(ps2c), .ps2_data(ps2d), .clk(clk),  .ready(done), .data(data), .rdn(1'b0), .clrn(1'b1));
    ps2_process get_ps2_state(.clk(clk), .rst(rst), .done(done), .data(data), .counter(state));
    key_proccessor key_to_state(.move_state(move_state), .key_state(state));
    
endmodule