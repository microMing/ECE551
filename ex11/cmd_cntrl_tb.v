module cmd_cntrl_tb();

reg cmd_rdy, OK2Move, ID_vld, clk, rst_n;
reg [7:0] cmd, ID;

cmd_cntrl iDUT(.cmd(cmd),
 .cmd_rdy(cmd_rdy),
 .clr_cmd_rdy(clr_cmd_rdy),
 .in_transit(in_transit),
 .OK2Move(OK2Move),
 .go(go),
 .buzz(buzz),
 .buzz_n(buzz_n),
 .ID(ID),
 .ID_vld(ID_vld),
 .clr_ID_vld(clr_ID_vld),
 .clk(clk),
 .rst_n(rst_n));


initial begin
rst_n = 0;
clk = 0;
cmd_rdy = 0;
OK2Move = 0;
ID_vld = 0;
ID = 8'h00;
cmd = 8'h00;

#10
rst_n = 1;
#10
cmd_rdy = 1;
cmd = 8'b01110110;		//go, dest = 110110
#50
cmd_rdy = 1;
cmd = 8'b01100100;		//go, dest = 100100
#50
cmd = 8'b00100100;		//stop, dest = 100100

#50
cmd_rdy  = 0;
cmd = 8'b01110110;		//go, dest = 110110
#50
cmd_rdy = 1;
cmd = 8'b00110110;		//stop, dest = 110110

#50
cmd = 8'b01110110;		//go, dest = 110110
#50
cmd = 8'b11110110;		
ID_vld = 0;
#50
cmd_rdy = 0;
ID_vld = 1;
#50
cmd = 8'b11000000;		//dest = 000000
#50
ID = 8'b00110110;
#100


$stop;




end

always #1 clk = ~clk;

endmodule 