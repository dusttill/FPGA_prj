
module uart_rx #(
	parameter CLK_FRE 	= 50,      	//clock frequency(Mhz)
	parameter BAUD_RATE = 115200 	//serial baud rate
)(
	input                        clk,              //clock input
	input                        rst_n,            //asynchronous reset input, low active 
	output reg[7:0]              rx_data,          //received serial data
	output reg                   rx_data_valid,    //received serial data is valid
	input                        rx_pin            //serial data input
);

//calculates the clock cycle for baud rate 

reg[15:0]       cnt;        //baud rate counter
reg[3:0]        bit_cnt;    //bit counter !!!!

localparam BAUD_DIV_CNT = CLK_FRE * 1000000 / BAUD_RATE;

wire cnt_done       = (cnt == BAUD_DIV_CNT - 1);
wire half_cnt_done  = (cnt == BAUD_DIV_CNT/2 - 1); //在BIT位的中间时刻采集数据

localparam S_IDLE = 1'b0;
localparam S_RECV = 1'b1;

reg state;
always@(posedge clk) begin
	if(~rst_n) state <= S_IDLE;
	else case(state)
	S_IDLE: begin
        if(rx_pin==1'b0) state <= S_RECV;
	end

	S_RECV: begin
		if(half_cnt_done && bit_cnt == 10-1) state <= S_IDLE;
	end

	default: state <= S_IDLE;
    endcase
end

always@(posedge clk) begin
	if(~rst_n) cnt <= 0;
    else if(state == S_RECV) begin
        if(cnt_done) cnt <= 0;
	    else cnt <= cnt +  1;	
    end
    else cnt <= 0;
end

always@(posedge clk) begin
	if(~rst_n) bit_cnt <= 0;
    else if(state == S_RECV) begin
		if(half_cnt_done) 
            bit_cnt <= bit_cnt + 1;
		else bit_cnt <= bit_cnt;
    end
    else bit_cnt <= 0;
end

//receive serial 10 bits , include start and stop bit 
//in the middle time of every baud period
//先传送字符的低位，后传送字符的高位。 
//即低位（LSB）在前，高位（MSB）在后。
reg [9:0] rx_bits;
always@(posedge clk) begin
	if(~rst_n) rx_bits <= 10'd0;
    else if(state == S_RECV) begin
		if(half_cnt_done) 
            rx_bits[bit_cnt] <= rx_pin; //{1'b1, rx_data[7:0],1'b0};
		else rx_bits <= rx_bits;
    end
    else rx_bits <= 0;
end

//对其他模块输出接收到的字节数据
wire recv_done = (half_cnt_done && bit_cnt == 9);

//output reg[7:0] rx_data, //received 8bits data
always@(posedge clk) begin
	if(~rst_n) rx_data <= 8'd0;
    else if(recv_done) 
        rx_data <= rx_bits[8:1]; //{1'b1, rx_data[7:0],1'b0};
	else rx_data <= rx_data;
end

//output reg rx_data_valid, //received serial data is valid
always@(posedge clk) begin
	if(~rst_n) rx_data_valid <= 1'b0;
	else if(recv_done)
		rx_data_valid <= 1'b1;
	else rx_data_valid <= 1'b0;
end

endmodule 