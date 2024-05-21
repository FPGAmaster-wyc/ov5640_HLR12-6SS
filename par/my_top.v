module my_top(

    input               sys_clk     	,  //系统时钟
    input               sys_rst_n   	,  //系统复位，低电平有效
	 input 					key_hmjld      ,
	 input [1:0]         key_ctrl       ,
	 
    //摄像头接口
    input               cam_pclk    	,  //cmos 数据像素时钟
    input               cam_vsync   	,  //cmos 场同步信号
    input               cam_href    	,  //cmos 行同步信号
    input      [7:0]    cam_data    	,  //cmos 数据
    output              cam_rst_n   	,  //cmos 复位信号，低电平有效
    output        		cam_pwdn   		,  //cmos 电源休眠模式选择信号
    output              cam_scl     	,  //cmos SCCB_SCL线
    inout               cam_sda     	,  //cmos SCCB_SDA线
    //SDRAM接口
    output              sdram_clk   	,  //SDRAM 时钟
    output              sdram_cke   	,  //SDRAM 时钟有效
    output              sdram_cs_n  	,  //SDRAM 片选
    output              sdram_ras_n 	,  //SDRAM 行有效
    output              sdram_cas_n 	,  //SDRAM 列有效
    output              sdram_we_n  	,  //SDRAM 写有效
    output     [1:0]    sdram_ba    	,  //SDRAM Bank地址
    output     [1:0]    sdram_dqm   	,  //SDRAM 数据掩码
    output     [12:0]   sdram_addr  	,  //SDRAM 地址
    inout      [15:0]   sdram_data  	,  //SDRAM 数据 
	 //HDMI接口
    output              tmds_clk_p		,  // TMDS 时钟通道
    output              tmds_clk_n		,
    output     [2:0]    tmds_data_p		,  // TMDS 数据通道
    output     [2:0]    tmds_data_n  	,
	 //毫米波雷达
	 input 					i_hmbld1_uart_rxd	,
	 output 					o_hmbld1_uart_txd	,	
	 input 					i_hmbld2_uart_rxd	,
	 output 					o_hmbld2_uart_txd	,
	 output              o_bj_led1			,  
	 output              o_bj_led2			,
	 //数码管
	 output 		[5:0]		o_sel,
	 output  		[7:0]		o_seg
	 
);
/************************************************/
//							wire or reg 
/************************************************/
	wire [19:0]	jl1_data;
	wire [19:0]	sd_data;
	wire 			jl1_data_vld;
	wire [19:0]	jl2_data;
	wire 			jl2_data_vld;
	reg  [23:0] show_data;
	wire        show_crtl_en;

/************************************************/
//							摄像头+hdmi
/************************************************/

ov5640_hdmi  ov5640_hdmi(    
    .sys_clk     	(sys_clk  	 ),  //系统时钟
    .sys_rst_n   	(sys_rst_n   ),  //系统复位，低电平有效
    //摄像头接口
    .cam_pclk    	(cam_pclk    ),  //cmos 数据像素时钟
    .cam_vsync   	(cam_vsync   ),  //cmos 场同步信号
    .cam_href    	(cam_href    ),  //cmos 行同步信号
    .cam_data    	(cam_data    ),  //cmos 数据
    .cam_rst_n   	(cam_rst_n   ),  //cmos 复位信号，低电平有效
    .cam_pwdn		(cam_pwdn    ),  //cmos 电源休眠模式选择信号
    .cam_scl     	(cam_scl     ),  //cmos SCCB_SCL线
    .cam_sda     	(cam_sda     ),  //cmos SCCB_SDA线
    //SDRAM接口
    .sdram_clk   	(sdram_clk   ),  //SDRAM 时钟
    .sdram_cke   	(sdram_cke   ),  //SDRAM 时钟有效
    .sdram_cs_n  	(sdram_cs_n  ),  //SDRAM 片选
    .sdram_ras_n 	(sdram_ras_n ),  //SDRAM 行有效
    .sdram_cas_n 	(sdram_cas_n ),  //SDRAM 列有效
    .sdram_we_n  	(sdram_we_n  ),  //SDRAM 写有效
    .sdram_ba    	(sdram_ba    ),  //SDRAM Bank地址
    .sdram_dqm   	(sdram_dqm   ),  //SDRAM 数据掩码
    .sdram_addr  	(sdram_addr  ),  //SDRAM 地址
    .sdram_data  	(sdram_data  ),  //SDRAM 数据 
	 //HDMI接口
    .tmds_clk_p	(tmds_clk_p  ),    // TMDS 时钟通道
    .tmds_clk_n	(tmds_clk_n  ),
    .tmds_data_p	(tmds_data_p ),   // TMDS 数据通道
    .tmds_data_n	(tmds_data_n )
    );
	 
	 
	 

