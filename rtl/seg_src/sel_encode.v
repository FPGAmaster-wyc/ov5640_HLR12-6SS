module sel_code (clk_1k, rst_n, show_data, sel, seg_data);

   input rst_n;
	input [23:0] show_data;
	input clk_1k;
	
   output reg[5:0] sel;
   output reg[3:0] seg_data;
	
	reg [2:0] state;
	
	always @(posedge clk_1k or negedge rst_n)
	   begin
		   if (!rst_n)
		     begin
			  state <= 3'd0;
			  sel <= 64;
			  seg_data <= 0;
			  end
			else
	        begin
			    case (state)
				     0 : begin
					        seg_data <= show_data[19:16 ];
							  sel <= 6'b111110;
							  state <= 3'd1;
		               end
					  1 : begin
					        seg_data <= show_data[15:12];
							  sel <= 6'b111101;
							  state <= 3'd2;
							end
					  2 : begin
					        seg_data <= show_data[11:8];
							  sel <= 6'b111011;
							  state <= 3'd3;
							end 
					  3 : begin
					        seg_data <= show_data[7:4];
							  sel <= 6'b110111;
							  state <= 3'd4;
						   end  
			        4 : begin
					        seg_data <= show_data[3:0];
							  sel <= 6'b101111;
							  state <= 3'd5;
						   end  
			        5 : begin
					        seg_data <= show_data[23:20];
							  sel <= 6'b011111;
							  state <= 3'd0;
							 end

		           default : state <= 0;
		       endcase
		end

    end
	 
endmodule 