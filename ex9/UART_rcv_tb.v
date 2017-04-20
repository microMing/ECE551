module UART_rcv_tb2();

wire rx_rdy;
wire[7:0] rx_data;
reg RX, rx_rdy_clr,clk, rst_n;

integer i;
integer k;
integer faults;

reg[7:0] stim[0:27];
reg[7:0] resp[0:27];
reg[9:0] rx_stim[0:27];	//rx data

UART_rcv iDUT(
.rx_rdy(rx_rdy),
.rx_data(rx_data),
.RX(RX),
.rx_rdy_clr(rx_rdy_clr),
.clk(clk),
.rst_n(rst_n)

);

initial $readmemh("rx_stim.hex", stim);		//load stimulating data from hex file

initial begin
	faults =0;				//clear number of faults
	for (i =0; i <28; i = i+1) begin
		rx_stim[i][9] = 0;		//create rx_stim as input of RX
		rx_stim[i][8:1] = stim[i][7:0];
		rx_stim[i][0] = 1;

		resp[i][7] = stim[i][0];	//create resp as correct answers
		resp[i][6] = stim[i][1];
		resp[i][5] = stim[i][2];
		resp[i][4] = stim[i][3];
		resp[i][3] = stim[i][4];
		resp[i][2] = stim[i][5];
		resp[i][1] = stim[i][6];
		resp[i][0] = stim[i][7];

	end


rst_n = 0;					//reset and initalize
clk = 0;
RX = 1;
rx_rdy_clr = 0;					

#100
rst_n = 1;					
#100
	//////////Start Trasmitting RX//////////

	for (i =0; i <28; i = i+1) begin
		for(k = 9; k >= 0; k = k-1) begin
			 RX = rx_stim[i][k];
			 #5208;
		end
		#1000 
		
	/////////Check rx_data after transmitting one series of RX////////////

		if(rx_data - resp[i] !=0) begin
			$display("Test failed. Correct output is %h, your ouput is %h.", resp[i], rx_data);
			faults = faults +1;		//incrementing faults if rx_data not match with resp
		end

		#9900 	rx_rdy_clr = 1;			//clear rx_rdy
		#100 	rx_rdy_clr = 0; 
		
	end
rst_n = 0;

#10000
	

$display("Test failed: %d / 28.",faults);		//display number of faults
$stop;
end



always #1 clk = ~clk;			//toggle clock


endmodule



