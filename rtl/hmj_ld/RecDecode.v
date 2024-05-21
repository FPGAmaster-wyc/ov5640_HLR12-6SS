
// 将UartRx逻辑功能单元输出的来自测距模块的数据进行译码

module RecDecode(
		Clk,
		RstN,
		DataEn,
		DataIn,
		
		OutEn,
		DistOut,	
		sd_data,	
		jl_data
		
);

	input						Clk;
	input						RstN;
	input						DataEn;		// 待译码数据使能
	input			[103:0]	DataIn;		// 待译码数据输入
	
	output reg				OutEn;		// 译码完成
	output reg	[19:0]	DistOut;		// 译码输出数据
	output reg  [15:0]	jl_data;		// 距离数据
	output reg  [15:0]	sd_data;		// 速度数据
	
	reg			[1:0]		STATE;
	reg  [15:0]	jl_data_r;
	reg  [15:0]	sd_data_r;

	parameter				IDLE = 2'b00,
								READ = 2'b01,
								SEND = 2'b10,
								RETU = 2'b11;
	
always@(posedge Clk or negedge RstN)
begin
	if (~RstN)
	begin
		OutEn <= 1'b0;
		DistOut <= 1'b0;
		jl_data_r <= 0;
		STATE  <= IDLE;
	end
	else
	begin
	
		case(STATE)
		
			IDLE:
			begin
				OutEn <= 1'b0;
				DistOut <= 1'b0;
				jl_data_r <= 1'b0;
				if (~DataEn)
				begin
					STATE <= IDLE;
				end
				else
				begin
					STATE <= READ;
				end
			end
			
			READ:
			begin
				OutEn <= 1'b0;				// 示例板仅有4位LED，故提取XX.XX格式的4位测量值
				DistOut <= {DataIn[51:48],DataIn[43:40],DataIn[27:24],DataIn[19:16],DataIn[11:8]};  
				jl_data_r <= DataIn[71:56];
				sd_data_r <= DataIn[55:40];
				STATE <= SEND;
			end
	
			SEND:
			begin
				OutEn <= 1'b1;
				DistOut <= DistOut;
				jl_data_r <= jl_data_r;
				STATE <= RETU;
			end
			
			RETU:
			begin
				OutEn <= 1'b1;
				DistOut <= DistOut;
				jl_data_r <= jl_data_r;
				if (~DataEn)		// 本次译码完成后，等待DataEn变低后跳转到IDLE状态
				begin
					STATE <= IDLE;
				end
				else
				begin
					STATE <= RETU;
				end
			end
		
		endcase
	end
end

always @ ( posedge Clk or negedge RstN)
begin
	if (~RstN)
		jl_data <= 0;
	else if (OutEn)
		begin
			jl_data <= jl_data_r;
			sd_data <= sd_data_r;
		end
	else
		jl_data <= jl_data;
end

endmodule



	
	
	
	
	
	
	
	
	
	
	
	
	
	