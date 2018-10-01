/* ****************************************************************************
-- (C) Copyright 2018 Kevin M. Hubbard - All rights reserved.
-- Source file: xil_oddr.v 
-- Date:        May 2018 
-- Author:      khubbard
-- Language:    Verilog-2001
-- Simulation:  Mentor-Modelsim
-- Synthesis:   Xilinx-Vivado
-- License:     This project is licensed with the CERN Open Hardware Licence
--              v1.2.  You may redistribute and modify this project under the
--              terms of the CERN OHL v.1.2. (http://ohwr.org/cernohl).
--              This project is distributed WITHOUT ANY EXPRESS OR IMPLIED
--              WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
--              AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN OHL
--              v.1.2 for applicable Conditions.
-- Description: Xilinx 7-Series IDDR DDR input flop
-- Note: 100ns Power On Reset requirement until functional
-- Timing Diagram for SAME_EDGE_PIPELINED
--     |100ns|
-- clk ______/    \____/    \____/    \____/    \
-- din_ris  ---------< 0       >< 2      >----
-- din_fal  ---------< 1       >< 3      >----
-- dout     -----------< 0 >< 1 >< 2 >< 3 >----
-- ************************************************************************* */
`timescale 1 ns/ 100 ps
module ecp_oddr
(
  input  wire  clk,
  input  wire  din_ris,
  input  wire  din_fal,
  output wire  dout,
  input wire rst
);// 


/*
	Lattice FPGA User Guide states:

	D0 = First to be sent out
	D1 = Second to be sent out.

	Note sure right now if D0 == Rising Edge or Falling Edge.
*/

// ODDR1XF: Generic X1 ODDR implementation
// Lattice FPGA Libraries Reference Guide
ODDRX1F ODDRX1F_inst 
(
  .Q    ( dout    ),  // 1-bit DDR output
  .SCLK ( clk     ),  // 1-bit clock input
  .D0   ( din_ris ),  // 1-bit data input (positive edge)
  .D1   ( din_fal ),  // 1-bit data input (negative edge)
  .RST  ( rst    )   // 1-bit reset
);
// End of ODDR1XF_inst instantiation


endmodule
