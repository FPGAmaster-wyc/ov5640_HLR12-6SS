module seg_encode (clk_1k, seg_data, rst_n,sel, seg);
   input clk_1k;
	input [3:0] seg_data;
	input rst_n;
	input [5:0] sel ;
	
	output [7:0] seg;

	reg  [6:0]  seg_buf;
	wire 			seg_dp_buf;
	assign seg = {seg_dp_buf,seg_buf};
//	assign seg_dp_buf = (sel == 6'b101111) ? 0 : 1; 
	assign seg_dp_buf = 1; 
	
	always @ (posedge clk_1k or negedge rst_n)
	   begin
		   if (!rst_n)
			   begin
				   seg_buf <= 7'b0000_0000;
				end
			else
		      begin
			      case (seg_data)
					   0 : seg_buf  <= 7'b100_0000;
						1 : seg_buf  <= 7'b111_1001;
						2 : seg_buf  <= 7'b010_0100;
						3 : seg_buf  <= 7'b011_0000;
						4 : seg_buf  <= 7'b001_1001;
						5 : seg_buf  <= 7'b001_0010;
						6 : seg_buf  <= 7'b000_0010;
						7 : seg_buf  <= 7'b111_1000;
						8 : seg_buf  <= 7'b000_0000;
						9 : seg_buf  <= 7'b001_0000;
						10 : seg_buf <= 7'b000_1000;
						11 : seg_buf <= 7'b000_0011;
						12 : seg_buf <= 7'b100_0110;
						13 : seg_buf <= 7'b010_0001;
                  14 : seg_buf <= 7'b000_0110;
                  15 : seg_buf <= 7'b000_1110;						
                  default : seg_buf <=7'hef;
               endcase

			   end	
		
		end

endmodule 