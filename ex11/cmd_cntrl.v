//cmd cntrl
//for the ex11
//group project
//the following is rtl
module cmd_cntrl(cmd, cmd_rdy, clr_cmd_rdy, in_transit, OK2Move, go, buzz, buzz_n, ID, ID_vld, clr_ID_vld, clk, rst_n);

//input/output
input cmd_rdy, OK2Move, ID_vld, clk, rst_n;
input [7:0] cmd, ID;

output wire go, buzz, buzz_n;
output reg clr_cmd_rdy, in_transit, clr_ID_vld;
reg state, nxt_state;
reg [5:0] dest_ID;
//parameter
localparam IDLE = 1'b0;
localparam INTRANSIT = 1'b1;

//state
always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		state <= IDLE;
	else state <= nxt_state;
end

//combination assigment
always @(state, cmd_rdy, cmd, ID_vld, ID) begin
	nxt_state = IDLE;
	clr_cmd_rdy = 0;
	clr_ID_vld = 0;
	in_transit = 0;

	case(state)
		IDLE: 
			if(cmd_rdy&&cmd[7:6] == 2'b01) begin
				dest_ID = cmd[5:0];
				nxt_state = INTRANSIT;
				in_transit = 1;
			end

		      	else begin 
				dest_ID = 6'h00;
				nxt_state = IDLE;
			end
		INTRANSIT: 
			if(cmd_rdy&&cmd[7:6] == 2'b01) begin
				dest_ID = cmd[5:0];
				nxt_state = INTRANSIT;
				in_transit = 1;
			end

		     	else if(cmd_rdy&&cmd[7:6] == 2'b00) begin
				nxt_state = IDLE;
				clr_cmd_rdy = 1;
				in_transit = 0;
		      	end

		     	else if(ID_vld) begin
				clr_ID_vld = 1;

				if(ID == dest_ID) begin
					clr_cmd_rdy = 1;
					nxt_state = IDLE;
					in_transit = 0;
				end

				else begin
					in_transit = 1;
					nxt_state = INTRANSIT;
				end
			end

		       else begin 
				in_transit = 1;				
				nxt_state = INTRANSIT;
			end
		endcase
end

//
assign go = OK2Move & in_transit;
assign buzz = !OK2Move & in_transit;
assign buzz_n = ~buzz; 

endmodule
