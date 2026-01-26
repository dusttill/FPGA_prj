//数码管驱动模块
module digi_tube_drv#(
    CLK_FREQ = 50_000_000
)(
    input  clk,   	 
    input  rst_n,	 

    input wire [3:0] d_0,//个位
    input wire [3:0] d_1,	
    input wire [3:0] d_2,
    input wire [3:0] d_3,
	 
    output reg [7:0] seg_sel,   //段选
    output reg [3:0] bit_sel	//位选
);

//根据视觉暂留效应和余晖效应，数码管的刷新频率最好控制在500-1000Hz内
reg [15:0] div_cnt;//分频计数器 50*10^6/2^16 = 762Hz
always @(posedge clk) begin
    if(!rst_n)
        div_cnt = 0;
    else div_cnt <= div_cnt + 1;
end

wire div_clk = div_cnt[13];//bit[N] 的频率 = 系统时钟 / 2^(N+1)，N为bit[N]的位数
//50,000,000 / 2^(13+1) = 3571Hz <-----> 892Hz/位

always @(posedge div_clk) begin
	if(~rst_n) bit_sel <= 4'b1110;
	else if(bit_sel == 4'b0000 || bit_sel == 4'b1111) bit_sel <= 4'b1110;
	else bit_sel <= {bit_sel[2:0],bit_sel[3]};
end

reg [3:0] disp_num;//要显示的数字


//位选控制
always @(posedge clk) begin
	case(bit_sel)
	4'b1110 : disp_num = d_0;
	4'b1101 : disp_num = d_1;
	4'b1011 : disp_num = d_2;
	4'b0111 : disp_num = d_3;
	default : disp_num = 10; //Error
	endcase
end


//段选控制
always @(posedge clk) begin
	case(disp_num) 
		0 : seg_sel <= 8'b11000000;    
		1 : seg_sel <= 8'b11111001;    
		2 : seg_sel <= 8'b10100100;    
		3 : seg_sel <= 8'b10110000;  //3  
		4 : seg_sel <= 8'b10011001;    
		5 : seg_sel <= 8'b10010010;    
		6 : seg_sel <= 8'b10000010;    
		7 : seg_sel <= 8'b11111000;    
		8 : seg_sel <= 8'b10000000;    
		9 : seg_sel <= 8'b10010000;       
		default: seg_sel <= 8'hFF;  //ALL OFF
	endcase
end

endmodule
