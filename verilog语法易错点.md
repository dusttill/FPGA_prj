# verilog语法易错点
```
#verilog 示例代码
module led_key
(
    //端口定义
    input wire clk,//时钟
    input wire key_in,//按键K1
    output reg led_out
); 

endmodule
```
1. 代码中注释使用`#`，而不是`//`，`//`是C语言中的注释
2. 模块定义使用`module`关键字，而不是`program`关键字
3. 模块定义中，端口定义必须在模块定义的第一行，不能在模块定义中间添加端口定义
4. 模块定义中：端口必须使用方向关键字 input、output、inout 指明，不能用 wire/reg 代替方向。
5. 端口类型可以在方向后显式指定，如 input wire（wire为默认）或 output reg（当输出由过程块赋值时）
6. 端口定义中，不能同时使用 wire 和 reg 关键字，只能选择其中之一。
7. Verilog 是区分大小写的，每个语句必须以分号为结束符。空白符（换行、制表、空格）都没有实际的意义，在编译阶段可忽略。
8. 用 // 进行单行注释：| 用 /* 与 */ 进行跨行注释:
9. 标识符和关键字 
- 标识符（identifier）可以是任意一组字母、数字、$ 符号和 _(下划线)符号的合，但标识符的第一个字符必须是字母或者下划线，不能以数字或者美元符开始。

- 另外，标识符是区分大小写的。

- 关键字是 Verilog 中预留的用于定义语言结构的特殊标识符。

- Verilog 中关键字全部为小写。
```
reg [3:0] counter ; //reg 为关键字， counter 为标识符
input clk; //input 为关键字，clk 为标识符
input CLK; //CLK 与 clk是 2 个不同的标识符
```
10. 数字表示：
- 数字声明时，合法的基数格式有 4 中，包括：十进制('d 或 'D)，十六进制('h 或 'H)，二进制（'b 或 'B），八进制（'o 或 'O）。数值可指明位宽，也可不指明位宽。
```verilog
4'b1011         // 4bit 数值
32'h3022_c0de   // 32bit 的数值
```
- 一般直接写数字时，默认为十进制表示,例如下面的 3 种写法是等效的：
```verilog
100     // 十进制数
0d100   // 十进制数
0D100   // 十进制数
```
- 负数表示：通常在表示位宽的数字前面加一个减号来表示负数。
```verilog
-6'd15  
-15
```
11. 数据类型
    - Verilog 中数据类型有 3 种：
    - net 类型：表示连接的物理导线，常用的 net 类型是 wire。
    - reg 类型：表示逻辑变量，常用 reg 类型是 reg。寄存器（reg）用来表示存储单元，它会保持数据原有的值，直到被改写。
    - 整数类型：表示整数，常用的整数类型是 integer。
    - 向量类型：表示多位数据，常用的向量类型是 wire 和 reg。
```verilog
reg [3:0]      counter ;    //声明4bit位宽的寄存器counter
wire [32-1:0]  gpio_data;   //声明32bit位宽的线型变量gpio_data
wire [8:2]     addr ;       //声明7bit位宽的线型变量addr，位宽范围为8:2
reg [0:31]     data ;       //声明32bit位宽的寄存器变量data, 最高有效位为0
```

- 数组：在 Verilog 中允许声明 reg, wire, integer, time, real 及其向量类型的数组。
```verilog
integer          flag [7:0] ; //8个整数组成的数组
reg  [3:0]       counter [3:0] ; //由4个4bit计数器组成的数组
wire [7:0]       addr_bus [3:0] ; //由4个8bit wire型变量组成的数组
wire             data_bit[7:0][5:0] ; //声明1bit wire型变量的二维数组
reg [31:0]       data_4d[11:0][3:0][3:0][255:0] ; //声明4维的32bit数据变量数组
```
12. 参数：
- 参数（`parameter`）是 Verilog 中用于定义常量的特殊标识符。
- 参数可以在模块定义中使用，也可以在实例化模块时使用。
```verilog
module led_key
(
    //端口定义
    input wire clk,//时钟
    input wire key_in,//按键K1
    output reg led_out
); 

parameter LED_ON = 1'b1; //定义参数LED_ON，值为1'b1
parameter LED_OFF = 1'b0; //定义参数LED_OFF，值为1'b0

endmodule
```
- 局部参数用 `localparam `来声明，其作用和用法与 `parameter `相同，区别在于它的值不能被改变。所以当参数只在本模块中调用时，可用 localparam 来说明。
