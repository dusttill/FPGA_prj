
`timescale 1ns/1ps
module uart2eeprom_control  #(
    parameter MAX_BYTE_NUM = 64
)(
	input			clk, 
	input			rst_n,
	
	//uart interface
    input [7:0]    rx_data,          //received byte data
    input          rx_data_valid,    //received byte data is valid

    //ee iic interface
    output reg          				wr_byte_req,
    output reg [7:0] 					wr_byte_num_sub1,
    output reg [23:0]   				wr_byte_addr,    
    output reg [7:0] 					wr_byte_data,	
    input  wire        					wr_byte_rden,
    input  wire      					wr_byte_busy
);

//数据缓存和数据发送控制
localparam ARRAY_SIZE = MAX_BYTE_NUM+6;
reg [7:0] rx_data_shift[0:ARRAY_SIZE-1]; //移位寄存器

always @(posedge clk) begin
    if(!rst_n)
        rx_data_shift[0] <= 8'h00;	
	else if(rx_data_valid) 
        rx_data_shift[0] <= rx_data;
	else rx_data_shift[0] <= rx_data_shift[0];	
end

genvar i; //variable 变量
generate for(i=1;i<ARRAY_SIZE;i=i+1) begin 
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

wire ee_wr_header_found = ({rx_data_shift[5],rx_data_shift[4]} == EE_WR_HEADER);

always @(posedge clk) 
	if(ee_wr_header_found) wr_byte_addr <= {rx_data_shift[3],rx_data_shift[2],rx_data_shift[1]};

always @(posedge clk) 
	if(ee_wr_header_found) wr_byte_num_sub1 = rx_data_shift[0]-1;  

//eeprom write data frame receive done
wire ee_wr_req = ({rx_data_shift[5+wr_byte_num_sub1+1],rx_data_shift[4+wr_byte_num_sub1+1]} == EE_WR_HEADER);

reg ee_wr_req_d0;
reg ee_wr_req_d1;
always @(posedge clk) ee_wr_req_d0 <= ee_wr_req;
always @(posedge clk) ee_wr_req_d1 <= ee_wr_req_d0;
wire ee_wr_req_rise = ~ee_wr_req_d1 & ee_wr_req_d0;

reg wr_byte_busy_d0;
reg wr_byte_busy_d1;
always @(posedge clk) wr_byte_busy_d0 <= wr_byte_busy;
always @(posedge clk) wr_byte_busy_d1 <= wr_byte_busy_d0;
wire wr_byte_busy_rise = ~wr_byte_busy_d1 & wr_byte_busy_d0;
wire wr_byte_busy_fall = wr_byte_busy_d1 & ~wr_byte_busy_d0;

localparam S_IDLE  		= 0;
localparam S_WRITE_REQ  = 1;
localparam S_WRITE_WAIT = 2;

reg [1:0] state;

always @(posedge clk) begin
	if(~rst_n) state <= S_IDLE;
	else begin
	case(state)
	S_IDLE: begin
		if(ee_wr_req_rise) state <= S_WRITE_REQ;	
		else state <= S_IDLE;
	end

	S_WRITE_REQ: begin
        if(wr_byte_busy_rise) state <= S_WRITE_WAIT;
		else state <= S_WRITE_REQ;
	end

	S_WRITE_WAIT: begin
		if(wr_byte_busy_fall) state <= S_IDLE;
		else state <= S_WRITE_WAIT;
	end

	default: state <= S_IDLE;
	endcase
	end
end

always @(*) wr_byte_req = (state == S_WRITE_REQ);

reg [7:0] wr_byte_cnt;
always @(posedge clk) begin
	if(~rst_n) wr_byte_cnt <= 0;
	else if(state == S_IDLE) wr_byte_cnt <= 0;
	else if(wr_byte_rden) wr_byte_cnt <= wr_byte_cnt + 1;
	else wr_byte_cnt <= wr_byte_cnt;
end

always @(posedge clk) wr_byte_data <= rx_data_shift[wr_byte_num_sub1-wr_byte_cnt];

endmodule