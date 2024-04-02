module freq1 (clk, rst_n, clk_1k);
   
	input clk;
	input rst_n;
	
	output reg clk_1k;
	
	parameter T500us = 25000 - 1;
	
	reg [14:0] cnt;
	
	always @(posedge clk or negedge rst_n)
	   begin
		   if (!rst_n)
			   begin
				clk_1k <= 1'b1;
				end
			else
		      begin
				   if(cnt < T500us)
			         begin
					      cnt <=cnt +1;
						   clk_1k <= clk_1k;
					   end
					else
					   begin
						   clk_1k <= ~ clk_1k;
					      cnt <= 0;		
						end	
					   
			   end 
		
		end

endmodule 
