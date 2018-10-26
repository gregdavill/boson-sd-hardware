/* ****************************************************************************
-- (C) Copyright 2018 Kevin M. Hubbard - All rights reserved.
-- Source file: hyper_xface_pll.v           
-- Date:        July 2018
-- Author:      khubbard
-- Language:    Verilog-2001 
-- Simulation:  Xilinx-Vivado   
-- Synthesis:   Xilinx-Vivado
-- License:     This project is licensed with the CERN Open Hardware Licence
--              v1.2.  You may redistribute and modify this project under the
--              terms of the CERN OHL v.1.2. (http://ohwr.org/cernohl).
--              This project is distributed WITHOUT ANY EXPRESS OR IMPLIED
--              WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
--              AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN OHL
--              v.1.2 for applicable Conditions.
-- Description: S27KL0641DABHI020 : Cypress IC DRAM 64MBIT 3V 100MHZ 24BGA
--              This is a dword interface module to HyperRAM for writing
--              and reading DWORDs. This version runs the core at the same 
--              clock as the DRAM. It requires an external PLL to generate a 
--              clock 90o shifted from the data and also requires DDR flops
--              for outputting 16bit data onto 8 pins at DDR.
--              Power On Reset : Part requires 150uS after Power On or Reset
-- History:
--   2018.07.01 : khubbard : Fork from original hyper_xface.v Div-4 module
--   2018.08.08 : khubbard : First release.
--
-- [ Section-1 ]
-- Write Single Cycle:
--  clk        /\/\/\
--  wr_req     / \__
--  addr[47:0] < >--
--  wr_d[31:0] < >--
--  busy       __/                                                        \_
--                 1       2       3      ...   .     14      15      16
--  dram_ck    __/   \___/   \___/   \___/   \_  \___/   \___/   \___/   \__
--  dram_cs_l  \___________________________________________________________/
--  dram_dq    <A1><A2><A3><A4><A5><A6>--------------------<11><22><33><44>-
--
-- Read  Cycle:
--  clk        /\/\/\
--  rd_req     / \___
--  addr       < >---
--  num_dwrds  < >---
--  busy       __/                                                        \_
--  rd_d       ----------------------------------------------------------<>-
--  rd_rdy     __________________________________________________________/\_
--                 1       2       3      ...       14      15      16
--  dram_ck    __/   \___/   \___/   \___/   \_  __/   \___/   \___/   \__
--  dram_cs_l  \___________________________________________________________/
--  dram_dq    <A1><A2><A3><A4><A5><A6>--------------------<11><22><33><44>-
--  dram_rwds  _/                     \____________________/   \___/   \____
--
-- Write Burst Cycle:
--  Writes may be bursted in groups of 32bits by asserting wr_req 
--  immediately when burst_wr_rdy has asserted. Note Addr is ignored. Burst
--  is automatically terminated when wr_req is NOT asserted after burst_wr_rdy
--  wr_req       / \_________________/ \___/ \_______________
--  addr[47:0]   <A>--------------<X>---<X>------------------
--  wr_d[31:0]   <B>--------------<C>---<D>------------------
--  burst_wr_rdy _________________/ \___/ \___/  \___________
--  dram_cs_l     \____________________________________/
--  dram_dq      --<A><A><A><A><A><A><B><B><C><C><D><D>------
--
-- Read Burst Cycle:
--  rd_req       / \_________________________________________
--  addr[47:0]   <A>-----------------------------------------
--  num_dwords   < >-----------------------------------------
--  busy       __/                                      \____
--  rd_d       ----------------------------------<C>--<D>----
--  rd_rdy     __________________________________/ \__/ \____
--  dram_cs_l     \___________________________________/
--  dram_dq      --<A><A><A><A><A>---------<C><C><D><D>------
--  dram_rwds    __________________________/  \__/  \________
--
-- [ Section-2 ]
-- Core Interface Description:
--  clk           : in  : FPGA clock. Actual DRAM clock is this shifted 90o.
--  clk_90p       : in  : Phase shifted clock. This only drives ODDR mirror.
--  rd_req        : in  : When core not busy, assert 1ck to make read request.
--  wr_req        : in  : When core not busy, assert 1ck to make write request.
--  mem_or_req    : in  : 0=DRAM Memory. 1=Configuration Register 
--                        Note: Not functional yet.
--  rd_num_dwords : in  : Number of dwords to read, example 0x01.
--  addr          : in  : 32bit DWORD address for 64Mbit DRAM cell.
--  wr_d          : in  : 32bit Write Data to DRAM.
--  rd_d          : out : 32bit Read Data from DRAM.
--  rd_rdy        : out : Read Ready Strobe. Asserts 1ck when rd_d is valid.
--  busy          : out : Busy Strobe asserts when Read or Write cycle is busy.
--  burst_wr_rdy  : out : Asserts when ready to accept next wr_req for burst.
--  lat_2x        : out : Asserts to indicate a 2x cycle just happened. Might 
--                        be useful for backing off some upstream FIFO, etc.
--                        observations are that this rarely asserts.
--
-- [ Section-3 ]
-- Example Setup: HyperRAM requires that both the DRAM and the Controller 
--   agree to a fixed latency. The FPGA controller is configured via the
--   latency_1x and latency_2x input ports. The DRAM is configured via a 
--   write to configuration register 0. The default setting is really slow 
--   but has the advantage of not requiring a special configuration cycle
--   at the beginning of time. The difference is about 2x, for example 8 vs
--   16 DRAM clocks for a single DWORD xfer. Default always uses 2x latency,
--   ignoring the rwds completely.
--   Default 6 Clock 166 MHz Latency, latency1x=0x07, latency2x=0x0a
--     CfgReg0 write(0x00000800, 0x8f1f0000);
--   Configd 3 Clock  83 MHz Latency, latency1x=0x04, latency2x=0x04
--     CfgReg0 write(0x00000800, 0x8fe40000);
--
-- Variable 1x/2x Latency:
--   8f14 0a07; 166 MHz  1x / 2x 12/18 clocks for 2 DWORD Writes
--   8f04 0806; 133 MHz  1x / 2x 11/16 clocks for 2 DWORD Writes
--   8ff4 0605; 100 MHz  1x / 2x 10/14 clocks for 2 DWORD Writes
--   8fe4 0404;  83 MHz  1x / 2x  9/12 clocks for 2 DWORD Writes
-- Fixed 2x Latency:
--   8f1c 0a07; 166 MHz  
--   8f0c 0806; 133 MHz  
--   8ffc 0605; 100 MHz  
--   8fec 0404;  83 MHz  
--
--  D(31:16) correspond to the configuration write 
--  D(15:8)  correspond to the 2x latency_2x[7:0] port.
--  D(7:0)   correspond to the 1x latency_1x[7:0] port.
--
-- [ Section-4 ] IOB Testing on Rev-1 "S7 Mini" prototype from BML
--  Note: DDR so datarate is 2x, ie 200 Mbps for 100 MHz
--    75 MHz :  4mA Slow  90o : Works 
--    86 MHz :  4mA Slow  90o : No response
--    86 MHz :  8mA Fast  90o : ?
--    86 MHz : 16mA Fast  90o : Works
--    83 MHz : 16mA Fast  90o : 8ff40605 100%
--                              8fe40404 100%
--    91 MHz : 16mA Fast  90o : 8ffc0605 100%
--                              8ff40605  90%
--   100 MHz : 16mA Fast  90o : 8ffc0605   0%
--                              8ff40605   0%
--   100 MHz : 16mA Fast  90o : Doesn't work
--   100 MHz : 16mA Fast 112o : Doesn't work
--   100 MHz : 16mA Fast 135o : Doesn't work
-- The writes are failing sometimes at 90 MHz > . Reads are actually fine.
-- Seems like force 2x latency is required above 90 MHz
-- ***************************************************************************/
`timescale 1 ns/ 100 ps
`default_nettype none // Strictly enforce all nets to be declared
  
