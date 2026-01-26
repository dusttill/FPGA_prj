module led_ctrl#(
    parameter CLK_FREQ = 50_000_000  // 50MHz
)(
    input sys_clk,
    input rst_n,
    input [1:0] sw,          // 2位拨码开关，选择4种模式
    
    output reg [7:0] led_out
);

wire [7:0] led_blink_out;     // 闪烁灯输出
wire [7:0] led_flow_out;      // 流水灯输出  
wire [7:0] led_horse_out;     // 跑马灯输出
wire [7:0] led_breath_out;    // 呼吸灯输出

led_blink #(
    .CLK_FREQ(CLK_FREQ)
) u_led_blink (
    .sys_clk(sys_clk),
    .rst_n(rst_n),
    .led_blink_out(led_blink_out)
);

led_flow #(
    .CLK_FREQ(CLK_FREQ)
) u_led_flow (
    .sys_clk(sys_clk),
    .rst_n(rst_n),
    .led_flow_out(led_flow_out)
);

led_horse #(
    .CLK_FREQ(CLK_FREQ)
) u_led_horse (
    .sys_clk(sys_clk),
    .rst_n(rst_n),
    .led_horse_out(led_horse_out)
);

led_breath #(
    .CLK_FREQ(CLK_FREQ)
) u_led_breath (
    .sys_clk(sys_clk),
    .rst_n(rst_n),
    .led_breath_out(led_breath_out)
);

always @(posedge sys_clk) begin
    if(!rst_n) begin
        led_out <= 8'b1111_1111;
    end
    else begin
        case(sw)
            2'b00: led_out <= led_blink_out;
            2'b01: led_out <= led_flow_out;
            2'b10: led_out <= led_horse_out;
            2'b11: led_out <= led_breath_out;
            default: led_out <= led_blink_out;  // 默认情况
        endcase
    end
end

endmodule