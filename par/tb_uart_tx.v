module tb_uart_tx;

	 reg clk_a,rst_n;
    reg rxd;
    wire clk_out;
    wire data1,sync,data2, txd;

     Controller DUT(
	.clk_a(clk_a),
	.rst_n(rst_n),
	.txd(txd)
);

 

    always #10 clk_a = ~clk_a;


    initial begin
	clk_a = 1;
	rst_n = 0;
	rxd = 1;
    #30	
        rst_n = 1;	
    #500000
    $stop;
    end





endmodule 