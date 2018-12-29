//module ps2_process(
//    input wire clk,
//    input wire rst,
//    input wire done,
//    input wire[7:0] data,
//    output reg[4:0] counter
//);
//localparam[7:0] key_a = 8'h70, key_s = 8'hb1, key_d = 8'h88, key_bk = 8'h1f, key_sp = 8'h28,key_w = 8'h71;
//reg del;
//initial begin
//    counter = 0;
//    del = 1'b0;
//end

//always @(posedge done)
//begin
//    if(data == key_bk)
//        del = 1'b1;
//    else 
//    begin 
//        case(data)
//            key_a:
//                counter[0] = ~del;
//            key_w:
//                counter[1] = ~del;
//            key_d:
//                counter[2] = ~del;
//            key_s:
//                counter[3] = ~del;
//            key_sp:
//                counter[4] = ~del;
//        endcase
//        del = 1'b0;
//    end  
//end
//endmodule
module ps2_process(
    input wire clk,
    input wire rst,
    input wire done,
    input wire[7:0] data,
    output reg[4:0] counter
);
localparam[7:0] key_a = 8'h1c, key_s = 8'h1b, key_d = 8'h23, key_bk = 8'hF0, key_sp = 8'h29,key_w = 8'h1d;
reg state_next;
reg state;
reg[4:0] counter_temp;
initial begin
    counter = 0;
    counter_temp = 0;
    state = 1'b0;
    state_next = 1'b0;
end

always @(posedge clk)
begin
    state <= state_next;
    counter <= counter_temp;
end

always @(posedge done)
begin
    case (state)
        1'b0: 
        case(data)
            key_a:
                counter_temp[0] <= 1'b1;
            key_w:
                counter_temp[1] <= 1'b1;
            key_d:
                counter_temp[2] <= 1'b1;
            key_s:
                counter_temp[3] <= 1'b1;
            key_sp:
                counter_temp[4] <= 1'b1;
            key_bk:
                state_next <= 1'b1;
        endcase
        1'b1: 
        case(data)
            key_a:
            begin 
                state_next <= 1'b0;
                counter_temp[0] <= 1'b0;
            end 
            key_w:
            begin 
                state_next <= 1'b0;
                counter_temp[1] <= 1'b0;
            end 
            key_d:
            begin 
                state_next <= 1'b0;
                counter_temp[2] <= 1'b0;
            end 
            key_s:
            begin 
                state_next <= 1'b0;
                counter_temp[3] <= 1'b0;
            end 
            key_sp:
            begin 
                state_next <= 1'b0;
                counter_temp[4] <= 1'b0;
            end 
            key_bk:
                state_next <= 1'b1;
        endcase 
    endcase
end
endmodule