module uart_rx#(
    parameter CLK_FREQ = 50,
    parameter BAUD_RATE = 115200//波特率
)(
    input               clk,
    input               rst_n,
    input               RX_DATA_IN,


    output reg [7:0]    RX_DATA,//
    output reg          RX_DATA_VALID//
); 

localparam  BAUD_RATE_CNT = CLK_FREQ*1000_000 / BAUD_RATE;//一个波特率周期的时钟数

reg [15:0]  baud_cnt;//波特率计数器
reg [3:0]   bit_cnt;//位计数器
reg         RX_BUSY;//
reg         state;

wire cnt_done = (baud_cnt == BAUD_RATE_CNT-1);
wire half_cnt_done  = (baud_cnt == BAUD_RATE_CNT/2 - 1); //在BIT位的中间时刻采集数据

localparam S_IDLE = 1'b0;
localparam S_RECV = 1'b1;

always@(posedge clk) begin
	if(~rst_n) state <= S_IDLE;
	else case(state)
	S_IDLE: begin
        if(RX_DATA_IN==1'b0) state <= S_RECV;
	end

	S_RECV: begin
		if(half_cnt_done && bit_cnt == 9) state <= S_IDLE;
	end

	default: state <= S_IDLE;
    endcase
end


//****************************波特率计数器***********************************//
always@(posedge clk) begin
	if(~rst_n) baud_cnt <= 0;
    else if(state == S_RECV) begin
        if(cnt_done) baud_cnt <= 0;
	    else baud_cnt <= baud_cnt +  1;	
    end
    else baud_cnt <= 0;
end


//****************************位计数器***********************************//
always@(posedge clk) begin
	if(~rst_n) bit_cnt <= 0;
    else if(state == S_RECV) begin
		if(half_cnt_done) 
            bit_cnt <= bit_cnt + 1;
		else bit_cnt <= bit_cnt;
    end
    else bit_cnt <= 0;
end

//****************************就绪状态***********************************//
always@(posedge clk) begin
	if(~rst_n) RX_BUSY <= 1'b0;
	else if(RX_DATA_IN==1'b0) 
        RX_BUSY <= 1'b1;
    else if(half_cnt_done && bit_cnt == 9) 
        RX_BUSY <= 1'b0;
	else RX_BUSY <= RX_BUSY;
end

//****************************接收数据***********************************//
reg [9:0] rx_bits;
always@(posedge clk) begin
	if(~rst_n) rx_bits <= 10'd0;
    else if(state == S_RECV) begin
		if(half_cnt_done) 
            rx_bits[bit_cnt] <= RX_DATA_IN; //{1'b1, rx_data[7:0],1'b0};
		else rx_bits <= rx_bits;
    end
    else rx_bits <= 0;
end

wire recv_done = (half_cnt_done && bit_cnt == 9);

always@(posedge clk) begin
	if(~rst_n) RX_DATA <= 8'd0;
	else if(recv_done) 
        RX_DATA <= rx_bits[8:1]; 
    else RX_DATA <= RX_DATA;
end

//****************************数据有效标志***********************************//
always@(posedge clk) begin
	if(~rst_n) RX_DATA_VALID <= 1'b0;
	else if(recv_done)
		RX_DATA_VALID <= 1'b1;
	else RX_DATA_VALID <= 1'b0;
end
endmodule