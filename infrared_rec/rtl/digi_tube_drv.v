module digi_tube_drv #(
	parameter CLK_FREQ 	= 50_000_000 	//MHz
)(
    input  clk,   	 
    input  rst_n,	 

    input wire [3:0] d0,
    input wire [3:0] d1,	
    input wire [3:0] d2,
    input wire [3:0] d3,
	 
    output wire [7:0] tube_seg,
    output wire [3:0] tube_bit	
);

localparam ONE_MSECOND = CLK_FREQ / 1000;

reg [15:0] cnt;
wire time_on = (cnt == ONE_MSECOND-1);
always @(posedge clk) begin
   if(~rst_n) cnt <= 0;
   else if(time_on) cnt <= 0;
   else cnt <= cnt + 1;
end

//--------------Display----------------
//1.select tube bit, active low
reg [3:0] bit_sel;
always @(posedge clk) begin
	if(~rst_n) bit_sel <= 4'b1110;
	else if(time_on) bit_sel <= {bit_sel[2:0],bit_sel[3]};
	else bit_sel <= bit_sel;
end

//2. set current segment data to display
reg [3:0] hex_num;
always @(*) begin
	case(bit_sel)
	4'b1110 : hex_num = d0;
	4'b1101 : hex_num = d1;
	4'b1011 : hex_num = d2;
	4'b0111 : hex_num = d3;
	default : hex_num = d0;
	endcase
end

//3. encode 7seg led for hex data 
//   for led active low
reg [7:0] seg_out;
always @(posedge clk) begin
	case(hex_num) 
			4'h0: seg_out <= 8'b11000000; //0  
			4'h1: seg_out <= 8'b11111001; //1
			4'h2: seg_out <= 8'b10100100; //2
			4'h3: seg_out <= 8'b10110000; //3
			4'h4: seg_out <= 8'b10011001; //4
			4'h5: seg_out <= 8'b10010010; //5
			4'h6: seg_out <= 8'b10000010; //6
			4'h7: seg_out <= 8'b11111000; //7
			4'h8: seg_out <= 8'b10000000; //8
			4'h9: seg_out <= 8'b10010000; //9
			4'ha: seg_out <= 8'b10001000; //A
			4'hb: seg_out <= 8'b10000011; //b
			4'hc: seg_out <= 8'b11000110; //C
			4'hd: seg_out <= 8'b10100001; //d
			4'he: seg_out <= 8'b10000110; //E
			4'hf: seg_out <= 8'b10001110; //F
			default : seg_out <= 8'b11111111;
	endcase
end

assign tube_seg = seg_out;
assign tube_bit = bit_sel;

endmodule