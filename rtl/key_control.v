module key_control (
	input i_sys_clk,
	input i_sys_rst_n,
	
	input  [1:0] 	i_key,
	output reg		o_crtl_en
);

always @ (posedge i_sys_clk or negedge i_sys_rst_n)
begin
	if (~i_sys_rst_n)
		o_crtl_en <= 0;
	else if (i_key == 2'b10)
		o_crtl_en <= 1;
	else if (i_key == 2'b01)
		o_crtl_en <= 0;	
	else 
		o_crtl_en <= o_crtl_en;
end

endmodule 