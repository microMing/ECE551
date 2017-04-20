//barcode testbench
//test the function of barcode
//crated by liang zhang
//email:lzhang432@wisc.edu


module barcode_tb();

reg clk;
reg RST_n;
wire BC;

wire [7:0] ID;
wire ID_vld;
reg clr_ID_vld;

reg [21:0] tb_period;
reg tb_rst_n;
reg tb_send;
reg [7:0] tb_ID;
wire tb_bc_done;
//connection
barcode barcode(.clk(clk), .rst_n(RST_n), .BC(BC), .ID(ID), .ID_vld(ID_vld), .clr_ID_vld(clr_ID_vld));
barcode_mimic barcode_mimic(.clk(clk), .rst_n(tb_rst_n), .period(tb_period), .send(tb_send), .station_ID(tb_ID), .BC(BC), .BC_done(tb_bc_done));

reg [5:0] tb_ID_6bit;
integer error;

initial begin
clk = 1'b0;
RST_n=1'b1;
tb_rst_n=1'b1;
clr_ID_vld = 1'b0;
tb_period = 22'd0;
tb_send = 1'b0;
tb_ID = 8'd0;
tb_ID_6bit = 5'b0;
error = 0;
@(negedge clk) RST_n = 1'b0; tb_rst_n = 1'b0;
@(negedge clk) RST_n = 1'b1; tb_rst_n = 1'b1;
///////////
//test min period 512, randome ID
@(negedge clk) tb_rst_n = 1'b0;
@(negedge clk) tb_rst_n = 1'b1;
repeat (5) @(negedge clk) tb_period = 22'd512;
                          tb_ID_6bit = $random;
                          tb_ID = {2'b0, tb_ID_6bit};
@(negedge clk) tb_send = 1'b0;
@(negedge clk) tb_send = 1'b1;
@(negedge clk) tb_send = 1'b0;
@(posedge tb_bc_done) 
@(negedge clk)

 if(((ID_vld == 1'b1)&(tb_ID[7:6] == 2'b0)&(tb_ID == ID))||(ID_vld == 1'b0)&(tb_ID[7:6] != 2'b0))
    $display("pass");
 else begin
    $display("error");
    error = error +1;
    end

repeat (3) @(negedge clk) clr_ID_vld = 1'b1;
@(negedge clk) clr_ID_vld = 1'b0;
//$stop;
//////////////////
///////////
//test max period , randome ID
@(negedge clk) tb_rst_n = 1'b0;
@(negedge clk) tb_rst_n = 1'b1;
repeat (5) @(negedge clk) tb_period = 22'h3d_ffe1;
                          tb_ID_6bit = $random;
                          tb_ID = {2'b0, tb_ID_6bit};
@(negedge clk) tb_send = 1'b0;
@(negedge clk) tb_send = 1'b1;
@(negedge clk) tb_send = 1'b0;
@(posedge tb_bc_done) 
@(negedge clk)

 if(((ID_vld == 1'b1)&(tb_ID[7:6] == 2'b0)&(tb_ID == ID))||(ID_vld == 1'b0)&(tb_ID[7:6] != 2'b0))
    $display("pass");
 else begin
    $display("error");
    error = error +1;
    end

repeat (3) @(negedge clk) clr_ID_vld = 1'b1;
@(negedge clk) clr_ID_vld = 1'b0;
//////////////////
///////////
//test mddle period , randome ID
@(negedge clk) tb_rst_n = 1'b0;
@(negedge clk) tb_rst_n = 1'b1;
repeat (5) @(negedge clk) tb_period = 22'h1f_abcd;
                          tb_ID_6bit = $random;
                          tb_ID = {2'b0, tb_ID_6bit};
@(negedge clk) tb_send = 1'b0;
@(negedge clk) tb_send = 1'b1;
@(negedge clk) tb_send = 1'b0;
@(posedge tb_bc_done) 
@(negedge clk)

 if(((ID_vld == 1'b1)&(tb_ID[7:6] == 2'b0)&(tb_ID == ID))||(ID_vld == 1'b0)&(tb_ID[7:6] != 2'b0))
    $display("pass");
 else begin
    $display("error");
    error = error +1;
    end

repeat (3) @(negedge clk) clr_ID_vld = 1'b1;
@(negedge clk) clr_ID_vld = 1'b0;
//////////////////
///////////
//test min period 512, invalid randome ID
@(negedge clk) tb_rst_n = 1'b0;
@(negedge clk) tb_rst_n = 1'b1;
repeat (5) @(negedge clk) tb_period = 22'd512;
                          tb_ID_6bit = $random;
                          tb_ID = {2'b01, tb_ID_6bit};
@(negedge clk) tb_send = 1'b0;
@(negedge clk) tb_send = 1'b1;
@(negedge clk) tb_send = 1'b0;
@(posedge tb_bc_done) 
@(negedge clk)

 if(((ID_vld == 1'b1)&(tb_ID[7:6] == 2'b0)&(tb_ID == ID))||(ID_vld == 1'b0)&(tb_ID[7:6] != 2'b0))
    $display("pass");
 else begin
    $display("error");
    error = error +1;
    end

repeat (3) @(negedge clk) clr_ID_vld = 1'b1;
@(negedge clk) clr_ID_vld = 1'b0;
//$stop;
//////////////////
///////////
//test max period , invlaid randome ID
@(negedge clk) tb_rst_n = 1'b0;
@(negedge clk) tb_rst_n = 1'b1;
repeat (5) @(negedge clk) tb_period = 22'h3d_ffe1;
                          tb_ID_6bit = $random;
                          tb_ID = {2'b10, tb_ID_6bit};
@(negedge clk) tb_send = 1'b0;
@(negedge clk) tb_send = 1'b1;
@(negedge clk) tb_send = 1'b0;
@(posedge tb_bc_done) 
@(negedge clk)

 if(((ID_vld == 1'b1)&(tb_ID[7:6] == 2'b0)&(tb_ID == ID))||(ID_vld == 1'b0)&(tb_ID[7:6] != 2'b0))
    $display("pass");
 else begin
    $display("error");
    error = error +1;
    end

repeat (3) @(negedge clk) clr_ID_vld = 1'b1;
@(negedge clk) clr_ID_vld = 1'b0;
//////////////////
///////////
//test middle period, invlaid randome ID
@(negedge clk) tb_rst_n = 1'b0;
@(negedge clk) tb_rst_n = 1'b1;
repeat (5) @(negedge clk) tb_period = 22'h1f_abcd;
                          tb_ID_6bit = $random;
                          tb_ID = {2'b11, tb_ID_6bit};
@(negedge clk) tb_send = 1'b0;
@(negedge clk) tb_send = 1'b1;
@(negedge clk) tb_send = 1'b0;
@(posedge tb_bc_done) 
@(negedge clk)

 if(((ID_vld == 1'b1)&(tb_ID[7:6] == 2'b0)&(tb_ID == ID))||(ID_vld == 1'b0)&(tb_ID[7:6] != 2'b0))
    $display("pass");
 else begin
    $display("error");
    error = error +1;
    end

repeat (3) @(negedge clk) clr_ID_vld = 1'b1;
@(negedge clk) clr_ID_vld = 1'b0;
//////////////////
///////////
//test randome 
@(negedge clk) tb_rst_n = 1'b0;
@(negedge clk) tb_rst_n = 1'b1;
repeat (5) @(negedge clk) tb_period = $urandom_range(512, 4063201);
                          tb_ID_6bit = $random;
                          tb_ID = $random;
@(negedge clk) tb_send = 1'b0;
@(negedge clk) tb_send = 1'b1;
@(negedge clk) tb_send = 1'b0;
@(posedge tb_bc_done) 
@(negedge clk)

 if(((ID_vld == 1'b1)&(tb_ID[7:6] == 2'b0)&(tb_ID == ID))||(ID_vld == 1'b0)&(tb_ID[7:6] != 2'b0))
    $display("pass");
 else begin
    $display("error");
    error = error +1;
    end

repeat (3) @(negedge clk) clr_ID_vld = 1'b1;
@(negedge clk) clr_ID_vld = 1'b0;
//////////////////
///////////
//test randome 
@(negedge clk) tb_rst_n = 1'b0;
@(negedge clk) tb_rst_n = 1'b1;
repeat (5) @(negedge clk) tb_period = $urandom_range(512, 4063201);
                          tb_ID_6bit = $random;
                          tb_ID = $random;
@(negedge clk) tb_send = 1'b0;
@(negedge clk) tb_send = 1'b1;
@(negedge clk) tb_send = 1'b0;
@(posedge tb_bc_done) 
@(negedge clk)

 if(((ID_vld == 1'b1)&(tb_ID[7:6] == 2'b0)&(tb_ID == ID))||(ID_vld == 1'b0)&(tb_ID[7:6] != 2'b0))
    $display("pass");
 else begin
    $display("error");
    error = error +1;
    end

repeat (3) @(negedge clk) clr_ID_vld = 1'b1;
@(negedge clk) clr_ID_vld = 1'b0;
//////////////////
///////////
//test randome 
@(negedge clk) tb_rst_n = 1'b0;
@(negedge clk) tb_rst_n = 1'b1;
repeat (5) @(negedge clk) tb_period = $urandom_range(512, 4063201);
                          tb_ID_6bit = $random;
                          tb_ID = $random;
@(negedge clk) tb_send = 1'b0;
@(negedge clk) tb_send = 1'b1;
@(negedge clk) tb_send = 1'b0;
@(posedge tb_bc_done) 
@(negedge clk)

 if(((ID_vld == 1'b1)&(tb_ID[7:6] == 2'b0)&(tb_ID == ID))||(ID_vld == 1'b0)&(tb_ID[7:6] != 2'b0))
    $display("pass");
 else begin
    $display("error");
    error = error +1;
    end

repeat (3) @(negedge clk) clr_ID_vld = 1'b1;
@(negedge clk) clr_ID_vld = 1'b0;
//////////////////
///////////
//test randome 
@(negedge clk) tb_rst_n = 1'b0;
@(negedge clk) tb_rst_n = 1'b1;
repeat (5) @(negedge clk) tb_period = $urandom_range(512, 4063201);
                          tb_ID_6bit = $random;
                          tb_ID = $random;
@(negedge clk) tb_send = 1'b0;
@(negedge clk) tb_send = 1'b1;
@(negedge clk) tb_send = 1'b0;
@(posedge tb_bc_done) 
@(negedge clk)

 if(((ID_vld == 1'b1)&(tb_ID[7:6] == 2'b0)&(tb_ID == ID))||(ID_vld == 1'b0)&(tb_ID[7:6] != 2'b0))
    $display("pass");
 else begin
    $display("error");
    error = error +1;
    end

repeat (3) @(negedge clk) clr_ID_vld = 1'b1;
@(negedge clk) clr_ID_vld = 1'b0;
//////////////////
///////////
//test randome 
@(negedge clk) tb_rst_n = 1'b0;
@(negedge clk) tb_rst_n = 1'b1;
repeat (5) @(negedge clk) tb_period = $urandom_range(512, 4063201);
                          tb_ID_6bit = $random;
                          tb_ID = $random;
@(negedge clk) tb_send = 1'b0;
@(negedge clk) tb_send = 1'b1;
@(negedge clk) tb_send = 1'b0;
@(posedge tb_bc_done) 
@(negedge clk)

 if(((ID_vld == 1'b1)&(tb_ID[7:6] == 2'b0)&(tb_ID == ID))||(ID_vld == 1'b0)&(tb_ID[7:6] != 2'b0))
    $display("pass");
 else begin
    $display("error");
    error = error +1;
    end

repeat (3) @(negedge clk) clr_ID_vld = 1'b1;
@(negedge clk) clr_ID_vld = 1'b0;
//////////////////
///////////
//test randome 
@(negedge clk) tb_rst_n = 1'b0;
@(negedge clk) tb_rst_n = 1'b1;
repeat (5) @(negedge clk) tb_period = $urandom_range(512, 4063201);
                          tb_ID_6bit = $random;
                          tb_ID = $random;
@(negedge clk) tb_send = 1'b0;
@(negedge clk) tb_send = 1'b1;
@(negedge clk) tb_send = 1'b0;
@(posedge tb_bc_done) 
@(negedge clk)

 if(((ID_vld == 1'b1)&(tb_ID[7:6] == 2'b0)&(tb_ID == ID))||(ID_vld == 1'b0)&(tb_ID[7:6] != 2'b0))
    $display("pass");
 else begin
    $display("error");
    error = error +1;
    end

repeat (3) @(negedge clk) clr_ID_vld = 1'b1;
@(negedge clk) clr_ID_vld = 1'b0;
//////////////////


$stop;

end

always begin
#5 clk = ~clk;
end

endmodule

