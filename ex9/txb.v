
module UART_rcv_tb();

wire rx_rdy;
wire[7:0] rx_data;
reg RX, rx_rdy_clr,clk, rst_n;

UART_rcv iDUT(

.rx_rdy(rx_rdy),
.rx_data(rx_data),
.RX(RX),
.rx_rdy_clr(rx_rdy_clr),
.clk(clk),
.rst_n(rst_n)


);

initial begin

rst_n = 0;
clk = 0;
RX = 1;
rx_rdy_clr = 0;

#100
rst_n = 1;

// testing 0 FF 1
RX = 0; 
#5208
RX = 1;
#5208
RX = 1;
#5208
RX = 1;
#5208
RX = 1;
#5208
RX = 1;
#5208
RX = 1;
#5208
RX = 1;
#5208
RX = 1;
#5208
RX = 1;
#10000	//IDLE
rx_rdy_clr = 1; // clear rx_rdy
#100
rx_rdy_clr = 0; 

// testing 0 48 1
RX = 0; 
#5208
RX = 0;
#5208
RX = 0;
#5208
RX = 0;
#5208
RX = 1;
#5208
RX = 0;
#5208
RX = 0;
#5208
RX = 1;
#5208
RX = 0;
#5208
RX = 1;
#10000	//IDLE

// testing 0 37 1
RX = 0; 
#5208
RX = 1;
#5208
RX = 1;
#5208
RX = 0;
#5208
RX = 0;
#5208
RX = 1;
#5208
RX = 1;
#5208
RX = 1;
#5208
RX = 0;
#5208
RX = 1;

#5208	//START

// testing 0 AB 1 
RX = 0; 
#5208
RX = 1;
#5208
RX = 1;
#5208
RX = 0;
#5208
RX = 1;
#5208
RX = 0;
#5208
RX = 1;
#5208
RX = 0;
#5208
RX = 1;
#5208
RX = 1;
#10000




$stop;
end



always #1 clk = ~clk;


endmodule

