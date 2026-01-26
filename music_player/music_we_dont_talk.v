module music_we_dont_talk(
    input wire clk,
    input wire rst,
    input wire [7:0] beat_cnt2,//192个音符

    output reg [4:0] music
);
//低音1   2   3   4   5   6   7
//中音8   9   10  11  12  13  14 
//高音15  16  17  18  19  20  21

//音乐数据ROM：存储歌曲的音符序列
always@(posedge clk)begin
    if(rst == 1'b0)
        music <= 5'd0;
    else
        case(beat_cnt2)
            6'd0   :   music <= 5'd0;
            6'd1   :   music <= 5'd0;
            6'd2   :   music <= 5'd0;
            6'd3   :   music <= 5'd0;
            6'd4   :   music <= 5'd0;
            6'd5   :   music <= 5'd0;
            6'd6   :   music <= 5'd0;
            6'd7   :   music <= 5'd0;
            6'd8   :   music <= 5'd16;
            6'd9   :   music <= 5'd17;
            6'd10  :   music <= 5'd17;
            6'd11  :   music <= 5'd17;
            6'd12  :   music <= 5'd0;
            6'd13  :   music <= 5'd0;
            6'd14  :   music <= 5'd0;
            6'd15  :   music <= 5'd0;

            6'd16  :   music <= 5'd0;
            6'd17  :   music <= 5'd0;
            6'd18  :   music <= 5'd0;
            6'd19  :   music <= 5'd0;
            6'd20  :   music <= 5'd0;
            6'd21  :   music <= 5'd0;
            6'd22  :   music <= 5'd0;
            6'd23  :   music <= 5'd0;
            6'd24  :   music <= 5'd0;
            6'd25  :   music <= 5'd17;
            6'd26  :   music <= 5'd17;
            6'd27  :   music <= 5'd17;
            6'd28  :   music <= 5'd17;
            6'd29  :   music <= 5'd16;
            6'd30  :   music <= 5'd15;
            6'd31  :   music <= 5'd13;

            6'd32  :   music <= 5'd13;
            6'd33  :   music <= 5'd13;
            6'd34  :   music <= 5'd13;
            6'd35  :   music <= 5'd13;
            6'd36  :   music <= 5'd13;
            6'd37  :   music <= 5'd14;
            6'd38  :   music <= 5'd14;
            6'd39  :   music <= 5'd14;
            6'd40  :   music <= 5'd15;
            6'd41  :   music <= 5'd15;
            6'd42  :   music <= 5'd15;
            6'd43  :   music <= 5'd15;
            6'd44  :   music <= 5'd19;
            6'd45  :   music <= 5'd19;
            6'd46  :   music <= 5'd18;
            6'd47  :   music <= 5'd18;

            6'd48  :   music <= 5'd17;
            6'd49  :   music <= 5'd17;
            6'd50  :   music <= 5'd17;
            6'd51  :   music <= 5'd17;
            6'd52  :   music <= 5'd16;
            6'd53  :   music <= 5'd16;
            6'd54  :   music <= 5'd17;
            6'd55  :   music <= 5'd17;
            6'd56  :   music <= 5'd16;
            6'd57  :   music <= 5'd17;
            6'd58  :   music <= 5'd17;
            6'd59  :   music <= 5'd16;
            6'd60  :   music <= 5'd17;
            6'd61  :   music <= 5'd16;
            6'd62  :   music <= 5'd15;
            6'd63  :   music <= 5'd13;

            6'd64   :   music <= 5'd13;
            6'd65   :   music <= 5'd13;
            6'd66   :   music <= 5'd0;
            6'd67   :   music <= 5'd0;
            6'd68   :   music <= 5'd0;
            6'd69   :   music <= 5'd0;
            6'd70   :   music <= 5'd0;
            6'd71   :   music <= 5'd0;
            6'd72   :   music <= 5'd16;
            6'd73   :   music <= 5'd17;
            6'd74   :   music <= 5'd17;
            6'd75   :   music <= 5'd17;
            6'd76   :   music <= 5'd17;
            6'd77   :   music <= 5'd16;
            6'd78   :   music <= 5'd15;
            6'd79   :   music <= 5'd14;

            6'd80  :   music <= 5'd14;
            6'd81  :   music <= 5'd14;
            6'd82  :   music <= 5'd16;
            6'd83  :   music <= 5'd16;
            6'd84  :   music <= 5'd16;
            6'd85  :   music <= 5'd16;
            6'd86  :   music <= 5'd17;
            6'd87  :   music <= 5'd17;
            6'd88  :   music <= 5'd16;
            6'd89  :   music <= 5'd17;
            6'd90  :   music <= 5'd17;
            6'd91  :   music <= 5'd16;
            6'd92  :   music <= 5'd17;
            6'd93  :   music <= 5'd16;
            6'd94  :   music <= 5'd15;
            6'd95  :   music <= 5'd13;

            6'd96  :   music <= 5'd13;
            6'd97  :   music <= 5'd13;
            6'd98  :   music <= 5'd13;
            6'd99  :   music <= 5'd13;
            6'd100  :   music <= 5'd13;
            6'd101  :   music <= 5'd14;
            6'd102  :   music <= 5'd14;
            6'd103  :   music <= 5'd14;
            6'd104  :   music <= 5'd15;
            6'd105  :   music <= 5'd15;
            6'd106  :   music <= 5'd15;
            6'd107  :   music <= 5'd15;
            6'd108  :   music <= 5'd20;
            6'd109  :   music <= 5'd20;
            6'd110  :   music <= 5'd19;
            6'd111  :   music <= 5'd19;

            6'd112  :   music <= 5'd17;
            6'd113  :   music <= 5'd17;
            6'd114  :   music <= 5'd17;
            6'd115  :   music <= 5'd17;
            6'd116  :   music <= 5'd0;
            6'd117  :   music <= 5'd0;
            6'd118  :   music <= 5'd0;
            6'd119  :   music <= 5'd18;
            6'd120  :   music <= 5'd18;
            6'd121  :   music <= 5'd17;
            6'd122  :   music <= 5'd17;
            6'd123  :   music <= 5'd16;
            6'd124  :   music <= 5'd16;
            6'd125  :   music <= 5'd16;
            6'd126  :   music <= 5'd15;
            6'd127  :   music <= 5'd15;

            6'd128   :   music <= 5'd16;
            6'd129   :   music <= 5'd16;
            6'd130   :   music <= 5'd16;
            6'd131   :   music <= 5'd16;
            6'd132   :   music <= 5'd16;
            6'd133   :   music <= 5'd16;
            6'd134   :   music <= 5'd17;
            6'd135   :   music <= 5'd17;
            6'd136   :   music <= 5'd17;
            6'd137   :   music <= 5'd17;
            6'd138   :   music <= 5'd10;
            6'd139   :   music <= 5'd10;
            6'd140   :   music <= 5'd0;
            6'd141   :   music <= 5'd0;
            6'd142   :   music <= 5'd0;
            6'd143   :   music <= 5'd0;

            6'd144  :   music <= 5'd16;
            6'd145  :   music <= 5'd16;
            6'd146  :   music <= 5'd16;
            6'd147  :   music <= 5'd16;
            6'd148  :   music <= 5'd16;
            6'd149  :   music <= 5'd16;
            6'd150  :   music <= 5'd17;
            6'd151  :   music <= 5'd17;
            6'd152  :   music <= 5'd17;
            6'd153  :   music <= 5'd17;
            6'd154  :   music <= 5'd16;
            6'd155  :   music <= 5'd16;
            6'd156  :   music <= 5'd0;
            6'd157  :   music <= 5'd0;
            6'd158  :   music <= 5'd0;
            6'd159  :   music <= 5'd12;

            6'd160  :   music <= 5'd16;
            6'd161  :   music <= 5'd16;
            6'd162  :   music <= 5'd16;
            6'd163  :   music <= 5'd16;
            6'd164  :   music <= 5'd16;
            6'd165  :   music <= 5'd17;
            6'd166  :   music <= 5'd17;
            6'd167  :   music <= 5'd16;
            6'd168  :   music <= 5'd16;
            6'd169  :   music <= 5'd15;
            6'd170  :   music <= 5'd15;
            6'd171  :   music <= 5'd15;
            6'd172  :   music <= 5'd13;
            6'd173  :   music <= 5'd15;
            6'd174  :   music <= 5'd16;
            6'd175  :   music <= 5'd16;

            6'd176  :   music <= 5'd16;
            6'd177  :   music <= 5'd16;
            6'd178  :   music <= 5'd16;
            6'd179  :   music <= 5'd16;
            6'd180  :   music <= 5'd0;
            6'd181  :   music <= 5'd0;
            6'd182  :   music <= 5'd0;
            6'd183  :   music <= 5'd11;
            6'd184  :   music <= 5'd18;
            6'd185  :   music <= 5'd18;
            6'd186  :   music <= 5'd17;
            6'd187  :   music <= 5'd17;
            6'd188  :   music <= 5'd16;
            6'd189  :   music <= 5'd16;
            6'd190  :   music <= 5'd15;
            6'd191  :   music <= 5'd15;
            default:   music <= 5'd0;
        endcase
end
endmodule