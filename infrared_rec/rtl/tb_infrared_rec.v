`timescale 1ns / 1ps

module tb_infrared_rec();

    // 信号定义
    reg clk;
    reg rst_n;
    reg ir_in;
    wire [7:0] data_out;
    wire data_valid;
    wire is_repeat;

    // 实例化被测模块 (DUT)
    Infrared_Standard_NEC #(
        .CLK_FREQ(50_000_000)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .ir_in(ir_in),
        .data_out(data_out),
        .data_valid(data_valid),
        .is_repeat(is_repeat)
    );

    // 产生 50MHz 时钟
    initial clk = 0;
    always #10 clk = ~clk;

    // 定义发送“位”的任务
    // NEC 协议：每个位由 560us 低电平（接收头输出）开始
    // 逻辑 0：总时长 1.125ms
    // 逻辑 1：总时长 2.25ms
    task send_bit(input bit_val);
        begin
            ir_in = 0; #560000;  // 下降沿开始，持续 560us
            ir_in = 1; 
            if (bit_val) 
                #1690000;        // 逻辑1：高电平持续 1.69ms (总 2.25ms)
            else 
                #565000;         // 逻辑0：高电平持续 565us (总 1.125ms)
        end
    endtask

    // 模拟红外发送流程
    initial begin
        // 初始状态
        rst_n = 0;
        ir_in = 1;
        #200;
        rst_n = 1;
        #1000;

        // --- 1. 发送引导码 ---
        ir_in = 0; #9000000;    // 9ms 低电平
        ir_in = 1; #4500000;    // 4.5ms 高电平

        // --- 2. 发送 32 位数据 ---
        // 假设发送命令码 8'h54 (二进制 01010100)
        // 数据顺序：地址(8) -> 地址反(8) -> 命令(8) -> 命令反(8)
        
        // 地址 8'h00
        repeat(8) send_bit(0);
        // 地址反 8'hFF
        repeat(8) send_bit(1);
        
        // 命令码 8'h54 (从低位开始发: 00101010)
        send_bit(0); send_bit(0); send_bit(1); send_bit(0);
        send_bit(1); send_bit(0); send_bit(1); send_bit(0);
        
        // 命令反码 8'hAB
        send_bit(1); send_bit(1); send_bit(0); send_bit(1);
        send_bit(0); send_bit(1); send_bit(0); send_bit(1);

        // --- 3. 停止位 ---
        ir_in = 0; #560000;
        ir_in = 1;

        #2000000;
        $display("Test Finished. Data Received: %h", data_out);
        $stop;
    end

endmodule