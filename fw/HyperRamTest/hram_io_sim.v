module hyperram_io_ice40 (
	input		clk,

	input		hyperram_ce_to_pad_,
	input		hyperram_rst_to_pad_,

	input [7:0] hyperram_dq_to_pad,
	input		hyperram_rwds_to_pad,

	output [7:0] hyperram_dq_from_pad,
	output       hyperram_rwds_from_pad,

	inout 		HRAM_CS,
	inout 		HRAM_RWDS,
	inout [1:0]	HRAM_CK,
	inout [7:0] HRAM_DQ,
	);






	endmodule