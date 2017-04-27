//cmd cntrl
//for the ex11
//group project
//the following is rtl
module cmd_cntrl(cmd, cmd_rdy, clr_cmd_rdy, in_transit, OK2Move, go, buzz, buzz_n, ID, ID_vld, clr_ID_vld, clk, rst_n);

//input/output
input cmd_rdy, OK2Move, ID_vld, clk, rst_n;
input [7:0] cmd, ID;

output wire go;
output reg buzz;
output wire buzz_n;
output reg clr_cmd_rdy, in_transit, clr_ID_vld;
reg state, nxt_state;
reg [5:0] dest_ID;
//parameter
localparam IDLE = 1'b0;
localparam INTRANSIT = 1'b1;

wire buzz_en;
reg set_in_transit, clr_in_transit, set_dest_ID;

//state
always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		state <= IDLE;
	else state <= nxt_state;
end

always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		in_transit <= 1'b0;
	else if(set_in_transit)
        in_transit <= 1'b1;
    else if(clr_in_transit)
	    in_transit <= 1'b0;
end
//combination assigment
always @(state, cmd_rdy, cmd, ID_vld, ID) begin
	nxt_state = IDLE;
	//clr_cmd_rdy = 1'b0;
	//clr_ID_vld = 1'b0;
	set_in_transit = 1'b0;
	clr_in_transit = 1'b0;
	set_dest_ID = 1'b0;

	case(state)
		IDLE: 
			if(cmd_rdy&&cmd[7:6] == 2'b01) begin
				set_dest_ID = 1'b1;//cmd[5:0];
				nxt_state = INTRANSIT;
				set_in_transit = 1'b1;
			end

		      	else begin 
				//dest_ID = 6'h00;
				nxt_state = IDLE;
			end
		INTRANSIT: 
			if(cmd_rdy&&cmd[7:6] == 2'b01) begin
				//dest_ID = cmd[5:0];
				nxt_state = INTRANSIT;
				set_dest_ID = 1'b1;     // updated by Yiming on 04/27 3:50pm
				//in_transit = 1;
			end

		     	else if(cmd_rdy&&cmd[7:6] == 2'b00) begin
				nxt_state = IDLE;
				//clr_cmd_rdy = 1'b1;
				clr_in_transit = 1'b1;
		      	end

		     	else if(ID_vld) begin
				//clr_ID_vld = 1;

				if(ID == dest_ID) begin
					//clr_cmd_rdy = 1'b1;
					nxt_state = IDLE;
					clr_in_transit = 1'b1;
				end

				else begin
					//in_transit = 1;
					nxt_state = INTRANSIT;
				end
			end

		       else begin 
				//in_transit = 1;				
				nxt_state = INTRANSIT;
			end
		endcase
end

always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		dest_ID <= 6'b0;
	else if(set_dest_ID)
        dest_ID <= cmd[5:0];
end

always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		clr_cmd_rdy <= 1'b0;
	else 
        clr_cmd_rdy <= cmd_rdy;
end

always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		clr_ID_vld <= 1'b0;
	else 
        clr_ID_vld <= ID_vld;
end

//
assign go = OK2Move & in_transit;
assign buzz_en = !OK2Move & in_transit;
assign buzz_n = buzz_en? ~buzz : buzz; 

reg [13:0] buzz_cnt;

//DE0 provides 50Mhz clock, here we need 4kHz, that means 50_000/4 = 12_500
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		buzz <= 1'b0;
		buzz_cnt <= 14'h0;
	    end
	else begin
       if(buzz_en)
	     buzz_cnt <= buzz_cnt+1'b1;
	    if(buzz_cnt >= 14'd6250) // not sure whether it should be 6249 or 6250 (unpdated by Yiming on 04/27/2017)
          buzz<= 1'b1;
         else   
          buzz<= 1'b0;
          if (buzz_cnt == 14'd12499)
            buzz_cnt<= 14'h0;		  
       end
end

endmodule
