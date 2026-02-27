module top_infrared_rec_v2#(
    parameter CLK_FREQ = 50_000_000 // MHz
)(
    input clk,
    input rst_n,
    input ir_in,

    output [7:0] tube_seg,
    output [3:0] tube_bit,
    output led
);

wire [15:0] ir_data;
wire        ir_data_ready;

// 红外接收模块例化
Infrared_Standard_NEC #(
    .CLK_FREQ(CLK_FREQ)
) u_ir_new (
    .clk        (clk),      // 必须对应顶层的 clk
    .rst_n      (rst_n),
    .ir_in      (ir_in),    // 必须对应顶层的 ir_in
    .data_out   (ir_data[7:0]), // 注意 ir_data 是 16 位的，需指定位宽
    .data_valid (ir_data_ready),
    .is_repeat  ()
);
// 数码管驱动模块例化
digi_tube_drv #(		 
	.CLK_FREQ(CLK_FREQ)
) u_digi_tube_drv(
    .clk(clk),
    .rst_n(rst_n),
    .d0(ir_data[3:0]),
    .d1(ir_data[7:4]),
    .d2(ir_data[11:8]),
    .d3(ir_data[15:12]),
    .tube_seg(tube_seg),
    .tube_bit(tube_bit)
);

assign led = (ir_data != 16'h0);
endmodule