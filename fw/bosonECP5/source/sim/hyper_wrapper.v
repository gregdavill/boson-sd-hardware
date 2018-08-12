`timescale 1 ps/1 ps

module hyper_wrapper (
	input wire hb_clk_o,
	input wire hb_cs_o,
	input wire hb_rwds_o,
	output wire hb_rwds_i,
	input wire hb_rwds_dir,
	input wire [7:0] hb_dq_o,
	output wire [7:0] hb_dq_i,
	input wire hb_dq_dir,
	input wire hb_rst_o
);



/* Patch inout signals through to seperate input/output/dir channels */
assign hb_rwds_i = rwds;
assign hb_dq_i = dq;

reg dq_dir;
reg rwds_dir;

always @(hb_dq_dir) begin
   dq_dir = hb_dq_dir;
end

always @(hb_rwds_dir) begin
   rwds_dir = hb_rwds_dir;
end

wire [7:0] dq = dq_dir ? 8'bz : hb_dq_o;
wire rwds = rwds_dir ? 1'bz : hb_rwds_o;

wire cs_n = hb_cs_o;

reg ck, ck_n;
always @(hb_clk_o) begin
	ck = hb_clk_o;
	ck_n = !hb_clk_o;
end

wire hwreset_n = hb_rst_o;


s27ks0641 #(.TimingModel("S27KS0641DPBHI020"))
     s27ks0641 (
		// Inouts
		.DQ7			(dq[7]),
		.DQ6			(dq[6]),
		.DQ5			(dq[5]),
		.DQ4			(dq[4]),
		.DQ3			(dq[3]),
		.DQ2			(dq[2]),
		.DQ1			(dq[1]),
		.DQ0			(dq[0]),
		.RWDS			(rwds),	
		// Inputs
		.CSNeg			(cs_n),	
		.CK			    (ck),		
		.CKNeg			(ck_n),	
		.RESETNeg		(hwreset_n));

endmodule