//Author: Liang Zhang
//Email: lzhang432@wisc.edu
module uart_tx(clk, rst_n, tx, strt_tx, tx_data, tx_done);
//clk, rst_n;
input clk, rst_n;
//output
output tx;
//data in interface
input strt_tx;
input [7:0] tx_data;
output tx_done;

wire trmt = strt_tx;
//50Mhz clock, Baud rate: 19200. each data is 2604 clock cycles
//UART: Start (1'b0), data(LSB->MSB), stop(1'b1)

//10bit shifter (stop, tx_data, start), right shift
reg [9:0] shift_reg;
//baud_counter, 0-2603, rston rst_n, when a transmission starts, when 2603 reach
reg [11:0] baud_counter;
//index counter, 0-9, rest on rst_n, when a transmission starts, when 9 is reached
reg [3:0] index_counter;
//pre load
reg [7:0] pre_load_tx_data;

//state
reg state;
localparam idle = 1'b0;
localparam transmitting = 1'b1;
//declare
wire shift;
wire load;
wire tx;
reg tx_done;
reg start_reg;

assign load = start_reg&&shift;

//pre loader
always@(posedge clk, negedge rst_n)
begin
 if(~rst_n) begin
  pre_load_tx_data <= 8'h0;
  end
 else if(trmt) begin
  pre_load_tx_data <= tx_data;
  end
end

//shifter
always@(posedge clk, negedge rst_n)
begin
 if(~rst_n) begin
  shift_reg <= 10'h3ff;
  end
 else if(load) begin
  shift_reg <= {1'b1, pre_load_tx_data, 1'b0};
  end
 else if (shift) begin
  shift_reg <= {1'b1, shift_reg[9:1]};
  end
end

assign tx = shift_reg[0];

//baud_counter
always@(posedge clk, negedge rst_n) begin
 if(~rst_n) begin
  baud_counter <= 12'h000;
  end
 else if(shift) begin
  baud_counter <= 12'h000;
  end
 else begin
  baud_counter <= baud_counter+1'b1;
  end
end

//shift
assign shift = (baud_counter == 12'ha2b);

//start
always@(posedge clk, negedge rst_n) begin
 if(~rst_n) begin
   start_reg <= 1'b0;
  end
 else if ((state == idle)&&(trmt))
   start_reg <= 1'b1;
 else if(state == transmitting)
   start_reg <= 1'b0;
end


//index_counter
always@(posedge clk, negedge rst_n) begin
 if(~rst_n) begin
  index_counter <= 4'b0;
   end
 else if(start_reg  && shift) begin
  index_counter <= 4'b0;
  end
 else if( shift && (state == transmitting) ) begin
   index_counter <= index_counter + 1'b1; 
  end
end

//state
always@(posedge clk, negedge rst_n) begin
 if(~rst_n) begin
  state <= idle;
 end
 else if ((start_reg)&& shift) begin
  state <= transmitting;
 end
 else if ((index_counter == 4'h9) && shift) begin
  state <= idle;
 end
end

//output 
always@(posedge clk, negedge rst_n) begin
 if(~rst_n) begin
  tx_done <= 1'b0;
  end
 else if(trmt) begin
  tx_done<= 1'b0;
 end
 else if((index_counter == 4'h9)&&shift) begin
  tx_done <= 1'b1;
  end
 else begin
   tx_done <= 1'b0;
  end
 end



endmodule
