//module myps2(
//    input wire clk,rst,
//    input wire ps2c,ps2d,
//    output reg[7:0] data,
//    output reg ready
//);

//reg[3:0] counter;
//reg[2:0] ps2c_state;
//reg[7:0] ps2c_data;
//wire neg_ps2c;
//assign neg_ps2c = ~ps2c_state[2] & ps2c_state[1];
//initial begin
//    counter = 8'h00;
//    ps2c_state = 3'b000;
//end
//always @(posedge clk, posedge rst)
//begin
//    if(rst)
//        ps2c_state <= 3'b000;
//    if(clk)
//        ps2c_state <= {ps2c_state[1:0], ps2c};
//end

//always @(posedge clk, posedge rst)
//begin
//    if(rst)
//    begin
//        counter <= 4'h0;
//        ps2c_data <= 8'h00;
//        ready <= 1'b0;
//        data <= 8'hf0;
//    end
//    else if(neg_ps2c)
//        begin
//            case (counter)
//                4'hA:
//                begin
//                    ready <= 1'b1;
//                    counter <= 4'h0;
//                    data <= ps2c_data;
//                end
//                default:
//                begin
//                    ready <= 1'b0;
//                    ps2c_data <= {ps2c_data[6:0], ps2d};
//                    counter <= counter + 4'b1;
//                end
//            endcase
//        end
//end
//endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/24 21:30:59
// Design Name: 
// Module Name: ps2_keyboard
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ps2_keyboard (input clk, clrn, ps2_clk, ps2_data, rdn, 
            output [7:0] data, 
            output ready,
            output reg overflow // fifo overflow
            );
  reg [3:0] count;     // count ps2_data bits, internal signal, for test
  reg [9:0] buffer;     // ps2_data bits
  reg [7:0] fifo[7:0];   // data fifo
  reg [2:0] w_ptr, r_ptr;  // fifo write and read pointers
  reg [2:0] ps2_clk_sync;

  always @ (posedge clk) begin
    ps2_clk_sync <= {ps2_clk_sync[1:0],ps2_clk};
  end
  wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];
  always @ (posedge clk) begin
    if (clrn == 0) begin
        count <= 0;
        w_ptr <= 0;
        r_ptr <= 0;
        overflow <= 0;
    end else if (sampling) begin
        if (count == 4'd10) begin
            if ((buffer[0] == 0) &&   // start bit
               (ps2_data) &&     // stop bit
               (~buffer[9:1])) begin   // 
                   fifo[w_ptr] <= buffer[8:1];   // kbd scan code
                   w_ptr <= w_ptr + 3'b1;
                   overflow <= overflow |  (r_ptr == (w_ptr + 3'b1));
                          end  
                   count <= 0; // for next
            end else begin
                   buffer[count] <= ps2_data;   // store ps2_data
                   count <= count + 3'b1;   // count ps2_data bits
            end
        end
        if (!rdn && ready) begin
          r_ptr <= r_ptr + 3'b1;
          overflow <= 0;
        end
   end
assign ready = (w_ptr != r_ptr);
assign data = fifo[r_ptr];
endmodule 