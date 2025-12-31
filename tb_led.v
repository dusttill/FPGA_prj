`timescale 1ns/1ps

module tb_led_ctrl();
    
    // 信号定义
    reg clk;
    reg rst;
    reg [3:0] sw;
    wire [7:0] led;
    
    // 实例化被测模块
    led_ctrl u_led_ctrl (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .led(led)
    );
    
    // 生成时钟（50MHz，周期20ns）
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    
    // 主测试过程
    initial begin
        // 生成波形文件
        $dumpfile("led_wave.vcd");
        $dumpvars(0, tb_led_ctrl);
        
        // 显示测试开始信息
        $display("========== LED控制器测试开始 ==========");
        $display("时间(ns)  复位  开关模式  LED输出");
        $display("--------------------------------------");
        
        // 1. 初始化
        rst = 1'b1;      // 复位有效
        sw = 4'b0000;
        #100;
        $display("%8t    %b     %4b     %8b", $time, rst, sw, led);
        
        // 2. 释放复位，测试模式0
        rst = 1'b0;
        #100;
        $display("%8t    %b     %4b     %8b", $time, rst, sw, led);
        
        // 3. 测试模式1：全亮
        sw = 4'b0001;
        #200;
        $display("%8t    %b     %4b     %8b", $time, rst, sw, led);
        
        // 4. 测试模式2：从左向右流水
        sw = 4'b0010;
        #2000;  // 等待一段时间看流水效果
        $display("%8t    %b     %4b     %8b", $time, rst, sw, led);
        #2000;
        $display("%8t    %b     %4b     %8b", $time, rst, sw, led);
        
        // 5. 测试模式3：从右向左流水
        sw = 4'b0011;
        #2000;
        $display("%8t    %b     %4b     %8b", $time, rst, sw, led);
        #2000;
        $display("%8t    %b     %4b     %8b", $time, rst, sw, led);
        
        // 6. 测试模式4：呼吸灯
        sw = 4'b0100;
        #5000;
        $display("%8t    %b     %4b     %8b", $time, rst, sw, led);
        #5000;
        $display("%8t    %b     %4b     %8b", $time, rst, sw, led);
        
        // 7. 测试模式5：两边向中间
        sw = 4'b0101;
        #5000;
        $display("%8t    %b     %4b     %8b", $time, rst, sw, led);
        #5000;
        $display("%8t    %b     %4b     %8b", $time, rst, sw, led);
        
        // 8. 结束测试
        #1000;
        $display("\n========== LED控制器测试完成 ==========");
        $display("总仿真时间：%t ns", $time);
        $finish;
    end

endmodule