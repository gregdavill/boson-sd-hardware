/* ****************************************************************************
-- Source file: top.v                
-- Date:        October 08, 2016
-- Author:      khubbard
-- Description: Top Level Verilog RTL for Lattice ICE5LP FPGA Design
-- Language:    Verilog-2001 and VHDL-1993
-- Simulation:  Mentor-Modelsim 
-- Synthesis:   Lattice     
-- License:     This project is licensed with the CERN Open Hardware Licence
--              v1.2.  You may redistribute and modify this project under the
--              terms of the CERN OHL v.1.2. (http://ohwr.org/cernohl).
--              This project is distributed WITHOUT ANY EXPRESS OR IMPLIED
--              WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
--              AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN OHL
--              v.1.2 for applicable Conditions.
-- 
--  Lattice ICE-Stick
--               -----------------------------------------------------------
--             /                   119 118 117 116 115 114 113 112 GND  3V  |
--            /                      o   o   o   o   o   o   o   o   o   o  |
--           /                                               -----          |
--   -------             ---------          R            3V |o   o|3V       |
--  |          -------  |         |         |           GND |o P o|GND      |
--  |USB      | FTDI  | |Lattice  |      R--G--R    event[7]|o M o|event[6] |
--  |         |FT2232H| |iCE40HX1K|         |       event[5]|o O o|event[4] |
--  |          -------  |         |         R       event[3]|o D o|event[2] |
--   -------             ---------                  event[1]|o   o|event[0] |
--           \                                               -----          |
--            \                      o   o   o   o   o   o   o   o   o   o  |
--             \                    44  45  47  48  56  60  61  62  GND 3V  |
--               ----------------------------------------------------------- 
--                           event [15][14][13][12][11][10] [9] [8]
--
-- Revision History:
-- Ver#  When      Who      What
-- ----  --------  -------- ---------------------------------------------------
-- 0.1   10.08.16  khubbard Creation
-- ***************************************************************************/
`default_nettype none // Strictly enforce all nets to be declared

module sump2_top
(
  input  wire         clk,
  input  wire         serial_rx_i,
  output wire         serial_tx_o,
  input  wire [31:0]   events_i
);// module top

  wire          lb_wr;
  wire          lb_rd;
  wire [31:0]   lb_addr;
  wire [31:0]   lb_wr_d;
  wire [31:0]   lb_rd_d;
  wire          lb_rd_rdy;
  wire [31:0]   events_loc;



  wire          mesa_wi_loc;
  wire          mesa_wo_loc;
  wire          mesa_ri_loc;
  wire          mesa_ro_loc;

  wire          mesa_wi_nib_en;
  wire [3:0]    mesa_wi_nib_d;
  wire          mesa_wo_byte_en;
  wire [7:0]    mesa_wo_byte_d;
  wire          mesa_wo_busy;
  wire          mesa_ro_byte_en;
  wire [7:0]    mesa_ro_byte_d;
  wire          mesa_ro_busy;
  wire          mesa_ro_done;
  wire [7:0]    mesa_core_ro_byte_d;
  wire          mesa_core_ro_byte_en;
  wire          mesa_core_ro_done;
  wire          mesa_core_ro_busy;


  wire          mesa_wi_baudlock;

  // Hookup FTDI RX and TX pins to MesaBus Phy
  assign mesa_wi_loc  = serial_rx_i;
  assign serial_tx_o  = mesa_ro_loc;


  assign events_loc   = events_i;
  

//-----------------------------------------------------------------------------
// Note: 40kHz modulated ir_rxd signal looks like this
//  \_____/                       \___/                      \___/
//  |<2us>|<-------24us----------->
//-----------------------------------------------------------------------------



//-----------------------------------------------------------------------------
// FSM for reporting ID : This also muxes in Ro Byte path from Core
// This didn't fit in ICE-Stick, so removed.
//-----------------------------------------------------------------------------
//mesa_id u_mesa_id
//(
//  .reset                 ( reset_loc                ),
//  .clk                   ( clk_lb_tree              ),
//  .report_id             ( report_id                ),
//  .id_mfr                ( 32'h00000001             ),
//  .id_dev                ( 32'h00000002             ),
//  .id_snum               ( 32'h00000001             ),
//
//  .mesa_core_ro_byte_en  ( mesa_core_ro_byte_en     ),
//  .mesa_core_ro_byte_d   ( mesa_core_ro_byte_d[7:0] ),
//  .mesa_core_ro_done     ( mesa_core_ro_done        ),
//  .mesa_ro_byte_en       ( mesa_ro_byte_en          ),
//  .mesa_ro_byte_d        ( mesa_ro_byte_d[7:0]      ),
//  .mesa_ro_done          ( mesa_ro_done             ),
//  .mesa_ro_busy          ( mesa_ro_busy             )
//);// module mesa_id
 assign mesa_ro_byte_d[7:0] = mesa_core_ro_byte_d[7:0];
 assign mesa_ro_byte_en     = mesa_core_ro_byte_en;
 assign mesa_ro_done        = mesa_core_ro_done;
 assign mesa_core_ro_busy   = mesa_ro_busy;


//-----------------------------------------------------------------------------
// MesaBus Phy : Convert UART serial to/from binary for Mesa Bus Interface
//  This translates between bits and bytes
//-----------------------------------------------------------------------------
mesa_phy u_mesa_phy
(
//.reset            ( reset_core          ),
  .reset            ( 1'b0           ),
  .clk              ( clk         ),
  .clr_baudlock     ( 1'b0                ),
  .disable_chain    ( 1'b1                ),
  .mesa_wi_baudlock (     ),
  .mesa_wi          ( mesa_wi_loc         ),
  .mesa_ro          ( mesa_ro_loc         ),
  .mesa_wo          ( mesa_wo_loc         ),
  .mesa_ri          ( mesa_ri_loc         ),
  .mesa_wi_nib_en   ( mesa_wi_nib_en      ),
  .mesa_wi_nib_d    ( mesa_wi_nib_d[3:0]  ),
  .mesa_wo_byte_en  ( mesa_wo_byte_en     ),
  .mesa_wo_byte_d   ( mesa_wo_byte_d[7:0] ),
  .mesa_wo_busy     ( mesa_wo_busy        ),
  .mesa_ro_byte_en  ( mesa_ro_byte_en     ),
  .mesa_ro_byte_d   ( mesa_ro_byte_d[7:0] ),
  .mesa_ro_busy     ( mesa_ro_busy        ),
  .mesa_ro_done     ( mesa_ro_done        )
);// module mesa_phy


//-----------------------------------------------------------------------------
// MesaBus Core : Decode Slot,Subslot,Command Info and translate to LocalBus
//-----------------------------------------------------------------------------
mesa_core 
#
(
  .spi_prom_en       ( 1'b0                       )
)
u_mesa_core
(
//.reset               ( reset_core               ),
  .reset               ( 1'b0       ),
  .clk                 ( clk              ),
  .spi_sck             (                   ),
  .spi_cs_l            (                  ),
  .spi_mosi            (                  ),
  .spi_miso            (                  ),
  .rx_in_d             ( mesa_wi_nib_d[3:0]       ),
  .rx_in_rdy           ( mesa_wi_nib_en           ),
  .tx_byte_d           ( mesa_core_ro_byte_d[7:0] ),
  .tx_byte_rdy         ( mesa_core_ro_byte_en     ),
  .tx_done             ( mesa_core_ro_done        ),
  .tx_busy             ( mesa_core_ro_busy        ),
  .tx_wo_byte          ( mesa_wo_byte_d[7:0]      ),
  .tx_wo_rdy           ( mesa_wo_byte_en          ),
  .subslot_ctrl        (                          ),
  .bist_req            (                          ),
  .reconfig_req        (                          ),
  .reconfig_addr       (                          ),
  .oob_en              ( 1'b0                     ),
  .oob_done            ( 1'b0                     ),
  .lb_wr               ( lb_wr                    ),
  .lb_rd               ( lb_rd                    ),
  .lb_wr_d             ( lb_wr_d[31:0]            ),
  .lb_addr             ( lb_addr[31:0]            ),
  .lb_rd_d             ( lb_rd_d[31:0]            ),
  .lb_rd_rdy           ( lb_rd_rdy                )
);// module mesa_core


//-----------------------------------------------------------------------------
// Design Specific Logic
//-----------------------------------------------------------------------------
core u_core 
(
//.reset               ( reset_core               ),
  .reset               ( 1'b0        ),
  .clk_lb              ( clk                      ),
  .clk_cap             ( clk                      ),
  .lb_wr               ( lb_wr                    ),
  .lb_rd               ( lb_rd                    ),
  .lb_wr_d             ( lb_wr_d[31:0]            ),
  .lb_addr             ( lb_addr[31:0]            ),
  .lb_rd_d             ( lb_rd_d[31:0]            ),
  .lb_rd_rdy           ( lb_rd_rdy                ),
  .led_bus             (                          ),
  .events_din          ( events_loc[31:0]         )
);  


endmodule // top.v
