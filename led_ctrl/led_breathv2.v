module led_breath #(
    parameter CLK_FREQ = 50_000_000  // 系统时钟
)(
    input  wire       sys_clk,
    input  wire       rst_n,
    output reg [7:0]  led_breath_out
);

reg [15:0] pwm_cnt;      // PWM计数器
reg [7:0]  duty;         // 占空比 0~255
reg        direction;     // 呼吸变化方向0: 变亮, 1: 变暗
reg [25:0] breath_cnt;    // 呼吸分频计数器

always @(posedge sys_clk) begin
    if(!rst_n)
        pwm_cnt <= 16'd0;
    else
        pwm_cnt <= pwm_cnt + 1'b1;
end

always @(posedge sys_clk) begin
    if(!rst_n)
        breath_cnt <= 26'd0;
    else if(breath_cnt == CLK_FREQ/500 - 1)  // 调节速度，约 100ms 更新一次
        breath_cnt <= 26'd0;
    else
        breath_cnt <= breath_cnt + 1'b1;
end

always @(posedge sys_clk) begin
    if(!rst_n)
        duty <= 8'd0;
    else if(breath_cnt == CLK_FREQ/500 - 1) begin
        if(direction == 1'b0) begin
            if(duty == 8'd255)
                duty <= duty;  // 保持最大，占空比由方向控制翻转
            else
                duty <= duty + 1'b1;
        end
        else begin
            if(duty == 8'd0)
                duty <= duty;  // 保持最小
            else
                duty <= duty - 1'b1;
        end
    end
end

always @(posedge sys_clk) begin
    if(!rst_n)
        direction <= 1'b0;
    else if(breath_cnt == CLK_FREQ/500 - 1) begin
        if(duty == 8'd255)
            direction <= 1'b1;  // 最大占空比 → 变暗
        else if(duty == 8'd0)
            direction <= 1'b0;  // 最小占空比 → 变亮
    end
end

always @(posedge sys_clk) begin
    if(!rst_n)
        led_breath_out <= 8'b11111111;  // 初始全灭（低电平点亮）
    else if(pwm_cnt[15:8] < duty)
        led_breath_out <= 8'b00000000;  // LED点亮
    else
        led_breath_out <= 8'b11111111;  // LED熄灭
end

endmodule
