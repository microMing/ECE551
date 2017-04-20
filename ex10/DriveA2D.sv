//this module created by lzhang432@wisc.edu
//push on button and the chnnel add 1
module DriveA2D(rst_n,  clk, button, strt_cnv, chnnl);
input rst_n;
input clk;
input button;//on clock cycle
output strt_cnv;
output [2:0] chnnl;//output channle

reg [2:0] chnnl;

always@(posedge clk, negedge rst_n)
  if(~rst_n)
     chnnl<=3'b0;
   else if(button)
     chnnl<= chnnl + 1'b1;

wire strt_cnv = button;

endmodule 
