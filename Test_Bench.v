`timescale 1ns/1ps

module test_bench();
parameter WIDTH = 8, START_BIT = 0, STOP_BIT = 1;
reg [WIDTH-1:0] TX_IN_P;
reg TX_IN_V, PAR_EN, PAR_TYP, TX_CLK, RST, RX_CLK;
reg [8:0] Prescale;
wire TX_OUT_S, TX_OUT_V;
wire [WIDTH-1:0] RX_OUT_P;
wire RX_OUT_V;
integer i = 0;
UART#(WIDTH,START_BIT,STOP_BIT) UART_BLOCK (TX_IN_P, TX_IN_V, PAR_EN, PAR_TYP, TX_CLK, RST, RX_CLK, Prescale, RX_OUT_V, RX_OUT_P, TX_OUT_S, TX_OUT_V);
initial begin
    TX_CLK = 0;
    forever begin
        #50 TX_CLK = ~TX_CLK;
    end
end
initial begin
    RX_CLK = 0;
    forever begin
        #12.5 RX_CLK = ~RX_CLK;
    end
end
initial begin
    RST = 0;
    TX_IN_P = 8'h54;
    PAR_EN = 1;
    PAR_TYP = 0;
    TX_IN_V = 0;
    Prescale = 348;
    @(negedge TX_CLK);
 
    RST = 1; // IDLE

    TX_IN_V = 1;

    @(negedge TX_CLK); // START
    
    TX_IN_V = 0;
    repeat(87)@(negedge TX_CLK);
   

    @(negedge TX_CLK); // DATA
  
    for(i=0;i<WIDTH;i=i+1)begin
    repeat(87)@(negedge TX_CLK);
   
    end
   
    @(negedge TX_CLK); // PARITY
   
    repeat(87)@(negedge TX_CLK);
   

    @(negedge TX_CLK); // STOP
   
    repeat(87)@(negedge TX_CLK);
    
    @(negedge TX_CLK);// CLEAR
    if(TX_IN_P!=RX_OUT_P)begin
        $display("Error");
        $stop;
    end

    @(negedge TX_CLK); // IDLE
   
    $stop;

end
endmodule