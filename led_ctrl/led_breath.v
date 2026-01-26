module led_breath #(
	parameter CLK_FREQ = 50_000_000,
    parameter LED_ON  = 1'b1
)(
    input wire sys_clk,       
    input wire rst_n,     
    output wire [7:0] led_breath_out      
);

// 呼吸灯周期，假设为1/256秒钟为一个PWM周期,修改此参数可以改变速度
localparam ONE_SECOND = CLK_FREQ*1;
localparam PWM_PERIOD  = ONE_SECOND/256;//一个完整PWM波形的持续时间（3.9ms）50000000.256=195312,195312*20ns=3.9ms.一个呼吸周期256*3.9ms≈1s
localparam UNIT_TIME  = PWM_PERIOD/256; //时间单位：1/256个PWM周期

reg [31:0] pwm_cnt;

always @(posedge sys_clk) begin
    if (!rst_n) pwm_cnt <= 0;
    else if (pwm_cnt == PWM_PERIOD-1) begin 
        pwm_cnt <= 0;
    end
    else pwm_cnt <= pwm_cnt + 1;
end

//PWM DUTY（调整占空比)
reg [31:0] pwm_duty;
always @(posedge sys_clk) begin
    if (!rst_n) pwm_duty <= 0;
    else if (pwm_cnt == PWM_PERIOD-1) begin
        if(pwm_duty <= PWM_PERIOD-UNIT_TIME) begin
            pwm_duty <= pwm_duty + UNIT_TIME;
        end
        else pwm_duty <= 0;
    end
    else pwm_duty <= pwm_duty;
end

// 根据PWM计数器的值和呼吸灯的亮度变化来控制LED的亮度
reg led_t;
always @(posedge sys_clk) begin
    if (!rst_n) led_t <= ~LED_ON; 
    else if (pwm_cnt < pwm_duty) 
        led_t <= LED_ON;
    else led_t <= ~LED_ON; 
end

assign led_breath_out = {8{led_t}};

endmodule
