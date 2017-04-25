////////////////////////////////////////////////////////
//2016-2017 Spring ECE551 
//This module is a testbench for motion_contrl
//The testbench tests the PWM enable signal, start_conv,
//and chnnl. It also tests whether the robot can stop
//correctly or not
//
//Edited by Yiming Liu on 04/24/2017
///////////////////////////////////////////////////////






module motion_cntrl_tb();
reg clk, rst_n;
reg go; // tell the robot to move
reg cnv_cmplt; // indicate A2D conversion is completed
reg[11:0] A2D_res; // unsigned 12-bit result from A2D

wire start_conv; // initiates a A2D conversion
wire IR_in_en; // PWM based enable to inner IR sensors
wire IR_mid_en; // PWM based enable to middle IR sensors
wire IR_out_en; // PWM based enable to outer IR sensors
wire[2:0] chnnl; // A2D channel number
wire[7:0] LEDs; // upper bits of error
wire[10:0] lft; // direction/speed of left motor
wire[10:0] rht; // direction/speed of right motor

/////////////////DUT instantiation////////////////////////
motion_cntrl iDUT(.clk(clk),.rst_n(rst_n),.go(go), .cnv_cmplt(cnv_cmplt), .A2D_res(A2D_res), .start_conv(start_conv),.IR_in_en(IR_in_en), .IR_mid_en(IR_mid_en), .IR_out_en(IR_out_en),
                    .chnnl(chnnl), .LEDs(LEDs), .lft(lft), .rht(rht));


initial clk = 1'b0;
always #2 clk = ~clk; // a clk cycle is 4

initial begin
rst_n = 1'b0;
go = 1'b0;
cnv_cmplt = 1'b0;
A2D_res = 12'b0;
#4 rst_n = 1'b1;      // make rst_n low for a clk cycle

///////////////read IR_in(chnnl 1, then chnnl 0)////////////////////
go = 1'b1;

	
#4 go = 1'b0;                      // assert go for a clk cycle
#4
if(IR_in_en == 1)
	$display("IR_in is enabled");
else 
    $display("IR_in failed to enable");
#564                               // The delay is to test PWM enable signal: Since the duty cycle is 0x8C, which is 140.
                                   // Since the clk period is 4, the time need to count to 140 is 560.//should be 0-0x8c, so 141 cycles
if(IR_in_en == 0)
	$display("IR_in PWM is correct");
else 
    $display("IR_in PWM is not correct");
	
#15820                             // wait for 4096 clk cycle to count to 4096 (timer is basically enabled when go is asserted. 
				   // 4096*4 - 560 = 15824
