module key_proccessor(
    input wire[4:0] key_state,
    output wire[3:0] move_state
);

localparam[3:0] up =4'b0001, left = 4'b0010, right = 4'b0011, down = 4'b0100, jump = 4'b1000, stop = 4'b0000;
//reg[3:0] move_state_next;
assign move_state = key_state[0] ? {key_state[4], left[2:0]} :
   (key_state[1] ? {key_state[4], up[2:0]} :
   (key_state[2] ? {key_state[4], right[2:0]} : 
   (key_state[3] ? {key_state[4], down[2:0]} : {key_state[4], stop[2:0]})));
endmodule