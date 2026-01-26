module beep_drive
(
    input wire clk,
    input wire rst,
    input wire [31:0] div,

    output reg beep
);

//reg [31:0] beat_cnt1;//分频计数器
reg [31:0] beat_cnt2;//分频计数器

// 分频计数器：根据分频系数循环计数
always @(posedge clk) begin
    if(rst == 1'b0)          // 复位时清零
        beat_cnt2 <= 32'd0;
    else if(beat_cnt2 < div - 1)  // 未达到分频值时累加
        beat_cnt2 <= beat_cnt2 + 1'b1;
    else                      // 达到分频值时清零
        beat_cnt2 <= 32'd0;
end

// 蜂鸣器PWM信号生成：产生50%占空比的方波
always @(posedge clk) begin
    if(rst == 1'b0)          // 复位时输出低电平
        beep <= 1'b0;
    else if(beat_cnt2 < div[31:1])  // 前半个周期输出低电平。相当于除以2
        beep <= 1'b0;
    else                      // 后半个周期输出高电平
        beep <= 1'b1;
end

endmodule