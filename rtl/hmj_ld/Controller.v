`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/18 16:36:59
// Design Name: 
// Module Name: gen_uart_data
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Controller(
	input clk_a,
	input rst_n,
	output txd
);

	reg [39:0] temp_data;
	reg [7:0] tx_data;
	reg tx_valid;
	wire ready;

	reg [31:0] delay_cnt;	//发送一个坐标延时


	reg [3:0] c_state, n_state;
	parameter   S0 = 0,
		        S1 = 1,	//发送数据
                S2 = 2,	//数据改变
				S3 = 3,	//发送结束  延时
				S4 = 4; //坐标改变

	UartTx #(
	.CHECK_BIT ("None"	)	,       //“None”无校验  “Odd”奇校验  “Even”偶校验
	.BPS       (115200	)	,       //系统波特率 
	.CLK       (50_000_000)	,   	//系统时钟频率 hz 
	.DATA_BIT  (8		)	,       //数据位（6、7、8）
	.STOP_BIT  (1       )   		//停止位
) TX (
	.i_reset(!rst_n),
	.i_clk(clk_a),
	.i_data(tx_data),
	.i_valid(tx_valid),
	.o_ready(ready),
	.o_txd(txd)
);

	always @(posedge clk_a, negedge rst_n) begin
		if (!rst_n)
			c_state <= 0;
		else 
			c_state <= n_state;
	end

	always @(*) begin
		case (c_state)
			S0	:	begin
						n_state = S1;
			end

			S1	:	begin
						if (ready)
                      		n_state = S2;
						else
							n_state = S1;
			end

			S2 	:	begin
						if (temp_data == 0)
							n_state = S3;
						else
							n_state = S1;
			end

            S3  :   begin
						if (delay_cnt <= 32'd5_000_000)
                        	n_state = S3;
						else
							n_state = S4;
            end	

			S4	:	begin
						n_state = S0;
			end

			default :	n_state = 0;
		endcase 
	end

	always @(posedge clk_a, negedge rst_n) begin
		if (!rst_n)
			begin
				tx_data <= 0;
				temp_data <= 40'h55_5a_02_D3_84;
				tx_valid <= 0;
			end
		else 
			case (n_state)
				S0	:	begin						
							temp_data <= 40'h55_5a_02_D3_84;
				end

				S1	:	begin						
							tx_valid <= 1;
							tx_data <= temp_data[39:32];
				end

				S2	:	begin						
							temp_data <= temp_data << 8;
							tx_valid <= 0;	
				end

                S3  :   begin
							tx_valid <= 0;							
                end

				S4	:	begin
				    
				end
			endcase 
	end

	always @(posedge clk_a) begin
		if (!rst_n)
			begin
				delay_cnt <= 0;
			end
		else if (c_state == 0)
			delay_cnt <= 0;
		else 
			delay_cnt <= delay_cnt + 1;
	end


endmodule



