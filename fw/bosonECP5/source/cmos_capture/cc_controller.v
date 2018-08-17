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
`default_nettype none

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
           // WISHBONE slave wb_streamer
           wb_streamer_dat_i, 
           wb_streamer_dat_o,
           wb_streamer_adr_i, 
           wb_streamer_sel_i, 
           wb_streamer_we_i, 
           wb_streamer_cyc_i, 
           wb_streamer_stb_i, 
           wb_streamer_ack_o,
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
		   cmos_reset_o,
		   
		   dbg_out
       );

input wire wb_clk_i;
input wire wb_rst_i;
input wire [31:0] wb_dat_i;
output wire [31:0] wb_dat_o;
input wire [7:0] wb_adr_i;
input wire [3:0] wb_sel_i;
input wire wb_we_i;
input wire wb_cyc_i;
input wire wb_stb_i;
output wire wb_ack_o;

input wire [31:0]  wb_streamer_dat_i;
output wire [31:0] wb_streamer_dat_o;
input wire [7:0]   wb_streamer_adr_i;
input wire [3:0]   wb_streamer_sel_i;
input wire         wb_streamer_we_i;
input wire         wb_streamer_cyc_i;
input wire         wb_streamer_stb_i;
output wire         wb_streamer_ack_o;

output wire [31:0] m_wb_adr_o;
output wire [3:0] m_wb_sel_o;
output wire m_wb_we_o;
input wire [31:0] m_wb_dat_i;
output wire [31:0] m_wb_dat_o;
output wire m_wb_cyc_o;
output wire m_wb_stb_o;
input wire m_wb_ack_i;
output wire [2:0] m_wb_cti_o;
output wire [1:0] m_wb_bte_o;

input wire [15:0] cmos_data_i;
input wire cmos_clk_i;
input wire cmos_vsync_i;
input wire cmos_hsync_i;
input wire cmos_valid_i;
output wire cmos_reset_o;

output wire [7:0] dbg_out;

//wb accessible registers
wire [31:0] dma_addr_reg;
wire [31:0] status_reg;
wire [31:0] data_count_reg;
wire [31:0] data_count_reg_wb;

wire arm_bit_wb,arm_bit_cmos;


wire cc_data_valid;
wire cc_start;


wire stream_s_ready_o;


cc_data_host cc_data_host0 (
	.cmos_clk_i     (cmos_clk_i),
    .rst            (wb_rst_i),
    .cmos_data_i    (cmos_data_i),
	.cmos_hsync_i   (cmos_hsync_i),
	.cmos_vsync_i   (cmos_vsync_i),
	.cmos_valid_i   (cmos_valid_i),
	.cmos_reset_o   (cmos_reset_o),
	/* Data ready to be read */
	.cmos_en_o      (cc_data_valid),
	/* Control Signals */
	.arm			(arm_bit_cmos),
	.data_count_reg (data_count_reg)
);

cc_controller_wb cc_controller_wb0(
    .wb_clk_i                       (wb_clk_i),
    .wb_rst_i                       (wb_rst_i),
    .wb_dat_i                       (wb_dat_i),
    .wb_dat_o                       (wb_dat_o),
    .wb_adr_i                       (wb_adr_i[4:0]),
    .wb_sel_i                       (wb_sel_i),
    .wb_we_i                        (wb_we_i),
    .wb_stb_i                       (wb_stb_i),
    .wb_cyc_i                       (wb_cyc_i),
    .wb_ack_o                       (wb_ack_o),
    .data_count_reg                 (data_count_reg_wb),
    .status_reg                     (status_reg),
    .dma_addr_reg                   (dma_addr_reg),
	.arm_bit                        (arm_bit_wb)
    );



	wb_stream_reader #(
		.WB_DW(32),
		.WB_AW(32),
		.FIFO_AW(5) 
		) cmos_streamer (
		.clk			 (wb_clk_i),
		.rst			 (wb_rst_i),
		//Wisbhone memory interface
		.wbm_adr_o		 (m_wb_adr_o),
		.wbm_dat_o		 (m_wb_dat_o),
		.wbm_sel_o		 (m_wb_sel_o),
		.wbm_we_o 		 (m_wb_we_o ),
		.wbm_cyc_o		 (m_wb_cyc_o),
		.wbm_stb_o		 (m_wb_stb_o),
		.wbm_cti_o		 (m_wb_cti_o),
		.wbm_bte_o		 (m_wb_bte_o),
		.wbm_dat_i		 (m_wb_dat_i),
		.wbm_ack_i		 (m_wb_ack_i),
		//.wbm_err_i		 (m_wb_err_i),
		//Stream interface
		.stream_s_clk_i  (cmos_clk_i),
		.stream_s_data_i ({16'b0,cmos_data_i}),
		.stream_s_valid_i(cc_data_valid),
		.stream_s_ready_o(stream_s_ready_o),
		.irq_o			 (),
		//Configuration interface
		.wbs_adr_i		 (wb_streamer_adr_i[4:0]),
		.wbs_dat_i		 (wb_streamer_dat_i),
		.wbs_sel_i		 (wb_streamer_sel_i),
		.wbs_we_i 		 (wb_streamer_we_i ),
		.wbs_cyc_i		 (wb_streamer_cyc_i),
		.wbs_stb_i		 (wb_streamer_stb_i),
		.wbs_dat_o		 (wb_streamer_dat_o),
		.wbs_ack_o		 (wb_streamer_ack_o)
	);




/* Control signals crossing into CMOS_CLK */
monostable_domain_cross arm_bit_cross(wb_rst_i, wb_clk_i, arm_bit_wb, cmos_clk_i, arm_bit_cmos);


bistable_domain_cross #(32) data_count_reg_cross(wb_rst_i, cmos_clk_i, data_count_reg, wb_clk_i, data_count_reg_wb);



assign dbg_out[0] = arm_bit_wb;


endmodule
