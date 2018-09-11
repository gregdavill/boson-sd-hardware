
`timescale 1 ns/1 ns
`default_nettype wire

module top;


   vlog_tb_utils vlog_tb_utils0();
   vlog_tap_generator #("wb_hyper.tap", 1) vtg();

   reg	   wb_clk = 1'b1;
   reg     wb_clk90 = 1'b1;


   always #10 wb_clk <= ~wb_clk;

	always @(posedge wb_clk or negedge wb_clk)
		#5 wb_clk90 <= wb_clk;


	initial begin

		

		repeat (6500) @(posedge clk);

		top.sd0.CardStatus[12:9] = 6;

		force top.dut.sd_controller_top_0.sd_data_master0.start_tx_i = 1;

		repeat (1) @(posedge clk);
		release top.dut.sd_controller_top_0.sd_data_master0.start_tx_i;
		
		repeat (14000) @(posedge clk);
		$finish;
	end



`define SIM

	/* hyperram signals */
	wire hr_ck_p;
	wire hr_ck_n;
	wire hr_cs;
	wire hr_rwds;
	wire [7:0] hr_dq;
	wire hr_rst;

s27ks0641 #(.TimingModel("S27KS0641DPBHI020"))
     s27ks0641 (
		// Inouts
		.DQ7			(hr_dq[7]),
		.DQ6			(hr_dq[6]),
		.DQ5			(hr_dq[5]),
		.DQ4			(hr_dq[4]),
		.DQ3			(hr_dq[3]),
		.DQ2			(hr_dq[2]),
		.DQ1			(hr_dq[1]),
		.DQ0			(hr_dq[0]),
		.RWDS			(hr_rwds),	
		// Inputs
		.CSNeg			(hr_cs),	
		.CK			    (hr_ck_p),		
		.CKNeg			(hr_ck_n),	
		.RESETNeg		(hr_rst));



wire sd_clk;
wire sd_cmd;
wire [3:0] sd_dat;

sdModel #(
	.ramdisk(""),
  	.log_file("sd_log.txt")
  ) sd0 (
  .sdClk(sd_clk),
  .cmd(sd_cmd),
  .dat(sd_dat)
);


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

	.led(),

	.flash_csb(csb),
	.flash_clk(clk), /* CLK pin requires special USRMCLK module */
	.flash_io0(io0),
	.flash_io1(io1),
	.flash_io2(io2),
	.flash_io3(io3),
	
	.fpga_reset(),

	/* HYPER RAM SIGNALS */
	.HRAM_CK({hr_ck_n, hr_ck_p}),
	.HRAM_CS(hr_cs),
	.HRAM_RWDS(hr_rwds),
	.HRAM_DQ(hr_dq),
	.HRAM_RESET(hr_rst),
	
	.SDMMC_CD(),
	.SDMMC_DATA(sd_dat),
	.SDMMC_CMD(sd_cmd),
	.SDMMC_CK(sd_clk),

	/* 16bit CMOS Camera interface */
	.BOSON_DATA(cmos_dq),
	.BOSON_CLK  (cmos_clk),
	.BOSON_VSYNC(cmos_vsync),
	.BOSON_HSYNC(),
	.BOSON_VALID(cmos_valid),
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