module hyper_xface_pll
(
  input  wire         simulation_en,
  input  wire         reset,
  input  wire         clk,
  input  wire         clk_90p,
  input  wire         rd_req,
  input  wire         wr_req,
  input  wire         mem_or_reg,
  //input  wire [5:0]   rd_num_dwords,
  input  wire         rd_burst_en,
  input  wire [31:0]  addr,
  input  wire [31:0]  wr_d,
  output reg  [31:0]  rd_d,
  output reg          rd_rdy,
  output wire         busy,
  output reg          burst_wr_rdy,
  output reg          lat_2x,

  output wire         dram_rst_l,
  output wire         dram_ck,
  output wire         dram_ck_n,
  output wire         dram_cs_l,
  input  wire [7:0]   dram_dq_in,
  output wire [7:0]   dram_dq_out,
  output reg          dram_dq_oe_l,
  input  wire         dram_rwds_in,
  output reg          dram_rwds_out,
  output reg          dram_rwds_oe_l,

  output reg  [7:0]   cycle_len,
  output wire [31:0]  sump_dbg
);// module hyper_xface_pll


  wire [7:0]   latency_1x;
  wire [7:0]   latency_2x;
  reg  [15:0]  latency_cfg;
  reg  [47:0]  addr_sr;
  reg  [31:0]  data_sr;
  reg  [47:0]  rd_sr;
  reg  [5:0]   fsm_wait;
  reg          dq_oe_l;
  reg          busy_jk;
  reg          busy_jk_p1;
  reg          rw_bit;
  reg          reg_bit;
  reg          byte_wr_en;
  reg          cs_loc;
  reg          cs_l_reg;
  reg          cs_l_reg_p1;
  reg          cs_l_reg_p2;
  reg          cs_l_reg_p3;
  wire         dram_ck_loc;
  reg          dram_ck_en;
  reg          rd_done;
  reg          rd_burst_en_sr;
  reg          rd_first_byte;
  reg          rd_word_cnt;
  reg  [7:0]   dram_dq_out_ris;
  reg  [7:0]   dram_dq_out_fal;
  reg  [7:0]   go_sr;
  reg  [7:0]   data_fsm;
  reg  [15:0]  dout_word;
  reg          data_shift_en;
  reg          data_shift_abort;
  reg          halt_burst;
  wire         dram_rwds_in_ris;
  wire         dram_rwds_in_fal;
  reg          dram_rwds_in_fal_p1;
  reg          dram_rwds_in_ris_p1;
  wire [7:0]   dram_dq_in_ris;
  wire [7:0]   dram_dq_in_fal;
  reg  [7:0]   dram_dq_in_ris_p1;
  reg  [7:0]   dram_dq_in_fal_p1;
  reg          rd_dir_jk;
  reg          rd_dir_jk_p1;
  reg          rd_dir_jk_p2;
  reg          rd_dir_jk_p3;
  reg          rd_dir_jk_p4;
  reg          rd_dir_jk_p5;
  reg          ck_div2;
  reg  [31:0]  sump_loc;
  reg  [31:0]  sump_loc_p1;
  reg  [31:0]  sump_loc_p2;

  reg          dq_oe_l_f;
  reg          dq_oe_l_ff;
  reg 		   rwds_oe_l;
  reg 		   rwds_oe_l_f;
  reg 		   rwds_oe_l_ff;

