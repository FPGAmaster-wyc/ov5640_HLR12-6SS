module sel_seg_code (clk_1k, rst_n, show_data, sel, seg);

   input [23:0] show_data;
   input clk_1k;
	input rst_n;
	
   output [5:0] sel;
   output [7:0] seg;

   wire [3:0] seg_data;	

   sel_code sel_code_dut(
	   .clk_1k(clk_1k),
		.rst_n(rst_n), 
	   .show_data(show_data), 
	   .sel(sel), 
		.seg_data(seg_data)
	   );
								
								
   seg_encode seg_encode_dut(
	   .clk_1k	(clk_1k	), 
      .seg_data(seg_data), 
		.rst_n	(rst_n	), 
		.sel  	(sel		),
	   .seg		(seg		)
		);								

endmodule


 
