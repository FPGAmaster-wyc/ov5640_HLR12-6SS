module Kalman_update(
		clk_50M,
		Rst_n,
		En,
		X_,
		Kg,
		in_data,
		P_,
		X,
		P,
		End_flag
	);
	input clk_50M;
	input Rst_n;
	input En;//开始计算标志
	input [31:0]X_;
	input [31:0]Kg;
	input [31:0]in_data;
	input [31:0]P_;
	output reg [31:0]X;
	output reg [31:0]P;
	output reg End_flag;//计算完成标志位
	
	reg [31:0]ADD_dataa;
	reg [31:0]ADD_datab;
	reg ADD_sub;
	wire [31:0]ADD_result;//定义加法器的参数
	reg [31:0]MULT_dataa;
	reg [31:0]MULT_datab;
	wire [31:0]MULT_result;//定义除法器的参数

	reg [7:0]Count;//序列机基数
	reg En_;//用于启动计算
	always@(posedge clk_50M or negedge Rst_n)
	if(!Rst_n)
		Count <= 1'd0;
	else if(Count == 8'd57)
		Count <= 1'd0;
	else if(En_)
		Count <= Count + 1'd1;
	else 
		Count <= 1'd0;

	
	always@(posedge clk_50M or negedge Rst_n)
	if(!Rst_n)
		En_ <= 1'd0;
	else if(En)//如果外部来了一个使能信号
		En_ <= 1'd1;
	else if(Count == 8'd57)//如果计算完毕
		En_ <= 1'd0;//关闭计算
		
		
	always@(posedge clk_50M or negedge Rst_n)
	if(!Rst_n)
		End_flag<= 1'd0;
	else
	begin
		case (Count) 
			8'd1:
			begin
				End_flag <= 1'd0;//完成标志位清零
				ADD_sub <= 1'd0;//减法
				ADD_dataa <= in_data;
				ADD_datab <= X_;
			end
			8'd12:
			begin
				MULT_dataa <= Kg;
				MULT_datab <= ADD_result;
			end
			8'd23:
			begin
				ADD_sub <= 1'd1;//加法
				ADD_dataa <= X_;
				ADD_datab <= MULT_result;
			end
			8'd34:
			begin
				X <= ADD_result;//输出结果
				ADD_sub <= 1'd0;//减法 公式5  V
				ADD_dataa <= 32'H3F_80_00_00;//1
				ADD_datab <= Kg;
			end
			8'd45:
			begin
				MULT_dataa <= P_;
				MULT_datab <= ADD_result;
			end
			8'd56:
			begin
				P <= MULT_result;//输出结果
				End_flag <= 1'd1;//完成标志位置位
			end
		endcase
	end
//===================以下为运算单元=================//
	ADD	ADD_Three1 (
	.clock ( clk_50M ),
	.add_sub (ADD_sub),
	.dataa ( ADD_dataa ),
	.datab ( ADD_datab ),
	.result ( ADD_result )
	);

	MULT	MULT_Three1 (
	.clock ( clk_50M ),
	.dataa ( MULT_dataa ),
	.datab ( MULT_datab ),
	.result ( MULT_result )
	);






endmodule
