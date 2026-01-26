`timescale 1ns/1ps

module tb_led_ctrl;

    parameter CLK_FREQ = 50_000;   // 
    parameter CLK_PERIOD = 20;          // 50MHz -> 20ns
    reg         sys_clk;
    reg         rst_n;
    reg  [1:0]  sw;
    wire [7:0]  led_out;

    led_ctrl #(
        .CLK_FREQ(CLK_FREQ)
    ) uut (
        .sys_clk (sys_clk),
        .rst_n   (rst_n),
        .sw      (sw),
        .led_out (led_out)
    );

    initial begin
        sys_clk = 0;
        forever #(CLK_PERIOD/2) sys_clk = ~sys_clk;
    end

//仿真等待时间(ns)
//= 想要的模块时间(s) × CLK_FREQ × 时钟周期(ns)

    initial begin
        rst_n = 0;
        sw = 2'b00;
        #100;
        rst_n = 1;
        sw = 2'b00;
        #1_000_000;   // 仿真 2s
        sw = 2'b01;
        #1_000_000;
        sw = 2'b10;
        #1_000_000;
        sw = 2'b11;
        #1_000_000;
        $dumpvars(0, tb_led_ctrl.uut.u_led_breath);
        $dumpvars(0, tb_led_ctrl.uut.u_led_horse);

    end

endmodule