// Specific to simulation model. Note arbitrary size limit of 1K DWORDs
  reg  [31:0]             sim_ram_array[1023:0];
  reg  [9:0]              a_addr;
  reg                     a_we;
  reg  [31:0]             a_di;
  wire [31:0]             a_do;


  assign dram_rst_l = ~ reset;


//-----------------------------------------------------------------------------
// [ Section-5 ] Simulation Model:
// Simple Simulation Model that infers a SRAM and stores and retrieves DWORDs
// in the FPGA fabric clock domain. This does NOT model the HyperRAM, but is
// a cycle accurate model at the FPGA fabric level for memory access.
// Note: Synthesis should optimize this all away when simulation_en == 0
//-----------------------------------------------------------------------------
always @( posedge clk )
begin
 a_we <= 0;
 if ( simulation_en == 1 ) begin
   if ( a_we == 1 ) begin
     sim_ram_array[a_addr] <= a_di[31:0];
   end // if ( a_we )
 end


 if ( simulation_en == 1 ) begin
   if ( mem_or_reg == 0 ) begin
     if ( busy_jk == 0 && ( rd_req == 1 || wr_req == 1 ) ) begin
       a_addr <= addr[9:0];// Note MSBs are tossed
     end
     if ( busy_jk == 1 && ( rd_rdy == 1 || wr_req == 1 ) ) begin
       a_addr <= a_addr + 1;// Burst Write, so increment address
     end 
     if ( wr_req == 1 ) begin
       a_di <= wr_d[31:0];
       a_we <= 1;
     end
   end
 end
