
module UartRx(
		Clk,
		RstN,
		Rxd,		
		
		RxFull,
		DataBuff
);

	input						Clk;
	input						RstN;
	input						Rxd;

	output					RxFull;   
	output		[103:0]	DataBuff;


	//UART接收控制寄存器
	reg			[3:0]		RxBit;			//用于指示当前接收的位
//	reg			[87:0]	DataBuff;  	 	//11个字节的数据缓存
	reg			[103:0]	DataBuff;  	 	//11个字节的数据缓存
	reg			[7:0]		CurrByte;		//当前接收的字节缓存
	reg			[3:0]		RecCnt;			//接收数据字节计数器
	reg			[7:0]		DivCnt;			//分频计数器
	reg 			[1:0]		State;			//状态机
	reg			[3:0]		BitCnt;			//接收器计数
	reg						RxFull;		   //本次数据接收完毕标志位
	reg						RecClk;			//接收时钟
	reg						ClkFlag;			//接收时钟使能控制标志寄存器

		
	parameter			IDLE = 2'b00,
							READ = 2'b01,
							RETU = 2'b11;

	parameter  BTL_NUM = 8'd162;//50M/9600/16/2=162.7//接收时钟分频，波特率为9600/50M晶振，对应分频计数值为162.7
//	parameter  BTL_NUM = 8'd13;//50M/115200/16/2=//接收时钟分频，波特率为115200/50M晶振，对应分频计数值为
							
//接收时钟生成电路描述			
always@(posedge Clk or negedge RstN)
begin
	if (~RstN)
	begin
		RecClk <= 1'b0;
		DivCnt <= 8'd0;
	end
	else
	begin								//50M/9600/16/2=162.7
		if (DivCnt == BTL_NUM)   //接收时钟分频，波特率为9600/50M晶振，对应分频计数值为162.7
		begin
			DivCnt <= 8'd0;
			RecClk <= ~RecClk;
		end
		else
		begin
			DivCnt <= DivCnt + 1'b1;
			RecClk <= RecClk;
		end
	end
end


//UART数据接收模块
always@(posedge Clk or negedge RstN)
begin
	if (~RstN)
	begin
		State <= IDLE;
		DataBuff <= 1'b0;	
		CurrByte <= 8'b0;	
		RecCnt <= 1'b0;
		RxBit <= 1'b0;	
		RxFull <= 1'b0;
		ClkFlag <= 1'b0;
	end
	else
	begin
		if (RecClk && ~ClkFlag)
		begin
			ClkFlag <= RecClk;			
			case(State)
	
			IDLE:
			begin
				if (Rxd == 1'b1)
				begin
					BitCnt <= 4'b0;
					State <= IDLE;
				end
				else
				begin
					if (BitCnt < 4'h9)	// 当Rxd变低后，连续检测9个时钟周期，跳转到READ状态
					begin
						BitCnt <= BitCnt+1'b1;
						State <= State;
						RxBit <= 4'b1;
					end
					else
					begin
						BitCnt <= 4'b0;
						State <= READ;
						RxBit <= 4'b0;
					end
				end
			end	

			//按字节读入控制数据
			READ:
			begin
				if (BitCnt == 4'hF)				// 每隔一个波特率周期，采样一次数据
				begin									// 接收时钟recclk为波特率的16倍
					BitCnt <= 4'h0;
					if (RxBit == 4'd8)			// 接收完一个数据的8位后，状态机转移
					begin
						RxBit <= 1'b0;
						DataBuff <= {DataBuff[95:0],CurrByte}; // 接收到的数据以左移的方式存入缓存
//						DataBuff <= {DataBuff[79:0],CurrByte}; // 接收到的数据以左移的方式存入缓存
						State <= RETU;
					end
					else
					begin
						RxBit <= RxBit+1'b1;
						CurrByte[RxBit] <= Rxd;			// 保证存储在BUFF中的数据位与发送顺序一致
						State <= State;			   	
					end
				end					
				else
				begin
					BitCnt <= BitCnt+1'b1;
					RxBit <= RxBit;
					State <= State;
					CurrByte <= CurrByte;
					DataBuff <= DataBuff;
				end
			end


			RETU:
			begin
				if (RecCnt < 4'd12)	// 接收13字节数据
				begin
					RxFull <= 1'b0;						
					RecCnt <= RecCnt + 1'b1;
				end
//				else							// 接收11字节数据后，RxFull拉高
				else							// 接收13字节数据后，RxFull拉高
				begin							
					RxFull <= 1'b1;
					RecCnt <= 1'd0;
				
					DataBuff <= DataBuff;

				end		
					State <= IDLE;		
				end
			endcase
		end
		
		else
		begin
			if (~RecClk && ClkFlag)
			begin
				ClkFlag <= RecClk;
			end
			else
			begin
				ClkFlag <= ClkFlag;
			end	
		end
	end
end

endmodule
