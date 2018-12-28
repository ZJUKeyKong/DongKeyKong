module ps2_process(
    input wire clk,
    input wire rst,
    input wire done,
    input wire[7:0] data,
    output reg[4:0] counter
);
localparam[7:0] key_a = 8'h70, key_s = 8'hb1, key_d = 8'h88, key_bk = 8'h1f, key_sp = 8'h28,key_w = 8'h71;
reg del;
initial begin
    counter = 0;
    del = 1'b0;
end

always @(posedge done)
begin
    if(data == key_bk)
        del = 1'b1;
    else 
    begin 
        case(data)
            key_a:
                counter[0] = ~del;
            key_w:
                counter[1] = ~del;
            key_d:
                counter[2] = ~del;
            key_s:
                counter[3] = ~del;
            key_sp:
                counter[4] = ~del;
        endcase
        del = 1'b0;
    end  
end
endmodule