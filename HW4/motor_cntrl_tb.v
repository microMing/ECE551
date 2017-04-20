module motor_cntrl_tb();

reg [10:0] lft, rht;
reg clk, rst_n;
wire fwd_lft, rev_lft, fwd_rht, rev_rht;


motor_cntrl iDUT(.lft(lft), .rht(rht), .fwd_lft(fwd_lft), .rev_lft(rev_lft), .fwd_rht(fwd_rht), .rev_rht(rev_rht),
 .clk(clk), .rst_n(rst_n));


initial begin

lft = 11'h000;		
rht = 11'h000;
rst_n = 0;
clk = 0;
repeat(5) @(negedge clk);
rst_n = 1;
repeat(1023) @(negedge clk);		
lft = 11'h008;			//testing lft = 8
repeat(1023) @(negedge clk);	
lft = 11'h2A8;			//testing lft = 680
repeat(1023) @(negedge clk);		
lft = 11'h000;			//testing lft = 0
repeat(1023) @(negedge clk);	
lft = 11'h6A8;			//testing lft = -680
repeat(1023) @(negedge clk);	
rht = 11'h008;			//testing rht = 8
repeat(1023) @(negedge clk);	
rht = 11'h2A8;			//testing rht = 680
repeat(1023) @(negedge clk);	
rht = 11'h6A8;			//testing rht = -680
repeat(1023) @(negedge clk);	
repeat(5) @(negedge clk);
rst_n = 0;			//reset
rht = 11'h000;
lft = 11'h000;
repeat(1023) @(negedge clk);
lft = 11'h2A8;			//testing lft = 680
repeat(400) @(negedge clk);	//without driving output low
lft = 11'h008;
lft = 11'h2A8;			//testing lft = 680
repeat(1023) @(negedge clk);	

$stop;

end


always #1 clk = ~clk;

endmodule