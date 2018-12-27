`timescale 1ns / 1ps

module Seg7_driver(
    input wire clk,
    input wire seg_clk,
    input wire [31:0] data,
    output wire SEG_CLK,
    output wire SEG_SOUT,
    output wire SEG_PEN,
    output wire SEG_CLRN
    );
    
    SSeg7_Dev m4(.clk(clk), .rst(1'b0), .Start(seg_clk),
                 .SW0(1'b0), .flash(1'b0), .Hexs(data), .point(8'h00), .LES(8'h00), 
                 .seg_clk(SEG_CLK), .seg_sout(SEG_SOUT), .SEG_PEN(SEG_PEN), .seg_clrn(SEG_CLRN));

endmodule