end // always
  assign a_do = sim_ram_array[a_addr];


//-----------------------------------------------------------------------------
// [ Section-6 ] HyperRAM write timing
// Update latency_1x and latency_2x values whenever config write happens
//   8f14 0a07; 166 MHz  1x / 2x 12/18 clocks for 2 DWORD Writes
//   8f04 0806; 133 MHz  1x / 2x 11/16 clocks for 2 DWORD Writes
//   8ff4 0605; 100 MHz  1x / 2x 10/14 clocks for 2 DWORD Writes
//   8fe4 0404;  83 MHz  1x / 2x  9/12 clocks for 2 DWORD Writes
// This is basically a registered LUT. The 1x and 2x values are FSM delays
// that were determined to work with the 16bit HyperRAM config values. If 
// the values don't match, the writes to HyperRAM won't be aligned to when
// the HyperRAM is listening and when you read back your writes, the bytes 
// will be skewed. The reads wait for RWDS strobe, so they will be fine, it
// is the writes that will get messed up. Architecturally, HyperRAM is less
// than perfect as it basically requires you set to watches at the beginning
// of time and assume the agree with each other after that.
// This process attempts to keep them both syncrhonized with each other.
//-----------------------------------------------------------------------------
always @ ( posedge clk ) begin : proc_latency_timing
 begin
   if ( wr_req == 1 && mem_or_reg == 1 && addr == 32'h00000800 ) begin
     if          ( wr_d[23:20] == 4'h1 ) begin
       latency_cfg <= 16'h0A07;
     end else if ( wr_d[23:20] == 4'h0 ) begin
       latency_cfg <= 16'h0806;
     end else if ( wr_d[23:20] == 4'hF ) begin
       latency_cfg <= 16'h0605;
     end else if ( wr_d[23:20] == 4'hE ) begin
       latency_cfg <= 16'h0404;
     end
   end
   if ( reset == 1 ) begin 
     latency_cfg <= 16'h0D0A;// HyperRAM power on default
   end 
 end
end // always
  assign latency_2x = latency_cfg[15:8];
  assign latency_1x = latency_cfg[7:0];


//-----------------------------------------------------------------------------
// Notes gleaned from datasheet:
// The clock is not required to be free-running. 
//
// Note: RWDS and DQ are edge aligned
// During write transactions, data is center aligned with clock transitions.
//
// During write data transfers, RWDS is 1 to mask a data byte write.
//
// During read data transfers, RWDS is a read data strobe with data values 
// edge aligned with the transitions of RWDS.
//
// The HyperRAM device may stop RWDS transitions with RWDS LOW, between the
// delivery of words, in order to insert latency between words when crossing 
// memory array boundaries.
//
//
// Read 1x Latency
//                          |---------  1x Latency ---------|
// CS_L   \__________________________________________________________________/
// CK     ____/   \___/   \___/   \___/   \___/   \___/   \___/   \___/   \_
// RWDS   \____________________________________________________/   \___/   \___
//  dir     < input        
// DQ[7:0] -<47><39><31><23><15><7 >---------------------------<  ><  ><  ><  >
//  dir     <       output         >---------------------------<   input      >
//
// Read 2x Latency
//                   |---1x Latency--|---2x Latency--|            
// CS_L    \__________________________________________________________________/
// CK      ____/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \
// RWDS                  \______________________________/\__/\___
// DQ[7:0] ---<><><><><><>------------------------------<><><><>-----------
//  dir      < output    >------------------------------<input >-----------
//
// Mem Write 1x Latency
//                   |---1x Latency--|---2x Latency--|            
// CS_L    \__________________________________________________________________/
// CK      ____/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \
// RWDS                     __________/      \___________
// DQ[7:0] ---<><><><><><>------------<><><><>-----------
//  dir      <       output         >-<output>-----------
//
// Reg Write 
//                   
// CS_L    \__________________________________________________________________/
// CK      ____/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \
// RWDS                     _____________________________
// DQ[7:0] ---<><><><><><><><>---------------------------
//  dir      <       output  >--------------------
//
// Command-Address Bit Packing:
//  47 R/W# Identifies the transaction as a read or write.
//     R/W#=1 indicates a Read transaction
//     R/W#=0 indicates a Write transaction
//  46 Address Space
//     AS=0 indicates memory space
//     AS=1 indicates the register space
//  45 Burst Type
//     Indicates whether the burst will be linear or wrapped.
//     Burst Type=0 indicates wrapped burst
//     Burst Type=1 indicates linear burst
//  44-16 Row & Upper Column Address
//  15-3 Reserved for future column address expansion.
//  2-0 Lower Column Address
//
// Register Address Map CA[39:0] to A[31:0] mapping
// This module reduces 48bit address down to a 32bit address. This table
// records what the 32bit addresses are for the 4 registers + default values
// 0x000000 0000 : ID-Reg0   0x00000000   : 0x0c81
// 0x000000 0001 : ID-Reg1   0x00000001   : 0x0000
// 0x000100 0000 : Cfg-Reg0  0x00000800   : 0x8f1f
// 0x000100 0001 : Cfg-Reg1  0x00000801   : 0x0002
//
//
// tACC : HyperRAM Read Initial Access Time = 40ns
//-----------------------------------------------------------------------------
// Take in requests for Writes and Reads and shift out bytes DDR
//-----------------------------------------------------------------------------
always @ ( posedge clk ) begin : proc_fsm
 begin
   halt_burst    <= 0;
   go_sr         <= { go_sr[6:0], 1'b0 };
   data_fsm      <= { data_fsm[6:0], 1'b0 };
   data_fsm[0]   <= data_shift_en;
   byte_wr_en    <= 1;// This is fixed 1 for now
   rd_done       <= 0;
   rd_dir_jk_p1  <= rd_dir_jk;
   rd_dir_jk_p2  <= rd_dir_jk_p1;
   rd_dir_jk_p3  <= rd_dir_jk_p2;
   rd_dir_jk_p4  <= rd_dir_jk_p3;
   rd_dir_jk_p5  <= rd_dir_jk_p4;
   busy_jk_p1    <= busy_jk;

   dout_word[15:0] <= 16'b0;

   if ( data_shift_abort == 1 ) begin
     data_fsm[0]   <= 0;
     data_fsm[1]   <= 0;
   end

   if ( rd_rdy == 1 ) begin
	 rd_first_byte <= 0;
     if ( !rd_burst_en ) begin
       busy_jk        <= 0;
       rd_done        <= 1;
       rd_dir_jk      <= 0;
       rwds_oe_l <= 1;// Input
     end
   end

   if ( busy_jk == 0 && ( wr_req == 1 || rd_req == 1 ) ) begin
     rd_dir_jk      <= 0;
     rwds_oe_l <= 1;// Input
     busy_jk        <= 1;
     go_sr[0]       <= 1;// Kick off the FSM
     rw_bit         <= rd_req;     // 0=WriteOp, 1=ReadOp
     reg_bit        <= mem_or_reg; // 0=MemSpace,1=RegSpace
     addr_sr[47]    <= rd_req;     // 0=WriteOp, 1=ReadOp
     addr_sr[46]    <= mem_or_reg;// 0=MemSpace,1=RegSpace
     addr_sr[45]    <= 1'b1;// Linear Burst
     addr_sr[15:3]  <= 13'd0;
     data_sr[31:0]  <= wr_d[31:0];
     if ( mem_or_reg == 0 ) begin
       addr_sr[44:16] <= addr[30:2];
       addr_sr[2:0]   <= { addr[1:0], 1'b0 };// Always getting DWORD
     end else begin
       addr_sr[44:16] <= addr[31:3];
       addr_sr[2:0]   <= addr[2:0];// Reg access needs 16bit LSB bit
     end
     if ( rd_req == 1 ) begin 
       //rd_dwords_cnt <= rd_num_dwords[5:0];
	   rd_first_byte <= 1;
     end else begin
       //rd_dwords_cnt <= 6'd0;
     end
   end
   if ( go_sr[3] == 1 && rw_bit == 1 ) begin 
     rd_dir_jk      <= 1;// Turn the Byte bus around for reading DRAM
   end


   // Shift the Address Word Out as 6 DDR Bytes of 47:32, 31:16, 15:0
   if          ( go_sr[0] == 1 ) begin
     dout_word[15:0] <= addr_sr[47:32];
   end else if ( go_sr[1] == 1 ) begin
     dout_word[15:0] <= addr_sr[31:16];
   end else if ( go_sr[2] == 1 ) begin
     dout_word[15:0] <= addr_sr[15:0];
   end

   if ( go_sr[6] == 1 ) begin
     if ( rw_bit == 0 ) begin
       rwds_oe_l <= 0;// Output for Write Operations
     end
   end

   // Shift the Config Data Word ( and stop )
   if ( go_sr[3] == 1 && reg_bit == 1 ) begin
     dout_word[15:0] <= data_sr[31:16];
     go_sr[4] <= 0;
     busy_jk  <= 0;
   end

   // Shift the RAM Data Words out
   if          ( data_shift_en == 1 ) begin 
     dout_word[15:0] <= data_sr[31:16];
   end else if ( data_fsm[0]   == 1 ) begin 
     dout_word[15:0] <= data_sr[15:0];
   end

   // Load the Burst Write Data ( 2nd DWORD ) if present in time, else stop
   if ( data_fsm[1] == 1 && busy_jk == 1 ) begin
     if ( wr_req == 1 ) begin
       data_sr[31:0]   <= wr_d[31:0];
       dout_word[15:0] <= wr_d[31:16];
       data_fsm[0]     <= 1;
     end else begin
       if ( rw_bit == 0 ) begin
         halt_burst     <= 1;
         busy_jk        <= 0;
       end
     end
   end

   if ( busy_jk_p1 == 0 ) begin
     rwds_oe_l <= 1;// Back to input  
     rd_dir_jk      <= 0;//                
   end

   if ( reset == 1 ) begin
     rd_dir_jk     <= 0;
     busy_jk       <= 0;
     //rd_dwords_cnt <= 6'd0;
   end

 end
end // proc_fsm 
  assign busy = busy_jk;


//-----------------------------------------------------------------------------
// HyperRAM has this annoying feature of 1x or 2x latency.  At the beginning
// of any RAM cycle, the RWDS pin is sampled to determine which latency to use.
// Thankfully, the 2x latency is very infrequent. Unfortunately this also means
// timing is unpredictable for any given access cycle. This extra latency 
// exists as the internal refresh controller might be busy when cycle occurs.
// For deterministic timing, the core and HyperRAM may be configured for 2x
// latency always, which is slower but may be advantageous for some designs.
//-----------------------------------------------------------------------------
always @ ( posedge clk ) begin : proc_latency
 begin
   data_shift_abort <= 0;
   burst_wr_rdy  <= busy_jk & ( data_shift_en | ( wr_req & data_fsm[1] ));
   lat_2x        <= 0;
   data_shift_en <= 0;
   if ( fsm_wait != 6'd0 ) begin
     fsm_wait <= fsm_wait - 1;
     if ( fsm_wait == 6'd3 ) begin
       data_shift_en <= 1;
     end
   end 

   // Register Writes have zero latency
   if ( go_sr[2] == 1 && reg_bit == 1 && rw_bit == 0 ) begin
     fsm_wait <= 6'd0;
   end

   // DRAM Reads
   if ( go_sr[2] == 1 && reg_bit == 0 && rw_bit == 1 ) begin
     fsm_wait  <= 6'd63;// This actually ends from RWDS strobing
   end

   // DRAM Writes 1x Latency ( assume for now )
   if ( go_sr[2] == 1 && reg_bit == 0 && rw_bit == 0 ) begin
     fsm_wait <= latency_2x[5:0];
   end

   // DRAM Writes 2x Latency if RWDS sampled high on 5th clock
   if ( go_sr[5] == 1 && reg_bit == 0 && rw_bit == 0 ) begin
     if ( dram_rwds_in_ris == 1 || simulation_en == 1 ) begin
       fsm_wait         <= latency_2x[5:0];
       lat_2x           <= 1;
       data_shift_abort <= 1;
       data_shift_en    <= 0;
       burst_wr_rdy     <= 0;
     end
   end

   if ( reset == 1 || rd_done ) begin 
     fsm_wait <= 6'd0;// This actually ends from RWDS strobing
   end 
 
 end
end // proc_latency


//-----------------------------------------------------------------------------
// Read SR
//                                                              0 1 2 3 0 1 2
// CK     ___/   \___/   \___/   \___/   \___/   \___/   \___/   \___/   \_
// RWDS   \___________________________________________________/   \___/   \___
//  dir    < input
// DQ[7:0]-<47><39><31><23><15><7 >---------------------------<  ><  ><  ><  >
//
//
// Flop input data using IDDR flops 
// clk ______/    \____/    \____/    \____/    \
// din ---------< 0 >< 1 >< 2 >< 3 >----------
// dout_ris ---------------------< 1      >< 3     >
// dout_fal -----------< 0      >< 2      >----
//
// HyperRAM device may stop RWDS transitions with RWDS LOW between delivery of
// words to insert latency between words when crossing memory array boundaries.
//-----------------------------------------------------------------------------
always @ ( posedge clk ) begin : proc_rd_sr
 begin
	rd_burst_en_sr <= rd_burst_en;

   rd_rdy <= 0;
   dram_rwds_in_fal_p1 <= dram_rwds_in_fal;
   dram_rwds_in_ris_p1 <= dram_rwds_in_ris;
   dram_dq_in_ris_p1   <= dram_dq_in_ris[7:0];
   dram_dq_in_fal_p1   <= dram_dq_in_fal[7:0];
   if ( rd_burst_en_sr | rd_first_byte ) begin
     if ( ( ( dram_rwds_in_fal_p1 == 1 && dram_rwds_in_ris_p1 == 0) || simulation_en == 1 ) 
          && rd_dir_jk_p4 == 1 ) begin
       rd_word_cnt <= ~ rd_word_cnt;
       if ( rd_word_cnt == 1 ) begin
         rd_d   <= { dram_dq_in_fal_p1[7:0],
                     dram_dq_in_ris_p1[7:0],
                     dram_dq_in_fal[7:0],
                     dram_dq_in_ris[7:0]     };
         rd_rdy <= 1;
         if ( simulation_en == 1 ) begin
           rd_d   <= a_do[31:0];
         end
       end
     end
   end else begin
     rd_word_cnt   <= 0; // A ping pong
   end
   
   /* Timout */
   if(rw_bit == 1 && reg_bit == 0 && fsm_wait == 0) begin
	//rd_rdy <= 1;
   end
   
 end
end // proc_rd_sr


//-----------------------------------------------------------------------------
// IO Flops and SUMP2 debugging signals
//-----------------------------------------------------------------------------
always @ ( posedge clk ) begin : proc_out
 begin
   cs_loc          <= busy_jk & ~halt_burst;
   dram_dq_out_fal <= dout_word[7:0];
   dram_dq_out_ris <= dout_word[15:8];
   dram_rwds_out   <= ~ byte_wr_en;// Note: rwds is a mask, 1==Don't Write Byte
   cs_l_reg        <= ( ~cs_loc ) | halt_burst;
   cs_l_reg_p1     <= cs_l_reg;
   cs_l_reg_p2     <= cs_l_reg_p1;
   cs_l_reg_p3     <= cs_l_reg_p2;
   dq_oe_l         <= ( ~cs_loc ) | halt_burst | rd_dir_jk;
  // dram_ck_en      <= ~cs_l_reg;

   dq_oe_l_f       <= dq_oe_l;
   dq_oe_l_ff      <= dq_oe_l_f;
   dram_dq_oe_l    <= dq_oe_l_ff;

   rwds_oe_l_f <= rwds_oe_l;
   dram_rwds_oe_l <= rwds_oe_l_f;
   

   
   ck_div2         <= ~ ck_div2;         // Just a visual aid for SUMP2
   sump_loc_p1     <= sump_loc[31:0];    // Align internal with IDDR signals
   sump_loc_p2     <= sump_loc_p1[31:0]; // Align internal with IDDR signals


   sump_loc[0]     <= ck_div2;
   sump_loc[1]     <= rd_req;
   sump_loc[2]     <= wr_req;
   sump_loc[3]     <= mem_or_reg;
   sump_loc[4]     <= rd_rdy;
   sump_loc[5]     <= busy;
   sump_loc[6]     <= burst_wr_rdy;
   sump_loc[7]     <= lat_2x;

   sump_loc[8 ]    <= ~cs_l_reg;
   sump_loc[9 ]    <= ~rwds_oe_l;
   sump_loc[10]    <= ~dq_oe_l;
   sump_loc[11]    <= rd_dir_jk;
   sump_loc[12]    <= data_shift_en;
   sump_loc[13]    <= data_shift_abort;
   sump_loc[14]    <= dram_rwds_in_ris;
   sump_loc[15]    <= dram_rwds_in_fal;
   sump_loc[23:16] <= dram_dq_in_ris[7:0];
   sump_loc[31:24] <= dram_dq_in_fal[7:0];

   if ( cs_l_reg == 0 && cs_l_reg_p1 == 1 ) begin
     cycle_len <= 8'd0;// Clear to 0x00 on chip select assertion
   end else if ( cs_l_reg == 0 ) begin
     cycle_len <= cycle_len + 1;// Count number of clocks for this cycle
   end


   if ( reset == 1 ) begin
     cycle_len <= 8'd0;
     cs_l_reg  <= 1;
     ck_div2   <= 0;
   end 

 end
end // proc_out
  assign sump_dbg[31:14] = sump_loc[31:14];   // IDDR DQs, RWDS
  assign sump_dbg[ 8]    = sump_loc_p2[ 8];   // ODDR cs_l 
  assign sump_dbg[7:0]   = sump_loc_p1[7:0];  // Internal
  assign sump_dbg[13:9]  = sump_loc_p1[13:9]; // Internal






//-----------------------------------------------------------------------------
// Flop input data using IDDR flops 
// clk ______/    \____/    \____/    \____/    \
// din ---------< 0 >< 1 >< 2 >< 3 >----------
// dout_ris ---------------------< 1      >< 3     >
// dout_fal -----------< 0      >< 2      >----
//-----------------------------------------------------------------------------
genvar i2;
generate
for ( i2=0; i2<=7; i2=i2+1 ) begin: gen_i2
 ecp_iddr u_xil_iddr
  (
    .clk       ( clk                 ),
    .din       ( dram_dq_in[i2]      ),
    .dout_fal  ( dram_dq_in_fal[i2]  ),
    .dout_ris  ( dram_dq_in_ris[i2]  ),
  .rst       (reset )
  );
end
endgenerate
 ecp_iddr u0_xil_iddr
  (
    .clk       ( clk                 ),
    .din       ( dram_rwds_in        ),
    .dout_fal  ( dram_rwds_in_fal    ),
    .dout_ris  ( dram_rwds_in_ris    ),
  .rst       (reset )
  );


//-----------------------------------------------------------------------------
// Reflop Data at IOBs using DDR Output Flops
//-----------------------------------------------------------------------------
genvar i1;
generate
for ( i1=0; i1<=7; i1=i1+1 ) begin: gen_i1
 ecp_oddr u_xil_oddr
  (
    .clk       ( clk                 ),
    .din_ris   ( dram_dq_out_ris[i1] ),
    .din_fal   ( dram_dq_out_fal[i1] ),
    .dout      ( dram_dq_out[i1]     ),
  .rst       (reset )
  );
end
endgenerate

ecp_oddr u0_xil_oddr
(
  .clk       ( clk                 ),
  .din_ris   ( cs_l_reg  ),
  .din_fal   ( cs_l_reg  ),
  .dout      ( dram_cs_l           ),
  .rst       (reset )
);



always @(negedge clk) begin
	dram_ck_en <= ~cs_l_reg;
end


ecp_oddr u1_xil_oddr
(
  .clk       ( dram_ck_loc         ),
  .din_ris   ( 1'b1    ),
  .din_fal   ( 1'b0                ),
  .dout      ( dram_ck             ),
  .rst       (reset                )
);


ecp_oddr u2_xil_oddr
(
  .clk       ( dram_ck_loc          ),
  .din_ris   ( 1'b0    ),
  .din_fal   ( 1'b1                 ),
  .dout      ( dram_ck_n            ),
  .rst       (reset                 )
);
//assign #3 dram_ck_loc = clk;// Simulation Only - delay 10ns Sim clock by 2ns
assign    dram_ck_loc = clk_90p;// PLL 90o shifted

endmodule // hyper_xface.v
