module wb_stream_writer_fifo
  #(parameter DW = 0,
    parameter AW = 0)
   (input 	wire    clk,
    input 	wire      rst,
    output reg [AW:0] cnt,
    input wire [DW-1:0]    stream_s_data_i, 
    input wire	      stream_s_valid_i,
    output wire	      stream_s_ready_o,

    output wire [DW-1:0]   stream_m_data_o,
    output wire	      stream_m_valid_o,
    input 	wire      stream_m_ready_i);
   
   

   wire 	    fifo_rd_en;
   wire [DW-1:0]    fifo_dout;
   wire 	    fifo_empty;
   wire 	    full;
   
   reg 		    inc_cnt;
   reg 		    dec_cnt;

   assign stream_s_ready_o = !full;
   
   // orig_fifo is just a normal (non-FWFT) synchronous or asynchronous FIFO
   fifo
     #(.DEPTH_WIDTH (AW),
       .DATA_WIDTH  (DW))
   fifo0
     (
       .clk       (clk),
       .rst       (rst),       
       .rd_en_i   (fifo_rd_en),
       .rd_data_o (fifo_dout),
       .empty_o   (fifo_empty),
       .wr_en_i   (stream_s_valid_i & ~full),
       .wr_data_i (stream_s_data_i),
       .full_o    (full));

   stream_fifo_if
     #(.DW (DW))
   stream_if
   (.clk              (clk),
    .rst              (rst),
    .fifo_data_i      (fifo_dout),
    .fifo_rd_en_o     (fifo_rd_en),
    .fifo_empty_i     (fifo_empty),
    .stream_m_data_o  (stream_m_data_o),
    .stream_m_valid_o (stream_m_valid_o),
    .stream_m_ready_i (stream_m_ready_i));

   
   always @(posedge clk) begin
      inc_cnt = stream_s_valid_i & stream_s_ready_o;
      dec_cnt = stream_m_valid_o & stream_m_ready_i;

      if(inc_cnt & !dec_cnt)
	cnt <= cnt + 1;
      else if(dec_cnt & !inc_cnt)
	cnt <= cnt - 1;
      
      if (rst)
	cnt <= 0;
   end
endmodule

/******************************************************************************
 This Source Code Form is subject to the terms of the
 Open Hardware Description License, v. 1.0. If a copy
 of the OHDL was not distributed with this file, You
 can obtain one at http://juliusbaxter.net/ohdl/ohdl.txt
 Description: Store buffer
 Currently a simple single clock FIFO, but with the ambition to
 have combining and reordering capabilities in the future.
 Copyright (C) 2013 Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>
 ******************************************************************************/

module fifo
  #(
    parameter DEPTH_WIDTH = 0,
    parameter DATA_WIDTH = 0
    )
   (
    input wire		    clk,
    input wire		    rst,

    input wire [DATA_WIDTH-1:0]  wr_data_i,
    input wire 		    wr_en_i,

    output wire [DATA_WIDTH-1:0] rd_data_o,
    input wire 		    rd_en_i,

    output wire		    full_o,
    output wire		    empty_o
    );

   localparam DW = (DATA_WIDTH  < 1) ? 1 : DATA_WIDTH;
   localparam AW = (DEPTH_WIDTH < 1) ? 1 : DEPTH_WIDTH;

   //synthesis translate_off
   initial begin
      if(DEPTH_WIDTH < 1) $display("%m : Warning: DEPTH_WIDTH must be > 0. Setting minimum value (1)");
      if(DATA_WIDTH < 1) $display("%m : Warning: DATA_WIDTH must be > 0. Setting minimum value (1)");
   end
   //synthesis translate_on

   reg [AW:0] write_pointer;
   reg [AW:0] read_pointer;

   wire 	       empty_int = (write_pointer[AW] ==
				    read_pointer[AW]);
   wire 	       full_or_empty = (write_pointer[AW-1:0] ==
					read_pointer[AW-1:0]);
   
   assign full_o  = full_or_empty & !empty_int;
   assign empty_o = full_or_empty & empty_int;
   
   always @(posedge clk) begin
      if (wr_en_i)
	write_pointer <= write_pointer + 1'd1;

      if (rd_en_i)
	read_pointer <= read_pointer + 1'd1;

      if (rst) begin
	 read_pointer  <= 0;
	 write_pointer <= 0;
      end
   end
   simple_dpram_sclk
     #(
       .ADDR_WIDTH(AW),
       .DATA_WIDTH(DW),
       .ENABLE_BYPASS(1)
       )
   fifo_ram
     (
      .clk			(clk),
      .dout			(rd_data_o),
      .raddr			(read_pointer[AW-1:0]),
      .re			(rd_en_i),
      .waddr			(write_pointer[AW-1:0]),
      .we			(wr_en_i),
      .din			(wr_data_i)
      );

endmodule


module simple_dpram_sclk
  #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ENABLE_BYPASS = 1
    )
   (
    input wire 		    clk,
    input wire [ADDR_WIDTH-1:0]  raddr,
    input wire 		    re,
    input wire [ADDR_WIDTH-1:0]  waddr,
    input wire 		    we,
    input wire [DATA_WIDTH-1:0]  din,
    output wire [DATA_WIDTH-1:0] dout
    );

   reg [DATA_WIDTH-1:0]     mem[(1<<ADDR_WIDTH)-1:0];
   reg [DATA_WIDTH-1:0]     rdata;

generate
if (ENABLE_BYPASS) begin : bypass_gen
   reg [DATA_WIDTH-1:0]     din_r;
   reg 			    bypass;

   assign dout = bypass ? din_r : rdata;

   always @(posedge clk)
     if (re)
       din_r <= din;

   always @(posedge clk)
     if (waddr == raddr && we && re)
       bypass <= 1;
     else if (re)
       bypass <= 0;
end else begin
   assign dout = rdata;
end
endgenerate

   always @(posedge clk) begin
      if (we)
	mem[waddr] <= din;
      if (re)
	rdata <= mem[raddr];
   end

endmodule
