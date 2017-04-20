module A2D_test(clk,RST_n,nxt_chnnl,LEDs);

input clk,RST_n;		// 50MHz clock and active low unsynchronized reset from push button
input nxt_chnnl;		// unsynchronized push button.  Advances to convert next chnnl
output [7:0] LEDs;		// upper bits of conversion displayed on LEDs
wire a2d_SS_n;		// Active low slave select to A2D (part of SPI bus)
wire MOSI;			// Master Out Slave In to A2D (part of SPI bus)
wire MISO;				// Master In Slave Out from A2D (part of SPI bus)
wire SCLK;			// Serial clock of SPI bus

wire strt_cnv;      // Asserted for at least one clock cycle to start a conversion
wire [2:0] chnnl;   // Specifies which A2D channel (0..7) to convert
///////////////////////////////////////////////////
// Declare any registers or wires you need here //
/////////////////////////////////////////////////
wire [11:0] res;		// result of A2D conversion

reg q0, q1, q2; 
wire button_rise_edge;

/////////////////////////////////////
// Instantiate Reset synchronizer //
///////////////////////////////////
reset_synch iRST(.clk(clk), .RST_n(RST_n), .rst_n(rst_n));

////////////////////////////////
// Instantiate A2D Interface //
//////////////////////////////
A2D_intf iA2D(.clk(clk), .rst_n(rst_n), .strt_cnv(strt_cnv), .cnv_cmplt(cnv_cmplt), .chnnl(chnnl),
              .res(res), .a2d_SS_n(a2d_SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));


////////////////////////////////////////
// Synchronize nxt_chnnl push button //
//////////////////////////////////////
always@(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		q0 <= 0;
		q1 <= 0;
		q2 <= 0;
	end else begin
		q0 <= nxt_chnnl;
		q1 <= q0;
		q2 <= q1;
	end
end
 
///////////////////////////////////////////////////////////////////
// Implement method to increment channel and start a conversion //
// with every release of the nxt_chnnl push button.            //
////////////////////////////////////////////////////////////////
assign button_rise_edge = (!q2 && q1)? 1'b1 : 1'b0;

//////////////Instantiate DriveA2D/////////////////
DriveA2D iDriveA2D(.rst_n(rst_n),  .clk(clk), .button(button_rise_edge), .strt_cnv(strt_cnv), .chnnl(chnnl));




//////////////////////////////////////////////////////////
// Demo 1: ADC128S                                      //
//////////////////////////////////////////////////////////

ADC128S  ADC128S_0(.clk(clk), .rst_n(rst_n), .SS_n(a2d_SS_n), .SCLK(SCLK), .MISO(MISO), .MOSI(MOSI));


//////////////////////////////////////////////////////////////////////////
// Demo 2: ADC128S                                           			//
// Modify this file and .qsf to connect to the physical ADC. 			//
// - Remove the instantiation of ADC128S.                   			//
// - Add SPI ports to the top module and map them to pins in .qsf file. //
//////////////////////////////////////////////////////////////////////////

	
assign LEDs = res[11:4];

endmodule
    
