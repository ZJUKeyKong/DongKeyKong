module myps2(
    input wire clk,rst,
    input wire ps2c,ps2d,
    output reg[7:0] data,
    output reg ready
);

reg[3:0] counter;
reg[2:0] ps2c_state;
reg[7:0] ps2c_data;
wire neg_ps2c;
assign neg_ps2c = ~ps2c_state[2] & ps2c_state[1];
initial begin
    counter = 8'h00;
    ps2c_state = 3'b000;
end
always @(posedge clk, posedge rst)
begin
    if(rst)
        ps2c_state <= 3'b000;
    if(clk)
        ps2c_state <= {ps2c_state[1:0], ps2c};
end

always @(posedge clk, posedge rst)
begin
    if(rst)
    begin
        counter <= 4'h0;
        ps2c_data <= 8'h00;
        ready <= 1'b0;
        data <= 8'hf0;
    end
    else if(neg_ps2c)
        begin
            case (counter)
                4'hA:
                begin
                    ready <= 1'b1;
                    counter <= 4'h0;
                    data <= ps2c_data;
                end
                default:
                begin
                    ready <= 1'b0;
                    ps2c_data <= {ps2c_data[6:0], ps2d};
                    counter <= counter + 4'b1;
                end
            endcase
        end
end
endmodule