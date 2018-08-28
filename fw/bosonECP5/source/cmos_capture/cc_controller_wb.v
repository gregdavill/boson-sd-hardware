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
		   arm_bit
       );

// WISHBONE common
input wire wb_clk_i;     // WISHBONE clock
input wire wb_rst_i;     // WISHBONE reset
input wire [31:0] wb_dat_i;     // WISHBONE data input
output reg [31:0] wb_dat_o;     // WISHBONE data output
// WISHBONE error output

// WISHBONE slave
input wire [4:0] wb_adr_i;     // WISHBONE address input
input wire [3:0] wb_sel_i;     // WISHBONE byte select input
input wire wb_we_i;      // WISHBONE write enable input
input wire wb_cyc_i;     // WISHBONE cycle input
input wire wb_stb_i;     // WISHBONE strobe input
output reg wb_ack_o;     // WISHBONE acknowledge output
//Buss accessible registers

//Register Controll
output wire arm_bit;

wire we;


reg arm_start;
reg [1:0] arm_sr;
always @(posedge wb_clk_i) arm_sr <= {arm_sr[0] , arm_start};
assign arm_bit = (arm_sr == 2'b01);

assign we = (wb_we_i && ((wb_stb_i && wb_cyc_i) || wb_ack_o)) ? 1'b1 : 1'b0;


always @(posedge wb_clk_i)
begin
    if (wb_rst_i) begin
        wb_ack_o <= 0;
		arm_start <= 0;
    end
    else
    begin
		wb_ack_o <= 0;
		arm_start <= 0;
        if (wb_stb_i & wb_cyc_i)begin
            if (wb_we_i) begin
                case (wb_adr_i)
                  4: arm_start <= wb_dat_i[0];    
                endcase
            end
            wb_ack_o <= ~wb_ack_o;
        end
    end
end


always @(posedge wb_clk_i) begin
    if (wb_rst_i == 1) begin
        wb_dat_o <= 0;
	end else begin
		wb_dat_o <= 0;
	end
end

endmodule
