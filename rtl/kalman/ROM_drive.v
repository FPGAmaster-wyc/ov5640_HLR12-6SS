module ROM_drive (
	clk_50M,
	Rst_n,
	En,
	ROM_q
	);


	input clk_50M;
	input Rst_n;
	input En;//更新输出使能
	output [8:0]ROM_q;
	

	reg [8:0]ROM_addr;//ROM的地址
	always@(posedge clk_50M or negedge Rst_n)
	if(!Rst_n)
		ROM_addr <= 9'd0;
	else if(ROM_addr==314)
		ROM_addr <= 9'd0;
	else if(En)
		ROM_addr <= ROM_addr+1'b1;
	
	ROM ROM1(
		.address(ROM_addr),
		.clock(clk_50M),
		.q(ROM_q)
		);
		
		
endmodule 