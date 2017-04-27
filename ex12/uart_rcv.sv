//////////////////////////////////////////////////////
//2017 fall ECE551 Exercise7
//This is an 8-bit UART receiver module.
//
//
//
//////////////////////////////////////////////////////
module uart_rcv(rx_rdy, rx_data, clk, rst_n, clr_rx_rdy, RX);

////////input and output declration/////////////
output reg rx_rdy;
output reg [7:0] rx_data;
input clk, rst_n, clr_rx_rdy, RX;

// start: when falling edge of RX is detected, start synchronize receiver
// reading: start baud counting and bit counting
// shift: when half clock cycle has reached, start shifting  RX into rx_shft_reg
// detected: asserted when falling edge is detected
// baud_cnt_clr: clear baud counter when one clock cycle is reached
// q0, q1: wire of double floping
reg start, reading, shift, detected, rx_rdy_reg, baud_cnt_clr, q0, q1, q2;
reg[9:0] rx_shft_reg;
////////flip-flops in the logic/////////////////
reg unsigned [11:0] baud_cnt;
reg unsigned [3:0] bit_cnt;
typedef enum reg[1:0] {IDLE, RECEIVE, SHIFT} state_t;
state_t crnt_state, nxt_state;

//for the final demo
wire  rx_rdy_clr = clr_rx_rdy;
 
always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		crnt_state <= IDLE;
		
	else
		crnt_state <= nxt_state;
		
end

/////////////////rx_rdy output//////////////////
always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		rx_rdy <= 1'b0;
		
	else if(rx_rdy_clr | detected)
		rx_rdy <= 1'b0;
	else
		rx_rdy <= rx_rdy_reg;
end
/////////rx falling edge detector///////////////
always@(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		q0 <= 1'b1;
		q1 <= 1'b1;
		q2 <= 1'b1;
	end else begin
		q0 <= RX;
		q1 <= q0;
		q2 <= q1;
	end

end

assign detected = (crnt_state == IDLE || (crnt_state == SHIFT && bit_cnt == 4'd10))? (!q1 && q2): 1'b0;

/////////////////rx_data output//////////////////////////
always@(posedge clk, negedge rst_n) begin
	if(!rst_n) 
		rx_data <= 0;
	else if(rx_rdy_reg)
		rx_data <= rx_shft_reg[8:1];
	

end

/////////state machine in the UART_rx///////////
always @(*) begin
        start = 1'b1;
	reading = 1'b0;
	rx_rdy_reg = 1'b0;
	nxt_state = crnt_state;
	
	
    case (crnt_state)
      IDLE: begin
		if(detected)begin
			start = 1'b0;
			reading = 1'b1;
			nxt_state = RECEIVE;
		end else begin
			start = 1'b0;
			reading = 1'b0;
			nxt_state = IDLE;
		end
      end
      RECEIVE: begin
        if(shift) begin
			start = 1'b0;
			reading = 1'b1;
			nxt_state = SHIFT;
		end else begin
			start = 1'b0;
			reading = 1'b1;
			nxt_state = RECEIVE;
		end
        
      end
     
      SHIFT: begin
	 if(detected)begin
		start = 1'b1;
		reading = 1'b0;
		
		nxt_state = RECEIVE;
 	 end
         else if(bit_cnt == 4'd10)begin
			if(baud_cnt == 12'b0) begin
				
				start = 1'b1;
				reading = 1'b0;
				rx_rdy_reg = 1'b1;
				nxt_state = IDLE;
			end else begin
				start = 1'b0;
				reading = 1'b1;
				rx_rdy_reg = 1'b1;
				nxt_state = SHIFT;
			end
		
	end else begin
			start = 1'b0;
			reading = 1'b1;
			nxt_state = RECEIVE;
	end
		
      end
    endcase
  end
////////10-bit shift register///////////////////
always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		rx_shft_reg <= 10'b0;
	else if(start == 1'b1)
		rx_shft_reg <= 10'b0;
	else if(shift == 1'b1)
		rx_shft_reg <= {q2,rx_shft_reg[9:1]};
	else 
		rx_shft_reg <= rx_shft_reg;
end



///////baud counter////////////////////////////
always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
	baud_cnt <= 12'h000;
	else if(baud_cnt_clr == 1'b1 )
		baud_cnt <= 12'h000;
	else if( reading == 1'b1)
		baud_cnt <= baud_cnt + 1;
	else 
		baud_cnt <= baud_cnt;
end

///////shift or not/////////////////////////////
assign shift = (baud_cnt == 12'b010100010110)? 1'b1: 1'b0;

///////when to clear clock cycle/////////////////////
assign baud_cnt_clr = (baud_cnt == 12'b101000101100)? 1'b1:1'b0;



///////shift bit counter////////////////////////
always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		bit_cnt <= 0;
	else if(start == 1'b1 )
		bit_cnt <= 4'b0000;
	else if(shift == 1'b1)	
		bit_cnt <= bit_cnt + 1;
	else
		bit_cnt <= bit_cnt;

end

endmodule
