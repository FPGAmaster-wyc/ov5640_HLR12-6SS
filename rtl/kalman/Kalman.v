module Kalman(
			clk_50M,
			Rst_n,
			i_data_in,
			ROM_q,
			Out_sign_one,
			Out_sign_tow,
			X_,
			Kg,
			P_,
			X,
			P
			);
				
	input clk_50M;
	input Rst_n;
	input  [8:0]i_data_in;
	output [8:0]ROM_q;//ROM输出
	
	output [31:0]X_;
	output [31:0]Kg;
	output [31:0]P_;
	output [31:0]X;
	output [31:0]P;
	output Out_sign_one;
	output Out_sign_tow;
	
	wire En;
	wire End_flag;//计算完成标志位
	
	wire [31:0]fROM_q;//用于ROM的浮点数
	reg [31:0]X_last;
	reg [31:0]P_last;
	
	ROM_drive ROM_drive1(
		.clk_50M(clk_50M),
		.Rst_n(Rst_n),
		.En(En),
		.ROM_q(ROM_q)
	);
	
	convert	convert1 (
		.clock ( clk_50M ),
		.dataa ( ROM_q ),
		.result ( fROM_q )
	);
	
	Kalman_forecastOne Kalman_forecastOne1(
		.clk_50M(clk_50M),
		.Rst_n(Rst_n),
		.X_last(X_last),
		.Xd(32'H3F_80_00_00),////////////
		.Out_sign(Out_sign_one),
		.X_(X_)
	);
	Kalman_forecastTow Kalman_forecastTow1(
		.clk_50M(clk_50M),
		.Rst_n(Rst_n),
		.Out_sign(Out_sign_tow),
		.P_last(P_last),
		.Q_error(32'H3F_80_00_00),//1
		.R_error(32'H40_40_00_00),//3
		.P_(P_),
		.Kg(Kg)
	);
	assign En = Out_sign_one & Out_sign_tow;
	Kalman_update Kalman_update1(
		.clk_50M(clk_50M),
		.Rst_n(Rst_n),
		.En(En),
		.X_(X_),
		.Kg(Kg),
		.in_data(fROM_q),
		.P_(P_),
		.X(X),
		.P(P),
		.End_flag(End_flag)
	);
	
	
	//=========同步跟新数据============//
	always@(posedge clk_50M or negedge Rst_n)
	if(!Rst_n)
	begin
		X_last <= 32'd0;
		P_last <= 32'H3F_80_00_00;//初始化
	end
	else if(End_flag)
	begin
		X_last <= X;
		P_last <= P;
	end

endmodule