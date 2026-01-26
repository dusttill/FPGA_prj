/*
  超声波测距系统顶层模块
  功能：协调二进制转BCD、距离测量和数码管显示
*/

module ultrasonic #(
    parameter CLK_FREQ = 50_000_000  // 时钟频率50MHz
)(
    input wire clk,          // 系统时钟
    input wire rst_n,        // 复位信号，低电平有效
    input wire echo,         // 超声波回波信号
    output wire trig,        // 超声波触发信号
    output      bell,
    output wire [7:0] seg_sel,  // 数码管段选
    output wire [3:0] bit_sel   // 数码管位选
);

    //1. 超声波测距离，单位：毫米
    wire [15:0] distance;
    wire distance_valid;

    measure #(
        .CLK_FREQ(CLK_FREQ)
    ) u_measure (
        .clk(clk),
        .rst_n(rst_n),
        .echo(echo),
        .trig(trig),
        .distance(distance),
        .distance_valid(distance_valid)
    );


    //2. 二进制的数转换为十进制数BCD码
    wire [15:0] bcd_distance;

    binary2bcd u_binary2bcd (
        .bin_in(distance),  // 输入14位二进制数（最大9999）
        .bcd_out(bcd_distance)                // 输出16位BCD码
    );
    wire [3:0] thousands;          // 千位
    wire [3:0] hundreds;           // 百位
    wire [3:0] tens;               // 十位
    wire [3:0] ones;               // 个位

    // 3. 数码管驱动模块
    digi_tube_drv #(
        .CLK_FREQ(CLK_FREQ)
    ) u_digi_tube_drv (
        .clk(clk),
        .rst_n(rst_n),
        .d_0(bcd_distance[3:0]),
        .d_1(bcd_distance[7:4]),	
        .d_2(bcd_distance[11:8]),
        .d_3(bcd_distance[15:12]),
        .seg_sel(seg_sel),
        .bit_sel(bit_sel)
    );  

    //4. 依据超声波测量的不同距离利用蜂鸣器播放不同的音符
    reg [4:0] tone_index;
    always @(posedge clk) begin
        if(~rst_n) tone_index <= 0;
        else begin
            if(distance > 2000)  		tone_index <= 0;
            else if(distance > 800) 	tone_index <= 7;
            else if(distance > 200) 	tone_index <= 9;
            else if(distance > 100) 	tone_index <= 12;
            else if(distance > 50) 		tone_index <= 15;
        else 						    tone_index <= 17;		
    end
    end

    tone #(
	    .CLK_FREQ(CLK_FREQ)
    ) u_tone(
	    .clk(clk),   
	    .rst_n(rst_n),  
	    .tone_index(tone_index),
	    .tone_out (bell) 
    );
endmodule
