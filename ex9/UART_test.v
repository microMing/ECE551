module UART_test(clk,RST_n,next_byte,LEDs);

input clk,RST_n;	// 50MHz clock & unsynched active low reset from push button
input next_byte;	// active low unsynched push button to send next byte over UART

output [7:0] LEDs;	// received byte of LEDs will be displayed over LEDs

reg [7:0] cnt;
//wire RX,send_next;


//// Instantiate reset synchronizer ////
wire rst_n;
reset_synch iRST(.clk(clk), .RST_n(RST_n), .rst_n(rst_n));

//// Make or instantiate a push button release detector /////
reg [2:0] release_detector;
always @(negedge clk, negedge rst_n)
 begin
   if(~rst_n)
       begin
          release_detector[0]<=1'b1;
          release_detector[1]<=1'b1;
          release_detector[2]<=1'b1;		  
	   end
	  else
	   begin
	      release_detector[0]<=next_byte;
		  release_detector[1]<=release_detector[0];
		  release_detector[2]<=release_detector[1];
	   end
 end
 wire falling_edge = release_detector[1] && (~release_detector[2]);
 
 wire TX;
 wire rx_rdy;//used to latch steady data
 wire [7:0] rx_data;//steady data 
 wire rx_rdy_clr;
//// Instantiate your UART_tx...data to transmit comes from 8-bit counter ////
UART_rcv rd_DUT(.clk(clk), .rst_n(rst_n), .RX(TX), .rx_rdy(rx_rdy), .rx_data(rx_data), .rx_rdy_clr(rx_rdy_clr));

//latch steady data;
reg [7:0] LEDs;
always@(posedge clk, negedge rst_n)
   begin
      if(~rst_n)
         LEDs <= 8'b0;
      else if(rx_rdy)
         LEDs <= rx_data;
   end

reg[1:0] rx_rdy_reg;
always@(posedge clk, negedge rst_n)
    begin
      if(~rst_n) begin
        rx_rdy_reg[0] <= 1'b0;
        rx_rdy_reg[1] <= 1'b0;
        end
      else begin
        rx_rdy_reg[0] <= rx_rdy; 
        rx_rdy_reg[1] <= rx_rdy_reg[0];
        end 
    end
assign rx_rdy_clr = rx_rdy_reg[0]&(!rx_rdy_reg[1]); //detect rising edge 

//// Instantiate your UART_rx...output byte should be connected to LEDs[7:0] ////
//// Instantiate UART Transmitter ////
wire [7:0] tx_data;
assign tx_data = cnt;
wire start_tx;
assign start_tx = falling_edge;
wire tx_done;//floating tx_done at this moment, current design can be controlled by pushing button

UART_tx iDUT(.clk(clk), .rst_n(rst_n), .TX(TX), .trmt(start_tx), .tx_data(tx_data), .tx_done(tx_done));

//// Make or instantiate an 8-bit counter to provide data to test with /////
always@(posedge clk, negedge rst_n)
   begin
     if(~rst_n)
	    begin
		  cnt <= 8'b0;
		end
		else if(falling_edge)
		  cnt <= cnt + 1'b1;
   end
	
endmodule
