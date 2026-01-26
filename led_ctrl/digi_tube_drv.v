/*-------------------------------------------------
模块功能：共阳极八位数码管驱动
    通过动态扫描方式驱动8位共阳极数码管显示

硬件连接：
    seg[7:0]  - 段选信号(a,b,c,d,e,f,g,dp)，低电平点亮
    sel[7:0]  - 位选信号，低电平选中对应位

工作原理：
    1. 使用动态扫描：依次点亮每一位数码管
    2. 扫描频率足够快时，人眼看到的是8位同时显示
    3. 共阳极：段选信号为0时对应段点亮，位选为0时选中该位

新增知识点：
    1. 动态扫描：通过快速切换显示位置，实现多位同时显示的效果
    2. 七段译码：将数字0-9,A-F转换为对应的七段显示编码
    3. 消影处理：切换位时短暂关闭显示，避免重影
----------------------------------------------------*/

module seg7_display #(
    parameter CLK_FREQ = 50_000_000  // 系统时钟频率
)(
    input  wire        sys_clk,      // 系统时钟
    input  wire        rst_n,        // 复位信号，低电平有效
    input  wire [31:0] display_data, // 要显示的32位数据
    input  wire [7:0]  dot_en,       // 小数点使能，每位对应一个小数点
    output reg  [7:0]  seg,          // 段选信号 {dp,g,f,e,d,c,b,a}
    output reg  [7:0]  sel           // 位选信号，低电平选中
);

//========================================================
// 参数定义
//========================================================
// 扫描频率设置：每位显示1ms，8位循环一次需8ms，刷新率125Hz
localparam SCAN_FREQ = 1000;  // 每位扫描1ms
localparam CNT_MAX = CLK_FREQ / SCAN_FREQ - 1;

//========================================================
// 信号定义
//========================================================
reg [15:0] scan_cnt;      // 扫描计数器
reg [2:0]  digit_sel;     // 当前选中的数码管位(0-7)
reg [3:0]  digit_data;    // 当前位要显示的数据(0-F)

//========================================================
// 扫描计数器：产生1ms的时基
//========================================================
always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n)
        scan_cnt <= 16'd0;
    else if (scan_cnt == CNT_MAX)
        scan_cnt <= 16'd0;
    else
        scan_cnt <= scan_cnt + 1'b1;
end

//========================================================
// 位选控制：依次选中8个数码管
//========================================================
always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n)
        digit_sel <= 3'd0;
    else if (scan_cnt == CNT_MAX) begin
        if (digit_sel == 3'd7)
            digit_sel <= 3'd0;
        else
            digit_sel <= digit_sel + 1'b1;
    end
end

//========================================================
// 数据提取：从32位数据中提取当前位要显示的4位数据
//========================================================
always @(*) begin
    case (digit_sel)
        3'd0: digit_data = display_data[3:0];    // 最低位
        3'd1: digit_data = display_data[7:4];
        3'd2: digit_data = display_data[11:8];
        3'd3: digit_data = display_data[15:12];
        3'd4: digit_data = display_data[19:16];
        3'd5: digit_data = display_data[23:20];
        3'd6: digit_data = display_data[27:24];
        3'd7: digit_data = display_data[31:28];  // 最高位
        default: digit_data = 4'd0;
    endcase
end

//========================================================
// 七段译码：将0-F转换为七段码
// 共阳极：0-点亮，1-熄灭
// 段码定义：{g,f,e,d,c,b,a} (不含小数点dp)
//========================================================
reg [6:0] seg_code;

always @(*) begin
    case (digit_data)
        //                gfedcba
        4'h0: seg_code = 7'b100_0000;  // 0
        4'h1: seg_code = 7'b111_1001;  // 1
        4'h2: seg_code = 7'b010_0100;  // 2
        4'h3: seg_code = 7'b011_0000;  // 3
        4'h4: seg_code = 7'b001_1001;  // 4
        4'h5: seg_code = 7'b001_0010;  // 5
        4'h6: seg_code = 7'b000_0010;  // 6
        4'h7: seg_code = 7'b111_1000;  // 7
        4'h8: seg_code = 7'b000_0000;  // 8
        4'h9: seg_code = 7'b001_0000;  // 9
        4'hA: seg_code = 7'b000_1000;  // A
        4'hB: seg_code = 7'b000_0011;  // b
        4'hC: seg_code = 7'b100_0110;  // C
        4'hD: seg_code = 7'b010_0001;  // d
        4'hE: seg_code = 7'b000_0110;  // E
        4'hF: seg_code = 7'b000_1110;  // F
        default: seg_code = 7'b111_1111;  // 全灭
    endcase
end

//========================================================
// 段选输出：包含小数点控制
//========================================================
always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n)
        seg <= 8'b1111_1111;  // 全灭
    else begin
        // seg = {dp, g, f, e, d, c, b, a}
        seg <= {~dot_en[digit_sel], seg_code};
    end
end

//========================================================
// 位选输出：共阳极，低电平选中
//========================================================
always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n)
        sel <= 8'b1111_1111;  // 全部不选中
    else begin
        case (digit_sel)
            3'd0: sel <= 8'b1111_1110;  // 选中第0位
            3'd1: sel <= 8'b1111_1101;  // 选中第1位
            3'd2: sel <= 8'b1111_1011;  // 选中第2位
            3'd3: sel <= 8'b1111_0111;  // 选中第3位
            3'd4: sel <= 8'b1110_1111;  // 选中第4位
            3'd5: sel <= 8'b1101_1111;  // 选中第5位
            3'd6: sel <= 8'b1011_1111;  // 选中第6位
            3'd7: sel <= 8'b0111_1111;  // 选中第7位
            default: sel <= 8'b1111_1111;
        endcase
    end
end

endmodule