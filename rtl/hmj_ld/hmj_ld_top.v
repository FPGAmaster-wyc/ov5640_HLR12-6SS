module hmj_ld_top (
	input 	i_sys_clk,
	input 	i_reset_n,
	input 	key_hmjld,
	
	input 	i_uart_rxd,
	output 	o_uart_txd,
	
	output [19:0] 	o_jgcs_data,
	output 			o_jgcs_data_vld,
	output [19:0]	jl_data
	);

	wire [103:0]	uart_rx_data;
	
	wire 				uart_rx_data_vld;
	
	wire [39:0]		uart_tx_data;
	wire 				uart_tx_data_vld;
	
	wire [15:0]		jl_data_r;
	
	Controller CONM(
	.clk_a(i_sys_clk),
	.rst_n(i_reset_n),
	.txd(o_uart_txd)
);	
	
	UartRx(
	.Clk			(i_sys_clk			),
	.RstN			(i_reset_n			),
	.Rxd			(i_uart_rxd			),		
	
	.RxFull		(uart_rx_data_vld	),
	.DataBuff 	(uart_rx_data		)
	);
	
	RecDecode RecDecode(
	.Clk			(i_sys_clk			),
	.RstN			(i_reset_n			),
	.DataEn		(uart_rx_data_vld	),
	.DataIn		(uart_rx_data		),
		
	.OutEn		(o_jgcs_data_vld	),
	.DistOut		(o_jgcs_data		),
	.jl_data		(jl_data_r			)
	);

	
	assign jl_data[19:16] = jl_data_r/10000;    // 百位
	assign jl_data[15:12] = jl_data_r/1000%10;  // 十位
	assign jl_data[11:8]  = jl_data_r/100%10;   // 个位
	assign jl_data[7:4]   = jl_data_r/10%10;    // 0.1
	assign jl_data[3:0]   = jl_data_r%10;       // 0.01
		
endmodule 