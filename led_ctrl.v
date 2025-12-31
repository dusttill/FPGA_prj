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
