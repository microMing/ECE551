module UART_rcv(clk, rst_n, RX, rx_rdy, rx_data, rx_rdy_clr);

input clk, rst_n, RX, rx_rdy_clr;
output reg rx_rdy;
output reg [7:0] rx_data;
wire shift, baudcycle;
reg state, nxt_state, transmitting;
reg [11:0] baud_cnt;
reg [3:0] bit_cnt;
reg start;
localparam IDLE = 1'b0;
localparam TRANSMITTING = 1'b1;


always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin			//active low reset
		state = IDLE;
	end
	else begin
		state<=nxt_state;
	end
end
always @(posedge clk, negedge rst_n) 
  if (!rst_n) // start with reset case, not normal case 
    rx_data <= 8'h00; // reset rx_data to zero
  else if (shift & bit_cnt < 4'd9) begin
    rx_data <= {RX, rx_data[7:1]}; // put RX to MSB 
     end
  else rx_data = rx_data;


always @(posedge clk, negedge rst_n) begin
  if (!rst_n) // start with reset case, not normal case 
    baud_cnt <= 12'h000; // reset to 0 on reset 
  else if (start || baudcycle) begin
    baud_cnt <= 12'h000; // reset when start or baud count indicates 19200 baud 

    end
  else if (transmitting) 
    baud_cnt <= baud_cnt+1; // only burn power incrementing if tranmitting
  else baud_cnt = baud_cnt;
end

always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin// start with reset case, not normal case 
  		 start = 0; // reset to 0 on reset 
		 rx_rdy = 1;
	end

	else if(!transmitting) begin
		if(RX == 0) start = 1;
	end
	else start = 0;
	
	if(rx_rdy_clr == 1) rx_rdy = 0;
	end

assign shift = (baud_cnt == 12'h515); // assert shift when baud_cnt reaches 1302 (small cloud in the middle of the diagram)
assign baudcycle = (baud_cnt == 12'hA2B); // // assert new baud cycle when baud_cnt reaches 2604

always @(posedge clk, negedge rst_n)
	 if (!rst_n) // start with reset case, not normal case 
   		 bit_cnt <= 4'h0; // reset to 0 on reset 
 	 else if (start) 
	    	 bit_cnt <= 4'h0; // reset when baud count indicates 19200 baud 
 	 else if (baudcycle) 
  		  bit_cnt <= bit_cnt+1; // only burn power incrementing if tranmitting

always@(posedge clk, state) begin
	nxt_state = 0;
	case(state)
	IDLE: if(start) begin // IDLE state, change when start bit appear
		nxt_state = TRANSMITTING;
		rx_rdy = 0;
		end
	       else begin
		nxt_state = IDLE; // In IDLE state, not start
		transmitting = 0;
		end
	TRANSMITTING: if (bit_cnt!=4'd10) begin // TRANSMITTING state, if ten bit of input not fully loaded
			nxt_state = TRANSMITTING;
			transmitting = 1;	// start transmitting
			rx_rdy = 0;	//set rx_rdy to 0
			end
		else if (bit_cnt == 4'd10) begin // TRANSMITTING state, if ten bit of input all loaded
			transmitting = 0; //stop transmitting
			nxt_state = IDLE; // back to IDLE state
			rx_rdy = 1;	// set rx_rdy to one
			end
	endcase
end

endmodule
	

