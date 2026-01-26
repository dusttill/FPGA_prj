module digi_tube_top#(
    parameter MAX_COUNT = 9999;
    parameter CLK_FREQ  = 50_000_000 // 系统时钟频率 // 最大计数值
) (
    input wire clk,          // 系统时钟
    input wire rst_n,        // 复位信号，低电平有效
    output wire [7:0] seg_sel, // 段选信号
    output wire [3:0] bit_sel  // 位选信号
);
    // 内部信号
    reg  [13:0] bin_counter = 0; // 二进制计数器，支持到 9999
    wire [15:0] bcd_out;          // BCD 码输出
    wire [3:0]  bcd_thousands;    // 千位
    wire [3:0]  bcd_hundreds;     // 百位
    wire [3:0]  bcd_tens;         // 十位
    wire [3:0]  bcd_ones;         // 个位


    reg [23:0] div_cnt;//分频计数器 50*10^6/2^16 = 762Hz
    always @(posedge clk) begin
        if(!rst_n)
            div_cnt = 0;
        else div_cnt <= div_cnt + 1;
    end



// 系统时钟频率：CLK_FREQ = 50,000,000 Hz (50MHz)
// 分频计数器位宽：div_cnt[23:0] (24位)
// 使用的时钟边沿：div_clk = div_cnt[20]
// div_cnt[20] 的频率 = 50MHz / 2^(20+1)
// = 50,000,000 / 2^21
// = 50,000,000 / 2,097,152
// ≈ 23.84 Hz

// 计数器计数频率：
// 计数器在每个 div_clk 的上升沿加1
// 所以计数频率 = 23.84 Hz
// 周期 = 1/23.84 ≈ 0.042秒
// 也就是 每0.042秒加1


    wire div_clk = div_cnt[20];
    // 二进制计数器
    always @(posedge div_clk) begin
        if (!rst_n) bin_counter <= 0;
        else begin
            if (bin_counter == MAX_COUNT) bin_counter <= 0; // 循环计数
            else bin_counter <= bin_counter + 1;
        end
    end

    // 二进制转 BCD 模块
    binary2bcd u_binary2bcd (
        .bin_in  (bin_counter),
        .bcd_out (bcd_out)
    );

    // 拆分 BCD 码为四位
    assign {bcd_thousands, bcd_hundreds, bcd_tens, bcd_ones} = bcd_out;

    // 数码管驱动模块实例化
    digi_tube_drv #(
        .CLK_FREQ(CLK_FREQ)
    ) u_digi_tube_drv (
        .clk     (clk),
        .rst_n   (rst_n),
        .d_0     (bcd_ones),
        .d_1     (bcd_tens),
        .d_2     (bcd_hundreds),
        .d_3     (bcd_thousands),
        .seg_sel (seg_sel),
        .bit_sel (bit_sel)
    );

endmodule