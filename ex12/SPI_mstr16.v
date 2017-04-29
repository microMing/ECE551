//Author: Liang Zhang
//Email: lzhang432@wisc.edu
//SPI master RTL design

module SPI_mstr16(clk, rst_n, wrt, cmd, done, rd_data, SCLK, SS_n, MOSI, MISO);
//clk, rest
input clk, rst_n;
//start a transaction
input wrt;  
//master shift data
input [15:0] cmd;
//master finish transaction
output done;
//read data from slave
output [15:0] rd_data;
//SPI interface 
output SCLK, SS_n, MOSI;
input MISO;

//declaration
wire SCLK;
reg [4:0] SCLK_counter;
reg [1:0] state;//idle->back_porch_start->transmitting->back_portch_end->idle
localparam idle = 2'b00;
localparam back_porch_start = 2'b01;
localparam transmitting = 2'b10;
localparam back_porch_end = 2'b11;
wire back_porch_time_out;
reg [2:0] back_porch_timer;
reg SS_n;
reg [15:0] MOSI_shifter;
reg [15:0] MISO_shifter;
wire load;
wire shift;
reg [1:0] shift_delay;
wire MOSI;
reg [3:0] shifter_counter;
reg done;
wire [15:0] rd_data;
//back_porch_timer
always@(posedge clk, negedge rst_n) begin
 if(~rst_n) begin
  back_porch_timer <= 3'b0;
 end
 else if((state == back_porch_start)||(state == back_porch_end))
  back_porch_timer <= back_porch_timer + 1'b1;
 else
  back_porch_timer <= 3'b0;
end 

assign back_porch_time_out = (back_porch_timer == 3'h7);

//back_porch
always@(posedge clk, negedge rst_n) begin
 if(~rst_n) begin
   SS_n <= 1'b1;
 end
 else if (state == back_porch_start) begin
  SS_n <= 1'b0;
 end
 else if ((state == back_porch_end)&&(back_porch_time_out))
  SS_n <= 1'b1;
end

//shift
always@(posedge clk, negedge rst_n) begin
 if(~rst_n) begin
  shifter_counter <= 4'h0;
 end
 else if(state == back_porch_start) begin
  shifter_counter <= 4'h0;
 end
 else if((state == transmitting)&&(SCLK_counter == 5'b11111)) begin
  shifter_counter <= shifter_counter + 1'b1;
 end
end

//SPI state
always@(posedge clk, negedge rst_n)begin
 if(~rst_n) begin
  state <= idle;
 end
 else if((wrt)&&(state == idle))
  state <= back_porch_start;
 else if((state == back_porch_start )&&(back_porch_time_out))
  state <= transmitting;
 else if ((state == transmitting)&&(shifter_counter == 4'hf)&&(SCLK))
  state <= back_porch_end;
 else if((state == back_porch_end)&&(back_porch_time_out))
  state <= idle;
end

//create SCLK
assign SCLK = SCLK_counter[4];

always@(posedge clk, negedge rst_n)begin
 if (~rst_n) begin
  	SCLK_counter <= 5'b11111;
  end
  else if((state == back_porch_start )&&(back_porch_time_out)) begin
        SCLK_counter <= 5'b0;
  end
  else if (state == transmitting) begin
  	SCLK_counter <= SCLK_counter + 1'b1;
  end
end

//MOSI and MISO
always@(posedge clk, negedge rst_n) begin
 if(~rst_n) begin
  MOSI_shifter <= 16'b0; 
 end
 else if(load) begin
  MOSI_shifter <= cmd;
 end
 else if(shift_delay[1]) //shifter left
  MOSI_shifter <= {MOSI_shifter[14:0], 1'b0};
end

assign MOSI = MOSI_shifter[15];

assign load = (state == back_porch_start);
assign shift = ((state == transmitting)&&(SCLK_counter == 5'b11111));

always@(posedge clk, negedge rst_n) begin
 if(~rst_n) begin
  shift_delay <= 2'b0;
 end
 else begin
  shift_delay[0] <= shift;
  shift_delay[1] <= shift_delay[0];  
 end
end

always@(posedge clk, negedge rst_n) begin
 if(~rst_n) begin
  MISO_shifter <= 16'b0;
 end
 else if ((state == transmitting)&&(SCLK_counter == 5'b01111)) begin
  MISO_shifter <= {MISO_shifter[14:0], MISO}; 
 end
end

//done and dataout
always@(posedge clk, negedge rst_n) begin
 if(~rst_n) begin
   done <= 1'b0;
 end
 else if(wrt) begin
   done<= 1'b0;
 end
 else if((state == back_porch_end)&&(back_porch_timer == 3'b100)) begin
   done <= 1'b1;
 end 
end

assign rd_data = MISO_shifter;

endmodule
