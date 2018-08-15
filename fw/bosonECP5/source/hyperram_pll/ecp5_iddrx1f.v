/* ****************************************************************************
-- (C) Copyright 2018 Kevin M. Hubbard - All rights reserved.
-- Source file: xil_iddr.v 
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
-- din ---------< 0 >< 1 >< 2 >< 3 >----------
-- dout_ris ---------------------< 1      >< 3     >
-- dout_fal -----------< 0      >< 2      >----
-- ************************************************************************* */
`timescale 1 ns/ 100 ps
module ecp_iddr
(
  input  wire  clk,
  input  wire  din,
  output wire  dout_ris,
  output wire  dout_fal
);// 



// IDDR1XF: Generic X1 IDDR implementation
// Lattice FPGA Libraries Reference Guide
IDDRX1F IDDRX1F_inst
(
  .Q0    ( dout_ris ), // 1-bit output for positive edge of clock
  .Q1    ( dout_fal ), // 1-bit output for negative edge of clock
  .SCLK  ( clk      ), // 1-bit clock input
  .D     ( din      ), // 1-bit DDR data input
  .RST   ( 1'b0     )  // 1-bit reset
);
// End of IDDR1XF_inst instantiation


endmodule
