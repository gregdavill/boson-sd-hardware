/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *                2018  Gregory Davill <greg.davill@gmail.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */


/*
 * HyperRAM connections:
 *   - HRAM_CK = Clock input to HyperRAM (CK[0] is positive ck, CK[1] is negative ck)
 *   - HRAM_DQ = Bidirectional DDR databus to HyperRAM
 *   - HRAM_CS = Chip Select. Active LOW
 *   - HRAM_RESET = Reset. Active LOW
 *   - HRAM_RWDS = Read Write Data Strobe, (Also Latency indicator.)
 */

`default_nettype none

module ecp5demo (
	input wire clk_input,

	output wire ser_tx,
	input wire ser_rx,
	output wire ser_tx_dir,
	output wire ser_rx_dir, 

	output wire led,

	output wire flash_csb,
`ifdef SIM
	output  trap,
	output  flash_clk, /* CLK pin requires special USRMCLK module */
`endif
	
	inout  wire flash_io0,
	inout  wire flash_io1,
	inout  wire flash_io2,
	inout  wire flash_io3,
	
	output wire fpga_reset,
	
	/* HYPER RAM SIGNALS */
	output wire [1:0] HRAM_CK,
	output wire  HRAM_CS,
	inout wire HRAM_RWDS,
	inout wire [7:0] HRAM_DQ,
	output wire HRAM_RESET,
	
	input wire SDMMC_CD,
	inout wire [3:0] SDMMC_DATA,
	inout wire SDMMC_CMD,
	output wire SDMMC_CK,

	/* 16bit CMOS Camera interface */
	input wire [15:0] BOSON_DATA,
	input wire BOSON_CLK,
	input wire BOSON_VSYNC,
	input wire BOSON_HSYNC,
	input wire BOSON_VALID,
	output wire BOSON_RESET
);

	wire clk,clk_90,pll_lock;
	
	/* Feed the PLL to generate a 12MHZ sys clk */
`ifdef SIM	
	assign clk = clk_input;
`else
    //OSC_TOP osc(clk);
	wire clk_tmp;
	
	//assign clk = clk_input;
	pll _inst (.CLKI(clk_input), .CLKOP(clk), .CLKOS(clk_90), .LOCK(pll_lock));
	/*
	DCSC DCSInst0 (
		.CLK0(clk_tmp),
		.CLK1(clk_tmp),
		.SEL0(1'b1),
		.SEL1(1'b0),
		.MODESEL(1'b0),
		.DCSOUT(clk)
	);
	defparam DCSInst0.DCSMODE = "POS";
	*/
	//pll _inst (.CLKI(clk_input), .CLKOS2(clk), .CLKOS3(clk_90), .LOCK(pll_lock));
	//mainPLL _inst (.CLKI(clk_input), .CLKOP(clk_90), .CLKOS(clk), .LOCK(pll_lock));
`endif
	

`ifdef SIM
	reg [4:0] reset_cnt = 0;
	wire resetn = reset_cnt[4];
	assign pll_lock = 1;
`else
	reg [21:0] reset_cnt = 0;
	wire resetn = reset_cnt[21];
`endif

	always @(posedge clk_input) begin
		if(pll_lock)
			reset_cnt <= reset_cnt + !resetn;
	end

	assign BOSON_RESET = 1'b1;

	wire wb_clk = clk;
	wire wb_rst = !resetn;

	wire trap;


	reg [19:0] cmos_reset_cnt = 0;
	wire cmos_resetn = &cmos_reset_cnt;

	always @(posedge BOSON_CLK) begin
		cmos_reset_cnt <= cmos_reset_cnt + !cmos_resetn;
	end
	wire cmos_reset = !cmos_resetn;


	`include "wb_intercon/intercon_gen.vh"


	assign wb_s2m_ram0_err = 1'b0;
	assign wb_s2m_ram0_rty = 1'b0;
	assign wb_s2m_flash0_err = 1'b0;
	assign wb_s2m_flash0_rty = 1'b0;
	assign wb_s2m_spi_conf_err = 1'b0;
	assign wb_s2m_spi_conf_rty = 1'b0;
	assign wb_s2m_uart0_err = 1'b0;
	assign wb_s2m_uart0_rty = 1'b0;
	assign wb_s2m_gpio0_err = 1'b0;
	assign wb_s2m_gpio0_rty = 1'b0;
	assign wb_s2m_sdc_slave_err = 1'b0;
	assign wb_s2m_sdc_slave_rty = 1'b0;


	wire flash_io0_oe, flash_io0_do, flash_io0_di;
	wire flash_io1_oe, flash_io1_do, flash_io1_di;
	wire flash_io2_oe, flash_io2_do, flash_io2_di;
	wire flash_io3_oe, flash_io3_do, flash_io3_di;
	wire flash_clk;

	/* Flash IO buffers */
