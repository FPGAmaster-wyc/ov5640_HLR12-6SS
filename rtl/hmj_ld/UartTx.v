module UartTx(
			Clk,
			RstN,
			DataEn,	
			DataIn,
				
			Tx
);

	input					Clk;
	input					RstN;
	input					DataEn;			// 发送数据使能
	input		[39:0]	DataIn;			// 待发送数据	
	
	output	reg		Tx;

	reg		[12:0]	ClkCnt;			// 串口发送时钟分频计数器
	reg		[9:0]		TxData;			// 发送数据缓冲，8个数据位，1个起始位，1个停止位
	reg		[3:0]		SendCnt;			// 位发送计数器
	reg		[3:0]		ByteCnt;			// 发送字节计数器
//	reg		[31:0]	SendBuff;		// 数据发送缓冲寄存器
	reg		[39:0]	SendBuff;		// 数据发送缓冲寄存器
	reg		[1:0]		STATE;			// 状态机寄存器
	
	
	
	parameter			IDLE = 2'b00,	// "空闲"状态
							LOAD = 2'b01,  // "置数"状态
							SEND = 2'b10,  // "发送"状态
							RETU = 2'b11;  // "返回"状态
							
	parameter BTL_NUM = 13'd5207; //9600bps 50M Clk 50M/9600= 5208;
//	parameter BTL_NUM = 13'd434; //9600bps 50M Clk 50M/115200= 434;											


always@(posedge Clk or negedge RstN)
begin
	if (~RstN)
	begin
		STATE <= IDLE;
		TxData <= 10'h1;
		ByteCnt <= 1'b0;
		SendBuff <= 1'b0;
	end
	else
	begin
		case(STATE)
		
		IDLE:
		begin
			ByteCnt <= 1'b0;
			if (DataEn)		// 发送数据使能有效时，将输入数据DataIn赋给数据发送缓冲寄存器SendBuff，并跳转到LOAD状态
			begin
				SendBuff <= DataIn;
				STATE <= LOAD;
			end
			else
			begin
				SendBuff <= 1'b0;
				STATE <= IDLE;
			end
		end

		
		LOAD:
		begin
//			if (ByteCnt < 3'd4)	// 字节计数
			if (ByteCnt < 3'd5)	// 字节计数
			begin
				ByteCnt <= ByteCnt + 1'b1;
//				TxData <= {1'b1,SendBuff[31:24],1'b0};	// 待发送字节组帧
//				SendBuff <= {SendBuff[23:0],SendBuff[31:24]};
				TxData <= {1'b1,SendBuff[39:32],1'b0};	// 待发送字节组帧
				SendBuff <= {SendBuff[31:0],SendBuff[39:32]};
				STATE <= SEND;
			end
			else
			begin
				ByteCnt <= ByteCnt;
				TxData <= 1'b0;
				STATE <= RETU;
			end
		end
		
		SEND:
		begin
			if( SendCnt < 4'b1010)		//发送数据位计数，用于状态转移
			begin
				STATE <= SEND;
			end
			else
			begin
				STATE <= LOAD;
			end
		end
		
		RETU:
		begin
			if (DataEn)			// 本次4字节命令数据发送完成后等待，数据发送使能DataEn变低后，跳转到IDLE状态，等待下次发送
			begin
				STATE <= RETU;
				TxData <= TxData;
			end
			else
			begin
				STATE <= IDLE;
				TxData <= 1'b1;
			end 
		end
		
		
	endcase
	end
end


always@(posedge Clk)
begin
	if (STATE == SEND)				//状态机处于SEND时，发送数据
	begin
		if (ClkCnt <= BTL_NUM)		//波特率设置
		begin
			Tx <= TxData[SendCnt];
			SendCnt <= SendCnt;
			ClkCnt <= ClkCnt + 1'b1;
		end
		else
		begin
			Tx <= Tx;
			SendCnt <= SendCnt + 1'b1;
			ClkCnt <= 12'b0;
		end			
	end
	else
	begin
		Tx <= 1'b1;
		SendCnt <= 4'b0;
	end
end


endmodule	