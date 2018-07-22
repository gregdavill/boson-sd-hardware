//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_controller_wb.v                                           ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Wishbone interface responsible for comunication with core    ////
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
`include "cc_defines.h"

module cc_controller_wb(
           // WISHBONE slave
           wb_clk_i, 
           wb_rst_i, 
           wb_dat_i, 
           wb_dat_o,
           wb_adr_i, 
           wb_sel_i, 
           wb_we_i, 
           wb_cyc_i, 
           wb_stb_i, 
           wb_ack_o,
           cc_start,
           data_count_reg,
           status_reg,
           dma_addr_reg
       );

// WISHBONE common
input wb_clk_i;     // WISHBONE clock
input wb_rst_i;     // WISHBONE reset
input [31:0] wb_dat_i;     // WISHBONE data input
output reg [31:0] wb_dat_o;     // WISHBONE data output
// WISHBONE error output

// WISHBONE slave
input [7:0] wb_adr_i;     // WISHBONE address input
input [3:0] wb_sel_i;     // WISHBONE byte select input
input wb_we_i;      // WISHBONE write enable input
input wb_cyc_i;     // WISHBONE cycle input
input wb_stb_i;     // WISHBONE strobe input
output reg wb_ack_o;     // WISHBONE acknowledge output
output reg cc_start;
//Buss accessible registers
input wire [31:0] data_count_reg;
input wire [31:0] status_reg;

//Register Controll
output [31:0] dma_addr_reg;

wire we;


assign we = (wb_we_i && ((wb_stb_i && wb_cyc_i) || wb_ack_o)) ? 1'b1 : 1'b0;

byte_en_reg #(32) dma_addr_r(wb_clk_i, wb_rst_i, we && wb_adr_i == `dst_src_addr, wb_sel_i[3:0], wb_dat_i, dma_addr_reg);


always @(posedge wb_clk_i or posedge wb_rst_i)
begin
    if (wb_rst_i)begin
        wb_ack_o <= 0;
    end
    else
    begin
        if ((wb_stb_i & wb_cyc_i) || wb_ack_o)begin
            //if (wb_we_i) begin
            //    case (wb_adr_i)
            //        
            //    endcase
            //end
            wb_ack_o <= wb_cyc_i & wb_stb_i & ~wb_ack_o;
        end
    end
end


always @(posedge wb_clk_i or posedge wb_rst_i)begin
    if (wb_rst_i == 1)
        wb_dat_o <= 0;
    else
        if (wb_stb_i & wb_cyc_i) begin //CS
            case (wb_adr_i)
                `data_count: wb_dat_o <= data_count_reg;
                `status: wb_dat_o <= status_reg;
                `dst_src_addr: wb_dat_o <= dma_addr_reg;
            endcase
        end
end

endmodule