module uart_tx#(
    parameter CLK_FREQ = 50,
    parameter BAUD_RATE = 115200//波特率
)(
    input       clk,
    input       rst_n,

    input [7:0] TX_DATA,
    input       TX_N,//检测到下降沿

    output  reg   TX_READY,//准备发送
    output  reg   TX_DATA_OUT//要发出去的数据
); 

localparam  BAUD_RATE_CNT = CLK_FREQ*1000_000 / BAUD_RATE;//一个波特率周期的时钟数

reg [15:0]  baud_cnt;//波特率计数器
reg [3:0]   bit_cnt;//位计数器
reg [1:0]   state;//状态

wire cnt_done = (baud_cnt == BAUD_RATE_CNT-1);
localparam S_IDLE      = 2'd1;
localparam S_SEND      = 2'd2;

always@(posedge clk) begin 
    if(!rst_n) state <= S_IDLE;
    else begin
        case(state)
            S_IDLE: begin
                if(TX_N)
                    state <= S_SEND;
            end
            S_SEND: begin
                if(cnt_done && bit_cnt == 4'd9)
                    state <= S_IDLE;
            end
            default: begin
                state <= S_IDLE;
            end
        endcase
    end
end


//****************************波特率计数器***********************************//
always@(posedge clk) begin
    if(!rst_n) begin
        baud_cnt <= 0;
    end
    else if(state == S_SEND) begin
        if(cnt_done)
            baud_cnt <= 0;
        else
            baud_cnt <= baud_cnt + 1;
    end
end



//****************************位计数器***********************************//
always@(posedge clk) begin
    if(!rst_n) begin
        bit_cnt <= 0;
    end
    else if(state == S_SEND)begin
        if(cnt_done)
            bit_cnt <= bit_cnt + 1;
        else bit_cnt <= bit_cnt;
    end
    else bit_cnt <= 0;
end


//****************************就绪状态***********************************//
always@(posedge clk) begin
    if(state == S_IDLE)
        TX_READY <= 1'b1;
    else TX_READY <= 1'b0;
end

//****************************DATA_OUT输出*******************************//
reg [9:0] tx_bits; // {stop_bit,tx_data,start_bit}

always@(posedge clk) begin
    if(!rst_n) begin
        tx_bits <= 1'b0; // 空闲状态，输出高电平
    end
    else if(state == S_IDLE && TX_N) begin
        tx_bits <= {1'b1, TX_DATA, 1'b0}; // 组装数据帧
    end 
    else tx_bits <= tx_bits;

end

always@(posedge clk)begin
    if(!rst_n)
        TX_DATA_OUT <= 1'b1; // 空闲状态高电平
    else if(state == S_SEND)
        TX_DATA_OUT <= tx_bits[bit_cnt];
    else TX_DATA_OUT <= 1'b1;
end

endmodule