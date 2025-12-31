module beep
#(
    parameter COUNT_500MS = 25'd24_999_999,//0.5s每个音调持续鸣叫时间
    parameter DO = 190840 ,//分频计数值（频率262）
    parameter RE = 170068 ,//分频计数值（频率294）
    parameter MI = 151515 ,//分频计数值（频率330）
    parameter FA = 143266 ,//分频计数值（频率349）
    parameter SO = 127551 ,//分频计数值（频率392）
    parameter LA = 113636 ,//分频计数值（频率440）
    parameter XI = 101020 //分频计数值（频率494）
    //parameter Do1 = 523 //分频计数值（频率523）
)
(
    input   wire  clk,
    input   wire  rst,

    output  reg   beep
);

reg [24:0] cnt ; //0.5s计数器
reg [17:0] freq_cnt ; //音调计数器
reg [2:0] cnt_500ms ; //0.5s个数计数
reg [17:0] freq_data ; //音调分频计数值

wire [16:0] duty_data ; //占空比计数值

//设置50％占空比：音阶分频计数值的一半即为占空比的高电平数
assign duty_data = freq_data >> 1'b1;
//cnt:0.5s循环计数器
always@(posedge clk or negedge rst)
    if(rst == 1'b0)
        cnt <= 25'd0;
    else if(cnt == COUNT_500MS )
        cnt <= 25'd0;
    else
        cnt <= cnt + 1'b1;

 //cnt_500ms：对500ms个数进行计数，每个音阶鸣叫时间0.5s，7个音节一循环
always@(posedge clk or negedge rst)
    if(rst == 1'b0)
        cnt_500ms <= 3'd0;
    else if(cnt == COUNT_500MS && cnt_500ms == 6)
        cnt_500ms <= 3'd0;
    else if(cnt == COUNT_500MS)
        cnt_500ms <= cnt_500ms + 1'b1;

//不同时间鸣叫不同的音阶
always@(posedge clk or negedge rst)
    if(rst == 1'b0)
        freq_data <= DO;
    else case(cnt_500ms)
        0: freq_data <= DO;
        1: freq_data <= RE;
        2: freq_data <= MI;
        3: freq_data <= FA;
        4: freq_data <= SO;
        5: freq_data <= LA;
        6: freq_data <= XI;
    default: freq_data <= DO;
 endcase

//freq_cnt：当计数到音阶计数值或跳转到下一音阶时，开始重新计数
always@(posedge clk or negedge rst)
    if(rst == 1'b0)
        freq_cnt <= 18'd0;
    else if(freq_cnt == freq_data || cnt == COUNT_500MS)
        freq_cnt <= 18'd0;
    else
        freq_cnt <= freq_cnt + 1'b1;

//beep：输出蜂鸣器波形
always@(posedge clk or negedge rst)
    if(rst == 1'b0)
        beep <= 1'b0;
    else if(freq_cnt < duty_data)
        beep <= 1'b1;
    else
        beep <= 1'b0;
        
endmodule