module uart_tx #(
	parameter CLK_FRE = 50,      //clock frequency(Mhz)
	parameter BAUD_RATE = 115200 //serial baud rate
)
(
	input                        clk,              //clock input
	input                        rst_n,            //asynchronous reset input, low active 
	input[7:0]                   tx_data,          //data to send
	input                        tx_data_req,      //data to be sent is valid
	output reg                   tx_data_ready,    //send ready
	output reg                   tx_pin            //serial data output
);

//calculates the clock cycle for baud rate 
localparam   BAUD_DIV_CNT = CLK_FRE * 1000000 / BAUD_RATE;

reg[15:0]    cnt;       //baud rate counter
reg[3:0]     bit_cnt;   //bit counter

wire cnt_done = (cnt == BAUD_DIV_CNT-1);

localparam S_IDLE = 1'b0;
localparam S_SEND = 1'b1;

reg state;
always@(posedge clk) begin
	if(~rst_n) state <= S_IDLE;
	else case(state)
	S_IDLE: begin
        if(tx_data_req) state <= S_SEND;
	end

	S_SEND: begin
		if(cnt_done && bit_cnt == 9) state <= S_IDLE;
	end

	default: state <= S_IDLE;
    endcase
end

always@(posedge clk) begin
	if(~rst_n) cnt <= 0;
    else if(state == S_SEND) begin
        if(cnt_done) cnt <= 0;
	    else cnt <= cnt +  1;	
    end
	else cnt <= 0;
end

//先传送字符的低位，后传送字符的高位。 
//即低位（LSB）在前，高位（MSB）在后。
reg [9:0] tx_bits; // {stop_bit,tx_data,start_bit}
always@(posedge clk) begin
	if(~rst_n) tx_bits <= 0;
	else if(state == S_IDLE && tx_data_req) tx_bits <= {1'b1, tx_data[7:0],1'b0}; 
    else tx_bits <= tx_bits;
end

always@(posedge clk) begin
	if(~rst_n) bit_cnt <= 3'd0;
	else if(state == S_SEND) begin
        if(cnt_done) bit_cnt <= bit_cnt + 1;
		else bit_cnt <= bit_cnt;
    end
	else bit_cnt <= 0;
end

//output reg tx_pin            
//serial data output
always@(posedge clk) begin
	if(~rst_n) tx_pin <= 1'b1;
	else if(state == S_SEND) 
		tx_pin <= tx_bits[bit_cnt];
	else tx_pin <= 1'b1;
end

always@(*) begin
	if(state == S_IDLE) tx_data_ready <= 1'b1;
    else tx_data_ready <= 1'b0;
end

endmodule 