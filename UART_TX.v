module UART_TX(P_DATA,DATA_VALID,PAR_EN,PAR_TYP,CLK,RST,TX_OUT,Busy);
parameter WIDTH = 8, START_BIT = 0, STOP_BIT = 1, CLK_PER_BIT = 87;
localparam EVEN = 1, ODD = 0;
parameter IDLE = 0, START = 1, DATA = 2, PARITY = 3, STOP = 4, CLEAR = 5;
input [WIDTH-1:0] P_DATA;
input DATA_VALID, PAR_EN, PAR_TYP, CLK, RST;
output reg TX_OUT, Busy;
reg START_BIT_SENT, DATA_BITS_SENT, PARITY_BIT_SENT, STOP_BIT_SENT;
reg [WIDTH-1:0] EIGHT_BITS_DATA;
reg [2:0] cs, ns;
reg [6:0] counter;
reg [2:0] DATA_INDEX;
always @(*)begin
    case(cs)

    IDLE:
    if(DATA_VALID)
    ns = START;
    else
    ns = IDLE;

    START:
    if(START_BIT_SENT)
    ns = DATA;
    else
    ns = START;

    DATA:
    if(DATA_BITS_SENT)begin
    if(PAR_EN)
    ns = PARITY;
    else
    ns = STOP;
    end
    else
    ns = DATA;

    PARITY:
    if(PARITY_BIT_SENT)
    ns = STOP;
    else
    ns = PARITY;

    STOP:
    if(STOP_BIT_SENT)
    ns = CLEAR;
    else
    ns = STOP;

    CLEAR:
    ns = IDLE;

    endcase
end
always @(posedge CLK or negedge RST)begin
    if(~RST)
    cs<=IDLE;
    else
    cs<=ns;
end
always @(posedge CLK or negedge RST)begin
    if(~RST)begin
        TX_OUT <= 1;
        Busy <= 0;
    end
    else if(cs==IDLE)begin
        TX_OUT <= 1;
        Busy <= 0;
        counter <= 0;
        START_BIT_SENT <= 0;
        DATA_BITS_SENT <= 0;
        PARITY_BIT_SENT <= 0;
        STOP_BIT_SENT <= 0;
        DATA_INDEX <= 0;
    end
    else if(cs==START)begin
        if(~Busy)begin
        EIGHT_BITS_DATA <= P_DATA;
        TX_OUT <= START_BIT;
        end
        if(ns==DATA)begin
            counter <= 0;
        end
        else if(counter==(CLK_PER_BIT-1))begin
            counter <= 0;
            START_BIT_SENT <= 1;
            TX_OUT <= START_BIT;
        end
        else begin
        Busy <= 1;
        counter <= counter + 1;
        TX_OUT <= START_BIT;
        end
    end
    else if(cs==DATA)begin
        if(ns==PARITY || ns==STOP)begin
            counter <= 0;
        end
          else if(counter==(CLK_PER_BIT-1))begin
            counter <= 0;
            DATA_INDEX <= DATA_INDEX + 1;
            TX_OUT <= EIGHT_BITS_DATA[DATA_INDEX];
            if(DATA_INDEX==WIDTH-1)begin
            DATA_BITS_SENT <= 1;
        end
        end
        else begin
        counter <= counter + 1;
        TX_OUT <= EIGHT_BITS_DATA[DATA_INDEX];
        end
    end
    else if(cs==PARITY)begin
        if(PAR_TYP==EVEN)begin
            if(ns==STOP)begin
            counter <= 0;
        end
           else if(counter==(CLK_PER_BIT-1))begin
            counter <= 0;
            PARITY_BIT_SENT <= 1;
            TX_OUT <= (^EIGHT_BITS_DATA)? 1 : 0;
        end
        else begin
        counter <= counter + 1;
        TX_OUT <= (^EIGHT_BITS_DATA)? 1 : 0;
        end
        end
        else begin
             if(ns==STOP)begin
            counter <= 0;
        end
           else if(counter==(CLK_PER_BIT-1))begin
            counter <= 0;
            TX_OUT <= (^EIGHT_BITS_DATA)? 0 : 1;
            PARITY_BIT_SENT <= 1;
        end
        else begin
        counter <= counter + 1;
        TX_OUT <= (^EIGHT_BITS_DATA)? 0 : 1;
        end
        end
    end
    else if(cs==STOP)begin
         if(ns==CLEAR)begin
            counter <= 0;
            TX_OUT <= 1;
        end
        else if(counter==(CLK_PER_BIT-1))begin
            counter <= 0;
            STOP_BIT_SENT <= 1;
            TX_OUT <= STOP_BIT;
        end
        else begin
        counter <= counter + 1;
        TX_OUT <= STOP_BIT;
        end
    end
    else if(cs==CLEAR)begin
        Busy <= 0;
    end
end
endmodule
