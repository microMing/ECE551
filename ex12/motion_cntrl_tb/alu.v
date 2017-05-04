//ex4, line detector
//author: Liang Zhang
//email: lzhang432@wisc.edu
//Describe: alu for realising the arithmetic and logic operation

module alu(Accum, Pcomp, Icomp, Pterm, Iterm, Fwd, A2D_res, Error, Intgrl, 
src0sel, src1sel, multiply, sub, mult2, mult4, saturate, dst);
input [15:0] Accum;
input [15:0] Pcomp;
input [11:0] Icomp;
input [13:0] Pterm;
input [11:0] Iterm;
input [11:0] Fwd;
input [11:0] A2D_res;
input [11:0] Error;
input [11:0] Intgrl;
input [2:0] src0sel;
input [2:0] src1sel;
input multiply;
input sub;
input mult2;
input mult4;
input saturate;
output [15:0] dst;

wire [15:0] dst;

//local paramter define for the src0 and src1 selection
localparam Accum2Src1 = 3'b000;
localparam Iterm2Src1 = 3'b001;
localparam Err2Src1 = 3'b010;
localparam ErrDiv22Scr1 = 3'b011;
localparam Fwd2Src1 = 3'b100;

localparam A2D2Src0 = 3'b000;
localparam Intgrl2Scr0 = 3'b001;
localparam Icomp2Src0 = 3'b010;
localparam Pcomp2Src0 = 3'b011;
localparam Pterm2Src0 = 3'b100;

reg [15:0] pre_src0, pre_src1;
wire [15:0] mul2_pre_src0, mul4_pre_src0, scaled_pre_src0, inv_pre_src0; 
wire alu_cin;
wire [15:0] alu_src0, alu_src1;
wire [16:0] alu_adder_out;
wire [15:0] alu_adder_sat_out;
wire signed [14:0] multiply_src0, multiply_src1;
wire signed [29:0] multiply_result;
wire [15:0] multiply_result_sat;
//src0sel
always@(src0sel, A2D_res, Intgrl, Icomp, Pcomp, Pterm)begin
 pre_src0 = 16'b0;
 case(src0sel)
	A2D2Src0: 	pre_src0 = {4'b0000, A2D_res};
	Intgrl2Scr0: 	pre_src0 = {{4{Intgrl[11]}}, Intgrl};
	Icomp2Src0:	pre_src0 = {{4{Icomp[11]}}, Icomp};
	Pcomp2Src0:	pre_src0 = Pcomp;
	Pterm2Src0:	pre_src0 = {2'b00,Pterm};
 endcase
end

//src1sel
always@(src1sel, Accum, Iterm, Error, Fwd) begin
 pre_src1 = 16'b0;
 case(src1sel)
	Accum2Src1:	pre_src1 = Accum;
	Iterm2Src1:	pre_src1 = {4'b0000,Iterm};
	Err2Src1:	pre_src1 = {{4{Error[11]}},Error};
	ErrDiv22Scr1:	pre_src1 = {{8{Error[11]}}, Error[11:4]};
	Fwd2Src1:	pre_src1 = {4'b0000, Fwd};
 endcase
end

//multi2, 4, &inv
assign mul2_pre_src0 = {pre_src0[14:0],1'b0};
assign mul4_pre_src0 = {pre_src0[13:0],2'b0};
assign scaled_pre_src0 = mult2 ? mul2_pre_src0 :
			(mult4 ? mul4_pre_src0:
			pre_src0);
assign inv_pre_src0  = ~scaled_pre_src0;
assign alu_cin = sub? 1'b1:1'b0;
//alu_src0, alu_src1
assign alu_src0 = sub? inv_pre_src0 : scaled_pre_src0;
assign alu_src1 = pre_src1;

//adder
assign alu_adder_out = alu_src0+alu_src1+alu_cin;

//saturate of adder
//satuarte to 12 bit, 
assign alu_adder_sat_out =(!saturate)? {alu_adder_out[15],alu_adder_out[14:0]} : //spc does not define the overflow, for now just ignore
			  (((alu_adder_out[15]==1'b1)&&(alu_adder_out[14:11]!=4'b1111))? 16'hf800 : 
			  (((alu_adder_out[15]==1'b0)&&(alu_adder_out[14:11]!=4'b0000))? 16'h07ff: {alu_adder_out[15:0]})); 

//signed multiply
assign multiply_src0 = alu_src0[14:0];
assign multiply_src1 = alu_src1[14:0];
assign multiply_result = multiply_src0*multiply_src1;
//saturate of multiply
assign multiply_result_sat = ((multiply_result[29]==1'b1)&&(multiply_result[28:26]!=3'b111))? 16'hc000:
			     (((multiply_result[29]==1'b0)&&(multiply_result[28:26]!=3'b000))? 16'h3fff: multiply_result[27:12]);

//multiply select
assign dst = multiply ? multiply_result_sat : alu_adder_sat_out;

endmodule
