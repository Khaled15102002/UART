module UART_RX(RX_IN,Prescale,PAR_EN,PAR_TYP,RST,CLK,DATA_VALID,P_DATA);
parameter WIDTH = 8, START_BIT = 0, STOP_BIT = 1;
parameter IDLE = 0, START = 1, DATA = 2, PARITY = 3, STOP = 4, CLEAR = 5;
localparam EVEN = 1, ODD = 0;
input RX_IN, PAR_EN, PAR_TYP, CLK, RST;
input [8:0] Prescale;
output reg DATA_VALID;
reg PAR_ERROR, STOP_ERROR, START_ERROR;
output reg [WIDTH-1:0] P_DATA;
reg START_BIT_CHECK, DATA_BITS_CHECK, PARITY_BIT_CHECK, STOP_BIT_CHECK, CHECK_DATA;
reg START_BIT_VALUE, PARITY_BIT_VALUE, STOP_BIT_VALUE;
reg [WIDTH-1:0] DATA_BITS_VALUE;
reg [8:0] counter;
reg [2:0] cs, ns, DATA_INDEX;
wire [8:0] half;
wire RX_DATA_SYNCH_OUT;
integer i;
Synchronizer#(1,0) RX_DATA_SYNCH (RX_IN,RST,CLK,RX_DATA_SYNCH_OUT);
assign half = (Prescale / 2);
always @(*)begin
    case(cs)

    IDLE:
    if(~RX_DATA_SYNCH_OUT)
    ns = START;
    else
    ns = IDLE;

    START:
    if(START_BIT_CHECK)
    ns = DATA;
    else
    ns = START;

    DATA:
    if(DATA_BITS_CHECK)begin
    if(PAR_EN)
    ns = PARITY;
    else
    ns = STOP;
    end
    else
    ns = DATA;

    PARITY:
    if(PARITY_BIT_CHECK)
    ns = STOP;
    else
    ns = PARITY;

    STOP:
    if(STOP_BIT_CHECK)
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
        DATA_VALID <= 0;
        PAR_ERROR <= 0;
        STOP_ERROR <= 0;
        P_DATA <= 0;
        START_ERROR <= 0;
    end
    else if(cs==IDLE)begin
        counter <= 0;
        DATA_INDEX <= 0;
        START_BIT_CHECK <= 0;
        DATA_BITS_CHECK <= 0;
        PARITY_BIT_CHECK <= 0;
        STOP_BIT_CHECK <= 0;
        DATA_VALID <= 0;
    end
    else if(cs==START)begin
        if(ns==DATA)begin
            counter <= 0;
        end
        else if(counter==half)begin
        START_BIT_VALUE <= RX_DATA_SYNCH_OUT;
        counter <= counter + 1;
        end
        else if(counter==Prescale-1)begin
            counter <= 0;
            if(START_BIT_VALUE==0)begin
                START_BIT_CHECK <= 1;
                START_ERROR <= 0;
            end
            else begin
                START_BIT_CHECK <= 0;
                START_ERROR <= 1;
            end
        end
        else
        counter<= counter + 1;
    end
    else if(cs==DATA)begin
        if(ns==PARITY || ns==STOP)begin
            counter <= 0;
        end
        else if(counter==half)begin
        DATA_BITS_VALUE[DATA_INDEX] <= RX_DATA_SYNCH_OUT;
        counter <= counter + 1;
        end
        else if(counter==Prescale-1)begin
            counter <= 0;
            DATA_INDEX <= DATA_INDEX + 1;
            if(DATA_INDEX==WIDTH-1)begin
            DATA_BITS_CHECK <= 1;
            if(PAR_TYP==EVEN)begin
                CHECK_DATA <= (^DATA_BITS_VALUE)? 1 : 0;
            end
            else begin
                CHECK_DATA <= (^DATA_BITS_VALUE)? 0 : 1;
            end
            end
        end
        else 
        counter<= counter + 1;
    end
    else if(cs==PARITY)begin
        if(ns==STOP)begin
            counter <= 0;
        end
        else if(counter==(half))begin
        PARITY_BIT_VALUE <= RX_DATA_SYNCH_OUT;
        counter <= counter + 1;
        end
        else if(counter==Prescale-1)begin
            counter <= 0;
            if(PARITY_BIT_VALUE==CHECK_DATA)begin
                PARITY_BIT_CHECK <= 1;
                PAR_ERROR <= 0;
            end
            else begin
                PARITY_BIT_CHECK <= 0;
                PAR_ERROR <= 1;
            end
        end
        else
        counter<= counter + 1;
    end
    else if(cs==STOP)begin
        if(ns==CLEAR)begin
            counter <= 0;
        end
        else if(counter==half)begin
        STOP_BIT_VALUE <= RX_DATA_SYNCH_OUT;
        counter <= counter + 1;
        end
        else if(counter==Prescale-1)begin
            counter <= 0;
            if(STOP_BIT_VALUE==1)begin
                STOP_BIT_CHECK <= 1;
                STOP_ERROR <= 0;
            end
            else begin
                STOP_BIT_CHECK <= 0;
                STOP_ERROR <= 1;
            end
        end
        else
        counter<= counter + 1;
    end
    else if (cs==CLEAR) begin
        P_DATA <= DATA_BITS_VALUE;
        DATA_VALID <= 1;
    end
end
endmodule