if(start_conv == 1'b1)
    $display("in_rht start successfully");
else 
    $display("in_rht fail to start");

if(chnnl == 3'b001)
    $display("chnnl 1 read correctly");
else 
    $display("supposed to read chnnl 1, but reading %b now", chnnl);

cnv_cmplt = 1'b1;
#4                                 // assert cnv_cmplt for a clk cycle, duummy read, so conv_cmplt last 2 clock cycles
A2D_res = 12'h001;
#4 cnv_cmplt = 1'b0;
#4 //one cycle for alu operation
#128                               // wait for 32 clk cycle to count to 32
if(start_conv == 1'b1)
    $display("in_lft start successfully");
else 
    $display("in_lft fail to start");
	
if(chnnl == 3'b000)
    $display("chnnl 0 read correctly");
else 
    $display("supposed to read chnnl 0, but reading %b now", chnnl);
	
cnv_cmplt = 1'b1;
#4                // assert cnv_cmplt for a clk cycle
A2D_res = 12'h002; 
#4 cnv_cmplt = 1'b0;               // assert cnv_cmplt for a clk cycle
///////////////read IR_mid(chnnl 4, then chnnl 2)////////////////////
#4

#16384                             // wait for 4096 clk cycle to count to 4096

if(start_conv == 1'b1)
    $display("mid_rht start successfully");
else 
    $display("mid_rht fail to start");
 
if(chnnl == 3'b100)
    $display("chnnl 4 read correctly");
else 
    $display("supposed to read chnnl 4, but reading %b now", chnnl);
	
cnv_cmplt = 1'b1;
#4                // assert cnv_cmplt for a clk cycle
A2D_res = 12'h003;
#4 cnv_cmplt = 1'b0;  
#4
#128                               // wait for 32 clk cycle to count to 32
if(start_conv == 1'b1)
    $display("mid_lft start successfully");
else 
    $display("mid_lft fail to start");

if(chnnl == 3'b010)
    $display("chnnl 2 read correctly");
else 
    $display("supposed to read chnnl 2, but reading %b now", chnnl);
	
cnv_cmplt = 1'b1;
#4                // assert cnv_cmplt for a clk cycle
A2D_res = 12'h004; 
#4 cnv_cmplt = 1'b0;  


///////////////read IR_out(chnnl 3, then chnnl 7)////////////////////
#4
#16384                             // wait for 4096 clk cycle to count to 4096

if(start_conv == 1'b1)
    $display("out_rht start successfully");
else 
    $display("out_rht fail to start");
 
if(chnnl == 3'b011)
    $display("chnnl 3 read correctly");
else 
    $display("supposed to read chnnl 3, but reading %b now", chnnl);
	
cnv_cmplt = 1'b1;
#4               // assert cnv_cmplt for a clk cycle
A2D_res = 12'h005;
#4 cnv_cmplt = 1'b0;
#4
#128                               // wait for 32 clk cycle to count to 32
if(start_conv == 1'b1)
    $display("out_lft start successfully");
else 
    $display("out_lft fail to start");
	
if(chnnl == 3'b111)
    $display("chnnl 7 read correctly");
else 
    $display("supposed to read chnnl 7, but reading %b now", chnnl);
	
cnv_cmplt = 1'b1;
#4                // assert cnv_cmplt for a clk cycle
A2D_res = 12'h006;
#4 cnv_cmplt = 1'b0;

#4
#28
#8                                 // wait for 2 extra clk cycle (no reason, just wait)

////////////////////test if robot can stop correctly ////////////////////////////////////////
//if(lft == 10'b0 && rht == 10'b0)
//    $display("robot stops successfully");
//else 
//    $display("Error: robot are supposed to stop since go is deasserted");
	
///////////////////test another iteration////////////////////////////////////////////////////
///////////////read IR_in(chnnl 1, then chnnl 0)////////////////////
go = 1'b1;
if(IR_in_en == 1)
	$display("IR_in is enabled");
else 
    $display("IR_in failed to enable");
	
#4 go = 1'b0;                      // assert go for a clk cycle
#568//#556                               // The delay is to test PWM enable signal: Since the duty cycle is 0x8C, which is 140.
                                   // Since the clk period is 4, the time need to count to 140 is 560.
if(IR_in_en == 0)
	$display("IR_in PWM is correct");
else 
    $display("IR_in PWM is not correct");
	
#15820 //#15824                             // wait for 4096 clk cycle to count to 4096 (timer is basically enabled when go is asserted. 																	    4096*4 - 560 = 15824)

if(start_conv == 1'b1)
    $display("in_rht start successfully");
else 
    $display("in_rht fail to start");

if(chnnl == 3'b001)
    $display("chnnl 1 read correctly");
else 
    $display("supposed to read chnnl 1, but reading %b now", chnnl);

cnv_cmplt = 1'b1;
#4                // assert cnv_cmplt for a clk cycle
A2D_res = 12'h001;
#4 cnv_cmplt = 1'b0;

#4

#128                               // wait for 32 clk cycle to count to 32
if(start_conv == 1'b1)
    $display("in_lft start successfully");
else 
    $display("in_lft fail to start");
	
if(chnnl == 3'b000)
    $display("chnnl 0 read correctly");
else 
    $display("supposed to read chnnl 0, but reading %b now", chnnl);
	
cnv_cmplt = 1'b1;
#4                // assert cnv_cmplt for a clk cycle
A2D_res = 12'h002; 
#4 cnv_cmplt = 1'b0;

$stop;
end
endmodule