/************************************************/
//							毫米波雷达
/************************************************/
wire ldrec_en;
ld_rec_en_unit ld_rec_en_unit(
	.i_sys_clk		(sys_clk		),
	.i_sys_rst_n	(sys_rst_n	),
	
	.o_ldrec_en		(ldrec_en	)
);

hmj_ld_top hmj_ld1_top(
	.i_sys_clk			(sys_clk  			),
	.i_reset_n			(sys_rst_n			),
//	.key_hmjld        (key_hmjld			),
	.key_hmjld        (ldrec_en			),	
	.i_uart_rxd			(i_hmbld1_uart_rxd	),
	.o_uart_txd			(o_hmbld1_uart_txd	),
	
	.o_jgcs_data		(),
	.o_jgcs_data_vld	(jl1_data_vld		),
	.sd_data				(sd_data				),
	.jl_data 			(jl1_data			)
	);
	/*
hmj_ld_top hmj_ld2_top(
	.i_sys_clk			(sys_clk  			),
	.i_reset_n			(sys_rst_n			),
//	.key_hmjld        (key_hmjld			),
	.key_hmjld        (ldrec_en			),	
	.i_uart_rxd			(i_hmbld2_uart_rxd	),
	.o_uart_txd			(o_hmbld2_uart_txd	),
	
	.o_jgcs_data		(),
	.o_jgcs_data_vld	(jl2_data_vld		),
	.jl_data 			(jl2_data			)
	);
	*/
	
	assign o_bj_led1	= ((jl1_data < 20'd35)&&(jl1_data > 3)) ? 1 : 0;		//beep
		
	assign o_bj_led2  = o_bj_led1;				//led
	
	
/************************************************/
//							kalman
/************************************************/
	wire [7:0]	rom_dat_out	;
	wire 			sign_one		;	
	wire 			sign_tow		;	
	wire [23:0]	xn_dat_out	; 
	wire [23:0]	Kg_dat_out	; 
	wire [23:0]	pn_dat_out	; 
	wire [23:0]	x_dat_out	;	
	wire [23:0]	p_dat_out	;

	Kalman Kalman(
	.clk_50M				(sys_clk		),
	.Rst_n				(sys_rst_n	),
	.i_data_in			(show_data[7:0]),
	.ROM_q				(rom_dat_out),
	.Out_sign_one		(sign_one	),
	.Out_sign_tow		(sign_tow	),
	.X_					(xn_dat_out ),
	.Kg					(Kg_dat_out ),
	.P_					(pn_dat_out ),
	.X						(x_dat_out	),
	.P						(p_dat_out	)
	);
	
/************************************************/
//							数码管
/************************************************/

key_control key_control(
	.i_sys_clk		(sys_clk			),
	.i_sys_rst_n	(sys_rst_n		),
	
	.i_key			(key_ctrl		),
	.o_crtl_en		(show_crtl_en	)
);
seg_show seg_show(
	.clk				(sys_clk  	), 
	.rst_n			(sys_rst_n	), 
	.show_data		(show_data  ), 
	.seg				(o_seg		), 
	.sel				(o_sel		)  
);

//assign show_data = show_crtl_en ? {4'd0,jl2_data} : {4'd0,jl1_data};

	reg [11:0] sudu;	//数码管显示的速度 小于20
	always @ (posedge sys_clk or negedge sys_rst_n )begin
		if (!sys_rst_n)
			sudu <= 0;
		else if (sd_data <= 100)
			sudu <= sd_data[11:0];
	end 

always @ (posedge sys_clk or negedge sys_rst_n  )
begin
	if (~sys_rst_n)
		show_data <= 0;
	else if (show_crtl_en == 1)
		show_data <= {sudu, jl1_data[11:0]};	
	else if (show_crtl_en == 0)
		show_data <= {sudu, jl1_data[11:0]};	
	else
		show_data <= show_data;			
end
                   
endmodule
