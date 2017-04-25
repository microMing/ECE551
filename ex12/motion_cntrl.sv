//module motion_cntrl
//created by liangzhang
//lzhang432@wisc.edu
//for ex11
module motion_cntrl(clk, rst_n, go, strt_cnv, chnnl, cnv_cmplt, A2D_res, IR_in_en, IR_mid_en, IR_out_en, LEDs, lft, rht);
input clk, rst_n;
input go;
output strt_cnv;//handle dummy read/write in this module
output [2:0] chnnl;//channel sequence: 1->0->4->2->3->7
input cnv_cmplt;//handle dummy read/write in this module
input [11:0] A2D_res;
output IR_in_en;//pwm output
output IR_mid_en;//pwm output
output IR_out_en;//pwm output
output [7:0] LEDs;//upper bits of error
output [10:0] lft;
output [10:0] rht;

//input/output
//wire strt_cnv;
wire [2:0] chnnl;
wire IR_in_en;
wire IR_mid_en;
wire IR_out_en;
reg [7:0] LEDs;
wire [10:0] lft;
wire [10:0] rht;

//state_machine_related
reg clr_accum;
reg set_start_conv;
reg enable_timer_4096;
reg enable_timer_32;
reg enable_timer_2;
reg update_channel;
reg [2:0] src0sel_d;
reg [2:0] src1sel_d;
reg set_src0sel;
reg set_src1sel;
reg set_multiply;
reg set_sub;
reg set_mult2;
reg set_mult4;
reg set_saturate;
reg set_dst_accum; //dst_xx means which dst go to xx register
reg set_dst_Intgrl;
reg set_dst_Icomp;
reg set_dst_Pcomp;
reg set_dst_rht_reg;
reg set_dst_left_reg;
reg set_dst_error;
reg latch_A2D_res;//because we have dummp read/write, determin when to read A2D_res into register
reg update_IR_sel; 
reg set_enable_pwm;
reg clr_enable_pwm;

wire pwm_check;
wire in, mid, out;

typedef enum logic[4:0] {idle, start, timer_4096, A2D_start, dummy_A2D, calculate, timer_32, A2D_start_2nd, dummy_A2D_2nd, calculate_2nd, PI_control_Intgrl, PI_control_Icomp, PI_control_Pcomp, PI_control_Accum_1, PI_control_rht_reg, PI_control_Accum_2, PI_control_lft_reg} t_state;
t_state cur_state, next_state;

//alu connection
wire [15:0] dst;
reg [13:0] Pterm;
reg [11:0] Iterm;

//register
reg [11:0] Fwd;
reg [2:0] channel;
reg [15:0] accum;
reg [11:0] timer;
reg [2:0] src0sel;
reg [2:0] src1sel;
reg multiply;
reg sub;
reg mult2;
reg mult4;
reg saturate;
reg [11:0] Intgrl;
reg [11:0] error;
reg [11:0] Icomp;
reg [15:0] Pcomp;
reg [11:0] rht_reg;
reg [11:0] lft_reg;
reg [11:0] A2D_res_reg;//because we have dummp read/write, determin when to read A2D_res into register
reg [2:0] IR_sel; 
reg strt_cnv;


//input/output declear
assign chnnl = channel;
assign rht = rht_reg[11:1];
assign lft = lft_reg[11:1];
//
assign in = (channel == 3'h1)|(channel == 3'h0);
assign mid = (channel == 3'h4)|(channel == 3'h2);
assign out = (channel == 3'h3)|(channel == 3'h7);

