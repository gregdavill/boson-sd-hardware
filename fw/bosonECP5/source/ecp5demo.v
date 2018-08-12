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
	//output flash_clk, /* CLK pin requires special USRMCLK module */
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
	output wire [3:0] SDMMC_DATA,
	output wire SDMMC_CMD,
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
	
	//assign clk = clk_input;
	/* Feed the PLL to generate a 48MHZ sys clk */
	mainPLL _inst (.CLKI(clk_input), .CLKOP(clk), .CLKOS(clk_90), .LOCK(pll_lock));

	
	reg [13:0] reset_cnt = 0;
	wire resetn = &reset_cnt;

	always @(posedge clk) begin
		reset_cnt <= reset_cnt + !resetn;
	end
	
	assign BOSON_RESET = 1'b1;

	wire wb_clk = clk;
	wire wb_rst = !resetn;

	wire trap;

wire [31:0] wb_m2s_picorv32_adr;
wire [31:0] wb_m2s_picorv32_dat;
wire  [3:0] wb_m2s_picorv32_sel;
wire        wb_m2s_picorv32_we;
wire        wb_m2s_picorv32_cyc;
wire        wb_m2s_picorv32_stb;
wire  [2:0] wb_m2s_picorv32_cti;
wire  [1:0] wb_m2s_picorv32_bte;
wire [31:0] wb_s2m_picorv32_dat;
wire        wb_s2m_picorv32_ack;
wire        wb_s2m_picorv32_err;
wire        wb_s2m_picorv32_rty;
wire [31:0] wb_m2s_sdc_master_adr;
wire [31:0] wb_m2s_sdc_master_dat;
wire  [3:0] wb_m2s_sdc_master_sel;
wire        wb_m2s_sdc_master_we;
wire        wb_m2s_sdc_master_cyc;
wire        wb_m2s_sdc_master_stb;
wire  [2:0] wb_m2s_sdc_master_cti;
wire  [1:0] wb_m2s_sdc_master_bte;
wire [31:0] wb_s2m_sdc_master_dat;
wire        wb_s2m_sdc_master_ack;
wire        wb_s2m_sdc_master_err;
wire        wb_s2m_sdc_master_rty;
wire [31:0] wb_m2s_ccc_master_adr;
wire [31:0] wb_m2s_ccc_master_dat;
wire  [3:0] wb_m2s_ccc_master_sel;
wire        wb_m2s_ccc_master_we;
wire        wb_m2s_ccc_master_cyc;
wire        wb_m2s_ccc_master_stb;
wire  [2:0] wb_m2s_ccc_master_cti;
wire  [1:0] wb_m2s_ccc_master_bte;
wire [31:0] wb_s2m_ccc_master_dat;
wire        wb_s2m_ccc_master_ack;
wire        wb_s2m_ccc_master_err;
wire        wb_s2m_ccc_master_rty;
wire [31:0] wb_m2s_ram0_adr;
wire [31:0] wb_m2s_ram0_dat;
wire  [3:0] wb_m2s_ram0_sel;
wire        wb_m2s_ram0_we;
wire        wb_m2s_ram0_cyc;
wire        wb_m2s_ram0_stb;
wire  [2:0] wb_m2s_ram0_cti;
wire  [1:0] wb_m2s_ram0_bte;
wire [31:0] wb_s2m_ram0_dat;
wire        wb_s2m_ram0_ack;
wire        wb_s2m_ram0_err;
wire        wb_s2m_ram0_rty;
wire [31:0] wb_m2s_flash0_adr;
wire [31:0] wb_m2s_flash0_dat;
wire  [3:0] wb_m2s_flash0_sel;
wire        wb_m2s_flash0_we;
wire        wb_m2s_flash0_cyc;
wire        wb_m2s_flash0_stb;
wire  [2:0] wb_m2s_flash0_cti;
wire  [1:0] wb_m2s_flash0_bte;
wire [31:0] wb_s2m_flash0_dat;
wire        wb_s2m_flash0_ack;
wire        wb_s2m_flash0_err;
wire        wb_s2m_flash0_rty;
wire [31:0] wb_m2s_spi_conf_adr;
wire [31:0] wb_m2s_spi_conf_dat;
wire  [3:0] wb_m2s_spi_conf_sel;
wire        wb_m2s_spi_conf_we;
wire        wb_m2s_spi_conf_cyc;
wire        wb_m2s_spi_conf_stb;
wire  [2:0] wb_m2s_spi_conf_cti;
wire  [1:0] wb_m2s_spi_conf_bte;
wire [31:0] wb_s2m_spi_conf_dat;
wire        wb_s2m_spi_conf_ack;
wire        wb_s2m_spi_conf_err;
wire        wb_s2m_spi_conf_rty;
wire [31:0] wb_m2s_gpio0_adr;
wire [31:0] wb_m2s_gpio0_dat;
wire  [3:0] wb_m2s_gpio0_sel;
wire        wb_m2s_gpio0_we;
wire        wb_m2s_gpio0_cyc;
wire        wb_m2s_gpio0_stb;
wire  [2:0] wb_m2s_gpio0_cti;
wire  [1:0] wb_m2s_gpio0_bte;
wire [31:0] wb_s2m_gpio0_dat;
wire        wb_s2m_gpio0_ack;
wire        wb_s2m_gpio0_err;
wire        wb_s2m_gpio0_rty;
wire [31:0] wb_m2s_uart0_adr;
wire [31:0] wb_m2s_uart0_dat;
wire  [3:0] wb_m2s_uart0_sel;
wire        wb_m2s_uart0_we;
wire        wb_m2s_uart0_cyc;
wire        wb_m2s_uart0_stb;
wire  [2:0] wb_m2s_uart0_cti;
wire  [1:0] wb_m2s_uart0_bte;
wire [31:0] wb_s2m_uart0_dat;
wire        wb_s2m_uart0_ack;
wire        wb_s2m_uart0_err;
wire        wb_s2m_uart0_rty;
wire [31:0] wb_m2s_uart1_adr;
wire [31:0] wb_m2s_uart1_dat;
wire  [3:0] wb_m2s_uart1_sel;
wire        wb_m2s_uart1_we;
wire        wb_m2s_uart1_cyc;
wire        wb_m2s_uart1_stb;
wire  [2:0] wb_m2s_uart1_cti;
wire  [1:0] wb_m2s_uart1_bte;
wire [31:0] wb_s2m_uart1_dat;
wire        wb_s2m_uart1_ack;
wire        wb_s2m_uart1_err;
wire        wb_s2m_uart1_rty;
wire [31:0] wb_m2s_sdc_slave_adr;
wire [31:0] wb_m2s_sdc_slave_dat;
wire  [3:0] wb_m2s_sdc_slave_sel;
wire        wb_m2s_sdc_slave_we;
wire        wb_m2s_sdc_slave_cyc;
wire        wb_m2s_sdc_slave_stb;
wire  [2:0] wb_m2s_sdc_slave_cti;
wire  [1:0] wb_m2s_sdc_slave_bte;
wire [31:0] wb_s2m_sdc_slave_dat;
wire        wb_s2m_sdc_slave_ack;
wire        wb_s2m_sdc_slave_err;
wire        wb_s2m_sdc_slave_rty;
wire [31:0] wb_m2s_ccc_slave_adr;
wire [31:0] wb_m2s_ccc_slave_dat;
wire  [3:0] wb_m2s_ccc_slave_sel;
wire        wb_m2s_ccc_slave_we;
wire        wb_m2s_ccc_slave_cyc;
wire        wb_m2s_ccc_slave_stb;
wire  [2:0] wb_m2s_ccc_slave_cti;
wire  [1:0] wb_m2s_ccc_slave_bte;
wire [31:0] wb_s2m_ccc_slave_dat;
wire        wb_s2m_ccc_slave_ack;
wire        wb_s2m_ccc_slave_err;
wire        wb_s2m_ccc_slave_rty;
wire [31:0] wb_m2s_wb_streamer_slave_adr;
wire [31:0] wb_m2s_wb_streamer_slave_dat;
wire  [3:0] wb_m2s_wb_streamer_slave_sel;
wire        wb_m2s_wb_streamer_slave_we;
wire        wb_m2s_wb_streamer_slave_cyc;
wire        wb_m2s_wb_streamer_slave_stb;
wire  [2:0] wb_m2s_wb_streamer_slave_cti;
wire  [1:0] wb_m2s_wb_streamer_slave_bte;
wire [31:0] wb_s2m_wb_streamer_slave_dat;
wire        wb_s2m_wb_streamer_slave_ack;
wire        wb_s2m_wb_streamer_slave_err;
wire        wb_s2m_wb_streamer_slave_rty;
wire [31:0] wb_m2s_hram0_cfg_adr;
wire [31:0] wb_m2s_hram0_cfg_dat;
wire  [3:0] wb_m2s_hram0_cfg_sel;
wire        wb_m2s_hram0_cfg_we;
wire        wb_m2s_hram0_cfg_cyc;
wire        wb_m2s_hram0_cfg_stb;
wire  [2:0] wb_m2s_hram0_cfg_cti;
wire  [1:0] wb_m2s_hram0_cfg_bte;
wire [31:0] wb_s2m_hram0_cfg_dat;
wire        wb_s2m_hram0_cfg_ack;
wire        wb_s2m_hram0_cfg_err;
wire        wb_s2m_hram0_cfg_rty;
wire [31:0] wb_m2s_hram0_adr;
wire [31:0] wb_m2s_hram0_dat;
wire  [3:0] wb_m2s_hram0_sel;
wire        wb_m2s_hram0_we;
wire        wb_m2s_hram0_cyc;
wire        wb_m2s_hram0_stb;
wire  [2:0] wb_m2s_hram0_cti;
wire  [1:0] wb_m2s_hram0_bte;
wire [31:0] wb_s2m_hram0_dat;
wire        wb_s2m_hram0_ack;
wire        wb_s2m_hram0_err;
wire        wb_s2m_hram0_rty;

