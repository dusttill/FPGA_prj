module Infrared_Standard_NEC #(
    parameter CLK_FREQ = 50_000_000  // 系统主频，默认50MHz
)(
    input            clk,            // 系统时钟
    input            rst_n,          // 复位信号（低电平有效）
    input            ir_in,          // 红外接收头输入信号（通常空闲为高）
    output reg [7:0] data_out,       // 解码出的8位命令码
    output reg       data_valid,    // 数据有效脉冲信号
    output reg       is_repeat      // 连发码标志（长按遥控器时触发）
);

// --- 1. 信号同步与边沿检测 ---
reg ir_reg1, ir_reg2;
always @(posedge clk) begin
    ir_reg1 <= ir_in;
    ir_reg2 <= ir_reg1;
end
// 捕捉下降沿：ir_in 从 1 变 0 的瞬间。NEC协议每个位都由一个下降沿开始
wire ir_negedge = ir_reg2 & ~ir_reg1; 

// --- 2. 产生 1us 基础时钟使能脉冲 ---
reg [6:0] tick_cnt;
wire      tick = (tick_cnt == (CLK_FREQ/1_000_000) - 1);
always @(posedge clk) begin
    if(!rst_n || ir_negedge) tick_cnt <= 0;
    else if(tick)            tick_cnt <= 0;
    else                     tick_cnt <= tick_cnt + 1'b1;
end

// --- 3. 微秒计数器（度量两个下降沿之间的时间） ---
reg [15:0] us_cnt; 
always @(posedge clk) begin
    if(!rst_n || ir_negedge) us_cnt <= 0; // 只要看到下降沿就清零，重新开始计下一个周期的时
    else if(tick)            us_cnt <= us_cnt + 1'b1;
end

// --- 4. 状态机定义 ---
localparam S_IDLE       = 3'd0; // 等待起始位
localparam S_LEAD_CHECK = 3'd1; // 确认引导码 (9ms+4.5ms)
localparam S_DATA_RECV  = 3'd2; // 接收32位数据（地址+命令及其反码）
localparam S_DONE       = 3'd3; // 校验并输出

reg [2:0]  state;
reg [5:0]  bit_cnt;   // 位计数器 0~31
reg [31:0] shift_reg; // 移位寄存器，存放接收到的32位原始波形信息

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state      <= S_IDLE;
        data_out   <= 8'd0;
        data_valid <= 1'b0;
        is_repeat  <= 1'b0;
        bit_cnt    <= 0;
    end else begin
        data_valid <= 1'b0; // 默认拉低，只在接收成功时产生一个时钟周期的高脉冲
        case(state)
            S_IDLE: begin
                is_repeat <= 1'b0;
                bit_cnt   <= 0;
                if(ir_negedge) state <= S_LEAD_CHECK; // 捕捉到第一个下降沿，开始解码
            end

            S_LEAD_CHECK: begin
                if(ir_negedge) begin
                    // 引导码判定：标准 13.5ms。这里设置了 12ms~15ms 的宽容差窗口
                    if(us_cnt > 12000 && us_cnt < 15000)
                        state <= S_DATA_RECV;
                    // 重复码判定：标准 11.25ms。长按遥控器时发送
                    else if(us_cnt > 10000 && us_cnt < 12000) begin
                        is_repeat <= 1'b1;
                        state     <= S_DONE;
                    end
                    else state <= S_IDLE; // 时间不对，判定为杂波，退回空闲态
                end
            end

            S_DATA_RECV: begin
                if(ir_negedge) begin
                    // NEC协议依靠下降沿间距判定：
                    // 逻辑 0: 约 1.125ms -> 判定区间 [400us, 1600us]
                    if(us_cnt > 400 && us_cnt < 1600)
                        shift_reg <= {1'b0, shift_reg[31:1]}; // 右移，低位先发
                    // 逻辑 1: 约 2.25ms -> 判定区间 [1600us, 3500us]
                    else if(us_cnt >= 1600 && us_cnt < 3500)
                        shift_reg <= {1'b1, shift_reg[31:1]};
                    else 
                        state <= S_IDLE; // 超出范围，视为解码失败

                    // 计数满32位跳转
                    if(bit_cnt == 5'd31) begin
                        bit_cnt <= 0;
                        state   <= S_DONE;
                    end else begin
                        bit_cnt <= bit_cnt + 1'b1;
                    end
                end
            end

            S_DONE: begin
                // 校验：NEC协议规定命令码(16-23位)和命令反码(24-31位)之和应为 0xFF
                // 使用异或校验：两者异或结果应全为1
                if((shift_reg[23:16] ^ shift_reg[31:24]) == 8'hFF) begin
                    data_out   <= shift_reg[23:16]; // 输出有效的8位键值
                    data_valid <= 1'b1;
                end
                state <= S_IDLE;
            end
            
            default: state <= S_IDLE;
        endcase
    end
end

endmodule