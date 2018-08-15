/*
	Lattice FPGA User Guide states:

	D0 = First to be sent out
	D1 = Second to be sent out.

	Note sure right now if D0 == Rising Edge or Falling Edge.
*/

// ODDR1XF: Generic X1 ODDR implementation
// Lattice FPGA Libraries Reference Guide
module ODDRX1F
(
  output reg Q,     // 1-bit DDR output
  input wire SCLK,   // 1-bit clock input
  input wire D0,     // 1-bit data input (positive edge)
  input wire D1,     // 1-bit data input (negative edge)
  input wire RST     // 1-bit reset
);

reg D_neg_edge;

	always @(posedge SCLK) begin
			Q <= D0;
		D_neg_edge <= D1;
	end

	always @(negedge SCLK)
			Q <= D_neg_edge;

endmodule
// End of ODDR1XF_inst instantiation



// IDDR1XF: Generic X1 IDDR implementation
// Lattice FPGA Libraries Reference Guide
module IDDRX1F
(
  output reg Q0,     // 1-bit output for positive edge of clock
  output reg Q1,     // 1-bit output for negative edge of clock
  input wire SCLK,   // 1-bit clock input
  input wire D,      // 1-bit DDR data input
  input wire RST     // 1-bit reset
);

	reg Q_neg_ff;
	reg Q_pos_ff;
	

	always @(posedge SCLK) begin
		//Q_pos_ff <= D;
		//Q0 <= Q_pos_ff;
		Q0 <= D;
		Q1 <= Q_neg_ff;
	end

	always @(negedge SCLK)
		Q_neg_ff <= D;

endmodule


