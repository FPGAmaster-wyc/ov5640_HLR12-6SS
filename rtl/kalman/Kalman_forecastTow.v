module Kalman_forecastTow(
				clk_50M,
				Rst_n,
				Out_sign,
				P_last,
				Q_error,
				R_error,
				P_,
				Kg
			);
	input clk_50M;
	input Rst_n;
	input [31:0]P_last;
	input [31:0]Q_error;
	input [31:0]R_error;
	output reg Out_sign;
	output reg [31:0]P_;
	output reg [31:0]Kg;
	
	reg [31:0]ADD_dataa;
	reg [31:0]ADD_datab;
	reg ADD_sub;
	wire [31:0]ADD_result;//定义加法器的参数
	reg [31:0]DIV_dataa;
	reg [31:0]DIV_datab;
	wire [31:0]DIV_result;//定义除法器的参数

	reg [7:0]Count;//序列机基数
	always@(posedge clk_50M or negedge Rst_n)
	if(!Rst_n)
		Count <= 1'd0;
	else if(Count == 8'd35)
		Count <= 1'd0;
	else 
		Count <= Count + 1'd1;
	
	always@(posedge clk_50M or negedge Rst_n)
	if(!Rst_n)
		Out_sign <= 1'd0;//标志清零
	else
	begin
		case (Count) 
			8'd1:
			begin
				Out_sign <= 1'd0;//标志位，开始计算
				ADD_sub<=1'd1;//加法
				ADD_dataa<=P_last;
				ADD_datab<=Q_error;//计算预测协方差
			end
			8'd12:
			begin
				ADD_sub<=1'd1;//加法
				ADD_dataa <= ADD_result;
				ADD_datab <= R_error;
				P_ <= ADD_result;//保存预测协方差
			end
			8'd23:
			begin
				DIV_dataa <= P_;
				DIV_datab <= ADD_result;
			end
			8'd34:
			begin
				Kg <= DIV_result;//输出卡尔曼增益
				Out_sign <= 1'd1;//标志位，结束计算
			end
		endcase
	end
	
	//==============以下为运算单元==================//
	ADD	ADD_Tow1 (
	.clock ( clk_50M ),
	.add_sub (ADD_sub),
	.dataa ( ADD_dataa ),
	.datab ( ADD_datab ),
	.result ( ADD_result )
	);
	DIV	DIV_Tow1 (
	.clock ( clk_50M ),
	.dataa ( DIV_dataa ),
	.datab ( DIV_datab ),
	.result ( DIV_result )
	);




endmodule 