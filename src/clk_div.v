`timescale 1ns / 1ps
/*
ClkDiv: To divide 
*/
module clkdiv(
    input wire clk,
    input wire rst,
    output wire [31:0] clk_div
    );
    reg [31:0] counter = 0;
    
    always @ (posedge clk) begin
        if(rst == 1'b1) begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
        end
    end
    
    assign clk_div = counter;
endmodule
