module infrared_rec#(
    parameter CLK_FREQ = 50_000_000
)(
    input clk,
    input rst_n,
    input ir_in, //红外接收头的输出信号（脉冲信号）

    output reg [15:0] data_out,//解码后的32位NEC协议数据
    output reg data_out_valid //数据有效信号
);

localparam  ONE_SECOND = CLK_FREQ;
localparam  ONE_MSECOND = ONE_SECOND / 1000;
localparam  ONE_USECOND = ONE_MSECOND / 1000;


//-------------------------------------------------------------
//引导码：9ms低电平 + 4.5ms高电平

//逻辑1：560us低电平 + 1.685ms高电平
//逻辑0：560us低电平 + 560us高电平
//-------------------------------------------------------------


//状态机状态
reg [2:0]   state;
localparam  S_IDLE = 3'b000;//空闲状态
localparam  S_LEAD_LOW = 3'b001;//引导码低电平9ms
localparam  S_LEAD_LOW_DONE = 3'b010;//引导码低电平结束
localparam  S_LEAD_HIGH = 3'b011; //引导码高电平4.5ms
localparam  S_LEAD_HIGH_DONE = 3'b100;//引导码高电平结束
localparam  S_DATA = 3'b101; //数据位低电平

//计数器定义
reg [31:0]  low_cnt; //低电平计数器
reg [31:0]  high_cnt; //高电平计数器
reg [5:0]  bit_cnt;//数据位数计数器，最大33

//状态机定义
always @(posedge clk)begin
    if(!rst_n)begin
        state <= S_IDLE;
    end
    else begin
        case(state)
            S_IDLE:begin
                if(!ir_in) state <= S_LEAD_LOW;
                else state <= S_IDLE;
            end
            S_LEAD_LOW:begin
                if(ir_in)
                    state <= S_LEAD_LOW_DONE;
                else 
                    state <= S_LEAD_LOW;
                end
            S_LEAD_LOW_DONE:begin
                if(low_cnt < ONE_MSECOND * 6)
                    state <= S_IDLE;
                else state <= S_LEAD_HIGH;
                end
            S_LEAD_HIGH:begin
                if(!ir_in)
                    state <= S_LEAD_HIGH_DONE;
                else 
                    state <= S_LEAD_HIGH;
            end
            S_LEAD_HIGH_DONE:begin
                if(high_cnt < ONE_MSECOND * 4)
                    state <= S_IDLE;
                else 
                    state <= S_DATA;
            end
            S_DATA:begin
                if((bit_cnt == 33) || (high_cnt > ONE_MSECOND * 3))
                    state <= S_IDLE;
                else 
                    state <= S_DATA;
            end
            default  : state <= S_IDLE;
        endcase
    end
end


//计数器逻辑


////低电平计数器
always @(posedge clk)begin
    if(!rst_n) low_cnt <= 0;
    else if(!ir_in) low_cnt <= low_cnt + 1'b1;
    else low_cnt <= 0;
end

////高电平计数器
always @(posedge clk)begin
    if(!rst_n) high_cnt <= 0;
    else if(ir_in) high_cnt <= high_cnt + 1'b1;
    else high_cnt <= 0;
end

////数据位数计数器
//数据采集期间，高电平时间理论上560us，这里取400us，超过400us则有一位数据
always @(posedge clk) begin
	if (!rst_n) bit_cnt <= 6'b0;
	else if (state == S_DATA) begin
		if (high_cnt == ONE_USECOND * 400) bit_cnt <= bit_cnt + 1'b1; 
		else bit_cnt <= bit_cnt;
	end   
	else bit_cnt <= 6'b0;
end

//数据采集
reg [32:0] data;//处理过程中的数据
always @(posedge clk) begin
    if (!rst_n)
        data <= 32'b0;
    else if(state == S_DATA) 
        if(high_cnt == ONE_USECOND * 500) //高电平时间超过500us，说明有一位数据
            data[bit_cnt] <= 1'b1; 
    else 
        data <= 0;
end

//解码

wire [7:0] addr     = data[7:0];//地址码
wire [7:0] addr_n   = data[15:8];//地址反码
wire [7:0] cmd      = data[23:16];//命令码
wire [7:0] cmd_n    = data[31:24];//命令反码

//校验
wire data_valid = (addr == ~addr_n) && (cmd == ~cmd_n);

//处理输出数据
always @(posedge clk) begin
    if (!rst_n)
        data_out <= 32'b0;
    else if(bit_cnt == 33) begin
        if(data_valid)
            data_out <= {addr[7:0],cmd[7:0]};
        else 
            data_out <= 16'h1010;//校验失败，输出固定错误码
    end
    else 
        data_out <= data_out;
end

always @(posedge clk) begin
	if (!rst_n) data_out_valid <= 1'b0;
    else if (bit_cnt == 33 && data_valid) begin
		data_out_valid <= 1'b1; 
	end
	else data_out_valid <= 1'b0;
end
endmodule

