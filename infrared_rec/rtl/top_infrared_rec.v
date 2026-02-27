module top_infrared_rec#(
    parameter CLK_FREQ = 50
)(
  input clk,
  input rst_n,

  input ir_in,

  output [7:0] tube_seg,
  output [3:0] tube_bit
);

wire [15:0] ir_data;
wire  			ir_data_ready;
infrared_rec #(
    .CLK_FREQ(CLK_FREQ)
) u_infrared_rec(
    .clk(clk),
    .rst_n(rst_n),
    .ir_in(ir_in),
    .data_out(ir_data),
    .data_out_valid(ir_data_ready)
);

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
endmodule