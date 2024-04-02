
//按键控制模块

module Controller(
		Clk,
		RstN,
		KeyA,
		KeyB,
		
		DataEn,
		DataOut
);

	input						Clk;
	input						RstN;
	input						KeyA;
	input						KeyB;
	
	output reg				DataEn;
//	output reg	[31:0]	DataOut;
	output reg	[39:0]	DataOut;
	
	reg			[25:0]	ClkCnt;
	reg			[1:0]		STATE;
	
	parameter				IDLE 	= 2'b00,		// "空闲"状态
								KEYA 	= 2'b01,		// "发送单次测量命令"状态
								KEYB	= 2'b10,		// "发送连续测量命令"状态
								RETU	= 2'b11;		// "返回"状态
								
always@(posedge Clk or negedge RstN)
begin
	if (~RstN)
	begin
		ClkCnt <= 1'b0;
		STATE <= IDLE;
		DataEn <= 1'b0;
		DataOut <= 1'b0;
	end
	else
	begin
		
		case(STATE)
			
			IDLE:
			begin
				ClkCnt <= 1'b0;
				DataEn <= 1'b0;
				DataOut <= 1'b0;
				if (~KeyA)		// 在IDLE状态中，通过if...else...语句响应按键输入，可更换为case语句
				begin
					STATE <= KEYA;
				end
				else if (~KeyB)
				begin
					STATE <= KEYB;
				end
				else
				begin
					STATE <= IDLE;
				end
			end
			
			KEYA:
			begin
				if (ClkCnt < 'd50000000)			// 1秒内连续判断按键状态，简单"去抖"，可使用其它方法实现
				begin
					ClkCnt <= ClkCnt + 1'b1;
					if (~KEYA)
					begin
						STATE <= STATE;
					end
					else	// 在1秒内检测到KEYA按键被释放，则返回到IDLE
					begin
						STATE <= IDLE;
					end
				end
				else
				begin
					DataEn <= 1'b1;
//					DataOut <= 32'h80_06_02_78;   	// 单次测量
					DataOut <= 40'h55_5A_02_D3_84;  	// 执行查询
					STATE <= RETU;
				end
			end
			
			KEYB:
			begin
				if (ClkCnt < 'd50000000)			// 1秒内连续判断按键状态，简单"去抖"，可使用其它方法实现
				begin
					ClkCnt <= ClkCnt + 1'b1;
					if (~KEYB)
					begin
						STATE <= STATE;
					end
					else
					begin  // 在1秒内检测到KEYB按键被释放，则返回到IDLE
						STATE <= IDLE;
					end
				end
				else
				begin
					DataEn <= 1'b1;
//					DataOut <= 32'h80_06_03_77;		// 多次测量
//					DataOut <= 40'h55_5A_03_D1_00_83;  // 雷达关：	
					DataOut <= 40'h55_5A_03_D1_01_84;  // 雷达开：
					STATE <= RETU;
				end
			end		
			
			RETU:
			begin
				ClkCnt <= 1'b0;
				DataEn <= DataEn;
				DataOut <= DataOut;
				STATE <= IDLE;
			end
			
		endcase
	end
end

endmodule

		
		
		
		
		