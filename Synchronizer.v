module Synchronizer(in,rst,clk,out);
parameter WIDTH = 1;
localparam SYNC = 1, ASYNC = 0;
parameter RSTTYPE = SYNC;
input [WIDTH-1:0] in;
input rst, clk;
output reg [WIDTH-1:0] out; 
reg [WIDTH-1:0]out_sync;
generate
    if(RSTTYPE==SYNC)begin 
        always @(posedge clk) begin
            if(~rst)begin
                out_sync<=0;
                out<=0;
            end
            else begin
                out_sync<=in;
                out<=out_sync;
            end
    end
    end
    else begin
        always @(posedge clk or negedge rst) begin 
            if(~rst)begin
                out_sync<=0;
                out<=0;
            end
            else begin
                out_sync<=in;
                out<=out_sync;
            end
    end
    end
endgenerate
endmodule