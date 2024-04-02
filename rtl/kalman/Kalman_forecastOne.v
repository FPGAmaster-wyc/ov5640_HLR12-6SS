module Kalman_forecastOne(
		clk_50M,
		Rst_n,
		X_last,
		Xd,
		Out_sign,
		X_
		);
		
	input clk_50M;
	input Rst_n;
	input [31:0]X_last;//输入变量
	input [31:0]Xd;//输入变量
	output reg [31:0]X_;//输出变量
	output reg Out_sign;//计算完成标志
	
	reg [7:0]Count;//序列机基数
	
	reg [31:0]ADD_dataa;
	reg [31:0]ADD_datab;
	reg ADD_sub;//定义加减标志
	wire [31:0]ADD_result;//定义加法器的参数
	reg [31:0]MULT_dataa;
	reg [31:0]MULT_datab;
	wire [31:0]MULT_result;//定义加法器的参数
	
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
				ADD_sub <= 1'd0;//做减法运算
				ADD_dataa<=X_last;
				ADD_datab<=Xd;
			end
			8'd12:
			begin
				MULT_dataa <= ADD_result;
				MULT_datab <= 32'H3F_00_00_00;
			end
			8'd23:
			begin
				ADD_dataa <= MULT_result;
				ADD_datab <= X_last;
			end
			8'd34:
			begin
				X_ <= X_last;//输出公式一的结果
				Out_sign <= 1'd1;//标志位，计算完成
			end
		endcase
	end
	//==================以下为运算单元==================//

	ADD	ADD_One1 (
	.clock ( clk_50M ),
	.add_sub (ADD_sub),
	.dataa ( ADD_dataa ),
	.datab ( ADD_datab ),
	.result ( ADD_result )
	);

	MULT	MULT_One1 (
	.clock ( clk_50M ),
	.dataa ( MULT_dataa ),
	.datab ( MULT_datab ),
	.result ( MULT_result )
	);







endmodule
 