# LED阵列
## 实验设备：
- EP4CE6E22C8N
- LED[0:7](LED0~LED7)
- K[0:1]
- DIP[0:3]
- freq-50MHZ
## 实验一：按键同时控制所有LED灯
```verilog
module led_ctrl(
    //input clk,
    //input rst,
    //input [3:0] sw,//拨码开关
    input key_in,
    output wire [7:0] led//八个LED灯

);

assign led[0] = key_in;
assign led[1] = key_in;
assign led[2] = key_in;
assign led[3] = key_in;
assign led[4] = key_in;
assign led[5] = key_in;
assign led[6] = key_in;
assign led[7] = key_in;

endmodule
```
### 注意⚠️
1. **不能用`assign led[7:0] = key_in`来赋值，assign 只能给一个信号赋值，不能给多个信号赋值**
2. `reg [7:0] led`是指8位的信号，是向量形式；`reg led[7:0]`数组形式，表示多个元件
3. 连续赋值（对于wire变量）：`assign led = key_in`，等号左侧不能是reg型，右侧则没有类型要求
4. 过程赋值（对于reg变量）：变量在被赋值后，会保持赋值后的值，直到重新被赋值
   - 阻塞赋值：顺序执行，使用`=`,多用组合逻辑，例如initial块
   - 非阻塞赋值：并行执行，使用`<=`,多用时序逻辑,例如always块

### 仿真测试：
```verilog
`timescale 1ns/1ps
module tb_led(); 
    wire [7:0] led;
    reg key_in;

    assign led[0] = key_in;
    assign led[1] = key_in;
    assign led[2] = key_in;
    assign led[3] = key_in;
    assign led[4] = key_in;
    assign led[5] = key_in;
    assign led[6] = key_in;
    assign led[7] = key_in;

    initial begin
        $dumpfile("tb_led.vcd");   // 指定波形文件名
        $dumpvars(0, tb_led);      // 0表示记录所有信号
        key_in = 0;
        #1000 $finish;
    end

    always #10 key_in <= $random % 2;//随机产生0或1

    //实例化被测模块
    led_ctrl u_led_ctrl(
        .key_in(key_in),
        .led(led)
    );
endmodule
```
### testbench文件怎么写：
1. 时间表声明：`timescale <时间单位> / <时间精度>
2. module声明：`module <模块名>(<端口定义>)
3. 内部信号:它将驱动激励信号进入 UUT 并监控 UUT 的响应，信号驱动和监控
4. UUT 实例化
5. 激励生成：编写语句以创建激励和程序块
```verilog
`timescale 1ns/1ps

module tb_led_ctrl_simple();
    
    // 1. 定义信号
    reg        key_in;      // 输入信号用reg
    wire [7:0] led;         // 输出信号用wire
    
    // 2. 实例化被测模块
    led_ctrl uut (          // uut: Unit Under Test（被测单元）
        .key_in(key_in),
        .led(led)
    );
    
    // 3. 主测试过程
    initial begin
        // 生成波形文件
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_led_ctrl_simple);
        
        // 测试1：初始状态
        key_in = 0;
        #50;
        
        // 测试2：按键按下
        key_in = 1;
        #50;
        
        // 测试3：按键松开
        key_in = 0;
        #50;
        
        // 测试4：快速切换
        key_in = 1; #20;
        key_in = 0; #20;
        key_in = 1; #20;
        key_in = 0; #20;
        
        // 结束
        #100 $finish;
    end

endmodule
```
---
## 实验二：拨码开关控制LED灯的显示模式
```verilog
module led_ctrl(
    input clk,
    input rst,
    input [3:0] sw,//拨码开关
    //input key_in,
    output reg [7:0] led//八个LED灯

);

/*assign led[0] = key_in;
assign led[1] = key_in;
assign led[2] = key_in;
assign led[3] = key_in;
assign led[4] = key_in;
assign led[5] = key_in;
assign led[6] = key_in;
assign led[7] = key_in;*/
reg [31:0] counter;        // 计数器
reg [7:0] shift_reg;       // 移位寄存器

always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 32'd0;
        shift_reg <= 8'b00000001;
        led <= 8'b00000000;
    end else begin
        counter <= counter + 1;
        
        case(sw)
            // 模式0：全灭
            4'b0000: led <= 8'b00000000;
            
            // 模式1：全亮
            4'b0001: led <= 8'b11111111;
            
            // 模式2：从左向右流水
            4'b0010: begin
                if (counter[21:0] == 22'b0) begin  // 约0.5Hz
                    shift_reg <= {shift_reg[6:0], shift_reg[7]};
                end
                led <= shift_reg;
            end
            
            // 模式3：从右向左流水
            4'b0011: begin
                if (counter[21:0] == 22'b0) begin
                    shift_reg <= {shift_reg[0], shift_reg[7:1]};
                end
                led <= shift_reg;
            end
            
            // 模式4：呼吸灯效果
            4'b0100: begin
                led <= {8{counter[24]}};  // 1Hz闪烁
            end
            
            // 模式5：两边向中间
            4'b0101: begin
                case(counter[23:21])  // 慢速变化
                    3'b000: led <= 8'b10000001;
                    3'b001: led <= 8'b11000011;
                    3'b010: led <= 8'b11100111;
                    3'b011: led <= 8'b11111111;
                    3'b100: led <= 8'b11100111;
                    3'b101: led <= 8'b11000011;
                    3'b110: led <= 8'b10000001;
                    3'b111: led <= 8'b00000000;
                endcase
            end
            
            // 其他模式
            default: led <= 8'b00000000;
        endcase
    end
end

endmodule
```
### 显示模式：
1. 模式0（0000）：8个LED全灭

2. 模式1（0001）：8个LED全亮

3. 模式2（0010）：从左向右流水灯    

    - LED从最左到最右逐个移动

    - 大约0.5Hz速度（每2秒循环一次）

4. 模式3（0011）：从右向左流水灯

    - LED从最右到最左逐个移动   

    - 反向流水效果

5. 模式4（0100）：呼吸灯效果

   - 所有LED同时闪烁（1Hz频率）

    - 类似呼吸的亮灭效果

6. 模式5（0101）：两边向中间交替

    - LED从两边向中间亮起，再从中间向两边熄灭

    - 8种状态循环