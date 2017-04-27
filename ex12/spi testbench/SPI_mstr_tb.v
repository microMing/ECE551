//author Liang Zhang
//email lzhang432@wisc.edu

`timescale 1ns/1ps

module SPI_mstr_tb();

//clk, rest
reg clk, rst_n;
//start a transaction
reg wrt;  
//master shift data
reg [15:0] cmd;
//master finish transaction
wire done;
//read data from slave
wire [15:0] rd_data;
//SPI interface 
wire SCLK, SS_n, MOSI;
wire MISO;

SPI_mstr master_DUT(.clk(clk), .rst_n(rst_n), .wrt(wrt), .cmd(cmd), .done(done), .rd_data(rd_data), .SCLK(SCLK), .SS_n(SS_n), .MOSI(MOSI), .MISO(MISO));

wire rdy;

SPI_slave slave_DUT(.clk(clk),.rst_n(rst_n),.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI),.rdy(rdy));


initial begin
	//clk, reset
	clk = 1'b0;
	rst_n = 1'b1;
	cmd = 16'b0;
	wrt = 1'b0;
	@(negedge clk) rst_n = 1'b0;
	repeat(5) @(negedge clk) cmd = 16'b1101_1111_0000_1100;
 	@(negedge clk) rst_n = 1'b1;
	@(negedge clk) wrt = 1'b1;
        @(negedge clk) wrt = 1'b0;

	repeat(600) @(negedge clk);

	@(negedge clk) wrt = 1'b1;
        @(negedge clk) wrt = 1'b0;

	repeat(600) @(negedge clk);
	#10 $stop; 
end

always begin
#5	clk = ~clk;
end
 

endmodule