`ifdef SIM
`else
	USRMCLK u1 (.USRMCLKI(flash_clk), .USRMCLKTS(flash_csb)) /* synthesis syn_noprune=1 */;
`endif
	BBPU flash_io_buf[3:0] (
		.B({flash_io3, flash_io2, flash_io1, flash_io0}),
		.T({!flash_io3_oe,!flash_io2_oe,!flash_io1_oe, !flash_io0_oe}),
		.I({flash_io3_do, flash_io2_do, flash_io1_do, flash_io0_do}),
		.O({flash_io3_di, flash_io2_di, flash_io1_di, flash_io0_di})
	);


// CMOS interface

	wire [15:0] cmos_data_in;
	wire cmos_clk_in;
	wire cmos_vsync_in;
	wire cmos_hsync_in;
	wire cmos_valid_in;
	wire cmos_reset_out;


	IB cmos_data_io_buf [15:0] (
		.I(BOSON_DATA),
		.O(cmos_data_in)
	);
	
	IB cmos_hsync_io_buf (
		.I(BOSON_HSYNC),
		.O(cmos_hsync_in)
	);
	IB cmos_vsync_io_buf (
		.I(BOSON_VSYNC),
		.O(cmos_vsync_in)
	);
	IB cmos_valid_io_buf (
		.I(BOSON_VALID),
		.O(cmos_valid_in)
	);
	
	IB cmos_clk_io_buf (
		.I(BOSON_CLK),
		.O(cmos_clk_in)
	);
	
	

	wire [15:0] gpio_reg;
	
	wire card_detect;
	IBPU sdmmc_cd_buf (
		.I(SDMMC_CD),
		.O(card_detect)
	);
	
	assign wb_s2m_gpio0_ack = wb_m2s_gpio0_cyc & wb_m2s_gpio0_stb;
	wbgpio #(
		.NIN(16), .NOUT(16)
	) gpio (
		.i_clk     (wb_clk              ), 
		.i_wb_cyc  (wb_m2s_gpio0_cyc    ), 
		.i_wb_stb  (wb_m2s_gpio0_stb    ), 
		.i_wb_we   (wb_m2s_gpio0_we     ), 
		.i_wb_data (wb_m2s_gpio0_dat    ), 
		.o_wb_data (wb_s2m_gpio0_dat    ),
		.i_gpio    (gpio_reg), 
		.o_gpio    (gpio_reg            ), 
		.o_int     ()
	);
		

	//wire trap;
	//assign led = trap;
	assign fpga_reset = 1'b1;
	//assign led = wb_m2s_picorv32_cyc;
	assign led = gpio_reg[0];
	//assign led = flash_clk;
	
	assign ser_tx_dir = 1;
	assign ser_rx_dir = 0;
	

	
	
	/* RISCV CPU */
	picosoc cpu (
		.wb_rst_i    (wb_rst   ),
		.wb_clk_i    (wb_clk   ),
	
		.wbm_adr_o   (wb_m2s_picorv32_adr  ),
		.wbm_dat_o   (wb_m2s_picorv32_dat  ),
		.wbm_dat_i   (wb_s2m_picorv32_dat  ),
		.wbm_we_o    (wb_m2s_picorv32_we   ),
		.wbm_sel_o   (wb_m2s_picorv32_sel  ),
		.wbm_stb_o   (wb_m2s_picorv32_stb  ),
		.wbm_cyc_o   (wb_m2s_picorv32_cyc  ),
		.wbm_ack_i   (wb_s2m_picorv32_ack  ),

		.irq_5        (1'b0        ),
		.irq_6        (1'b0        ),
		.irq_7        (1'b0        ),
		.trap         (trap        )
	);
	
	
	//wire cmos_reset_out = 0;
	//OB cmos_reset_oi_buf (
	//	.O(BOSON_RESET),
	//	.I(cmos_reset_out)
	//)//;

	//SD Card interface
	wire sd_cmd_oe;
	wire sd_dat_oe;
	wire sd_cmd_in;
	wire [3:0] sd_dat_in;
	wire sd_cmd_out;
	wire [3:0] sd_dat_out;
	wire sd_clk_pad_o;
		
	/*
	* SD IO port
	*/
	reg [3:0] dat_out_ff;
	always @(negedge sd_clk_pad_o)
		dat_out_ff <= sd_dat_out;
	reg dat_out_oe;
	always @(negedge sd_clk_pad_o)
		dat_out_oe <= !sd_dat_oe;
	BBPU sdmmc_io_buf[3:0] (
		.B(SDMMC_DATA),
		.T(dat_out_oe),
		.I(dat_out_ff),
		.O(sd_dat_in)
	);
	
	reg cmd_out_ff;
	always @(negedge sd_clk_pad_o)
		cmd_out_ff <= sd_cmd_out;
	BBPU sdmmc_cmd_buf (
		.B(SDMMC_CMD),
		.T(!sd_cmd_oe),
		.I(cmd_out_ff),
		.O(sd_cmd_in)
	);
	
	OB sdmmc_ck_buf (
		.O(SDMMC_CK),
		.I(sd_clk_pad_o)
	);
	


	
	wire uart0_rx;
	wire uart0_tx;
	

	assign uart0_rx = ser_rx;
	assign ser_tx = uart0_tx;


	reg [1:0] uart0_stb_sr;
	wire uart0_stb = (uart0_stb_sr == 2'b01);
	always @(posedge wb_clk)
		uart0_stb_sr[1:0] <= {uart0_stb_sr[0],wb_m2s_uart0_stb & wb_m2s_uart0_cyc};

	wbuart #(
    .INITIAL_SETUP(416)
	) uart0(
		.i_clk(wb_clk),
		.i_rst(wb_rst),
		//
		.i_wb_cyc (wb_m2s_uart0_cyc),
		.i_wb_stb (uart0_stb), 
		.i_wb_we  (wb_m2s_uart0_we), 
		.i_wb_addr(wb_m2s_uart0_adr[3:2]), 
		.i_wb_data(wb_m2s_uart0_dat),
		.o_wb_ack (wb_s2m_uart0_ack),  
		.o_wb_data(wb_s2m_uart0_dat),
		//
		.i_uart_rx(uart0_rx), 
		.o_uart_tx(uart0_tx),
		/* Don't use hardware flow control tie cts HIGH */
		.i_cts_n(1'b1) 
	);


	


wire hb_clk_o;
wire hb_clk_n_o;
wire hb_cs_o;
wire hb_rwds_o;
wire hb_rwds_i;
wire hb_rwds_dir;
wire [7:0] hb_dq_o;
wire [7:0] hb_dq_i;
wire hb_dq_dir;
wire hb_rst_o;

	wb_hyper wb_hyper (
	.wb_clk_i     (wb_clk),
	.wb_rst_i     (wb_rst),
	//.clk90        (clk_90),
	.wb_dat_i     (wb_m2s_hram0_dat),
	.wb_adr_i     ({8'b0,wb_m2s_hram0_adr[23:0]}),
	.wb_sel_i     (wb_m2s_hram0_sel),
	.wb_cti_i     (wb_m2s_hram0_cti),
	.wb_we_i      (wb_m2s_hram0_we),
	.wb_cyc_i     (wb_m2s_hram0_cyc),
	.wb_stb_i     (wb_m2s_hram0_stb),
	.wb_dat_o     (wb_s2m_hram0_dat),
	.wb_ack_o     (wb_s2m_hram0_ack),
	.wb_cfg_dat_i (wb_m2s_hram0_cfg_dat),
	.wb_cfg_dat_o (wb_s2m_hram0_cfg_dat),
	.wb_cfg_adr_i ({24'b0,wb_m2s_hram0_cfg_adr[7:0]}),
	.wb_cfg_sel_i (wb_m2s_hram0_cfg_sel),
	.wb_cfg_we_i  (wb_m2s_hram0_cfg_we),
	.wb_cfg_cyc_i (wb_m2s_hram0_cfg_cyc),
	.wb_cfg_stb_i (wb_m2s_hram0_cfg_stb),
	.wb_cfg_ack_o (wb_s2m_hram0_cfg_ack),
	.hb_clk_o     (hb_clk_o            ),
	//.hb_clk_n_o   (hb_clk_n_o            ),
	.hb_cs_o      (hb_cs_o             ),
	.hb_rwds_o    (hb_rwds_o           ),
	.hb_rwds_i    (hb_rwds_i           ),
	.hb_rwds_dir  (hb_rwds_dir         ),
	.hb_dq_o      (hb_dq_o             ),
	.hb_dq_i      (hb_dq_i             ),
	.hb_dq_dir    (hb_dq_dir           )//,
	//.hb_rst_o     (hb_rst_o            )
);

	assign hb_clk_n_o = !hb_clk_o;


	BBPU hr_dq_b[7:0] (
		.B(HRAM_DQ),
		.T(hb_dq_dir),
		.I(hb_dq_o),
		.O(hb_dq_i)
	);
	
	BBPU hr_rwds_b (
		.B(HRAM_RWDS),
		.T(hb_rwds_dir),
		.I(hb_rwds_o),
		.O(hb_rwds_i)
	);

	OB hr_ck_a (
		.O(HRAM_CK[0]),
		.I(hb_clk_o)
	);
	OB hr_ck_b (
		.O(HRAM_CK[1]),
		.I(hb_clk_n_o)
	);
	

	OB hr_res_b (
		.O(HRAM_RESET),
		.I(hb_rst_o)
	);

	OB hr_cs_b (
		.O(HRAM_CS),
		.I(hb_cs_o)
	);

	
	spimemio_wb flash0
	(
		.wb_clk_i(wb_clk),
		.wb_rst_i(wb_rst),
		.wb_adr_i(wb_m2s_flash0_adr),
		.wb_cyc_i(wb_m2s_flash0_cyc),
		.wb_stb_i(wb_m2s_flash0_stb),
		.wb_dat_o(wb_s2m_flash0_dat),
		.wb_ack_o(wb_s2m_flash0_ack),

		.wb_spi_conf_dat_i(wb_m2s_spi_conf_dat),
		.wb_spi_conf_sel_i(wb_m2s_spi_conf_sel),
		.wb_spi_conf_we_i (wb_m2s_spi_conf_we),
		.wb_spi_conf_cyc_i(wb_m2s_spi_conf_cyc),
		.wb_spi_conf_stb_i(wb_m2s_spi_conf_stb),
		.wb_spi_conf_dat_o(wb_s2m_spi_conf_dat),
		.wb_spi_conf_ack_o(wb_s2m_spi_conf_ack),


		.flash_csb   (flash_csb),
		.flash_clk   (flash_clk),
		.flash_io0_oe(flash_io0_oe),
		.flash_io1_oe(flash_io1_oe),
		.flash_io2_oe(flash_io2_oe),
		.flash_io3_oe(flash_io3_oe),
		.flash_io0_do(flash_io0_do),
		.flash_io1_do(flash_io1_do),
		.flash_io2_do(flash_io2_do),
		.flash_io3_do(flash_io3_do),
		.flash_io0_di(flash_io0_di),
		.flash_io1_di(flash_io1_di),
		.flash_io2_di(flash_io2_di),
		.flash_io3_di(flash_io3_di)
	);
	
	
	picosoc_ram_wb #(
		.MEM_WORDS(4096)
	) ram0 (
		.wb_clk_i(wb_clk),
	    .wb_rst_i(wb_rst),
		.wb_adr_i(wb_m2s_ram0_adr),
		.wb_dat_i(wb_m2s_ram0_dat),
	    .wb_cyc_i(wb_m2s_ram0_cyc),
	    .wb_stb_i(wb_m2s_ram0_stb),
	    .wb_sel_i(wb_m2s_ram0_sel),
	    .wb_we_i (wb_m2s_ram0_we),
	    .wb_dat_o(wb_s2m_ram0_dat),
	    .wb_ack_o(wb_s2m_ram0_ack)
	);


	
	
	 /*
	  * 
	  */
	
	sdc_controller sd_controller_top_0
	(
		.wb_clk_i      (wb_clk                     ),
		.wb_rst_i      (wb_rst                     ),
		.wb_dat_i      (wb_m2s_sdc_slave_dat       ),
		.wb_dat_o      (wb_s2m_sdc_slave_dat       ),
		.wb_adr_i      (wb_m2s_sdc_slave_adr[7:0]  ),
		.wb_sel_i      (wb_m2s_sdc_slave_sel       ),
		.wb_we_i       (wb_m2s_sdc_slave_we        ),
		.wb_stb_i      (wb_m2s_sdc_slave_stb       ),
		.wb_cyc_i      (wb_m2s_sdc_slave_cyc       ),
		.wb_ack_o      (wb_s2m_sdc_slave_ack       ),
		.m_wb_adr_o    (wb_m2s_sdc_master_adr      ),
		.m_wb_sel_o    (wb_m2s_sdc_master_sel      ),
		.m_wb_we_o     (wb_m2s_sdc_master_we       ),
		.m_wb_dat_o    (wb_m2s_sdc_master_dat      ),
		.m_wb_dat_i    (wb_s2m_sdc_master_dat      ),
		.m_wb_cyc_o    (wb_m2s_sdc_master_cyc      ),
		.m_wb_stb_o    (wb_m2s_sdc_master_stb      ),
		.m_wb_ack_i    (wb_s2m_sdc_master_ack      ),
		.m_wb_cti_o    (wb_m2s_sdc_master_cti      ),
		.m_wb_bte_o    (wb_m2s_sdc_master_bte      ),

		.sd_cmd_dat_i  (sd_cmd_in    ),
		.sd_cmd_out_o  (sd_cmd_out   ),
		.sd_cmd_oe_o   (sd_cmd_oe    ),
		.sd_dat_dat_i  (sd_dat_in    ),  //sd_dat_pad_io),
		.sd_dat_out_o  (sd_dat_out   ),
		.sd_dat_oe_o   (sd_dat_oe    ),
		.sd_clk_o_pad  (sd_clk_pad_o ),
		.sd_clk_i_pad  (wb_clk       )
	);
	 
	 
	
	/* TODO Stream FlowControl module: 
	
		Tasks:
			Monitor Camera clk freq (freq capture)
			Monitor V-sync, clocks between pulses. (PWM capture?)
			Monitor H-Sync, clocks between pulses. (PWM capture?)
			Monitor Data EN, Total bits per frame,
			
			Count total frames.

		Syncronised V-sync.
	
		jk, set/reset to capture a total frame.
		 - CPU set register, monitor while frame capture is active.
		 - Module resets flag when frame is captured to RAM.
	
	*/
	


	wire cmos_enable_mask;
	wire streamer_irq;

	wb_cc_cfg wb_cc_cfg0
	(
		.wb_clk_i(wb_clk),
		.wb_rst_i(wb_rst),
		.wb_adr_i(wb_m2s_cc_cfg_adr[4:0]),
		.wb_dat_i(wb_m2s_cc_cfg_dat),
		.wb_sel_i(wb_m2s_cc_cfg_sel),
		.wb_we_i (wb_m2s_cc_cfg_we),
		.wb_cyc_i(wb_m2s_cc_cfg_cyc),
		.wb_stb_i(wb_m2s_cc_cfg_stb),
		.wb_cti_i(wb_m2s_cc_cfg_cti),
		.wb_bte_i(wb_m2s_cc_cfg_bte),
		.wb_dat_o(wb_s2m_cc_cfg_dat),
		.wb_ack_o(wb_s2m_cc_cfg_ack),
		.wb_err_o(wb_s2m_cc_cfg_err),
		.frame_start(!cmos_vsync_in),
		.capture_done(streamer_irq),
		.enable(cmos_enable_mask)
	);
	
	
	


	wire stream_up_valid,stream_up_ready;
	wire [31:0] stream_up_data;
	
	wire stream_wb_valid,stream_wb_ready;
	wire [31:0] stream_wb_data;


	stream_upsizer #(
		.DW_IN(16),
		.SCALE(2)
	) stream_up0 (
		.clk(cmos_clk_in),
		.rst(wb_rst),

		.s_data_i( cmos_data_in),
		.s_valid_i(cmos_valid_in),
		//.s_ready_o(ser_tx),

		.m_data_o (stream_up_data),
		.m_valid_o(stream_up_valid),
		.m_ready_i(stream_up_ready)
	);
	
	
	stream_dual_clock_fifo #(
	 .DW(32),
	 .AW(10)
	 ) stream_fifo_dc (
		.wr_clk(cmos_clk_in),
		.wr_rst(wb_rst),
		
		.stream_s_data_i(stream_up_data),
		.stream_s_valid_i(stream_up_valid & cmos_enable_mask),
		.stream_s_ready_o(stream_up_ready),
		
		.rd_clk(wb_clk),
		.rd_rst(wb_rst),
		
		.stream_m_data_o(stream_wb_data),
		.stream_m_valid_o(stream_wb_valid),
		.stream_m_ready_i(stream_wb_ready)
	 );
	



	wb_stream_reader #( 
		.WB_DW(32),
		.WB_AW(32),
		.FIFO_AW(7) 
	) wb_stream_reader0 (
		.clk			 (wb_clk),
		.rst			 (wb_rst),
		//Wisbhone memory interface
		.wbm_adr_o		 (wb_m2s_streamer_master_adr),
		.wbm_dat_o		 (wb_m2s_streamer_master_dat),
		.wbm_sel_o		 (wb_m2s_streamer_master_sel),
		.wbm_we_o 		 (wb_m2s_streamer_master_we ),
		.wbm_cyc_o		 (wb_m2s_streamer_master_cyc),
		.wbm_stb_o		 (wb_m2s_streamer_master_stb),
		.wbm_cti_o		 (wb_m2s_streamer_master_cti),
		.wbm_bte_o		 (wb_m2s_streamer_master_bte),
		.wbm_dat_i		 (wb_s2m_streamer_master_dat),
		.wbm_ack_i		 (wb_s2m_streamer_master_ack),
		.wbm_err_i		 (1'b0),
		//Stream interface
		.stream_s_data_i (stream_wb_data),
		.stream_s_valid_i(stream_wb_valid),
		.stream_s_ready_o(stream_wb_ready),
		.irq_o			 (streamer_irq),
		//Configuration interface
		.wbs_adr_i		 ( wb_m2s_streamer_adr[4:0]),
		.wbs_dat_i		 ( wb_m2s_streamer_dat     ),
		.wbs_sel_i		 ( wb_m2s_streamer_sel     ),
		.wbs_we_i 		 ( wb_m2s_streamer_we      ),
		.wbs_cyc_i		 ( wb_m2s_streamer_cyc     ),
		.wbs_stb_i		 ( wb_m2s_streamer_stb     ),
		.wbs_dat_o		 ( wb_s2m_streamer_dat     ),
		.wbs_ack_o		 ( wb_s2m_streamer_ack     ),
		.wbs_cti_i		 ( wb_m2s_streamer_cti     ),
		.wbs_bte_i		 ( wb_m2s_streamer_bte     )
	);
	
	

endmodule

	

