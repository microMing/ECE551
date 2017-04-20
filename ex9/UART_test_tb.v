//alu testbench
//test the function of alu
//crated by liang zhang
//email:lzhang432@wisc.edu

//`timescale 1ns/1us

module UART_test_tb();

reg clk;
reg RST_n;
reg next_byte;
wire [7:0] LEDs;

UART_test uart_test(.clk(clk), .RST_n(RST_n), .next_byte(next_byte), .LEDs(LEDs));

initial 
begin
clk = 1'b0;
RST_n=1'b1;
next_byte = 1'b1;
@(negedge clk) RST_n = 1'b0;
@(negedge clk) RST_n = 1'b1;
repeat (5) @(negedge clk) next_byte = 1'b0;
repeat (3) @(negedge clk) next_byte = 1'b1;


repeat (30000) @(negedge clk); 
repeat (3) @(negedge clk) next_byte = 1'b0; 
repeat (3) @(negedge clk) next_byte = 1'b1;

repeat (30000) @(negedge clk);
$stop;

end

always begin
#5 clk = ~clk;
end

endmodule
