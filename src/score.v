module score(
    input wire clk,
    input wire rst,
    input wire[9:0] mario_posx, barrel_posx,
    input wire[8:0] mario_posy, barrel_posy,
    input wire barrel_fall,
    input wire mario_jumping,
    output reg[10:0] count
);
    localparam[1:0] same_floor_no_intersection = 2'b01,
        different_floor = 2'b00, same_floor_with_intersection = 2'b10, goal = 2'b11;
    localparam[9:0] mario_width = 34, barrel_fall_width = 42, barrel_roll_width = 32;
    localparam[8:0] mario_height = 36, barrel_height = 24, jump_height = 60;

    wire same_floor;
    wire intersection;
    wire[9:0] barrel_posx1,barrel_posx2,mario_posx1,mario_posx2;
    wire[8:0] barrel_bottom, mario_bottom;
    reg[10:0] count_next;
    reg[1:0] state, state_next;

    initial begin
        count_next <= 0;
        count <= 0;
        state <= 0;
        state_next <= 0;  
    end

    assign barrel_posx1 = barrel_posx;
    assign barrel_posx2 = barrel_posx + (barrel_fall ? barrel_fall_width : barrel_roll_width);
    assign mario_posx1 = mario_posx;
    assign mario_posx2 = mario_posx + mario_width;
    assign barrel_bottom = barrel_posy + barrel_height;
    assign mario_bottom = mario_posy + mario_height;
    assign same_floor = mario_bottom <= barrel_bottom + 4 & mario_bottom >= barrel_bottom - jump_height;
    assign intersection = (mario_posx2 > barrel_posx1 & barrel_posx2 > mario_posx1)
    | (mario_posx2 < barrel_posx1 & barrel_posx2 < mario_posx1);

    always @(posedge clk, posedge rst)
    begin
        if(rst)
        begin
            count <= 0;
            count_next <= 0;
            state <= 0;
            state_next <= 0;
        end
        else begin
            count <= count_next;
            state <= state_next;
        end
    end

    always @*
    begin
        case (state)
          different_floor:
            if(same_floor) 
                state_next <= intersection ? same_floor_with_intersection : same_floor_no_intersection;
            else
                state_next <= different_floor;
          same_floor_no_intersection:
            if(same_floor)
                state_next <= intersection ? same_floor_with_intersection : same_floor_no_intersection;
            else
                state_next <= different_floor;
          same_floor_with_intersection:  
            if(same_floor)
                state_next <=  intersection ? same_floor_with_intersection :
                 (mario_jumping ? goal : same_floor_no_intersection);
            else
                state_next <= different_floor;
          goal: 
            begin
                count_next <= count + 1;
                state_next <= same_floor_no_intersection;
            end
        endcase
    end
endmodule