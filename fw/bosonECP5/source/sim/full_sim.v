
`timescale 1 us/1 us
`default_nettype none

module top;


   vlog_tb_utils vlog_tb_utils0();
   vlog_tap_generator #("wb_hyper.tap", 1) vtg();

   reg	   wb_clk = 1'b1;
   reg     wb_clk90 = 1'b1;

   reg	   wb_rst = 1'b1;

   always #6 wb_clk <= ~wb_clk;
   initial  #500 wb_rst <= 0;

	always @(posedge wb_clk or negedge wb_clk)
		#3 wb_clk90 <= wb_clk;

	reg done = 0;
	wire trap;


	


	always @(posedge done) begin
      vtg.ok("All tests complete");
      $display("All tests complete");
      $finish;
   end




	always @(posedge wb_clk) begin
		if(trap)
			done <= 1;
	end

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


 ecp5demo dut (
	.clk_input(wb_clk),

	.ser_tx(),
	.ser_rx(),
	.ser_tx_dir(),
	.ser_rx_dir(),

	.led(),

	.trap(trap),

	.flash_csb(csb),
	.flash_clk(clk), /* CLK pin requires special USRMCLK module */
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
	.BOSON_DATA(),
	.BOSON_CLK  (),
	.BOSON_VSYNC(),
	.BOSON_HSYNC(),
	.BOSON_VALID(),
	.BOSON_RESET()
);

endmodule


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