always@(*) begin
clr_accum = 1'b0;
set_start_conv = 1'b0;
enable_timer_4096 = 1'b0;
enable_timer_32=1'b0;
enable_timer_2 = 1'b0;
update_channel=1'b0;
src0sel_d = 3'b0;
src1sel_d = 3'b0;
set_src0sel = 1'b0;
set_src1sel = 1'b0;
set_multiply = 1'b0;
set_sub = 1'b0;
set_mult2 = 1'b0;
set_mult4 = 1'b0;
set_saturate = 1'b0;
set_dst_accum = 1'b0;
set_dst_Intgrl = 1'b0;
set_dst_Icomp = 1'b0;
set_dst_error = 1'b0;
set_dst_Pcomp = 1'b0;
set_dst_rht_reg = 1'b0;
set_dst_left_reg = 1'b0;
latch_A2D_res = 1'b0;
update_IR_sel = 1'b0;
next_state = cur_state;
set_enable_pwm = 1'b0;
clr_enable_pwm = 1'b0;
  begin
     case(cur_state)
       idle: begin
               if (go&(channel == 3'h1)) begin
                  next_state = start;
                  end
             end
       start: begin
                 next_state = timer_4096;
                 set_enable_pwm = 1'b1;
                 clr_accum = 1'b1;
              end
       timer_4096: begin
                     enable_timer_4096 = 1'b1;
                     if(timer == 12'd4095) begin
                        next_state = A2D_start;
                        set_start_conv = 1'b1;
                       end
                     else
                        next_state = timer_4096;
                   end
       A2D_start: begin
                     if(!cnv_cmplt)
                        next_state = A2D_start;
                     else begin
                        next_state = dummy_A2D;
                        set_start_conv = 1'b1;
                     end  
                  end
       dummy_A2D: begin
                    if(!cnv_cmplt)
                       next_state = dummy_A2D;
                    else begin
                       next_state = calculate;
                       latch_A2D_res = 1'b1;
                       set_src1sel = 1'b1;
                       set_src0sel = 1'b1;
                       src1sel_d = 3'b000;
                       src0sel_d = 3'b000;
                       if (mid)
                         set_mult2 = 1'b1;
                       else
                         set_mult2 = 1'b0;
                       if (out)
                         set_mult4 = 1'b1;
                       else 
                         set_mult4 = 1'b0;
                    end
                  end
       calculate: begin
                   set_dst_accum = 1;
                   update_channel = 1'b1;
                   next_state = timer_32;
                end
       timer_32: begin
                   enable_timer_32 = 1'b1;
                   if(timer == 12'd31) begin
                        next_state = A2D_start_2nd;
                        set_start_conv = 1'b1;
                      end
                    else
                      next_state = timer_32;
                 end
        A2D_start_2nd: begin
                    if(!cnv_cmplt)
                      next_state = A2D_start_2nd;
                    else begin
                         next_state = dummy_A2D_2nd;
                         set_start_conv = 1'b1;
                       end
                 end
       dummy_A2D_2nd: begin
                     if(!cnv_cmplt)
                         next_state = dummy_A2D_2nd;
                     else begin
                         clr_enable_pwm = 1'b1;
                         next_state = calculate_2nd;
                         latch_A2D_res = 1'b1;
                         if(in|mid) begin
                         set_src0sel = 1'b1;
                         set_src1sel = 1'b1;
                         set_sub = 1'b1;
                         src1sel_d = 3'b000;
                         src0sel_d = 3'b000;
                         end
                         if(mid)
                          set_mult2 = 1'b1;
                        if (out) begin
                          set_src0sel = 1'b1;
                          set_src1sel = 1'b1;
                          src0sel_d = 3'b000;
                          src1sel_d = 3'b000;
                          set_sub = 1'b1;
                          set_mult4 = 1'b1;
                         end
                     end
                 end
       calculate_2nd: begin
                        if(out)
                          set_dst_error = 1'b1;
                        else
                           set_dst_accum = 1'b1;
                        if(channel == 3'h7) begin
                         next_state = PI_control_Intgrl;
                         update_channel = 1'b1;
                         update_IR_sel = 1'b1;
                         clr_enable_pwm = 1'b1;
                         set_src0sel = 1'b1;
                         set_src1sel = 1'b1;
                         src0sel_d = 3'b010;
                         src1sel_d = 3'b001;
                         set_mult4 = 1'b1;
                         set_saturate = 1'b1;
                       end
                        else begin
                         next_state = timer_4096;
                         update_channel = 1'b1;
                         update_IR_sel = 1'b1;
                         set_enable_pwm = 1'b1;
                      end
                   end
        PI_control_Intgrl: begin
                      set_dst_Intgrl = 1'b1;
                      next_state = PI_control_Icomp;
                      set_src0sel = 1'b1;
                      set_src1sel = 1'b1;
                      src1sel_d = 3'b001;
                      src0sel_d = 3'b001;
                      set_multiply = 1'b1;
                 end
        PI_control_Icomp: begin //x 2cycles
                      set_dst_Icomp = 1'b1;
                      enable_timer_2 = 1'b1;
                      if(timer==12'd1) begin
                         next_state = PI_control_Pcomp;
                         set_src1sel = 1'b1;
                         set_src0sel = 1'b1;
                         src1sel_d = 3'b010;
                         src0sel_d = 3'b100;
                         set_multiply = 1'b1;
                      end
                      else begin
                        next_state = PI_control_Icomp;
                        set_src0sel = 1'b1;
                        set_src1sel = 1'b1;
                        src1sel_d = 3'b001;
                        src0sel_d = 3'b001;
                        set_multiply = 1'b1;
                      end
                 end
       PI_control_Pcomp: begin //x 2cycles
                   set_dst_Pcomp = 1'b1;
                   enable_timer_2 = 1'b1;
                     if(timer==12'd1) begin
                         next_state = PI_control_Accum_1;
                         set_src1sel = 1'b1;
                         set_src0sel = 1'b1;
                         src1sel_d = 3'b100;
                         src0sel_d = 3'b011;
                         set_sub = 1'b1;
                      end
                      else begin
                         next_state = PI_control_Pcomp;
                         set_src1sel = 1'b1;
                         set_src0sel = 1'b1;
                         src1sel_d = 3'b010;
                         src0sel_d = 3'b100;
                         set_multiply = 1'b1;
                      end

                 end
       PI_control_Accum_1: begin
                      set_dst_accum = 1'b1;
                      next_state = PI_control_rht_reg;
                      set_src1sel = 1'b1;
                      set_src0sel = 1'b1;
                      src1sel_d = 3'b000;
                      src0sel_d = 3'b010;
                      set_saturate = 1'b1;
                      set_sub = 1'b1;
                 end
       PI_control_rht_reg: begin
                      set_dst_rht_reg = 1'b1;
                      next_state = PI_control_Accum_2;
                      set_src1sel = 1'b1;
                      set_src0sel = 1'b1;
                      src1sel_d = 3'b100;
                      src0sel_d = 3'b011;
                 end
       PI_control_Accum_2: begin
                      set_dst_accum = 1'b1;
                      next_state = PI_control_lft_reg;
                      set_src1sel = 1'b1;
                      set_src0sel = 1'b1;
                      src1sel_d = 3'b000;
                      src0sel_d = 3'b010;
                      set_saturate = 1'b1;
                 end
       PI_control_lft_reg: begin
                      set_dst_left_reg = 1'b1;
                      next_state = idle;
                 end
     endcase
  end
end

always@(posedge clk, negedge rst_n)
 if(!rst_n)
   cur_state <= idle;
 else
   cur_state <= next_state;

always@(posedge clk, negedge rst_n)
  if(~rst_n)
     channel <= 3'h1;
  else if((channel == 3'h1)&&(update_channel))
     channel <= 3'h0;
  else if((channel == 3'h0)&&(update_channel))
     channel <= 3'h4;
  else if((channel == 3'h4)&&(update_channel))
     channel <= 3'h2;
  else if((channel == 3'h2)&&(update_channel))
     channel <= 3'h3;
  else if((channel == 3'h3)&&(update_channel))
     channel <= 3'h7;
  else if((channel == 3'h7)&&(update_channel))
     channel <= 3'h1;
  

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    Pterm <= 14'h3680;

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    Iterm <= 12'h500;

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    strt_cnv <= 1'b0;
 else
    strt_cnv <= set_start_conv;

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    accum <= 16'b0;
 else if(clr_accum)
    accum <= 16'b0;
 else if(set_dst_accum)
    accum <= dst;

always@(posedge clk, negedge rst_n)
 if (~rst_n)
    timer<= 12'b0;
 else if((enable_timer_4096)&&(timer == 12'd4095))
    timer<= 12'b0; 
 else if(enable_timer_4096)
    timer<= timer + 1'b1;
 else if((enable_timer_32)&&(timer == 13'd31))
    timer<=12'b0;
 else if(enable_timer_32)
    timer<=timer+1'b1;
 else if((enable_timer_2)&&(timer == 12'd1))
    timer<=12'b0;
 else if(enable_timer_2)
    timer<=timer+1'b1;
 else
    timer<=12'b0;


always@(posedge clk, negedge rst_n)
 if(~rst_n)
    src0sel<=3'b0;
 else if(set_src0sel)
    src0sel<=src0sel_d;
 else
    src0sel<=3'b0;

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    src1sel<=3'b0;
 else if(set_src1sel)
    src1sel<=src1sel_d;
 else
    src1sel<=3'b0;

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    multiply<=1'b0;
 else if(set_multiply)
    multiply<=1'b1;
 else
    multiply<=1'b0;

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    sub<=1'b0;
 else if(set_sub)
    sub<=1'b1;
 else
    sub<=1'b0;

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    mult2<=1'b0;
 else if(set_mult2)
    mult2<=1'b1;
 else
    mult2<=1'b0;

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    mult4<=1'b0;
 else if(set_mult4)
    mult4<=1'b1;
 else
    mult4<=1'b0;

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    saturate<=1'b0;
 else if(set_saturate)
    saturate<=1'b1;
 else
    saturate<=1'b0;

reg[1:0] int_dec;
always@(posedge clk, negedge rst_n)
 if(~rst_n)
    int_dec<=2'b0;
 else if(set_dst_Intgrl)
    int_dec<=int_dec+1'b1;

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    Intgrl<=12'b0;
 else if(set_dst_Intgrl&(int_dec==2'b11))
    Intgrl<=dst[11:0];
 
always@(posedge clk, negedge rst_n)
 if(~rst_n)
    Icomp<=12'b0;
 else if(set_dst_Icomp)
    Icomp<=dst[11:0];

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    Pcomp<=16'b0;
 else if(set_dst_Pcomp)
    Pcomp<=dst;

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    error<=12'b0;
 else if(set_dst_error)
    error<=dst[11:0];


always@(posedge clk, negedge rst_n)
 if(~rst_n)
    rht_reg<=12'b0;
 else if(set_dst_rht_reg)
    rht_reg<=dst[11:0];

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    lft_reg<=12'b0;
 else if(set_dst_left_reg)
    lft_reg<=dst[11:0];

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    A2D_res_reg<=12'b0;
 else if(latch_A2D_res)
    A2D_res_reg<=A2D_res;

always@(posedge clk, negedge rst_n)
 if(~rst_n)
    IR_sel<=3'b0;
 else if((update_IR_sel)&(IR_sel == 3'h0))
    IR_sel<=3'h1;
 else if((update_IR_sel)&(IR_sel == 3'h1))
    IR_sel<=3'h2;
 else if((update_IR_sel)&(IR_sel == 3'h2))
    IR_sel<=3'h0;


//pwm logic
//reg declear
reg [7:0] pwm_cnt;
reg PWM_sig;
reg enable_pwm;

//free running counter
always@(posedge clk, negedge rst_n)
  if(~rst_n)
	pwm_cnt<=8'b0;
  else if(enable_pwm) 
	pwm_cnt<=pwm_cnt+1'b1;
  else
        pwm_cnt<=8'b0;

//output must be reg output
always@(posedge clk, negedge rst_n)
  if(~rst_n)
	PWM_sig <= 1'b0;
  else if(set_enable_pwm)
        PWM_sig <= 1'b1;
  else if(pwm_cnt == 8'b1111_1111)
	PWM_sig <= 1'b1;
  else if(pwm_cnt == 8'h8c)
        PWM_sig <= 1'b0;
  else
        PWM_sig <= PWM_sig;

assign pwm_check = (pwm_cnt == 8'b1111_1111);

always@(posedge clk, negedge rst_n)
if(!rst_n)
   enable_pwm <= 1'b0;
else if(clr_enable_pwm)
   enable_pwm <= 1'b0;
else if(set_enable_pwm)
   enable_pwm <= 1'b1;

assign IR_in_en = in? PWM_sig : 1'b0;
assign IR_mid_en = mid? PWM_sig : 1'b0;
assign IR_out_en = out? PWM_sig : 1'b0;

//alu connection
alu alu(.Accum(accum), .Pcomp(Pcomp), .Icomp(Icomp), .Pterm(Pterm), .Iterm(Iterm), .Fwd(Fwd), .A2D_res(A2D_res_reg), .Error(error), .Intgrl(Intgrl), .src0sel(src0sel), .src1sel(src1sel), .multiply(multiply), .sub(sub), .mult2(mult2), .mult4(mult4), .saturate(saturate), .dst(dst));

always@(posedge clk, negedge rst_n)
if(!rst_n)
   LEDs <= 8'b0;
else 
   LEDs <= error[11:4];

always@(posedge clk, negedge rst_n)
if(!rst_n)
   Fwd <= 12'h0;
else if(~go)
   Fwd <= 12'b0;
else if(set_dst_Intgrl & ~&Fwd[10:8])
   Fwd <= Fwd+ 1'b1;

endmodule
