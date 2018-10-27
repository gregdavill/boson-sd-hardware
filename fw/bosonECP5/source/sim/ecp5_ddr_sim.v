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

	reg D1_f = 0;
	reg D1_ff = 0;
	reg D1_fff = 0;
	reg D0_f = 0;
	reg D0_ff = 0;
	
	always @(posedge SCLK) begin
		Q <= D0_ff;
		
		D0_f <= D0;
		D0_ff <= D0_f;
		
		D1_f <= D1;
		D1_ff <= D1_f;
		D1_fff <= D1_ff;
	end

	always @(negedge SCLK) 
		Q <= D1_fff;

endmodule



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

	reg Q_neg_f = 0;
	reg Q_neg_ff = 0;
	reg Q_pos_f = 0;

	//always @(posedge clk)
//	dout_fal <= dout_fal_f;
	

	always @(posedge SCLK) begin
		Q_pos_f <= D;
		Q1 <= Q_pos_f;
		Q0 <= Q_neg_ff;
	end

	always @(negedge SCLK) begin
		Q_neg_f <= D;
		Q_neg_ff <= Q_neg_f;
	end

endmodule


