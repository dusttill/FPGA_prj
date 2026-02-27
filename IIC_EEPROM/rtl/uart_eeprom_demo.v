
/*
	Receive Data from PC using UART and Write Data to EEPROM By IIC,
	Read data from EEPROM BY IIC and then send to PC use UART

localparam EE_WR_HEADER = 8'he1;
localparam EE_RD_HEADER = 8'he2;

wire ee_rd_req = (rx_data_shift[3] == EE_RD_HEADER);
always @(posedge clk) rd_byte_num <= rx_data_shift[2];
always @(posedge clk) rd_byte_addr <= {rx_data_shift[1], rx_data_shift[0]};  

parameter MAX_BYTE_NUM = 8;
wire ee_wr_req = (rx_data_shift[MAX_BYTE_NUM+3] == EE_WR_HEADER);
always @(*) wr_byte_num = rx_data_shift[MAX_BYTE_NUM+2];
always @(*) wr_byte_addr = {rx_data_shift[MAX_BYTE_NUM+1], rx_data_shift[MAX_BYTE_NUM+0]}; 
*/

`timescale 1ns/1ps
module uart_eeprom_demo #(
	parameter SYS_CLK_FRE = 50, //MHz
    parameter IIC_CLK_FRE = 400, //KHz
	parameter BAUD_RATE	= 115200,
	parameter MAX_BYTE_NUM = 64,

	//for EEPROM M24C32
    parameter [6:0] DEV_ADDR= {4'b1010, 3'b000},
    parameter REG_ADDR_SIZE = 2
)(
	input			clk, 
	input			rst_n,
	
	//i2c external interface
	output			ee_scl, 
	inout			ee_sda,

    output wire 	uart_txd,
    input wire 		uart_rxd	
);


//-----------------------------------------
//1. write path
//-----------------------------------------
wire [7:0]    			rx_data;          //received byte data
wire          			rx_data_valid;    //received byte data is valid

wire [7:0] 				tx_data;
wire 					tx_data_req;
wire					tx_data_ready;

wire           	        wr_byte_req;
wire [7:0] 		        wr_byte_num_sub1;
wire [23:0]            	wr_byte_addr;    
wire [7:0] 	            wr_byte_data;	
wire 	                wr_byte_rden;
wire                    wr_byte_busy;
wire 					wr_byte_error;

wire           	        rd_byte_req;
wire [7:0] 		        rd_byte_num_sub1;
wire [23:0]             rd_byte_addr;
wire [7:0] 	            rd_byte_data;	
wire 	                rd_byte_valid;
wire                    rd_byte_busy;

//receive data from host by uart 
uart_rx #(
	.BAUD_RATE(BAUD_RATE),
	.CLK_FRE(SYS_CLK_FRE)
)u0_uart_rx(		
	.clk(clk),	
	.rst_n(rst_n),
	.rx_pin(uart_rxd),
	.rx_data(rx_data),
	.rx_data_valid(rx_data_valid)
);


uart2eeprom_control #(
	.MAX_BYTE_NUM(MAX_BYTE_NUM)
)u_uart2eeprom_control(
	.clk        (clk   ), 
	.rst_n      (rst_n ),

	//uart interface
	.rx_data(rx_data),
	.rx_data_valid(rx_data_valid),

    //ee iic interface
	.wr_byte_req    	(wr_byte_req ),
	.wr_byte_num_sub1  	(wr_byte_num_sub1 ),
	.wr_byte_addr   	(wr_byte_addr),  
	.wr_byte_data   	(wr_byte_data),	
	.wr_byte_rden   	(wr_byte_rden),
	.wr_byte_busy   	(wr_byte_busy)
);

//write to eeprom using iic interface
wire 	iic_sda_in = ee_sda;   
wire 	iic_sda_out;  
wire 	iic_sda_out_en;  

//!!! 三态门高阻态必须在顶层模块直接连接inout引脚
assign ee_sda = iic_sda_out_en ? iic_sda_out : 1'bz;

eeprom_iic_drv #(
	.SYS_CLK_FRE(SYS_CLK_FRE),
    .IIC_CLK_FRE(IIC_CLK_FRE),
    .REG_ADDR_SIZE(REG_ADDR_SIZE)
)u_eeprom_iic_drv(
	.clk        (clk   ), 
	.rst_n      (rst_n ),
	
	//i2c external interface
	.iic_scl       		(ee_scl   		), 
	.iic_sda_in     	(iic_sda_in  	),       
	.iic_sda_out     	(iic_sda_out  	),  
	.iic_sda_out_en   	(iic_sda_out_en ),  

	//inner control interface
	.dev_addr		(DEV_ADDR),

	.wr_byte_req    	(wr_byte_req ),
	.wr_byte_num_sub1 	(wr_byte_num_sub1 ),
	.wr_byte_addr   	(wr_byte_addr),  
	.wr_byte_data   	(wr_byte_data),	
	.wr_byte_rden   	(wr_byte_rden),
	.wr_byte_busy   	(wr_byte_busy),

	.rd_byte_req    	(rd_byte_req  ),
	.rd_byte_num_sub1  	(rd_byte_num_sub1  ),
	.rd_byte_addr   	(rd_byte_addr ),  //reg addr  
	.rd_byte_data   	(rd_byte_data ),	
	.rd_byte_valid  	(rd_byte_valid),
    .rd_byte_busy   	(rd_byte_busy )	
);

//----------------------------------------------
//2. read path
// read data from eeprom and tx to pc by uart
//----------------------------------------------
eeprom2uart_control #(
	.MAX_BYTE_NUM(MAX_BYTE_NUM)
)u_eeprom2uart_control(
	.clk        (clk   ), 
	.rst_n      (rst_n ),

	//uart rx interface
	.rx_data(rx_data),
	.rx_data_valid(rx_data_valid),

    //ee iic interface
	.rd_byte_req    	(rd_byte_req  ),
	.rd_byte_num_sub1 	(rd_byte_num_sub1  ),
	.rd_byte_addr   	(rd_byte_addr ),  //reg addr  
	.rd_byte_data   	(rd_byte_data ),	
	.rd_byte_valid  	(rd_byte_valid),
    .rd_byte_busy   	(rd_byte_busy ),

	//uart tx interface
	.tx_data		(tx_data),  
	.tx_data_req	(tx_data_req), 
	.tx_data_ready	(tx_data_ready)		
);

uart_tx #(
	.BAUD_RATE(BAUD_RATE),
	.CLK_FRE(SYS_CLK_FRE)
)u1_uart_tx(		
	.clk(clk),	
	.rst_n(rst_n),
	.tx_data		(tx_data),  
	.tx_data_req	(tx_data_req), 
	.tx_data_ready	(tx_data_ready),
	.tx_pin			(uart_txd)
);


endmodule