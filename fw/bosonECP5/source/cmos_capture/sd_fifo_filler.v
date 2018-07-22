//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_fifo_filler.v                                             ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Fifo interface between sd card and wishbone clock domains    ////
//// and DMA engine eble to write/read to/from CPU memory         ////
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

module cc_fifo_filler(
           input wire wb_clk,
           input wire rst,
           //WB Signals
           output reg [31:0] wbm_adr_o,
           output wire wbm_we_o,
           output wire [31:0] wbm_dat_o,
           input wire [31:0] wbm_dat_i,
           output wire wbm_cyc_o,
           output wire wbm_stb_o,
           input wire wbm_ack_i,
           //Data Master Control signals
           input wire en_rx_i,
           input wire [31:0] adr_i,
           //Data Serial signals
           input wire cmos_clk,
           input wire [31:0] dat_i,
           input wire wr_i,
           output wire cc_full_o,
           output wire wb_empty_o
       );

`define FIFO_MEM_ADR_SIZE 8
`define MEM_OFFSET 4

wire reset_fifo;
wire fifo_rd;
reg fifo_rd_ack;
reg fifo_rd_reg;

assign fifo_rd = wbm_cyc_o & wbm_ack_i;
assign reset_fifo = !en_rx_i;

assign wbm_we_o = en_rx_i & !wb_empty_o;
assign wbm_cyc_o = en_rx_i & !wb_empty_o;
assign wbm_stb_o = en_rx_i ? wbm_cyc_o & fifo_rd_ack : wbm_cyc_o;

generic_fifo_dc_gray #(
    .dw(32), 
    .aw(`FIFO_MEM_ADR_SIZE)
    ) generic_fifo_dc_gray0 (
    .rd_clk(wb_clk),
    .wr_clk(sd_clk), 
    .rst(!(rst | reset_fifo)), 
    .clr(1'b0), 
    .din(dat_i), 
    .we(wr_i),
    .dout(wbm_dat_o), 
    .re(en_rx_i & wbm_cyc_o & wbm_ack_i), 
    .full(cc_full_o), 
    .empty(wb_empty_o), 
    .wr_level(), 
    .rd_level() 
    );


always @(posedge wb_clk or posedge rst)
    if (rst) begin
        wbm_adr_o <= 0;
        fifo_rd_reg <= 0;
        fifo_rd_ack <= 1;
    end
    else begin
        fifo_rd_reg <= fifo_rd;
        fifo_rd_ack <= fifo_rd_reg | !fifo_rd;
        if (wbm_cyc_o & wbm_stb_o & wbm_ack_i)
            wbm_adr_o <= wbm_adr_o + `MEM_OFFSET;
        else if (reset_fifo)
            wbm_adr_o <= adr_i;
    end

endmodule


