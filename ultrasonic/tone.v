module tone #(
	parameter  CLK_FREQ = 50_000_000//MHz
)(
	input clk,   
	input rst_n,  
	input [4:0] tone_index,
	output reg tone_out  
);

localparam  ToneL_0		= 00; //special, not valid
localparam  ToneL_1		= 01;
localparam  ToneL_2	 	= 02;
localparam  ToneL_3		= 03;
localparam  ToneL_4		= 04;
localparam  ToneL_5	 	= 05;
localparam  ToneL_6		= 06;
localparam  ToneL_7		= 07;
localparam  ToneM_1   	= 08; 
localparam  ToneM_2 	= 09;
localparam  ToneM_3 	= 10;
localparam  ToneM_4  	= 11;  
localparam  ToneM_5 	= 12;
localparam  ToneM_6  	= 13;
localparam  ToneM_7 	= 14;
localparam  ToneH_1    	= 15;
localparam  ToneH_2    	= 16;
localparam  ToneH_3    	= 17;
localparam  ToneH_4    	= 18;
localparam  ToneH_5    	= 19;
localparam  ToneH_6    	= 20;
localparam  ToneH_7    	= 21;

localparam ONE_SECOND = CLK_FREQ;
localparam ONE_HZ_CNT = ONE_SECOND / 2; 

//基于不同音符的分频计数值
//L：低音，M:中音，H:高音
//REF: ./_mysrc/doc/低中高音下不同音符的频率对应表.png
localparam  ToneL_1_CNT		= ONE_HZ_CNT / 261.6; 
localparam  ToneL_2_CNT		= ONE_HZ_CNT / 293.7; 
localparam  ToneL_3_CNT		= ONE_HZ_CNT / 329.6; 
localparam  ToneL_4_CNT		= ONE_HZ_CNT / 349.2; 
localparam  ToneL_5_CNT		= ONE_HZ_CNT / 392.0; 
localparam  ToneL_6_CNT		= ONE_HZ_CNT / 440.0; 
localparam  ToneL_7_CNT		= ONE_HZ_CNT / 493.9; 
localparam  ToneM_1_CNT   	= ONE_HZ_CNT / 523.3;  
localparam  ToneM_2_CNT 	= ONE_HZ_CNT / 587.3; 
localparam  ToneM_3_CNT 	= ONE_HZ_CNT / 659.3; 
localparam  ToneM_4_CNT  	= ONE_HZ_CNT / 698.5;   
localparam  ToneM_5_CNT 	= ONE_HZ_CNT / 784.0; 
localparam  ToneM_6_CNT  	= ONE_HZ_CNT / 880.0; 
localparam  ToneM_7_CNT 	= ONE_HZ_CNT / 987.8; 
localparam  ToneH_1_CNT    	= ONE_HZ_CNT / 1046.5; 
localparam  ToneH_2_CNT    	= ONE_HZ_CNT / 1174.7; 
localparam  ToneH_3_CNT    	= ONE_HZ_CNT / 1318.5; 
localparam  ToneH_4_CNT    	= ONE_HZ_CNT / 1396.9; 
localparam  ToneH_5_CNT    	= ONE_HZ_CNT / 1568.0; 
localparam  ToneH_6_CNT    	= ONE_HZ_CNT / 1760.0; 
localparam  ToneH_7_CNT    	= ONE_HZ_CNT / 1975.5; 

//-----------------------------------
//array of vectors
reg[31:0] tone_cnt;

always @(posedge clk) begin
    case(tone_index)
	ToneL_1: tone_cnt <= ToneL_1_CNT;
	ToneL_2: tone_cnt <= ToneL_2_CNT;
	ToneL_3: tone_cnt <= ToneL_3_CNT;
	ToneL_4: tone_cnt <= ToneL_4_CNT;
	ToneL_5: tone_cnt <= ToneL_5_CNT;
	ToneL_6: tone_cnt <= ToneL_6_CNT;
	ToneL_7: tone_cnt <= ToneL_7_CNT;
	ToneM_1: tone_cnt <= ToneM_1_CNT;
	ToneM_2: tone_cnt <= ToneM_2_CNT;
	ToneM_3: tone_cnt <= ToneM_3_CNT;
	ToneM_4: tone_cnt <= ToneM_4_CNT;	
	ToneM_5: tone_cnt <= ToneM_5_CNT;
	ToneM_6: tone_cnt <= ToneM_6_CNT;
	ToneM_7: tone_cnt <= ToneM_7_CNT;
	ToneH_1: tone_cnt <= ToneH_1_CNT;
	ToneH_2: tone_cnt <= ToneH_2_CNT;	
	ToneH_3: tone_cnt <= ToneH_3_CNT;
	ToneH_4: tone_cnt <= ToneH_4_CNT;
	ToneH_5: tone_cnt <= ToneH_5_CNT;
	ToneH_6: tone_cnt <= ToneH_6_CNT;
	ToneH_7: tone_cnt <= ToneH_7_CNT;		

    default: tone_cnt <= ONE_HZ_CNT;		//1Hz
    endcase									
end

reg [31:0] cnt;	 

always @(posedge clk) begin
	if(~rst_n) cnt <= 0;    
	else if (cnt_done) cnt <= 0;
	else cnt <= cnt + 1; 
end

wire cnt_done = (cnt > tone_cnt-1); 

always @(posedge clk) begin
	if(~rst_n) tone_out <= 0;    
	else if (cnt_done) tone_out <= ~tone_out;    
	else tone_out <= tone_out;
end

endmodule

