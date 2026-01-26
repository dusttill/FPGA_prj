/*
加3移位法
二进制数值转十进制BCD码
ref: https://gitcode.csdn.net/65e83e9e1a836825ed78b4e3.html?dp_token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTY2NDQzOSwiZXhwIjoxNzE3MTQzNzEyLCJpYXQiOjE3MTY1Mzg5MTIsInVzZXJuYW1lIjoicXFfMjc3MTk3OTEifQ.TycBADbuIobydkbbxybt08JEeVp_tX_tI5pYSpEr-mo
*/
module binary2bcd (
	input	[13:0]	bin_in, //max: 9999
	output	[15:0]	bcd_out
);
	
reg [3:0] ones;
reg [3:0] tens;
reg [3:0] hundreds;
reg [3:0] thousands;

integer i;
 
always @(bin_in) begin
	ones 		= 4'd0;
	tens 		= 4'd0;
	hundreds 	= 4'd0;
	thousands	= 4'b0;
	
	for(i = 13; i >= 0; i = i - 1) begin
		if (ones >= 4'd5) 		ones = ones + 4'd3;
		if (tens >= 4'd5) 		tens = tens + 4'd3;
		if (hundreds >= 4'd5)	hundreds = hundreds + 4'd3;
		if (thousands >= 4'd5)	thousands = thousands + 4'd3;
	
		thousands = {thousands[2:0],hundreds[3]};
		hundreds = {hundreds[2:0],tens[3]};
		tens	 = {tens[2:0],ones[3]};
		ones	 = {ones[2:0],bin_in[i]};	
	end
end	

assign bcd_out = {thousands,hundreds, tens, ones};

endmodule