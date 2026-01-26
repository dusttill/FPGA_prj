module led_blink#(
    parameter CLK_FREQ = 50_000_000
)(
    input sys_clk,
    input rst_n,

    output reg [7:0] led_blink_out
);

//1s闪烁一次
//20ns计数50_000_000个周期就得到一秒
//如果是0.5s闪烁一次，则计数25_000_000个周期
//如果是0.25s闪烁一次，则计数12_500_000个周期

reg [25:0] cnt; //26位计数器49_999_999共26位

always@(posedge sys_clk) 
begin
    if(!rst_n)
        cnt <= 26'd0;
    else if(cnt == CLK_FREQ - 1)
        cnt <= 26'd0; 
    else
        cnt <= cnt + 1;
end

always@(posedge sys_clk)
begin
    if(!rst_n)
        led_blink_out <= 8'b1111_1111;
    else if(cnt == CLK_FREQ - 1)
        led_blink_out <= ~led_blink_out;
end
endmodule 