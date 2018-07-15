`default_nettype wire

module spimemio_wb
   (input          wb_clk_i,
    input          wb_rst_i,
	input [31:0]   wb_adr_i,
    input          wb_cyc_i,
    input          wb_stb_i,
    output  [31:0] wb_dat_o,
    output         wb_ack_o,
	
    input [31:0]  wb_spi_conf_dat_i,
    input  [3:0]  wb_spi_conf_sel_i,
    input         wb_spi_conf_we_i,
    input         wb_spi_conf_cyc_i,
    input         wb_spi_conf_stb_i,
    output [31:0] wb_spi_conf_dat_o,
    output        wb_spi_conf_ack_o,
	
	
	output flash_csb,
	output flash_clk,

	output flash_io0_oe,
	output flash_io1_oe,
	output flash_io2_oe,
	output flash_io3_oe,

	output flash_io0_do,
	output flash_io1_do,
	output flash_io2_do,
	output flash_io3_do,

	input  flash_io0_di,
	input  flash_io1_di,
	input  flash_io2_di,
	input  flash_io3_di
    
	);
	
	assign wb_spi_conf_ack_o = wb_spi_conf_stb_i && wb_spi_conf_cyc_i;
	
	spimemio spimemio (
		.clk    (wb_clk_i),
		.resetn (!wb_rst_i),
		.valid  ((wb_stb_i && wb_cyc_i)),
		.ready  (wb_ack_o),
		.addr   (wb_adr_i[23:0]),
		.rdata  (wb_dat_o),

		.flash_csb    (flash_csb   ),
		.flash_clk    (flash_clk   ),

		.flash_io0_oe (flash_io0_oe),
		.flash_io1_oe (flash_io1_oe),
		.flash_io2_oe (flash_io2_oe),
		.flash_io3_oe (flash_io3_oe),

		.flash_io0_do (flash_io0_do),
		.flash_io1_do (flash_io1_do),
		.flash_io2_do (flash_io2_do),
		.flash_io3_do (flash_io3_do),

		.flash_io0_di (flash_io0_di),
		.flash_io1_di (flash_io1_di),
		.flash_io2_di (flash_io2_di),
		.flash_io3_di (flash_io3_di),

		.cfgreg_we((wb_spi_conf_we_i && wb_spi_conf_cyc_i) ? wb_spi_conf_sel_i : 4'b 0000),
		.cfgreg_di(wb_spi_conf_dat_i),
		.cfgreg_do(wb_spi_conf_dat_o)
	);
	
	endmodule
	