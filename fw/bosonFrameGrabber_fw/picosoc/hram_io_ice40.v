

module hyperram_io_ice40 (
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

	/* verilator lint_off PINMISSING */

	//============================================================
	// CE_ : posedge registered output
	//============================================================
	SB_IO #( 
		.PIN_TYPE(6'b0110_00), 
		.PULLUP(1'b0), 
		.NEG_TRIGGER(1'b0)
	       ) 
	hyperram_cs
		(
		.PACKAGE_PIN(HRAM_CS),
		//.CLOCK_ENABLE(1'b1),
		.OUTPUT_CLK(io_clk),
		.OUTPUT_ENABLE(1'b1),
		.D_OUT_0(hyperram_ce_to_pad_)
	);


	//============================================================
	// UL_ / BL_ : posedge registered output
	//============================================================

	SB_IO #( 
		.PIN_TYPE(6'b1101_00), 
		.PULLUP(1'b0), 
		.NEG_TRIGGER(1'b0) 
	       ) 
	hyperram_rwds
		(
		.PACKAGE_PIN(HRAM_RWDS),
		//.CLOCK_ENABLE(1'b1),
		.OUTPUT_CLK(io_clk),
		.INPUT_CLK(clk),
		.OUTPUT_ENABLE(1'b1),
		.D_OUT_0(hyperram_rwds_to_pad_0),
		.D_OUT_1(hyperram_rwds_to_pad_1),
		.D_IN_0(hyperram_rwds_from_pad_0),
		.D_IN_1(hyperram_rwds_from_pad_1)
	);

	SB_IO #( 
		.PIN_TYPE(6'b0110_00), 
		.PULLUP(1'b0), 
		.NEG_TRIGGER(1'b0) 
	       ) 
	hyperram_ck [1:0]
		(
		.PACKAGE_PIN(HRAM_CK),
		//.CLOCK_ENABLE(1'b1),
		//.INPUT_CLK(clk),
		.OUTPUT_CLK(clk),
		.OUTPUT_ENABLE(1'b1),
		.D_OUT_0({clk, !clk})
		);

	//============================================================
	// DATA : posedge output / negedge input => bidir DDR
	//============================================================

	//wire [7:0] hyperram_dq_from_pad_0;
	//wire [7:0] hyperram_dq_from_pad_1;

	SB_IO #( 
		.PIN_TYPE(6'b1000_00), 	/* DDR Registered Enable */
		.PULLUP(1'b0), 
		.NEG_TRIGGER(1'b0) 
	       ) 
	hyperram_dq [7:0]
		(
		.PACKAGE_PIN(HRAM_DQ),
		.LATCH_INPUT_VALUE(1'b1),
		//.CLOCK_ENABLE(1'b1),
		.INPUT_CLK(io_clk),
		.OUTPUT_CLK(io_clk),
		.OUTPUT_ENABLE(hyperram_dq_dir),
		.D_OUT_0(hyperram_dq_to_pad_0),
		.D_OUT_1(hyperram_dq_to_pad_1),
		.D_IN_0(hyperram_dq_from_pad_0),
		.D_IN_1(hyperram_dq_from_pad_1)
	);

endmodule