wb_intercon wb_intercon0
   (.wb_clk_i                   (wb_clk),
    .wb_rst_i                   (wb_rst),
    .wb_picorv32_adr_i          (wb_m2s_picorv32_adr),
    .wb_picorv32_dat_i          (wb_m2s_picorv32_dat),
    .wb_picorv32_sel_i          (wb_m2s_picorv32_sel),
    .wb_picorv32_we_i           (wb_m2s_picorv32_we),
    .wb_picorv32_cyc_i          (wb_m2s_picorv32_cyc),
    .wb_picorv32_stb_i          (wb_m2s_picorv32_stb),
    .wb_picorv32_cti_i          (wb_m2s_picorv32_cti),
    .wb_picorv32_bte_i          (wb_m2s_picorv32_bte),
    .wb_picorv32_dat_o          (wb_s2m_picorv32_dat),
    .wb_picorv32_ack_o          (wb_s2m_picorv32_ack),
    .wb_picorv32_err_o          (wb_s2m_picorv32_err),
    .wb_picorv32_rty_o          (wb_s2m_picorv32_rty),
    .wb_sdc_master_adr_i        (wb_m2s_sdc_master_adr),
    .wb_sdc_master_dat_i        (wb_m2s_sdc_master_dat),
    .wb_sdc_master_sel_i        (wb_m2s_sdc_master_sel),
    .wb_sdc_master_we_i         (wb_m2s_sdc_master_we),
    .wb_sdc_master_cyc_i        (wb_m2s_sdc_master_cyc),
    .wb_sdc_master_stb_i        (wb_m2s_sdc_master_stb),
    .wb_sdc_master_cti_i        (wb_m2s_sdc_master_cti),
    .wb_sdc_master_bte_i        (wb_m2s_sdc_master_bte),
    .wb_sdc_master_dat_o        (wb_s2m_sdc_master_dat),
    .wb_sdc_master_ack_o        (wb_s2m_sdc_master_ack),
    .wb_sdc_master_err_o        (wb_s2m_sdc_master_err),
    .wb_sdc_master_rty_o        (wb_s2m_sdc_master_rty),
    .wb_ccc_master_adr_i        (wb_m2s_ccc_master_adr),
    .wb_ccc_master_dat_i        (wb_m2s_ccc_master_dat),
    .wb_ccc_master_sel_i        (wb_m2s_ccc_master_sel),
    .wb_ccc_master_we_i         (wb_m2s_ccc_master_we),
    .wb_ccc_master_cyc_i        (wb_m2s_ccc_master_cyc),
    .wb_ccc_master_stb_i        (wb_m2s_ccc_master_stb),
    .wb_ccc_master_cti_i        (wb_m2s_ccc_master_cti),
    .wb_ccc_master_bte_i        (wb_m2s_ccc_master_bte),
    .wb_ccc_master_dat_o        (wb_s2m_ccc_master_dat),
    .wb_ccc_master_ack_o        (wb_s2m_ccc_master_ack),
    .wb_ccc_master_err_o        (wb_s2m_ccc_master_err),
    .wb_ccc_master_rty_o        (wb_s2m_ccc_master_rty),
    .wb_ram0_adr_o              (wb_m2s_ram0_adr),
    .wb_ram0_dat_o              (wb_m2s_ram0_dat),
    .wb_ram0_sel_o              (wb_m2s_ram0_sel),
    .wb_ram0_we_o               (wb_m2s_ram0_we),
    .wb_ram0_cyc_o              (wb_m2s_ram0_cyc),
    .wb_ram0_stb_o              (wb_m2s_ram0_stb),
    .wb_ram0_cti_o              (wb_m2s_ram0_cti),
    .wb_ram0_bte_o              (wb_m2s_ram0_bte),
    .wb_ram0_dat_i              (wb_s2m_ram0_dat),
    .wb_ram0_ack_i              (wb_s2m_ram0_ack),
    .wb_ram0_err_i              (wb_s2m_ram0_err),
    .wb_ram0_rty_i              (wb_s2m_ram0_rty),
    .wb_flash0_adr_o            (wb_m2s_flash0_adr),
    .wb_flash0_dat_o            (wb_m2s_flash0_dat),
    .wb_flash0_sel_o            (wb_m2s_flash0_sel),
    .wb_flash0_we_o             (wb_m2s_flash0_we),
    .wb_flash0_cyc_o            (wb_m2s_flash0_cyc),
    .wb_flash0_stb_o            (wb_m2s_flash0_stb),
    .wb_flash0_cti_o            (wb_m2s_flash0_cti),
    .wb_flash0_bte_o            (wb_m2s_flash0_bte),
    .wb_flash0_dat_i            (wb_s2m_flash0_dat),
    .wb_flash0_ack_i            (wb_s2m_flash0_ack),
    .wb_flash0_err_i            (wb_s2m_flash0_err),
    .wb_flash0_rty_i            (wb_s2m_flash0_rty),
    .wb_spi_conf_adr_o          (wb_m2s_spi_conf_adr),
    .wb_spi_conf_dat_o          (wb_m2s_spi_conf_dat),
    .wb_spi_conf_sel_o          (wb_m2s_spi_conf_sel),
    .wb_spi_conf_we_o           (wb_m2s_spi_conf_we),
    .wb_spi_conf_cyc_o          (wb_m2s_spi_conf_cyc),
    .wb_spi_conf_stb_o          (wb_m2s_spi_conf_stb),
    .wb_spi_conf_cti_o          (wb_m2s_spi_conf_cti),
    .wb_spi_conf_bte_o          (wb_m2s_spi_conf_bte),
    .wb_spi_conf_dat_i          (wb_s2m_spi_conf_dat),
    .wb_spi_conf_ack_i          (wb_s2m_spi_conf_ack),
    .wb_spi_conf_err_i          (wb_s2m_spi_conf_err),
    .wb_spi_conf_rty_i          (wb_s2m_spi_conf_rty),
    .wb_gpio0_adr_o             (wb_m2s_gpio0_adr),
    .wb_gpio0_dat_o             (wb_m2s_gpio0_dat),
    .wb_gpio0_sel_o             (wb_m2s_gpio0_sel),
    .wb_gpio0_we_o              (wb_m2s_gpio0_we),
    .wb_gpio0_cyc_o             (wb_m2s_gpio0_cyc),
    .wb_gpio0_stb_o             (wb_m2s_gpio0_stb),
    .wb_gpio0_cti_o             (wb_m2s_gpio0_cti),
    .wb_gpio0_bte_o             (wb_m2s_gpio0_bte),
    .wb_gpio0_dat_i             (wb_s2m_gpio0_dat),
    .wb_gpio0_ack_i             (wb_s2m_gpio0_ack),
    .wb_gpio0_err_i             (wb_s2m_gpio0_err),
    .wb_gpio0_rty_i             (wb_s2m_gpio0_rty),
    .wb_uart0_adr_o             (wb_m2s_uart0_adr),
    .wb_uart0_dat_o             (wb_m2s_uart0_dat),
    .wb_uart0_sel_o             (wb_m2s_uart0_sel),
    .wb_uart0_we_o              (wb_m2s_uart0_we),
    .wb_uart0_cyc_o             (wb_m2s_uart0_cyc),
    .wb_uart0_stb_o             (wb_m2s_uart0_stb),
    .wb_uart0_cti_o             (wb_m2s_uart0_cti),
    .wb_uart0_bte_o             (wb_m2s_uart0_bte),
    .wb_uart0_dat_i             (wb_s2m_uart0_dat),
    .wb_uart0_ack_i             (wb_s2m_uart0_ack),
    .wb_uart0_err_i             (wb_s2m_uart0_err),
    .wb_uart0_rty_i             (wb_s2m_uart0_rty),
    .wb_uart1_adr_o             (wb_m2s_uart1_adr),
    .wb_uart1_dat_o             (wb_m2s_uart1_dat),
    .wb_uart1_sel_o             (wb_m2s_uart1_sel),
    .wb_uart1_we_o              (wb_m2s_uart1_we),
    .wb_uart1_cyc_o             (wb_m2s_uart1_cyc),
    .wb_uart1_stb_o             (wb_m2s_uart1_stb),
    .wb_uart1_cti_o             (wb_m2s_uart1_cti),
    .wb_uart1_bte_o             (wb_m2s_uart1_bte),
    .wb_uart1_dat_i             (wb_s2m_uart1_dat),
    .wb_uart1_ack_i             (wb_s2m_uart1_ack),
    .wb_uart1_err_i             (wb_s2m_uart1_err),
    .wb_uart1_rty_i             (wb_s2m_uart1_rty),
    .wb_sdc_slave_adr_o         (wb_m2s_sdc_slave_adr),
    .wb_sdc_slave_dat_o         (wb_m2s_sdc_slave_dat),
    .wb_sdc_slave_sel_o         (wb_m2s_sdc_slave_sel),
    .wb_sdc_slave_we_o          (wb_m2s_sdc_slave_we),
    .wb_sdc_slave_cyc_o         (wb_m2s_sdc_slave_cyc),
    .wb_sdc_slave_stb_o         (wb_m2s_sdc_slave_stb),
    .wb_sdc_slave_cti_o         (wb_m2s_sdc_slave_cti),
    .wb_sdc_slave_bte_o         (wb_m2s_sdc_slave_bte),
    .wb_sdc_slave_dat_i         (wb_s2m_sdc_slave_dat),
    .wb_sdc_slave_ack_i         (wb_s2m_sdc_slave_ack),
    .wb_sdc_slave_err_i         (wb_s2m_sdc_slave_err),
    .wb_sdc_slave_rty_i         (wb_s2m_sdc_slave_rty),
    .wb_ccc_slave_adr_o         (wb_m2s_ccc_slave_adr),
    .wb_ccc_slave_dat_o         (wb_m2s_ccc_slave_dat),
    .wb_ccc_slave_sel_o         (wb_m2s_ccc_slave_sel),
    .wb_ccc_slave_we_o          (wb_m2s_ccc_slave_we),
    .wb_ccc_slave_cyc_o         (wb_m2s_ccc_slave_cyc),
    .wb_ccc_slave_stb_o         (wb_m2s_ccc_slave_stb),
    .wb_ccc_slave_cti_o         (wb_m2s_ccc_slave_cti),
    .wb_ccc_slave_bte_o         (wb_m2s_ccc_slave_bte),
    .wb_ccc_slave_dat_i         (wb_s2m_ccc_slave_dat),
    .wb_ccc_slave_ack_i         (wb_s2m_ccc_slave_ack),
    .wb_ccc_slave_err_i         (wb_s2m_ccc_slave_err),
    .wb_ccc_slave_rty_i         (wb_s2m_ccc_slave_rty),
    .wb_wb_streamer_slave_adr_o (wb_m2s_wb_streamer_slave_adr),
    .wb_wb_streamer_slave_dat_o (wb_m2s_wb_streamer_slave_dat),
    .wb_wb_streamer_slave_sel_o (wb_m2s_wb_streamer_slave_sel),
    .wb_wb_streamer_slave_we_o  (wb_m2s_wb_streamer_slave_we),
    .wb_wb_streamer_slave_cyc_o (wb_m2s_wb_streamer_slave_cyc),
    .wb_wb_streamer_slave_stb_o (wb_m2s_wb_streamer_slave_stb),
    .wb_wb_streamer_slave_cti_o (wb_m2s_wb_streamer_slave_cti),
    .wb_wb_streamer_slave_bte_o (wb_m2s_wb_streamer_slave_bte),
    .wb_wb_streamer_slave_dat_i (wb_s2m_wb_streamer_slave_dat),
    .wb_wb_streamer_slave_ack_i (wb_s2m_wb_streamer_slave_ack),
    .wb_wb_streamer_slave_err_i (wb_s2m_wb_streamer_slave_err),
    .wb_wb_streamer_slave_rty_i (wb_s2m_wb_streamer_slave_rty),
    .wb_hram0_cfg_adr_o         (wb_m2s_hram0_cfg_adr),
    .wb_hram0_cfg_dat_o         (wb_m2s_hram0_cfg_dat),
    .wb_hram0_cfg_sel_o         (wb_m2s_hram0_cfg_sel),
    .wb_hram0_cfg_we_o          (wb_m2s_hram0_cfg_we),
    .wb_hram0_cfg_cyc_o         (wb_m2s_hram0_cfg_cyc),
    .wb_hram0_cfg_stb_o         (wb_m2s_hram0_cfg_stb),
    .wb_hram0_cfg_cti_o         (wb_m2s_hram0_cfg_cti),
    .wb_hram0_cfg_bte_o         (wb_m2s_hram0_cfg_bte),
    .wb_hram0_cfg_dat_i         (wb_s2m_hram0_cfg_dat),
    .wb_hram0_cfg_ack_i         (wb_s2m_hram0_cfg_ack),
    .wb_hram0_cfg_err_i         (wb_s2m_hram0_cfg_err),
    .wb_hram0_cfg_rty_i         (wb_s2m_hram0_cfg_rty),
    .wb_hram0_adr_o             (wb_m2s_hram0_adr),
    .wb_hram0_dat_o             (wb_m2s_hram0_dat),
    .wb_hram0_sel_o             (wb_m2s_hram0_sel),
    .wb_hram0_we_o              (wb_m2s_hram0_we),
    .wb_hram0_cyc_o             (wb_m2s_hram0_cyc),
    .wb_hram0_stb_o             (wb_m2s_hram0_stb),
    .wb_hram0_cti_o             (wb_m2s_hram0_cti),
    .wb_hram0_bte_o             (wb_m2s_hram0_bte),
    .wb_hram0_dat_i             (wb_s2m_hram0_dat),
    .wb_hram0_ack_i             (wb_s2m_hram0_ack),
    .wb_hram0_err_i             (wb_s2m_hram0_err),
    .wb_hram0_rty_i             (wb_s2m_hram0_rty));





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
	USRMCLK u1 (.USRMCLKI(flash_clk), .USRMCLKTS(!resetn)) /* synthesis syn_noprune=1 */;
	BBPU flash_io_buf[3:0] (
		.B({flash_io3, flash_io2, flash_io1, flash_io0}),
		.T({!flash_io3_oe,!flash_io2_oe,!flash_io1_oe, !flash_io0_oe}),
		.I({flash_io3_do, flash_io2_do, flash_io1_do, flash_io0_do}),
		.O({flash_io3_di, flash_io2_di, flash_io1_di, flash_io0_di})
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
		.i_gpio    ({card_detect, 15'b0}), 
		.o_gpio    (gpio_reg            ), 
		.o_int     ()
	);
		

	//wire trap;
	//assign led = trap;
	assign fpga_reset = 1'b1;
	assign led = gpio_reg[0];
	
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
	//OB cmos_reset_oi_buf (
	//	.O(BOSON_RESET),
	//	.I(cmos_reset_out)
	//);

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
	/*
	reg [3:0] dat_out_ff;
	always @(negedge sd_clk_pad_o)
		dat_out_ff <= sd_dat_out;
	BBPU sdmmc_io_buf[3:0] (
		.B(SDMMC_DATA),
		.T(!sd_dat_oe),
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
	*/


	
	wire uart0_rx,uart0_tx;
	wire uart1_rx,uart1_tx;

	assign uart1_rx = 1;

`ifdef SUMP2
	/* Disconnect the UART */
	assign uart0_rx = uart1_tx;
`else
	assign uart0_rx = ser_rx;
	assign ser_tx = uart0_tx;
	
`endif

	reg [1:0] uart0_stb_sr;
	wire uart0_stb = (uart0_stb_sr == 2'b01);
	always @(posedge wb_clk)
		uart0_stb_sr[1:0] <= {uart0_stb_sr[0],wb_m2s_uart0_stb};

	wbuart #(
    .INITIAL_SETUP(416),
	.HARDWARE_FLOW_CONTROL_PRESENT(0)
	) uart0(
		.i_clk(wb_clk),
		.i_rst(wb_rst),
		//
		.i_wb_cyc (wb_m2s_uart0_cyc),
		.i_wb_stb (uart0_stb && wb_m2s_uart0_cyc), 
		.i_wb_we  (wb_m2s_uart0_we), 
		.i_wb_addr(wb_m2s_uart0_adr[3:2]), 
		.i_wb_data(wb_m2s_uart0_dat),
		.o_wb_ack (wb_s2m_uart0_ack),  
		.o_wb_data(wb_s2m_uart0_dat),
		//
		.i_uart_rx(uart0_rx), 
		.o_uart_tx(uart0_tx)
	);

	
	
	wbuart uart1(
		.i_clk(wb_clk),
		.i_rst(1'b1),
		//
		.i_wb_cyc (wb_m2s_uart1_cyc),
		.i_wb_stb (wb_m2s_uart1_stb && wb_m2s_uart0_cyc), 
		.i_wb_we  (wb_m2s_uart1_we), 
		.i_wb_addr(wb_m2s_uart1_adr[3:2]), 
		.i_wb_data(wb_m2s_uart1_dat),
		.o_wb_ack (wb_s2m_uart1_ack),  
		.o_wb_data(wb_s2m_uart1_dat),
		//
		.i_uart_rx(uart1_rx), 
		.o_uart_tx(uart1_tx)
	);
	

	


wire hb_clk_o;
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
	.wb_dat_i     (wb_m2s_hram0_dat),
	.wb_adr_i     (wb_m2s_hram0_adr[23:0]),
	.wb_sel_i     (wb_m2s_hram0_sel),
	.wb_cti_i     (wb_m2s_hram0_cti),
	.wb_we_i      (wb_m2s_hram0_we),
	.wb_cyc_i     (wb_m2s_hram0_cyc),
	.wb_stb_i     (wb_m2s_hram0_stb),
	.wb_dat_o     (wb_s2m_hram0_dat),
	.wb_ack_o     (wb_s2m_hram0_ack),
	.wb_cfg_dat_i (wb_m2s_hram0_cfg_dat),
	.wb_cfg_dat_o (wb_s2m_hram0_cfg_dat),
	.wb_cfg_adr_i (wb_m2s_hram0_cfg_adr[7:0]),
	.wb_cfg_sel_i (wb_m2s_hram0_cfg_sel),
	.wb_cfg_we_i  (wb_m2s_hram0_cfg_we),
	.wb_cfg_cyc_i (wb_m2s_hram0_cfg_cyc),
	.wb_cfg_stb_i (wb_m2s_hram0_cfg_stb),
	.wb_cfg_ack_o (wb_s2m_hram0_cfg_ack),
	.hb_clk_o     (hb_clk_o            ),
	.hb_cs_o      (hb_cs_o             ),
	.hb_rwds_o    (hb_rwds_o           ),
	.hb_rwds_i    (hb_rwds_i           ),
	.hb_rwds_dir  (hb_rwds_dir         ),
	.hb_dq_o      (hb_dq_o             ),
	.hb_dq_i      (hb_dq_i             ),
	.hb_dq_dir    (hb_dq_dir           ),
	.hb_rst_o     (hb_rst_o            )
);




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

	OB hr_ck_b [1:0] (
		.O(HRAM_CK),
		.I({!hb_clk_o,hb_clk_o})
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
	 
	 
	
	cc_controller cc_controller_top0(
        .wb_clk_i      (wb_clk                     ),
		.wb_rst_i      (wb_rst                     ),
		.wb_dat_i      (wb_m2s_ccc_slave_dat       ),
		.wb_dat_o      (wb_s2m_ccc_slave_dat       ),
		.wb_adr_i      (wb_m2s_ccc_slave_adr[7:0]  ),
		.wb_sel_i      (wb_m2s_ccc_slave_sel       ),
		.wb_we_i       (wb_m2s_ccc_slave_we        ),
		.wb_stb_i      (wb_m2s_ccc_slave_stb       ),
		.wb_cyc_i      (wb_m2s_ccc_slave_cyc       ),
		.wb_ack_o      (wb_s2m_ccc_slave_ack       ),
		.wb_streamer_dat_i      (wb_m2s_wb_streamer_slave_dat       ),
		.wb_streamer_dat_o      (wb_s2m_wb_streamer_slave_dat       ),
		.wb_streamer_adr_i      (wb_m2s_wb_streamer_slave_adr[7:0]  ),
		.wb_streamer_sel_i      (wb_m2s_wb_streamer_slave_sel       ),
		.wb_streamer_we_i       (wb_m2s_wb_streamer_slave_we        ),
		.wb_streamer_stb_i      (wb_m2s_wb_streamer_slave_stb       ),
		.wb_streamer_cyc_i      (wb_m2s_wb_streamer_slave_cyc       ),
		.wb_streamer_ack_o      (wb_s2m_wb_streamer_slave_ack       ),
		.m_wb_adr_o    (wb_m2s_ccc_master_adr      ),
		.m_wb_sel_o    (wb_m2s_ccc_master_sel      ),
		.m_wb_we_o     (wb_m2s_ccc_master_we       ),
		.m_wb_dat_o    (wb_m2s_ccc_master_dat      ),
		.m_wb_dat_i    (wb_s2m_ccc_master_dat      ),
		.m_wb_cyc_o    (wb_m2s_ccc_master_cyc      ),
		.m_wb_stb_o    (wb_m2s_ccc_master_stb      ),
		.m_wb_ack_i    (wb_s2m_ccc_master_ack      ),
		.m_wb_cti_o    (wb_m2s_ccc_master_cti      ),
		.m_wb_bte_o    (wb_m2s_ccc_master_bte      ),
		
		   // CMOS data interface
		.cmos_data_i   (cmos_data_in),
		.cmos_clk_i    (cmos_clk_in),
		.cmos_vsync_i  (cmos_vsync_in),
		.cmos_hsync_i  (cmos_hsync_in),
		.cmos_valid_i  (cmos_valid_in),
		.cmos_reset_o  (cmos_reset_out)
    );
	
	
	OB sdmmc_ck_buf_0 (
		.O(SDMMC_CK),
		.I(wb_clk)
	);
	OB sdmmc_ck_buf_1 (
		.O(SDMMC_CMD),
		.I(wb_m2s_picorv32_cyc)
	);
	OB sdmmc_ck_buf_2 (
		.O(SDMMC_DATA[0]),
		.I(wb_s2m_picorv32_err)
	);
	
	
`ifdef SUMP2

	wire [31:0] dbg_data;
	
	assign dbg_data[3] = wb_s2m_picorv32_ack;
	assign dbg_data[2] = wb_m2s_picorv32_we;
	assign dbg_data[1] = wb_m2s_picorv32_stb;
	assign dbg_data[0] = wb_m2s_picorv32_cyc;
	
	assign dbg_data[4] = wb_m2s_flash0_cyc;
	assign dbg_data[5] = wb_m2s_ram0_cyc;
	assign dbg_data[6] = wb_m2s_uart0_cyc;
	assign dbg_data[7] = wb_m2s_gpio0_cyc;
	
	assign dbg_data[8] = wb_m2s_ccc_slave_cyc;
	assign dbg_data[9] = wb_m2s_sdc_slave_cyc;
	//assign dbg_data[10] = wb_m2s_ccc_slave_cyc;
	
	assign dbg_data[11] = wb_s2m_picorv32_err;
	
	assign dbg_data[12] = wb_m2s_ccc_master_cyc;
	assign dbg_data[13] = wb_m2s_ccc_master_stb;
	assign dbg_data[14] = wb_s2m_ccc_master_ack;
	
	
	//assign dbg_data[15] = ser_rx;
	//assign dbg_data[16] = ser_tx;
	
	assign dbg_data[17] = trap;
	
	
	assign dbg_data[24] = flash_clk;
	assign dbg_data[25] = flash_io0_oe ? flash_io0_do : flash_io0_di;
	assign dbg_data[26] = flash_io1_oe ? flash_io1_do : flash_io1_di;
	assign dbg_data[27] = flash_io2_oe ? flash_io2_do : flash_io2_di;
	assign dbg_data[28] = flash_io3_oe ? flash_io3_do : flash_io3_di;
	assign dbg_data[29] = flash_io0_oe;
	
	
	
	/* SUMP2 Embedded Logic Analyser */
	sump2_top sump2_top0(
		.clk        (wb_clk),
		.serial_rx_i(ser_rx),
		.serial_tx_o(ser_tx),
		.events_i   (dbg_data)
	);

`endif	

endmodule

	

