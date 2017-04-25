////////////////////////////////////////////////////////////////////////
//ECE 551 Spring 2017
//Date: 04/09/2017
//This module is a barcode decoder.
//When the follower runs over a station ID (barcode) this signal will
//toggle in a pattern that follows the encoded station ID. This signal
//(BC) goes into a unit (barcode.sv) that will produce ID[7:0] and
//a signal called ID_vld from this signal. There is also an input to this
//module (clr_ID_vld) used to knock down the ID_vld output.
//
//Only the lower 6-bits of the ID are used as unique station ID
//identifiers. The upper 2-bits are used as an integrity check and must
//be 2’b00 for the ID to be considered valid.
//
//
//Edited by: Yiming Liu
//

module barcode(ID_vld, ID, BC, clr_ID_vld, clk, rst_n);

input BC, clr_ID_vld, clk, rst_n;      // BC: Signal from barcode IR sensor. Serial stream (8-bits in length) that has timing information encoded
                                       // clr_ID_vld: Asserted by the digital core to knock down ID_vld. Digital core would assert after having grabbed the ID from this unit.
output reg[7:0] ID;            // The 8-bit ID assembled by the unit, presented to the digital core.

output reg ID_vld;             // Asserted by barcode.sv when a full 8-bit station ID has
                           // been read, and the upper 2-bits are 2’b00. If upper 2’bits
                           // are not 2’b00 the barcode is assumed invalid.
reg[21:0] timing_cnt, BC_cnt;
reg[3:0] bit_cnt;          // tracking bit number that has been shifted in
reg q0, q1,q2, timing, BC_timing;
wire fall_detected, shift;

typedef enum reg[1:0] {IDLE, TIMING, SAMPLING, SHIFT} state_t;
state_t crnt_state, nxt_state;

always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		crnt_state <= IDLE;
		
	else
		crnt_state <= nxt_state;
		
end
////////////falling edge detector for BC//////////////
always@(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		q0 <= 1'b1;
		q1 <= 1'b1;
		q2 <= 1'b1;
	end
	else begin
		q0 <= BC;
		q1 <= q0;
		q2 <= q1;
	end
end
assign fall_detected = (!q1 && q2)? 1'b1: 1'b0;

////////////rising edge detector for BC//////////////
//always@(posedge clk, negedge rst_n) begin
//	if(!rst_n) begin
//		Q0 <= 0;
//		Q1 <= 0;
//	end
//	else begin
//		Q0 <= BC;
//		Q1 <= Q0;
//	end
//end
//assign rise_detected = (Q0 && !Q1)? 1'b1: 1'b0;
//////////////timing counter//////////////////////////
always@(posedge clk, negedge rst_n) begin	
	if(!rst_n) 
		timing_cnt <= 22'b0;
        else if(crnt_state == IDLE)
                timing_cnt <= 1'b0;
	else if(timing)
		timing_cnt <= timing_cnt + 1'b1;

end

////////////bit counter//////////////////////////////
always@(posedge clk, negedge rst_n) begin	
	if(!rst_n) 
		bit_cnt <= 4'b0;
	else if(shift)
		bit_cnt <= bit_cnt + 1'b1;
	else if((ID_vld)|(crnt_state == IDLE))
		bit_cnt <= 4'b0;
end

////////////BC counter///////////////////////////////
wire shift_check;
reg shift_clr;
always@(posedge clk, negedge rst_n) begin	
	if(!rst_n) 
		BC_cnt <= 22'b0;
	else if(shift_check)
		BC_cnt <= 22'b0;
	//else if(BC_timing)
        else if(crnt_state == SAMPLING)
    		BC_cnt <= BC_cnt + 1'b1;
	
end


always@(posedge clk, negedge rst_n)
  if(~rst_n)
    shift_clr <= 1'b0;
  else if(crnt_state == IDLE)
    shift_clr <= 1'b0;
  else if(shift_check)
    shift_clr <= ~shift_clr;

///////////shifting//////////////////////////////////

assign shift_check = ((crnt_state != IDLE)&(crnt_state != TIMING)&(BC_cnt == timing_cnt))? 1'b1: 1'b0;
assign shift = shift_check&(!shift_clr);



//////////ID counter/////////////////////////////////
always@(posedge clk, negedge rst_n) begin	
	if(!rst_n) 
		ID <= 8'b0;
	else if(shift)
		ID <= {ID[6:0], q1};
end

/////////////////////////FSM//////////////////////////
always @(*) begin
    timing = 1'b0;   
	BC_timing = 1'b0;
	nxt_state = IDLE;
	
    case (crnt_state)                     //IDLE: wait for start bit
      IDLE: begin
		if(fall_detected)begin
			timing = 1'b0;
			BC_timing = 1'b0;
			nxt_state = TIMING;
		end else
			nxt_state = IDLE;
      end
      TIMING: begin                      //TIMING: get the time encoding from start bit
        
		if(fall_detected) begin
		    timing = 1'b0;
			BC_timing = 1'b1;
			nxt_state = SAMPLING;
			
		end else if(q1) begin
			timing = 1'b0;
			BC_timing = 1'b0;
			nxt_state = TIMING;
		end else begin
			timing = 1'b1;
			BC_timing = 1'b0;
			nxt_state = TIMING;
		end
        
      end
      SAMPLING: begin                   //SAMPLING: shift one bit of ID when shift is asserted
		  if(shift) begin
			timing = 1'b0;
			BC_timing = 1'b0;
			nxt_state = SHIFT;
		  
		  end else if(fall_detected) begin
			timing = 1'b0;
			BC_timing = 1'b1;
			nxt_state = SAMPLING;
		  
		  end else begin
			timing = 1'b0;
			BC_timing = 1'b0;
			nxt_state = SAMPLING;
		  end
		  
	  end
      SHIFT: begin                     //SHIFT: check whether 8-bit ID has been collected
         if(bit_cnt == 4'd8)begin
			timing = 1'b0;
			BC_timing = 1'b0;
			nxt_state = IDLE;
		
		end else begin
			timing = 1'b0;
			BC_timing = 1'b0;
			nxt_state = SAMPLING;
		end
		
      end
    endcase
  end
 
///////////////ID_vld////////////////////////
always@(posedge clk, negedge rst_n) begin
	if(!rst_n) 
		ID_vld <= 1'b0;
	else if(ID[7:6] != 0)
		ID_vld <= 1'b0;
	else if(clr_ID_vld)
		ID_vld <= 1'b0;
	else if(bit_cnt == 4'h8)
		ID_vld <= 1'b1;
end


















endmodule