
`timescale 1ns/1ps
module eeprom2uart_control #(
    parameter MAX_BYTE_NUM = 64
)(
	input			clk, 
	input			rst_n,
	
	//uart interface
    input [7:0]             rx_data,          //received byte data
    input                   rx_data_valid,    //received byte data is valid

    output reg              rd_byte_req,
    output reg [5:0] 	    rd_byte_num_sub1,
    output reg [23:0]       rd_byte_addr,
    input [7:0] 	        rd_byte_data,	
    input 	                rd_byte_valid,
    input                   rd_byte_busy,

    input                   tx_data_ready,
    output reg [7:0] 		tx_data,
    output reg 				tx_data_req
);

//数据缓存和数据发送控制
localparam ARRAY_SIZE = 6;
reg [7:0] rx_data_shift[0:ARRAY_SIZE-1]; //移位寄存器

always @(posedge clk) begin
    if(!rst_n)
        rx_data_shift[0] <= 8'h00;	
	else if(rx_data_valid) 
        rx_data_shift[0] <= rx_data;
	else rx_data_shift[0] <= rx_data_shift[0];	
end

genvar i;
generate for(i=1;i<ARRAY_SIZE;i=i+1) begin: loop_rx_arr
	always @(posedge clk) begin
		if(!rst_n) 
			rx_data_shift[i] <= 8'h00;	
		else if(rx_data_valid) 
			rx_data_shift[i] <= rx_data_shift[i-1]; 
		else rx_data_shift[i] <= rx_data_shift[i];			
	end
end
endgenerate

//协议解析
localparam EE_WR_HEADER = 16'hEEC0;
localparam EE_RD_HEADER = 16'hEEC1;

//EE_WRITE_CMD
// {EE_WR_HEADER[15:0],wr_byte_addr[23:0],wr_byte_num[7:0],{n bytes of data}}

//EE_READ_CMD
// {EE_RD_HEADER[15:0],rd_byte_addr[23:0],rd_byte_num[7:0]}

wire ee_rd_req = ({rx_data_shift[5],rx_data_shift[4]} == EE_RD_HEADER);

always @(posedge clk) 
	if(ee_rd_req) rd_byte_addr <= {rx_data_shift[3],rx_data_shift[2],rx_data_shift[1]};

always @(posedge clk) 
	if(ee_rd_req) rd_byte_num_sub1 = rx_data_shift[0]-1;  

reg ee_rd_req_d0;
reg ee_rd_req_d1;
always @(posedge clk) ee_rd_req_d0 <= ee_rd_req;
always @(posedge clk) ee_rd_req_d1 <= ee_rd_req_d0;
wire ee_rd_req_rise = ~ee_rd_req_d1 & ee_rd_req_d0;

reg rd_byte_busy_d0;
reg rd_byte_busy_d1;
always @(posedge clk) rd_byte_busy_d0 <= rd_byte_busy;
always @(posedge clk) rd_byte_busy_d1 <= rd_byte_busy_d0;
wire rd_byte_busy_rise = ~rd_byte_busy_d1 & rd_byte_busy_d0;
wire rd_byte_busy_fall = rd_byte_busy_d1 & ~rd_byte_busy_d0;

reg tx_data_ready_d0;
reg tx_data_ready_d1;
always @(posedge clk) tx_data_ready_d0 <= tx_data_ready;
always @(posedge clk) tx_data_ready_d1 <= tx_data_ready_d0;
wire tx_data_ready_rise = ~tx_data_ready_d1 & tx_data_ready_d0;
wire tx_data_ready_fall = tx_data_ready_d1 & ~tx_data_ready_d0;

wire tx_bytes_done;

//---------------------------------------
//tx to PC
localparam S_IDLE  		= 0;
localparam S_READ_REQ   = 1;
localparam S_READ_WAIT  = 2;
localparam S_TX_REQ     = 3;
localparam S_TX_WAIT    = 4;
localparam S_TX_DONE    = 5;

reg [2:0] state;

always @(posedge clk) begin
	if(~rst_n) state <= S_IDLE;
	else begin
	case(state)
	S_IDLE: begin
		if(ee_rd_req_rise) state <= S_READ_REQ;	
		else state <= S_IDLE;
	end

	S_READ_REQ: begin
		if(rd_byte_busy_rise) state <= S_READ_WAIT;
		else state <= S_READ_REQ;
	end

	S_READ_WAIT: begin
		if(rd_byte_busy_fall) state <= S_TX_REQ;
		else state <= S_READ_WAIT;
	end

    S_TX_REQ: begin
        if(tx_data_ready_fall) state <= S_TX_WAIT;
        else state <= S_TX_REQ;
    end

    S_TX_WAIT: begin
        if(tx_data_ready_rise) state <= S_TX_DONE;
        else state <= S_TX_WAIT;
    end

    S_TX_DONE: begin
        if(tx_bytes_done) state <= S_IDLE;
        else state <= S_TX_REQ;
    end

	default: state <= S_IDLE;
	endcase
	end
end

//--------------------------------------------------
always @(*) rd_byte_req = (state == S_READ_REQ);

//数据缓存和数据发送控制
reg [7:0] tx_data_shift[0:MAX_BYTE_NUM-1]; //移位寄存器

always @(posedge clk) begin
    if(!rst_n) 
        tx_data_shift[0] <= 8'h00;	
	else if(rd_byte_valid) 
        tx_data_shift[0] <= rd_byte_data;	
end

generate for(i=1;i<MAX_BYTE_NUM;i=i+1) begin: loop_tx_arr
	always @(posedge clk) begin
		if(!rst_n) 
			tx_data_shift[i] <= 8'h00;	
		else if(rd_byte_valid) 
			tx_data_shift[i] <= tx_data_shift[i-1]; 
	end
end
endgenerate

//wire tx_bytes_done
reg [7:0] tx_byte_cnt;
always @(posedge clk) begin
	if(~rst_n) tx_byte_cnt <= 0;
	else if(state == S_IDLE) tx_byte_cnt <= 0;
	else if(state == S_TX_DONE) tx_byte_cnt <= tx_byte_cnt + 1;
	else tx_byte_cnt <= tx_byte_cnt;
end

assign tx_bytes_done = (tx_byte_cnt == rd_byte_num_sub1);

//output reg [7:0] 		tx_data,
//output reg 		    tx_data_req
always @(*) tx_data_req <= (state == S_TX_REQ);
always @(*) tx_data <= tx_data_shift[rd_byte_num_sub1-tx_byte_cnt]; //MSB first

endmodule