//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sdc_controller.v                                             ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Top level entity.                                            ////
//// This core is based on the "sd card controller" project from  ////
//// http://opencores.org/project,sdcard_mass_storage_controller  ////
//// but has been largely rewritten. A lot of effort has been     ////
//// made to make the core more generic and easily usable         ////
//// with OSs like Linux.                                         ////
//// - data transfer commands are not fixed                       ////
//// - data transfer block size is configurable                   ////
//// - multiple block transfer support                            ////
//// - R2 responses (136 bit) support                             ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
////                                                              ////
//// Based on original work by                                    ////
////     Adam Edvardsson (adam.edvardsson@orsoc.se)               ////
////                                                              ////
////     Copyright (C) 2009 Authors                               ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
`default_nettype wire

module cc_controller(
           // WISHBONE common
           wb_clk_i, 
           wb_rst_i, 
           // WISHBONE slave
           wb_dat_i, 
           wb_dat_o,
           wb_adr_i, 
           wb_sel_i, 
           wb_we_i, 
           wb_cyc_i, 
           wb_stb_i, 
           wb_ack_o,
           // WISHBONE master
           m_wb_dat_o,
           m_wb_dat_i,
           m_wb_adr_o, 
           m_wb_sel_o, 
           m_wb_we_o,
           m_wb_cyc_o,
           m_wb_stb_o, 
           m_wb_ack_i,
           m_wb_cti_o, 
           m_wb_bte_o,
		   // CMOS data interface
		   cmos_data_i,
		   cmos_clk_i,
		   cmos_vsync_i,
		   cmos_hsync_i,
		   cmos_valid_i,
		   cmos_reset_o
       );

input wb_clk_i;
input wb_rst_i;
input [31:0] wb_dat_i;
output [31:0] wb_dat_o;
//input card_detect;
input [7:0] wb_adr_i;
input [3:0] wb_sel_i;
input wb_we_i;
input wb_cyc_i;
input wb_stb_i;
output wb_ack_o;
output [31:0] m_wb_adr_o;
output [3:0] m_wb_sel_o;
output m_wb_we_o;
input [31:0] m_wb_dat_i;
output [31:0] m_wb_dat_o;
output m_wb_cyc_o;
output m_wb_stb_o;
input m_wb_ack_i;
output [2:0] m_wb_cti_o;
output [1:0] m_wb_bte_o;

input wire [15:0] cmos_data_i;
input wire cmos_clk_i;
input wire cmos_vsync_i;
input wire cmos_hsync_i;
input wire cmos_valid_i;
output wire cmos_reset_o;


//wb accessible registers
wire [31:0] dma_addr_reg;
wire [31:0] status_reg;
wire [31:0] data_count_reg;
wire [31:0] data_count_reg_wb;

wire [31:0] wbm_adr;


wire cc_start;

wire [31:0] data_in_rx_fifo;

cc_data_host cc_data_host0 (
	.cmos_clk_i     (cmos_clk_i),
    .rst            (wb_rst_i),
    .data_out       (data_in_rx_fifo),
    .we             (we_fifo),
    .cmos_data_i    (cmos_data_i),
	.cmos_hsync_i   (cmos_hsync_i),
	.cmos_vsync_i   (cmos_vsync_i),
	.cmos_valid_i   (cmos_valid_i),
	.cmos_reset_o   (cmos_reset_o),
	.start			(cc_start),
	.data_count_reg (data_count_reg)
);

cc_fifo_filler cc_fifo_filler0(
    .wb_clk    (wb_clk_i),
    .rst       (wb_rst_i),
    .wbm_adr_o (wbm_adr),
    .wbm_we_o  (m_wb_we_o),
    .wbm_dat_o (m_wb_dat_o),
    .wbm_dat_i (m_wb_dat_i),
    .wbm_cyc_o (m_wb_cyc_o),
    .wbm_stb_o (m_wb_stb_o),
    .wbm_ack_i (m_wb_ack_i),
    .en_rx_i   (start_rx_fifo),
    .adr_i     (dma_addr_reg),
    .cmos_clk  (cmos_clk_i),
    .dat_i     (data_in_rx_fifo),
    .wr_i      (we_fifo),
    .cc_full_o (rx_fifo_full),
    .wb_empty_o   ()
    );


cc_controller_wb cc_controller_wb0(
    .wb_clk_i                       (wb_clk_i),
    .wb_rst_i                       (wb_rst_i),
    .wb_dat_i                       (wb_dat_i),
    .wb_dat_o                       (wb_dat_o),
    .wb_adr_i                       (wb_adr_i),
    .wb_sel_i                       (wb_sel_i),
    .wb_we_i                        (wb_we_i),
    .wb_stb_i                       (wb_stb_i),
    .wb_cyc_i                       (wb_cyc_i),
    .wb_ack_o                       (wb_ack_o),
    .cc_start                       (cc_start),
    .data_count_reg                 (data_count_reg_wb),
    .status_reg                     (status_reg),
    .dma_addr_reg                   (dma_addr_reg)
    );

assign m_wb_cti_o = 3'b000;
assign m_wb_bte_o = 2'b00;



bistable_domain_cross #(32) data_count_reg_cross(wb_rst_i, cmos_clk_i, data_count_reg, wb_clk_i, data_count_reg_wb);


assign m_wb_sel_o = 4'b1111;
assign m_wb_adr_o = {wbm_adr[31:2], 2'b00};

endmodule
