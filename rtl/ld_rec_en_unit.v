module ld_rec_en_unit(
	input 	i_sys_clk,
	input 	i_sys_rst_n,
	
	output   o_ldrec_en
);
	reg [23:0] count;
	
	always @ (posedge i_sys_clk or negedge i_sys_rst_n) 
	begin
		if (~i_sys_rst_n)
			count <= 0;
		else if (count == 16'd4999999)
			count <= 0;
		else
			count <= count + 1;
	end
	
	assign o_ldrec_en = (count == 16'd4999999) ? 0 : 1;


endmodule 