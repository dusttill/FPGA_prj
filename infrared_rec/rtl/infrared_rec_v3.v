module infrared_rec_v3 #(
    parameter CLK_FREQ = 50_000_000
)(
    input clk,
    input rst_n,
    input ir_in, 

    output reg [15:0] data_out,
    output reg data_out_valid 
);

localparam  ONE_MSECOND = CLK_FREQ / 1000;
localparam  ONE_USECOND = ONE_MSECOND / 1000;

// 2. 阈值设定
localparam CNT_560US_MIN	=ONE_USECOND * 200;
localparam CNT_560US_MID    =ONE_USECOND * 800;
localparam CNT_560US_MAX	=ONE_USECOND *1800;//高电平时间：560us--1680us
localparam CNT_9MS_MIN      = ONE_MSECOND * 8;
localparam CNT_9MS_MAX      = ONE_MSECOND * 10;
localparam CNT_4_5MS_MIN    = ONE_MSECOND * 4;
localparam CNT_4_5MS_MAX    = ONE_MSECOND * 5;
localparam CNT_2_25MS_MAX   = (ONE_MSECOND * 5)/2;

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


reg ir_in_reg1, ir_in_reg2;
always @(posedge clk) begin
    ir_in_reg1 <= ir_in;
    ir_in_reg2 <= ir_in_reg1;
end

wire ir_fell = ir_in_reg2 && !ir_in_reg1; // 下降沿
wire ir_rise = !ir_in_reg2 && ir_in_reg1; // 上升沿：低变高，引导码低电平结束

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
                if(ir_rise) state <= S_LEAD_LOW_DONE; // 使用上升沿触发跳转
                else state <= S_LEAD_LOW;
                end
            S_LEAD_LOW_DONE:begin
                if(low_cnt >= CNT_9MS_MIN && low_cnt <= CNT_9MS_MAX)
                    state <= S_LEAD_HIGH;
                else 
                    state <= S_IDLE;

                end
            S_LEAD_HIGH:begin
                if(!ir_in)
                    state <= S_LEAD_HIGH_DONE;
                else 
                    state <= S_LEAD_HIGH;
            end
            S_LEAD_HIGH_DONE:begin
                // if(high_cnt < CNT_4_5MS_MIN || high_cnt > CNT_4_5MS_MAX)
                //     state <= S_IDLE;
                // else 
                    state <= S_DATA;
            end
            S_DATA: begin
                if (bit_cnt == 32) 
                    state <= S_IDLE; 
                else if (bit_cnt > 0 && high_cnt > CNT_2_25MS_MAX)
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
always @(posedge clk) begin
    if(!rst_n) low_cnt <= 0;
    else if(!ir_in) low_cnt <= low_cnt + 1'b1;
    else if(ir_rise) low_cnt <= low_cnt; // 关键：上升沿保持数值，供状态机下一拍校验
    else low_cnt <= 0;
end


////高电平计数器
always @(posedge clk) begin
    if(!rst_n) high_cnt <= 0;
    else if(ir_in) high_cnt <= high_cnt + 1'b1;
    else if(ir_fell) high_cnt <= high_cnt; // 关键：下降沿保持数值，供 bit_cnt 判定
    else high_cnt <= 0;
end





////数据位数计数器
//数据采集期间，高电平时间理论上560us-1680us，
always @(posedge clk) begin
    if (!rst_n) 
        bit_cnt <= 6'b0;
    else if (state == S_DATA) begin
        if (ir_fell && (high_cnt > CNT_560US_MIN) && (high_cnt < CNT_560US_MAX))
            bit_cnt <= bit_cnt + 1'b1;
    end   
    else 
        bit_cnt <= 6'b0;
end

// 数据采集
reg [32:0] data;//处理过程中的数据
always @(posedge clk) begin
    if (!rst_n)
        data <= 32'b0;
    else if (state == S_DATA && ir_fell) begin
        // 判断高电平持续时间来区分 0 和 1
        if ((high_cnt > CNT_560US_MIN) && (high_cnt < CNT_560US_MID))
            data[bit_cnt] <= 1'b0;
        else if ((high_cnt > CNT_560US_MID) && (high_cnt < CNT_560US_MAX))
            data[bit_cnt] <= 1'b1;
    end
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
    if (!rst_n) begin
        data_out <= 16'h0;
    end 
    else if (bit_cnt == 6'd32) begin 
        // if (data_valid) begin
        //     data_out <= {addr[7:0], cmd[7:0]}; 
        // end 
        // else begin
        //     data_out <= 16'h1010; 
        //end
        data_out <= {addr[7:0], cmd[7:0]};
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        data_out_valid <= 1'b0; //
    end 
    else if (bit_cnt == 6'd32) begin
        data_out_valid <= 1'b1; //
    end 
    else begin
        data_out_valid <= 1'b0; // 仅在完成时刻产生一个高电平脉冲
    end
end
endmodule

