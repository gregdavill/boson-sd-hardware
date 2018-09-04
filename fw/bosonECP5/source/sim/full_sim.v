
`timescale 1 ns/1 ns
`default_nettype wire

module top;


   //vlog_tb_utils vlog_tb_utils0();
   //vlog_tap_generator #("wb_hyper.tap", 1) vtg();

   reg	   wb_clk = 1'b1;
   reg     wb_clk90 = 1'b1;

   reg	   wb_rst = 1'b1;

   always #10 wb_clk <= ~wb_clk;
   initial  #500 wb_rst <= 0;

	always @(posedge wb_clk or negedge wb_clk)
		#5 wb_clk90 <= wb_clk;



`define SIM

	/* Create a Simulated SPI FLASH module */
wire csb;
wire clk;
wire io0;
wire io1;
wire io2;
wire io3;

spiflash flash (
	.csb(csb),
	.clk(clk),
	.io0(io0), // MOSI
	.io1(io1), // MISO
	.io2(io2),
	.io3(io3)
);


wire [15:0] cmos_dq;
wire cmos_clk;
wire cmos_vsync;
wire cmos_hsync;
wire cmos_valid;

bosonCamera cam (
	.reset(0),
	.CMOS_DQ   (cmos_dq   ),
	.CMOS_CLK  (cmos_clk  ),
	.CMOS_VSYNC(cmos_vsync),
	.CMOS_HSYNC(cmos_hsync),
	.CMOS_VALID(cmos_valid)
);

 ecp5demo dut (
	.clk_input(wb_clk),

	.ser_tx(),
	.ser_rx(1'b1),
	.ser_tx_dir(),
	.ser_rx_dir(),

	.led(clk),

	.flash_csb(csb),
	//.flash_clk(clk), /* CLK pin requires special USRMCLK module */
	.flash_io0(io0),
	.flash_io1(io1),
	.flash_io2(io2),
	.flash_io3(io3),
	
	.fpga_reset(),
	
	/* HYPER RAM SIGNALS */
	.HRAM_CK(),
	.HRAM_CS(),
	.HRAM_RWDS(),
	.HRAM_DQ(),
	.HRAM_RESET(),
	
	.SDMMC_CD(),
	.SDMMC_DATA(),
	.SDMMC_CMD(),
	.SDMMC_CK(),

	/* 16bit CMOS Camera interface */
	.BOSON_DATA(cmos_dq),
	.BOSON_CLK  (cmos_clk),
	.BOSON_VSYNC(),
	.BOSON_HSYNC(),
	.BOSON_VALID(cmos_valid),
	.BOSON_RESET()
);

endmodule

/*
module IB (
	input wire I,
	output wire O
);
	assign O = I;
endmodule

module IBPU (
	input wire I,
	output wire O
);
	assign O = I;
endmodule

module OB (
	input wire I,
	output wire O
);
	assign O = I;
endmodule

module BBPU (
	input wire I,
	output wire O,
	input wire T,
	inout B
);
	assign B = T ? 1'bz : I;
	assign O = B;

endmodule
*/