/* 
 * MIT License
 * 
 * Copyright (c) 2018 Greg Davill
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * 
 */

`timescale 1 ns/1 ns

module testbench (
);
	reg clk = 1;
	reg resetn = 0;

	always #10 clk = ~clk;

	
	initial begin
		repeat (10) @(posedge clk);
		resetn <= 1;
	end

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
		
		#300_000
		$finish;
	end


	

	reg [11:0] hram_address = 0;
	reg  hram_ren = 0;
	wire  hram_wen;

	wire [15:0] hram_data;
	wire [15:0] hram_data_out;
	wire hram_data_out_clk;

	wire [15:0] boson_dq;

	bosonCamera cam (
		.reset(resetn),
		.CMOS_CLK(boson_clk),
		.CMOS_DQ(boson_dq),
		.CMOS_VALID(boson_valid)
	);


	BramFifo #(
		.DATA_WIDTH(16)
	) fifo	(
		.CLK0(clk), .RST0(!resetn), .Q(hram_data), .DEQ(hram_nxt), .EMPTY(hram_wen), .ALM_EMPTY(),
		.CLK1(boson_clk), .RST1(!resetn), .D(boson_dq), .ENQ(boson_valid),  .FULL(),  .ALM_FULL()
	);
 
	always @(posedge clk) begin
		if(hram_nxt)
			hram_address <= hram_address + 1;
	end
		
	hyperram_ctrl hram (
		.clk(clk),
		.reset_(resetn),
		// SRAM core issue interface
		.sram_req(!hram_wen),
		.sram_ready(hram_nxt),
		.sram_rd(hram_ren),
		.sram_addr(hram_address),
		.sram_wr_data(hram_data),

		// SRAM core read data interface
		.sram_rd_data_vld(hram_data_out_clk),
		.sram_rd_data(hram_data_out),
		
		// IO interface
		.hyperram_io_clk(hram_io_clk),
		.hyperram_clk(hram_clk),
		.hyperram_rwds_dir(hyperram_rwds_dir),
		.hyperram_dq_dir(hyperram_dq_dir),

		.hyperram_ce_to_pad_(hyperram_ce_to_pad_),
		.hyperram_rst_to_pad_(hyperram_rst_to_pad_),

		.hyperram_dq_to_pad_0(hyperram_dq_to_pad_0),
		.hyperram_dq_to_pad_1(hyperram_dq_to_pad_1),
		.hyperram_rwds_to_pad_0(hyperram_rwds_to_pad_0),
		.hyperram_rwds_to_pad_1(hyperram_rwds_to_pad_1),

		.hyperram_dq_from_pad_0(hyperram_dq_from_pad_0),
		.hyperram_dq_from_pad_1(hyperram_dq_from_pad_1)
	/*	.hyperram_rwds_from_pad_0(),
		.hyperram_rwds_from_pad_()
	*/
		);

	wire [7:0] hyperram_dq_to_pad_0,hyperram_dq_to_pad_1;
	wire [7:0] hyperram_dq_from_pad_0,hyperram_dq_from_pad_1;

	wire hyperram_rwds_dir,hyperram_dq_dir;


	wire hram_cs;

	wire hram_rwds;
	wire hram_dq0;
	wire hram_dq1;
	wire hram_dq2;
	wire hram_dq3;
	wire hram_dq4;
	wire hram_dq5;
	wire hram_dq6;
	wire hram_dq7;
	wire hram_ck;
	wire hram_ck_;


	hyperram_io hram_io (
		.io_clk(hram_io_clk),
		
		.clk(hram_clk),
		
		.hyperram_dq_dir(hyperram_dq_dir),
		.hyperram_rwds_dir(hyperram_rwds_dir),

		.hyperram_ce_to_pad_(hyperram_ce_to_pad_),
		.hyperram_rst_to_pad_(hyperram_rst_to_pad_),
		.hyperram_dq_to_pad_0(hyperram_dq_to_pad_0),
		.hyperram_dq_to_pad_1(hyperram_dq_to_pad_1),
		.hyperram_rwds_to_pad_0(hyperram_rwds_to_pad_0),
		.hyperram_rwds_to_pad_1(hyperram_rwds_to_pad_1),
		.hyperram_dq_from_pad_0(hyperram_dq_from_pad_0),
		.hyperram_dq_from_pad_1(hyperram_dq_from_pad_1),
		.hyperram_rwds_from_pad_0(hyperram_rwds_from_pad_0),
		.hyperram_rwds_from_pad_1(hyperram_rwds_from_pad_1),


		.HRAM_CS(hram_cs),
		.HRAM_RWDS(hram_rwds),
		.HRAM_CK({hram_ck,hram_ck_}),
		.HRAM_DQ({hram_dq7,hram_dq6,hram_dq5,hram_dq4,hram_dq3,hram_dq2,hram_dq1,hram_dq0})
	);


	/* simulated RAM */
	s27ks0641 hram_sim
    (
		.DQ7(hram_dq7),
		.DQ6(hram_dq6),
		.DQ5(hram_dq5),
		.DQ4(hram_dq4),
		.DQ3(hram_dq3),
		.DQ2(hram_dq2),
		.DQ1(hram_dq1),
		.DQ0(hram_dq0),
		.RWDS(hram_rwds),

		.CSNeg(hram_cs),
		.CK(hram_ck),
		.CKNeg(hram_ck_),
		.RESETNeg(resetn)
    );

endmodule

// --- simple module to simulate the internal logic of the SB_IO modules
module hyperram_io (
	input		io_clk,
	input		clk,

	input        hyperram_rwds_dir,
	input 	     hyperram_dq_dir,
	input		 hyperram_ce_to_pad_,
	input		 hyperram_rst_to_pad_,

	input [7:0]  hyperram_dq_to_pad_0,
	input [7:0]  hyperram_dq_to_pad_1,
	input		 hyperram_rwds_to_pad_0,
	input		 hyperram_rwds_to_pad_1,

	output [7:0] hyperram_dq_from_pad_0,
	output [7:0] hyperram_dq_from_pad_1,
	output       hyperram_rwds_from_pad_0,
	output       hyperram_rwds_from_pad_1,

	inout 		HRAM_CS,
	inout 		HRAM_RWDS,
	inout [1:0]	HRAM_CK,
	inout [7:0] HRAM_DQ
	);

	
	assign HRAM_DQ = hyperram_dq_dir ? ( io_clk ? hyperram_dq_to_pad_0 : hyperram_dq_to_pad_1 ) : 8'bz;

	reg hyperram_dq_from_pad_0 = 0;
	reg hyperram_dq_from_pad_1 = 0;

	always @(posedge io_clk)
		hyperram_dq_from_pad_0 <= HRAM_DQ;

	always @(negedge io_clk)
		hyperram_dq_from_pad_1 <= HRAM_DQ;
		
	
	assign HRAM_CS = hyperram_ce_to_pad_;
	assign HRAM_RWDS = hyperram_rwds_dir ? ( io_clk ? hyperram_rwds_to_pad_0 : hyperram_rwds_to_pad_1 ) : 1'bz;
	assign HRAM_CK = {clk,!clk};
	
endmodule

