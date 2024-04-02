

/*

例化模板：
uart_tx #(
	.CHECK_BIT ("None"	)	,       //“None”无校验  “Odd”奇校验  “Even”偶校验
	.BPS       (115200	)	,       //系统波特率 
	.CLK       (25_000_000)	,   	//系统时钟频率 hz 
	.DATA_BIT  (8		)	,       //数据位（6、7、8）
	.STOP_BIT  (1       )   		//停止位 (1、2、3... 整数)
) TX (
	.i_reset(!rst_n),				//高有效
	.i_clk(clk_a),
	.i_data(tx_data),               //tx_data [7:0]
	.i_valid(tx_valid),
	.o_ready(ready),
	.o_txd(txd)
);

//奇校验缩位同或
// assign check_data = ~^temp_data; 
//偶校验缩位异或
// assign check_data = ^temp_data; 

*/
module UartTx #(
	parameter CHECK_BIT = "None",       //“None”无校验  “Odd”奇校验  “Even”偶校验
	parameter BPS       = 115200,       //系统波特率 
	parameter CLK       = 25_000_000,   //系统时钟频率 hz 
	parameter DATA_BIT  = 8,            //数据位（6、7、8）
	parameter STOP_BIT  = 1             //停止位 (1、2、3... 整数)
)(
	input	i_reset,
	input	i_clk,
	input	[DATA_BIT-1:0] i_data,
	input	i_valid,
	output	reg o_ready,
	output  reg o_txd
);

    //get uart clk reg
    localparam	BPS_CNT	=	(CLK)/BPS-1,            //计算波特率计数值
					BPS_WD	=	log2(BPS_CNT),          //求波特率计数值的位宽
					STOP_WD =   log2(STOP_BIT+1);       //求停止位的位宽

    reg     [BPS_WD-1:0] div_cnt;                   //波特率计数器
    wire    tx_en;                                  //波特率信号（隔一个en发送一次数据）

    reg [STOP_WD-1:0]stop_cnt;                      //停止位计数器
    reg [DATA_BIT-1:0] temp_data;                   //捕获数据
    reg [7:0] tx_cnt;                               //bit计数

    reg check_data;                                 //奇偶校验位值

    reg [3:0] c_state, n_state;
    parameter   IDLE    = 0,
                STATE   = 1,
                DATA    = 2,
                CHECK   = 3,
                STOP    = 4;

///////////////////* 时钟波特率计算 *//////////////////////////////
    assign tx_en = (div_cnt == BPS_CNT - 1);
    always @(posedge i_clk, posedge i_reset) begin
        if (i_reset)
            div_cnt <= 'b0;
        else if (tx_en)
            div_cnt <= 'b0;
        else 
            div_cnt <= div_cnt + 1;     
    end

///////////////////* FSM *3 *//////////////////////////////
    always @(posedge i_clk, posedge i_reset) begin
        if (i_reset)
            c_state <= 0;
        else
            c_state <= n_state;
    end

    always @(*) begin
        case (c_state)
            IDLE    :   begin
                            if (tx_en && i_valid)
                                n_state = STATE;
                            else
                                n_state = IDLE;
            end  

            STATE   :   begin
                            if (tx_en)
                                n_state = DATA; 
                            else
                                n_state = STATE;
            end

            DATA    :   begin
                            if (tx_en && tx_cnt >= DATA_BIT && CHECK_BIT == "None")
                                n_state = STOP;
                            else if (tx_en && tx_cnt >= DATA_BIT)
                                n_state = CHECK;
                            else
                                n_state = DATA;
            end 

            CHECK   :   begin
                            if (tx_en)
                                n_state = STOP;
                            else
                                n_state = CHECK;
            end

            STOP    :   begin
                            if (tx_en && stop_cnt == 1)
                                n_state = IDLE;
                            else
                                n_state = STOP;
            end
            
            default :   n_state = 0;

        endcase
    end

    always @(posedge i_clk, posedge i_reset) begin
        if (i_reset)
            begin
                o_txd <= 1;
                o_ready <= 0;
                stop_cnt <= STOP_BIT + 1;
                temp_data <= 0;
                tx_cnt <= 0;
            end
        else
            case (n_state)
                IDLE    :   begin
                                o_txd <= 1;
                                o_ready <= 0; 
                end

                STATE   :   begin
                                o_txd <= 0;     
                                check_data <= (CHECK_BIT == "Odd") ? ~^temp_data : ^temp_data;                           
                                if (c_state == IDLE)            //保证o_ready只保持一个时钟周期
                                    begin
                                        o_ready <= 1; 
                                        temp_data <= i_data;
                                    end                                    
                                else
                                    o_ready <= 0;                                    
                end

                DATA    :   begin                                
                                if (tx_en)
                                    begin
                                        o_txd <= temp_data[0];
                                        temp_data <= temp_data >> 1;
                                        tx_cnt <= tx_cnt + 1;    
                                    end                                    
                end

                CHECK   :   begin                                
                                o_txd <= check_data;
                end

                STOP    :   begin
                                if (tx_en)
                                    begin 
                                        o_txd <= 1;
                                        stop_cnt <= stop_cnt - 1;
                                        tx_cnt <= 0;
                                    end 
                end
                default : ;
            endcase
    end

///////////////////*get_data_width*//////////////////////////////
    function integer log2(input integer v);
    begin
        log2 = 0;
        while (v >> log2) 
            log2 = log2 + 1;
    end
    endfunction

endmodule
    