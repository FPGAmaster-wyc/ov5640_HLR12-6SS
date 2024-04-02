module seg_show (clk, rst_n, show_data, seg, sel);

   input clk;
	input rst_n;
	input [23:0] show_data;
	  
	output [7:0] seg;
   output [5:0] sel;	
	
   wire clk_1k;

   freq1 freq_dut(
	.clk(clk), 
	.rst_n(rst_n), 
	.clk_1k(clk_1k)
	);
	
	sel_seg_code sel_seg_code_dut(
	.show_data(show_data), 
	.clk_1k(clk_1k),
	.rst_n(rst_n),
	.sel(sel), 
	.seg(seg)
	);
	
endmodule 