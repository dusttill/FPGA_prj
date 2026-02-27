
/*-----------------------------------------
EEPROM DEVICE ADDRESS
The device select code consists of a 4-bit device type identifier, 
and a 3-bit Chip Enable "Address" (E2, E1, E0). 
for my board,E2E1E0 = 3'b000;
To address the memory array, the 4-bit device type identifier is 1010b.

M24C32: 32 Kbits,4KBytes
//Device Addr = Device type identifier + Device Enable Pins

Each data byte in the memory has a 16-bit (two byte wide) address. 
The Most Significant Byte (Table 4) is sent first, 
followed by the Least Significant Byte (Table 5). 
Bits b15 to b0 form the address of the byte in memory.

The Page Write mode allows up to 32 bytes (for the M24C32 and M24C64) 
or 64 bytes (for the M24128) to be written in a single Write cycle, 
provided that they are all located in the same ’row’ in the memory: 
that is, the most significant memory address bits (b13-b6 for 
M24128, b12-b5 for M24C64, and b11-b5 for M24C32) are the same. 
If more bytes are sent than will fit up to the end of the row, 
a condition known as ‘roll-over’ occurs. 
This should be avoided, as data starts to become overwritten 
in an implementation dependent way
*/

`timescale 1ns/1ps
module eeprom_iic_drv #(
	parameter SYS_CLK_FRE   = 50, //MHz
    parameter IIC_CLK_FRE   = 400000, //Hz
    parameter REG_ADDR_SIZE = 2    //1~3
)(
	input			clk, 
	input			rst_n,
	
	//i2c external interface
	output reg		iic_scl, 
	input  wire 	iic_sda_in,   
	output  reg 	iic_sda_out,  
	output  reg 	iic_sda_out_en,  

	//inner control interface
    input [6:0]                 dev_addr,

	input           	        wr_byte_req,
    input [23:0]                wr_byte_addr,    
    input [5:0] 		        wr_byte_num_sub1,  
	input [7:0] 	            wr_byte_data,
	output reg 	                wr_byte_rden,    	
	output reg 	                wr_byte_busy,

	input           	        rd_byte_req,
    input [23:0]                rd_byte_addr,
    input [5:0] 		        rd_byte_num_sub1,  
	output reg [8-1:0]          rd_byte_data,	
	output reg 	                rd_byte_valid,
    output reg	                rd_byte_busy
);


//1. generate IIC Clock
localparam IIC_CLK_CNT = (SYS_CLK_FRE*1000000) / (IIC_CLK_FRE);

reg [31:0] clk_cnt;
reg iic_clk;

always@(posedge clk) begin
	if(~rst_n) clk_cnt <= 0;
    else if(clk_cnt == IIC_CLK_CNT-1) clk_cnt <= 0;
	else clk_cnt <= clk_cnt + 1'd1;
end

wire iic_clk_start  = (clk_cnt == 0);
wire iic_clk_mid    = (clk_cnt == IIC_CLK_CNT/2-1);
wire iic_clk_done   = (clk_cnt == IIC_CLK_CNT-1);

wire iic_clk_4_1    = (clk_cnt == IIC_CLK_CNT/4-1);
wire iic_clk_4_3    = (clk_cnt == IIC_CLK_CNT*3/4-1);

always@(posedge clk) begin
	if(~rst_n) iic_clk <= 1'b0;
	else if(iic_clk_4_1) iic_clk <= 1'b1;
    else if(iic_clk_4_3) iic_clk <= 1'b0;
    else iic_clk <= iic_clk;
end

reg [3:0] bit_cnt;
reg [7:0] byte_cnt;
reg op_reading;

wire iic_byte_done          = (iic_clk_done && bit_cnt == (9-1)); 
wire iic_wr_addr_done       = (iic_byte_done && byte_cnt == (REG_ADDR_SIZE-1)); 
wire iic_rd_bytes_done      = (iic_byte_done && byte_cnt == rd_byte_num_sub1); 
wire iic_wr_bytes_done      = (iic_byte_done && byte_cnt == wr_byte_num_sub1); 

//-------------------------------------------
localparam	S_IDLE		        = 0;
localparam	S_START		        = 1;
localparam	S_DEV_WADDR		    = 2;
localparam	S_REG_ADDR		    = 3;
localparam	S_WRITE_BYTE		= 4;
localparam	S_RESTART		    = 5;
localparam	S_DEV_RADDR		    = 6;
localparam	S_READ_BYTE		    = 7;
localparam	S_STOP              = 8;

reg [3:0] c_state;//current
reg [3:0] n_state;//next

always @(posedge clk) begin
    if(~rst_n) c_state <= S_IDLE;
    else c_state <= n_state;
end

always @(*) begin
    if(!rst_n) n_state = S_IDLE;
    else begin
        case(c_state)
        S_IDLE: begin
            if(iic_clk_done) begin
                if(wr_byte_req) n_state = S_START;      // set op_reading = 1'b0;
                else if(rd_byte_req) n_state = S_START; // set op_reading = 1'b1;
                else n_state = S_IDLE;
            end
            else n_state = S_IDLE;
        end

        S_START: 
            if(iic_clk_done) n_state = S_DEV_WADDR;
            else n_state = S_START;

        S_DEV_WADDR:   //write device addr
            if(iic_byte_done) n_state = S_REG_ADDR;  
            else n_state = S_DEV_WADDR;

        S_REG_ADDR:
            if(iic_wr_addr_done) begin
                if(op_reading == 1'b1) n_state = S_RESTART; //restart to read bytes
                else n_state = S_WRITE_BYTE;//to write bytes
            end
            else n_state = S_REG_ADDR;

        //write path
        S_WRITE_BYTE: 
            if(iic_wr_bytes_done) n_state = S_STOP;
            else n_state = S_WRITE_BYTE;

        //read path
        S_RESTART: 
            if(iic_clk_done) n_state = S_DEV_RADDR;
            else n_state = S_RESTART;

        S_DEV_RADDR: 
            if(iic_byte_done) n_state = S_READ_BYTE;
            else n_state = S_DEV_RADDR;

        S_READ_BYTE: 
            if(iic_rd_bytes_done) n_state = S_STOP;
            else n_state = S_READ_BYTE;

        S_STOP: 
            if(iic_clk_done) n_state = S_IDLE;
            else n_state = S_STOP;

        default: n_state = S_IDLE;
        endcase
    end
end

//-------------------------------------------------------
//reg op_reading
always @(posedge clk) begin
    if(c_state == S_IDLE && iic_clk_done) begin
        if(wr_byte_req) op_reading <= 1'b0;
        else if(rd_byte_req) op_reading <= 1'b1;
    end
    else op_reading <= op_reading;
end

//reg [7:0] bit_cnt;
always @(posedge clk) begin
    if(!rst_n) bit_cnt <= 0;
    else if(c_state != n_state) bit_cnt <= 0; //!!!
    else if(iic_clk_done) begin
        if(bit_cnt == 8) bit_cnt <= 0;
        else bit_cnt <= bit_cnt + 1;
    end
    else bit_cnt <= bit_cnt;
end

//reg [3:0] byte_cnt;
always @(posedge clk) begin
    if(!rst_n) byte_cnt <= 0;
    else if(c_state != n_state) byte_cnt <= 0;
    else if(iic_byte_done)
        byte_cnt <= byte_cnt + 1;
    else byte_cnt <= byte_cnt;
end

//----------------------------------------------------
wire [8:0] dev_wr_addr_z = {dev_addr[6:0],1'b0,1'b0}; //for write LSB = 1'b0;
wire [8:0] dev_rd_addr_z = {dev_addr[6:0],1'b1,1'b0}; //for read LSB = 1'b1;

//    input [23:0]                wr_byte_addr,
//    input [23:0]                rd_byte_addr,
wire [8:0] reg_addr_arr_z[0:2];
assign reg_addr_arr_z[2] = op_reading ? {rd_byte_addr[23:16],1'b0} : {wr_byte_addr[23:16],1'b0}; 
assign reg_addr_arr_z[1] = op_reading ? {rd_byte_addr[15:8],1'b0} :  {wr_byte_addr[15:8],1'b0};  
assign reg_addr_arr_z[0] = op_reading ? {rd_byte_addr[7:0],1'b0} :   {wr_byte_addr[7:0],1'b0};

//	input [8*8-1:0] wr_byte_data,
wire [9-1:0] rd_byte_z      =  {8'h00,1'b0}; //ACK
wire [9-1:0] rd_last_byte_z =  {8'h00,1'b1}; //NACK

wire [9-1:0] wr_byte_z      =  {wr_byte_data[7:0],1'b0};

//iic_clk
//output reg iic_scl
//reg sda_out
always@(posedge clk) begin
    if(~rst_n)  
        iic_scl <= 1'b1;
    else 
    case(c_state) 
    S_IDLE:   
        iic_scl <= 1'b1;

    S_START:   
        if(iic_clk_start) iic_scl <= 1'b1;
        else if(iic_clk_4_3) iic_scl <= 1'b0;
        else iic_scl <= iic_scl;

    //S_RESTART:   
    //    if(iic_clk_4_1) iic_scl <= 1'b1;
    //    else if(iic_clk_4_3) iic_scl <= 1'b0;
    //    else iic_scl <= iic_scl;

    S_STOP: 
        if(iic_clk_start) iic_scl <= 1'b0;
        else if(iic_clk_4_1) iic_scl <= 1'b1;
        else iic_scl <= iic_scl;

    default: iic_scl <= iic_clk;
    endcase
end

//iic_sda_out
always@(posedge clk) begin
    if(~rst_n) iic_sda_out <= 1'b1;
    else 
    case(c_state) 
    S_IDLE: iic_sda_out <= 1'b1;

    S_START: //fall of sda when scl is high
        if(iic_clk_start) iic_sda_out <= 1'b1;
        else if(iic_clk_4_1) iic_sda_out <= 1'b0;
        else iic_sda_out <= iic_sda_out;

    S_DEV_WADDR:        
        iic_sda_out <= dev_wr_addr_z[(9-1)-bit_cnt]; //MSB first

    S_REG_ADDR:         
        iic_sda_out <= reg_addr_arr_z[byte_cnt][(9-1)-bit_cnt];

    S_WRITE_BYTE:       
        iic_sda_out <= wr_byte_z[(9-1)-bit_cnt];

    S_RESTART: 
        if(iic_clk_start) iic_sda_out <= 1'b1;
        else if(iic_clk_mid) iic_sda_out <= 1'b0;
        else iic_sda_out <= iic_sda_out;

    S_DEV_RADDR:        
        iic_sda_out <= dev_rd_addr_z[(9-1)-bit_cnt]; //MSB first

    S_READ_BYTE:   
        if(byte_cnt == rd_byte_num_sub1) iic_sda_out <= rd_last_byte_z[(9-1)-bit_cnt]; //NACK
        else iic_sda_out <= rd_byte_z[(9-1)-bit_cnt]; //ACK

    S_STOP:     //rise of sda when scl is high
        if(iic_clk_start) iic_sda_out <= 1'b0;
        else if(iic_clk_4_3) iic_sda_out <= 1'b1;
    
    default: iic_sda_out <= 1'b1;
    endcase
end

always @(*) begin
    if(c_state == S_READ_BYTE) begin
        if(bit_cnt == 8) iic_sda_out_en = 1'b1;
        else iic_sda_out_en = 1'b0;
    end
    else begin
        if(bit_cnt == 8) iic_sda_out_en = 1'b0;
        else iic_sda_out_en = 1'b1;
    end
end

//output reg  wr_byte_rden,  
always @(posedge clk) begin
    if(c_state == S_WRITE_BYTE && iic_clk_mid && (bit_cnt == 8)) 
        wr_byte_rden <= 1'b1;
    else wr_byte_rden <= 1'b0;
end

reg [8:0] rd_bits_shift;
always @(posedge clk) begin
    if(!rst_n) rd_bits_shift <= 0;
    else if(c_state == S_READ_BYTE && iic_clk_mid)
        rd_bits_shift <= {rd_bits_shift[6:0],iic_sda_in};
    else rd_bits_shift <= rd_bits_shift;
end

//output reg [7:0] rd_byte_data,	
always @(posedge clk) begin
    if(!rst_n) rd_byte_data <= 8'h00;
    else if(c_state == S_READ_BYTE && iic_clk_mid && (bit_cnt == 8)) 
        rd_byte_data <= rd_bits_shift[7:0];
    else rd_byte_data <= rd_byte_data;
end

//output reg  rd_byte_valid	
always @(posedge clk) begin
    if(!rst_n) rd_byte_valid <= 1'b0;
    else if(c_state == S_READ_BYTE && iic_clk_mid && (bit_cnt == 8)) 
        rd_byte_valid <= 1'b1;
    else rd_byte_valid <= 1'b0;
end


wire ee_busy = (c_state != S_IDLE);

always@(*) rd_byte_busy = (ee_busy & op_reading);
always@(*) wr_byte_busy = (ee_busy & ~op_reading);

endmodule