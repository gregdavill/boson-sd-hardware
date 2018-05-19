/* ****************************************************************************
-- (C) Copyright 2018 Kevin M. Hubbard - All rights reserved.
-- Source file: hyper_dword.v           
-- Date:        April 2018
-- Author:      khubbard
-- Description: S27KL0641DABHI020 : Cypress IC DRAM 64MBIT 3V 100MHZ 24BGA
-- Language:    Verilog-2001
-- Simulation:  Mentor-Modelsim 
-- Synthesis:   Xilinst-XST 
-- License:     This project is licensed with the CERN Open Hardware Licence
--              v1.2.  You may redistribute and modify this project under the
--              terms of the CERN OHL v.1.2. (http://ohwr.org/cernohl).
--              This project is distributed WITHOUT ANY EXPRESS OR IMPLIED
--              WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
--              AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN OHL
--              v.1.2 for applicable Conditions.
-- ***************************************************************************/
`default_nettype none // Strictly enforce all nets to be declared
  
module testbench 
(
  
);// module hyper_dword 


  reg [7:0]    dram_dq_in0;
  reg [7:0]    dram_dq_in1;
  wire [7:0]   dram_dq_out0;
  wire [7:0]   dram_dq_out1;
  wire         dram_dq_oe_l;
  reg          dram_rwds_in0;
  reg          dram_rwds_in1;
  wire         dram_rwds_out0;
  wire         dram_rwds_out1;
  wire         dram_rwds_oe_l;
  wire         dram_ck;
  wire         dram_rst_l;
  wire         dram_cs_l;
  wire [7:0]   sump_dbg;

  wire burst_wr_rdy;


  reg          rd_req = 0;
  reg          wr_req = 0;
  reg          mem_or_reg = 0;
  reg  [3:0]   wr_byte_en = 4'hf;
  reg  [31:0]  addr = 32'hAAAAAAAA;
  reg  [31:0]  wr_d = 0;
  reg  [31:0]  rd_buffer = 0;
  reg  [5:0]   rd_num_dwords = 1;
  wire [31:0]  rd_d;
  wire         rd_rdy;
  wire         busy;
  reg  [7:0]   latency_1x = 8'h09;
  reg  [7:0]   latency_2x = 8'h0B;

  reg resetn;

  reg clk_internal;
  reg clk;
  reg clk90;

always begin
  #10 clk <= 1;
  #10 clk90 <= 1;
  #10 clk <= 0;
  #10 clk90 <= 0;
end


  task hyperram_write_ll;
    input [31:0] wr_data;
    input [31:0] wr_addr;
    begin
      while(busy && !burst_wr_rdy) begin
        repeat (1) @(posedge clk);
      end
      
      wr_req <= 1;
      wr_d <= wr_data;
      addr <= wr_addr;
      repeat (1) @(posedge clk);
      wr_req <= 0;
      repeat (1) @(posedge clk);
    end
  endtask

  task hyperram_read;
    //input [31:0] wr_data;
    input [31:0] rd_addr;
    input [5:0] rd_cnt;
    begin
      while(busy) begin
        repeat (1) @(posedge clk);
      end

      repeat (1) @(posedge clk);
      
      rd_req <= 1;
      rd_num_dwords <= rd_cnt;
      //wr_d <= wr_data;
      addr <= rd_addr;
      repeat (1) @(posedge clk);
      rd_req <= 0;
      repeat (1) @(posedge clk);
    end
  endtask

  task hyperram_write;
    input [31:0] wr_data;
    input [31:0] wr_addr;
    begin
      mem_or_reg <= 0;
      hyperram_write_ll(wr_data, wr_addr);
    end
  endtask

  task hyperram_write_reg;
    input [31:0] wr_data;
    input [31:0] wr_addr;
    begin
      hyperram_wait();
      mem_or_reg <= 1;
      hyperram_write_ll(wr_data, wr_addr);
    end
  endtask

  task hyperram_wait;
    begin
      while (busy) begin
        repeat (1) @(posedge clk);
      end
    end
  endtask

  /* Escape if we break the HyperRam module. Don't let the sim run off. */
  initial begin
	  repeat (1000) @(posedge clk);
    $finish;
  end

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);

    resetn <= 0;
    repeat (2) @(posedge clk);
    resetn <= 1; 

    repeat (5) @(posedge clk);

    /* Default Config Reg */
    hyperram_write_reg(32'h8f1f0000, 32'h0000_0800);

    hyperram_write(32'h01020304, 32'h0000_0FFF);
    hyperram_write(32'h05060708, 32'h0001_0000);
    hyperram_write(32'h090A0B0C, 32'h0001_0000);
    hyperram_write(32'h0D0E0F00, 32'h0001_0FFF);
    hyperram_wait();

    hyperram_read(32'h0000_0FFF,4'h2);
    hyperram_wait();



    hyperram_write(32'h01020304, 32'h0000_0010);
    

    hyperram_wait();
    repeat (10) @(posedge clk);

		$finish;
	end




//-----------------------------------------------------------------------------
// Bridge LB To a HyperRAM
//-----------------------------------------------------------------------------
hyper_xface u_hyper_xface
(
  .reset             ( !resetn            ),
  .clk               ( clk                ),
  .clk90             ( clk90              ),
  .rd_req            ( rd_req             ),
  .wr_req            ( wr_req             ),
  .mem_or_reg        ( mem_or_reg         ),
  .wr_byte_en        ( wr_byte_en         ),
  .addr              ( addr[31:0]         ),
  .rd_num_dwords     ( rd_num_dwords[5:0] ),
  .wr_d              ( wr_d[31:0]         ),
  .rd_d              ( rd_d[31:0]         ),
  .rd_rdy            ( rd_rdy             ),
  .burst_wr_rdy      ( burst_wr_rdy       ),
  .busy              ( busy               ),
  .latency_1x        ( latency_1x[7:0]    ),
  .latency_2x        ( latency_2x[7:0]    ),
  .dram_dq_in0       ( dram_dq_in0[7:0]    ),
  .dram_dq_in1       ( dram_dq_in1[7:0]    ),
  .dram_dq_out0      ( dram_dq_out0[7:0]   ),
  .dram_dq_out1      ( dram_dq_out1[7:0]   ),
  .dram_dq_oe_l      ( dram_dq_oe_l       ),
  .dram_rwds_in0     ( dram_rwds_in0       ),
  .dram_rwds_in1     ( dram_rwds_in1       ),
  .dram_rwds_out0    ( dram_rwds_out0      ),
  .dram_rwds_out1    ( dram_rwds_out1      ),
  .dram_rwds_oe_l    ( dram_rwds_oe_l     ),
  .dram_ck           ( dram_ck            ),
  .dram_rst_l        ( dram_rst_l         ),
  .dram_cs_l         ( dram_cs_l          ),
  .sump_dbg          ( sump_dbg[7:0]      )
);// module hyper_xface


reg [7:0] hyperram_dq_int;
wire [7:0] hyperram_dq;

always @(posedge clk) hyperram_dq_int <= dram_dq_out0;
always @(negedge clk) hyperram_dq_int <= dram_dq_out1;


always @(posedge clk90) dram_dq_in1 <= hyperram_dq;
always @(negedge clk90) dram_dq_in0 <= hyperram_dq;


assign hyperram_dq = dram_dq_oe_l == 0 ? hyperram_dq_int : 8'hz;

wire hyperram_cs;
wire hyperram_ck;

reg  hyperram_rwds_int;
wire hyperram_rwds;

wire hyperram_reset;

assign hyperram_cs = dram_cs_l;
assign hyperram_ck = dram_ck;

always @(posedge clk) hyperram_rwds_int <= dram_rwds_out0;
always @(negedge clk) hyperram_rwds_int <= dram_rwds_out1;

always @(posedge clk90) dram_rwds_in0 <= hyperram_rwds;
always @(negedge clk90) dram_rwds_in1 <= hyperram_rwds;

assign hyperram_rwds = dram_rwds_oe_l == 0 ? hyperram_rwds_int : 1'bz;

assign hyperram_reset = resetn;




s27ks0641 hypersim
    (
    .DQ7      (hyperram_dq[7]),
    .DQ6      (hyperram_dq[6]),
    .DQ5      (hyperram_dq[5]),
    .DQ4      (hyperram_dq[4]),
    .DQ3      (hyperram_dq[3]),
    .DQ2      (hyperram_dq[2]),
    .DQ1      (hyperram_dq[1]),
    .DQ0      (hyperram_dq[0]),
    .RWDS     (hyperram_rwds ),

    .CSNeg    (hyperram_cs),
    .CK       (hyperram_ck),
    .CKNeg    (~hyperram_ck),
    .RESETNeg (hyperram_reset)
    );

endmodule // hyper_dword.v