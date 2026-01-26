module beat_ctrl
#(
    parameter CNT_250MS = 12_500_000, //  八分音符250ms/20ns = 12_500_000
    parameter CNT_125MS = CNT_250MS/2 //  十六分音符125ms/20ns = 6_250_000
)(
  input clk,
  input rst,

  //output reg [5:0] beat_cnt1//第一首歌节拍计数器，每250ms加1
  output reg [7:0] beat_cnt2//第二首歌节拍计数器，每125ms加1
); 
reg     [25:0]   count;
wire             flag_250ms;
wire             flag_125ms;

//基础时钟计数器，实现250ms的计时
/*
always@(posedge clk)begin
    if(rst == 1'b0)
        count <= 26'd0;
    else if(count < CNT_250MS - 1)
        count <= count + 1'b1;
    else
        count <= 26'd0; 
end

assign flag_250ms = (count == CNT_250MS - 1)? 1'b1 : 1'b0;

// 节拍计数器，由250ms标志位触发计数
always@(posedge clk)begin
    if(rst == 1'b0)
        beat_cnt1 <= 6'd0;
    else if(flag_250ms == 1'b1)
        beat_cnt1 <= beat_cnt1 + 1'b1;
    else
        beat_cnt1 <= beat_cnt1;
end
*/



//基础时钟计数器，实现125ms的计时
always@(posedge clk)begin
    if(rst == 1'b0)
        count <= 26'd0;
    else if(count < CNT_125MS - 1)
        count <= count + 1'b1;
    else
        count <= 26'd0; 
end


assign flag_125ms = (count == CNT_125MS - 1)? 1'b1 : 1'b0;

// 节拍计数器，由250ms标志位触发计数
always@(posedge clk)begin
    if(rst == 1'b0)
        beat_cnt2 <= 6'd0;
    else if(flag_125ms == 1'b1)
        beat_cnt2 <= beat_cnt2 + 1'b1;
    else
        beat_cnt2 <= beat_cnt2;
end

endmodule