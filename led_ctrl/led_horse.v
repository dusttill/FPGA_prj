module led_horse #(
    parameter CLK_FREQ = 50_000_000
)(
    input  wire       sys_clk,
    input  wire       rst_n,
    output reg [7:0]  led_horse_out
);

reg [25:0] flow_cnt;   // 分频计数器
reg        direction;  
wire time_on = (flow_cnt == CLK_FREQ/2 - 1);

always @(posedge sys_clk) begin
    if(!rst_n)
        flow_cnt <= 26'd0;
    else if(time_on)
        flow_cnt <= 26'd0;
    else
        flow_cnt <= flow_cnt + 1'b1;
end


always @(posedge sys_clk) begin
    if(!rst_n) begin
        direction <= 1'b0;           // 初始方向：右 → 左
    end
    else if(time_on) begin
        // 计算“下一步方向”
        if(direction == 1'b0 && led_horse_out == 8'b0111_1111)
                direction <= 1'b1;
        else if(direction == 1'b1 && led_horse_out == 8'b1111_1110) 
                direction <= 1'b0;
    end
end
always @(posedge sys_clk) begin
    if(!rst_n)
        led_horse_out <= 8'b1111_1110;  // 初始状态：最灭
    else if(time_on)begin
        if (direction == 1'b0) begin
            if(led_horse_out == 8'b0111_1111)
                led_horse_out <= 8'b1011_1111;
            else
                led_horse_out <= {led_horse_out[6:0], led_horse_out[7]}; // 左移一位，最高位循环到最低位
        end
        else begin
            if(led_horse_out == 8'b1111_1110)
                led_horse_out <= 8'b1111_1101;
            else
                led_horse_out <= {led_horse_out[0],led_horse_out[7:1]}; // 左移一位，最高位循环到最低位
        end
    end
end

endmodule
