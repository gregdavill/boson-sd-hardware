`timescale 1 ns/1 ns

module top;


   vlog_tb_utils vlog_tb_utils0();
   vlog_tap_generator #("wb_crc.tap", 1) vtg();

   localparam aw = 32;
   localparam dw = 32;

   reg	   wb_clk = 1'b1;
   reg     wb_clk90 = 1'b1;

   reg	   wb_rst = 1'b1;

   always #10 wb_clk <= ~wb_clk;
   initial  #100 wb_rst <= 0;

	always @(posedge wb_clk or negedge wb_clk)
		#4 wb_clk90 <= wb_clk;


	reg done = 0;


	


	always @(posedge done) begin
      vtg.ok("All tests complete");
      $display("All tests complete");
      $finish;
   end



	wire [31:0] wb_s1_dat_o;
	wire [31:0] wb_s1_dat_i;
	wire [31:0] wb_s1_adr_o;
	wire [3:0] wb_s1_sel_o;
	wire [2:0] wb_s1_cti_o;
	wire wb_s1_we_o ;
	wire wb_s1_cyc_o;
	wire wb_s1_stb_o;
	wire wb_s1_ack_i;


wb_bfm_master #(
		  .dw (dw),
    .MAX_BURST_LEN           (32),
    .MAX_WAIT_STATES         (8),
    .VERBOSE                 (1)
  ) bfm (
    .wb_clk_i                (wb_clk),
    .wb_rst_i                (wb_rst),
    .wb_adr_o                (wb_s1_adr_o),
    .wb_dat_o                (wb_s1_dat_o),
    .wb_sel_o                (wb_s1_sel_o),
    .wb_we_o                 (wb_s1_we_o),
    .wb_cyc_o                (wb_s1_cyc_o),
    .wb_stb_o                (wb_s1_stb_o),
    .wb_cti_o                (wb_s1_cti_o),
   // .wb_bte_o                (wb_s1_bte_o),
    .wb_dat_i                (wb_s1_dat_i),
    .wb_ack_i                (wb_s1_ack_i)
  //  .wb_err_i                (wb_s1_err_i)
   // .wb_rty_i                (wb_s1_rty_i)
  );



	reg err;
	reg [31:0] data;

		reg[31:0] i;


	initial begin

		bfm.reset();
		//bfm.init();
	
		@(negedge wb_rst);

		repeat (2) @(posedge wb_clk);

		//bfm_cfg.read(4'h0,data, err);
		//bfm_cfg.read(4'h4,data, err);
		//bfm_cfg.read(4'h8,data, err);

		bfm.write(32'h0000_0000, 32'h01010101, 4'hF, err);	
		bfm.read(32'h0008_0004, data, err);	
		bfm.write(32'h0000_0000, 32'h02020202, 4'hF, err);	
		bfm.read(32'h0008_0004, data, err);	
		bfm.write(32'h0000_0000, 32'h04040404, 4'hF, err);	
		bfm.read(32'h0008_0004, data, err);	
	
		#100 done <= 1;
	end




	/* insert a wishbone controller for each slave */



	wb_crc32 uut(
	.wb_clk_i(wb_clk),
	.wb_rst_i(wb_rst),


	/* wishbone slave #1 */
	.wb_dat_i(wb_s1_dat_o),
	.wb_dat_o(wb_s1_dat_i),
	.wb_adr_i(wb_s1_adr_o),
	.wb_sel_i(wb_s1_sel_o),
	.wb_we_i (wb_s1_we_o ),
	.wb_cti_i(wb_s1_cti_o),
	.wb_cyc_i(wb_s1_cyc_o),
	.wb_stb_i(wb_s1_stb_o),
	.wb_ack_o(wb_s1_ack_i)
	);

endmodule