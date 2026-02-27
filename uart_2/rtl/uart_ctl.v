module uart_ctl  #(
	parameter BAUD_RATE = 115200,
	parameter CLK_FREQ = 50
)(
	input clk,	 
	input rst_n,	 

	input uart_rxd,	 
	output uart_txd,

	output wire [7:0] tube_seg,
    output wire [3:0] tube_bit	
);

//assign uart_txd = uart_rxd;

wire [7:0]    RX_DATA;          //received byte data
wire          RX_DATA_VALID;    //received byte data is valid

//接收数据模块
uart_rx #(
	.BAUD_RATE(BAUD_RATE),
	.CLK_FREQ(CLK_FREQ)
)u_uart_rx(		
	.clk(clk),	
	.rst_n(rst_n),
	.RX_DATA_IN(uart_rxd),
	.RX_DATA(RX_DATA),
	.RX_DATA_VALID(RX_DATA_VALID)
);

//数据缓存和数据发送控制
reg [7:0] rx_data_shift[0:1]; //移位寄存器

wire [7:0] rx_data_0 = rx_data_shift[0];
wire [7:0] rx_data_1 = rx_data_shift[1];

always @(posedge clk) begin
    if(!rst_n) begin
        rx_data_shift[0] <= 8'h00;
        rx_data_shift[1] <= 8'h00;
    end
	else if(RX_DATA_VALID) begin
        rx_data_shift[0] <= RX_DATA;
        rx_data_shift[1] <= rx_data_shift[0]; 
    end
end

digi_tube_drv #(
	.LED_ON  	(1'b0),
	.CLK_FREQ 	(CLK_FREQ)
)u_digi_tube_drv(
    .clk	(clk),   	 
    .rst_n	(rst_n),	 

    .d3(rx_data_1[7:4]),
    .d2(rx_data_1[3:0]),	
    .d1(rx_data_0[7:4]),
    .d0(rx_data_0[3:0]),
	 
    .tube_seg	(tube_seg),
    .tube_bit	(tube_bit)	
);


reg   [7:0]     TX_DATA;
reg             TX_N;

//TX_N必须保持到uart_tx模块发起新的TX流程
always @(posedge clk) begin
    if(~rst_n) TX_N <= 1'b0;
    else if(RX_DATA_VALID) TX_N <= 1'b1;
    else if(TX_READY) TX_N <= 1'b0;
    else TX_N <= TX_N;
end

always @(posedge clk) begin
    if(~rst_n) TX_DATA <= 8'h00;
    else if(RX_DATA_VALID) TX_DATA <= RX_DATA;
    else TX_DATA <= TX_DATA;
end

uart_tx #(
	.BAUD_RATE(BAUD_RATE),
	.CLK_FREQ(CLK_FREQ)
)u_uart_tx(		
	.clk(clk),	
	.rst_n(rst_n),
	.TX_DATA(TX_DATA),  
	.TX_N(TX_N), 
	.TX_READY(TX_READY),
	.TX_DATA_OUT(uart_txd)
);


endmodule
