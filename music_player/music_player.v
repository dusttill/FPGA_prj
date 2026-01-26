module music_player
(
    input wire clk,
    input wire rst,

    output beep
); 

//wire [5:0] beat_cnt1;
wire [5:0] beat_cnt2;
wire [4:0] music;
wire [31:0] div;

beat_ctrl beat_ctrl_inst
(
    .clk(clk),
    .rst(rst),
    .beat_cnt2(beat_cnt2)
);
/*
music_mem music_mem_inst
(
    .clk(clk),
    .rst(rst),
    .beat_cnt1(beat_cnt1),
    .music(music)
);
*/

music_we_dont_talk music_we_dont_talk_inst
(
    .clk(clk),
    .rst(rst),
    .beat_cnt2(beat_cnt2),
    .music(music)
);

freq_div freq_div_inst
(
    .clk(clk),
    .rst(rst),
    .music(music),
    .div(div)
);

beep_drive beep_drive_inst
(
    .clk(clk),
    .rst(rst),
    .div(div),
    .beep(beep)
);

endmodule