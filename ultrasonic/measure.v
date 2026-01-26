module measure#(
    parameter CLK_FREQ = 50_000_000
)(
    input clk,
    input rst_n,
    input echo,
    output reg trig,
    output reg [15:0] distance,//output reg echo_cnt_valid
    output reg distance_valid
);
localparam ONE_SECOND = CLK_FREQ;
localparam ONE_MSECOND = ONE_SECOND/1000;
localparam ONE_USECOND = ONE_MSECOND/1_000;

parameter IDLE = 4'b0000;
parameter TRIG = 4'b0001;
parameter WAIT = 4'b0010;
parameter ECHO = 4'b0100;
parameter DONE = 4'b1000;

reg [3:0]  state;
reg [31:0] idle_cnt;
reg [31:0] trig_cnt;
reg [31:0] echo_cnt;
reg echo_cnt_valid;

always @(posedge clk) begin
    if(!rst_n) state <= IDLE;
    else begin 
        case(state)
        IDLE: 
            if(idle_cnt > ONE_MSECOND*100)//TTL电平时间
                state <= TRIG;
            else state <= IDLE;

        TRIG: 
            if(trig_cnt > ONE_USECOND*16) 
                state <= WAIT;
            else state <= TRIG;

        WAIT: 
            if(echo == 1'b1) 
                state <= ECHO;
            else state <= WAIT;

        ECHO: 
            if(echo == 0) 
                state <= DONE;
            else state <= ECHO;

        DONE: state <= IDLE;
        default: state <= IDLE;
        endcase
    end
end

//reg [31:0] idle_cnt;
always @(posedge clk) begin
    if(!rst_n) idle_cnt <=0;
    else if(state == IDLE) idle_cnt <= idle_cnt +1;
    else idle_cnt <=0;
end

//reg [31:0] trig_cnt;
always @(posedge clk) begin
    if(!rst_n) trig_cnt <=0;
    else if(state == TRIG) trig_cnt <= trig_cnt +1;
    else trig_cnt <=0;
end

//reg [31:0] echo_cnt;
always@(posedge clk) begin
	if(!rst_n) echo_cnt <= 0;
    else if(state == IDLE) echo_cnt <= 0;
    else if(echo) echo_cnt <= echo_cnt + 1;
    else echo_cnt <= echo_cnt;
end

//output reg trig,
always@(posedge clk) begin
	if(!rst_n) trig <= 0;
	else  if(state == TRIG) trig <= 1'b1;
    else trig <= 1'b0;
end

//output reg distance_valid,
always@(posedge clk) begin
	if(!rst_n) distance_valid <= 1'b0;
    else if(state == DONE) distance_valid <= 1'b1;
    else distance_valid <= 1'b0;
end

//output reg [15:0] distance, 
always @(posedge clk) begin
	//if(state == S_DONE) distance <= (echo_cnt * 1715) / 500000;
	if(state == DONE) distance <= (echo_cnt * 3597) >> 20; 
    else distance <= distance;
end

endmodule


/*======================================================
!!! Verilog不支持浮点数运算
distance计算公式推导过程

1. 计算声波传播距离
声波在空气中以约343m/s的速度（常温下）传播
距离(mm) = 时间 * 速度

full_distance = (echo_cnt / 50000000)s * 343000mm/s
full_distance = (echo_cnt * 343000) / 50000000
full_distance = (echo_cnt * 3430) / 500000 

2. 实际到障碍物距离
half_distance = full_distance / 2 = (echo_cnt * 1715) / 500000 

3. 除法特别消耗硬件资源，而移位算法所需硬件资源极小
   最好将除法转换为移位运算: (dist / 2^n)  === (dist >> n)

1024*1024 = 2^20
(1024*1024) / 500000 = 2.097152

half_distance = (echo_cnt * 1715 * 2.097152) / (500000 * 2.097152)
half_distance = (echo_cnt * 3597) / (1024*1024)
half_distance = (echo_cnt * 3597) >> 20 
======================================================*/