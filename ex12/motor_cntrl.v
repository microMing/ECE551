//motor controller, modified based on pwm generator
//author: liang zhang
//email: lzhang432@wisc.edu

module motor_cntrl(clk, rst_n, lft, rht, fwd_lft, rev_lft, fwd_rht, rev_rht);
//input/output declear
input clk, rst_n;
input [10:0] lft, rht;
output fwd_lft, rev_lft;
output fwd_rht, rev_rht;  

//to avoid glitch, must reg output
reg fwd_lft, rev_lft, fwd_rht, rev_rht;

reg [10:0] left, right;


//reg declear
reg [9:0] cnt;
//must latch the lft, rht to avoid problem
always@(posedge clk, negedge rst_n)
  begin
    if(~rst_n) begin
      left<= 11'b0;
      right<= 11'b0;
     end
    else if(cnt == 10'b11_1111_1110) begin
      left<= lft;
      right<=rht;
     end
  end
//get magnitude and pos/neg
wire [9:0] duty_left, duty_right;
wire pos_left, pos_right;
wire all_zero_left, all_zero_right;
assign duty_left = pos_left ? left[9:0] : 
                   (left[10:0]== 11'b100_0000_0000) ? 10'b11_1111_1111 : (~left[9:0] + 1'b1);
assign duty_right = pos_right? right[9:0]:
                  (right[10:0] == 11'b100_0000_0000) ? 10'b11_1111_1111 : (~right[9:0] + 1'b1);
assign pos_left = (left[10] == 1'b0);
assign pos_right = (right[10] == 1'b0);
assign all_zero_left = (left == 11'b0);
assign all_zero_right = (right == 11'b0);



//free running counter
always@(posedge clk, negedge rst_n)
  if(~rst_n)
	cnt<=10'b0;
  else 
	cnt<=cnt+1'b1;

//output must be reg output
//reg fwd_lft, rev_lft, fwd_rht, rev_rht;
always@(posedge clk, negedge rst_n)
  if(~rst_n)
	fwd_lft <= 1'b1;
  else if (all_zero_left)
    fwd_lft <= 1'b1;
  else if (!pos_left)
    fwd_lft <= 1'b0;
  else if(cnt == 10'b11_1111_1111)
	fwd_lft <= 1'b1;
  else if (cnt == (duty_left))
        fwd_lft <= 1'b0;
  else
        fwd_lft <= fwd_lft;


always@(posedge clk, negedge rst_n)
  if(~rst_n)
	rev_lft <= 1'b1;
  else if(all_zero_left)
    rev_lft <= 1'b1;
  else if(pos_left)
    rev_lft <= 1'b0;
  else if(cnt == 10'b11_1111_1111)
	rev_lft <= 1'b1;
  else if (cnt == (duty_left))
        rev_lft <= 1'b0;
  else
        rev_lft <= rev_lft;

always@(posedge clk, negedge rst_n)
  if(~rst_n)
	fwd_rht <= 1'b1;
  else if(all_zero_right)
    fwd_rht <= 1'b1;
  else if(!pos_right)
    fwd_rht <= 1'b0;
  else if(cnt == 10'b11_1111_1111)
	fwd_rht <= 1'b1;
  else if (cnt == (duty_right))
        fwd_rht <= 1'b0;
  else
        fwd_rht <= fwd_rht;

always@(posedge clk, negedge rst_n)
  if(~rst_n)
	rev_rht <= 1'b1;
  else if(all_zero_right)
    rev_rht <= 1'b1;
  else if(pos_right)
    rev_rht <= 1'b0;
  else if(cnt == 10'b11_1111_1111)
	rev_rht <= 1'b1;
  else if (cnt == (duty_right))
        rev_rht <= 1'b0;
  else
        rev_rht <= rev_rht;

endmodule 

