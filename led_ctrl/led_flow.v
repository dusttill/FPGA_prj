module led_flow #(
    parameter CLK_FREQ = 50_000_000
)(
    input  wire       sys_clk,
    input  wire       rst_n,
    output reg [7:0]  led_flow_out
);

reg [31:0] flow_cnt;
reg        direction;      // 0: 右→左，1: 左→右
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
        led_flow_out   <= 8'b1111_1111;   // 初始：最右边 LED 亮（低电平亮）
    end
    else if(time_on) begin

        // 根据“下一步的方向”移动 LED
        if(direction == 1'b0) begin
            led_flow_out <= {led_flow_out[6:0], 1'b0};
        end
        else begin
            led_flow_out <= {1'b1, led_flow_out[7:1]};
        end
    end
end

always @(posedge sys_clk) begin
    if(!rst_n) begin
        direction <= 1'b0;           // 初始方向：右 → 左
    end
    else if(time_on) begin
        // 计算“下一步方向”
        if(direction == 1'b0) begin
            if (led_flow_out == 0) begin
                direction <= 1'b1;
            end
            
        end 
        else begin
            if (led_flow_out == 8'b1111_1111 )begin
                direction <= 0;
            end
        end
    end
end
endmodule