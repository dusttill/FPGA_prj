`timescale 1ns / 1ps

module tb_ir_rec();

    // 1. 信号定义
    reg clk;
    reg rst_n;
    reg ir_in;
    wire [15:0] data_out;
    wire data_out_valid;

    // 2. 例化被测模块 (DUT)
    infrared_rec_v3 #(
        .CLK_FREQ(50_000_000)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .ir_in(ir_in),
        .data_out(data_out),
        .data_out_valid(data_out_valid)
    );

    // 3. 时钟产生 (50MHz)
    always #10 clk = ~clk;

    // 4. 定义发送任务 (Task) 以便重复调用
    // 发送逻辑 0：560us 低 + 560us 高
    task send_bit_0;
        begin
            ir_in = 0; #560_000;
            ir_in = 1; #560_000;
        end
    endtask

    // 发送逻辑 1：560us 低 + 1680us 高
    task send_bit_1;
        begin
            ir_in = 0; #560_000;
            ir_in = 1; #1_680_000;
        end
    endtask

    // 发送一整个字节 (LSB 先发)
    task send_byte;
        input [7:0] byte_val;
        integer i;
        begin
            for (i=0; i<8; i=i+1) begin
                if (byte_val[i]) send_bit_1();
                else             send_bit_0();
            end
        end
    endtask

    // 5. 仿真主体逻辑
    initial begin
        // 初始化信号
        clk = 0;
        rst_n = 0;
        ir_in = 1; // 红外空闲状态为高电平 [cite: 22, 38]

        #100 rst_n = 1;
        #100;

        // --- 开始模拟发送 NEC 协议帧 ---
        
        // Step 1: 引导码 (9ms 低电平 + 4.5ms 高电平) [cite: 19, 20]
        ir_in = 0; #9_000_000; 
        ir_in = 1; #4_500_000;

        // Step 2: 发送数据位 (32位)
        // 地址码: 8'h12, 地址反码: 8'hED 
        send_byte(8'h12); 
        send_byte(8'hED);
        
        // 命令码: 8'h34, 命令反码: 8'hCB 
        send_byte(8'h34);
        send_byte(8'hCB);

        // Step 3: 停止位 (结束位，拉低 560us 再拉高回到空闲)
        ir_in = 0; #560_000;
        ir_in = 1;

        // 等待数据更新到 data_out [cite: 47, 48]
        #2_000_000;

        // 验证结果
        if (data_out == 16'h1234) 
            $display("Simulation Success! Received: %h", data_out);
        else 
            $display("Simulation Failed! Received: %h", data_out);

        #1000 $stop;
    end

endmodule