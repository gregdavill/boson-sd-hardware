`timescale 1 us/1 us

module top;


   vlog_tb_utils vlog_tb_utils0();
   vlog_tap_generator #("wb_hyper.tap", 1) vtg();

   localparam aw = 32;
   localparam dw = 32;

   reg	   wb_clk = 1'b1;
   reg     wb_clk90 = 1'b1;

   reg	   wb_rst = 1'b1;

   always #6 wb_clk <= ~wb_clk;
   initial  #500 wb_rst <= 0;

	always @(posedge wb_clk or negedge wb_clk)
		#3 wb_clk90 <= wb_clk;


	reg done = 0;


	


	always @(posedge done) begin
      vtg.ok("All tests complete");
      $display("All tests complete");
      $finish;
   end


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


  wb_bfm_master #(
		  .dw (dw),
    .MAX_BURST_LEN           (32),
    .MAX_WAIT_STATES         (8),
    .VERBOSE                 (1)
  ) bfm_cfg (
    .wb_clk_i                (wb_clk),
    .wb_rst_i                (wb_rst),
    .wb_adr_o                (wb_s2_adr_o),
    .wb_dat_o                (wb_s2_dat_o),
    .wb_sel_o                (wb_s2_sel_o),
    .wb_we_o                 (wb_s2_we_o),
    .wb_cyc_o                (wb_s2_cyc_o),
    .wb_stb_o                (wb_s2_stb_o),
   // .wb_cti_o                (wb_s2_cti_o),
   // .wb_bte_o                (wb_s1_bte_o),
    .wb_dat_i                (wb_s2_dat_i),
    .wb_ack_i                (wb_s2_ack_i)
  //  .wb_err_i                (wb_s1_err_i)
   // .wb_rty_i                (wb_s1_rty_i)
  );


	reg err;
	reg [31:0] data;

		reg[31:0] i;


	initial begin

		bfm.reset();
		//bfm.init();
		bfm_cfg.reset();
		//bfm_cfg.init();

		@(negedge wb_rst);

		repeat (2) @(posedge wb_clk);

	//	bfm_cfg.write(4'h0,8'h04,4'hF, err);
	//	bfm_cfg.write(4'h4,8'h0a,4'hF, err);	
	//	bfm_cfg.write(4'h8,32'h8fe4_0000,4'hF, err);
		
		#1000
		//bfm_cfg.read(4'h0,data, err);
		//bfm_cfg.read(4'h4,data, err);
		//bfm_cfg.read(4'h8,data, err);

		bfm.write(32'h0000_0000, 32'h12345678, 4'hF, err);	
		#350
		bfm.read(32'h0000_0000, data, err);	
		#500
		bfm.write(32'h0000_0000, 32'h12345678, 4'hF, err);	
		#500 
		bfm.read(32'h0000_0000, data, err);	
		#500


		bfm.write_data[0] = 32'h01020304;
		bfm.write_data[1] = 32'h05060708;
		bfm.write_data[2] = 32'h090a0b0c;
		bfm.write_data[3] = 32'h0d0e0f00;

	
		bfm.write_burst(0,0,4'hF, 3'b010, 2'b00, 4, err);

	    #100

		bfm.read_burst_comp(0,0,4'hF, 3'b010, 2'b00, 4, err);
		
		#1000 done <= 1;
	end

	/* hyperram signals */
	wire hb_clk;
	wire hb_cs;
	wire hb_rwds_o;
	wire hb_rwds_i;
	wire hb_rwds_dir;
	wire [7:0] hb_dq_o;
	wire [7:0] hb_dq_i;
	wire hb_dq_dir;
	wire hb_rst;


	wire [31:0] wb_s1_dat_o;
	wire [31:0] wb_s1_dat_i;
	wire [31:0] wb_s1_adr_o;
	wire [3:0] wb_s1_sel_o;
	wire [2:0] wb_s1_cti_o;
	wire wb_s1_we_o ;
	wire wb_s1_cyc_o;
	wire wb_s1_stb_o;
	wire wb_s1_ack_i;


	wire [31:0] wb_s2_dat_o;
	wire [31:0] wb_s2_dat_i;
	wire [31:0] wb_s2_adr_o;
	wire [3:0] wb_s2_sel_o;
	wire wb_s2_we_o ;
	wire wb_s2_cyc_o;
	wire wb_s2_stb_o;
	wire wb_s2_ack_i;


	/* insert a wishbone controller for each slave */



	wb_hyper uut(
	.wb_clk_i(wb_clk),
	.wb_rst_i(wb_rst),

	.clk90 (wb_clk90),

	/* wishbone slave #1 */
	.wb_dat_i(wb_s1_dat_o),
	.wb_dat_o(wb_s1_dat_i),
	.wb_adr_i(wb_s1_adr_o),
	.wb_sel_i(wb_s1_sel_o),
	.wb_we_i (wb_s1_we_o ),
	.wb_cti_i(wb_s1_cti_o),
	.wb_cyc_i(wb_s1_cyc_o),
	.wb_stb_i(wb_s1_stb_o),
	.wb_ack_o(wb_s1_ack_i),
	// Wishbone Cfg Slave
	.wb_cfg_dat_i(wb_s2_dat_o),
	.wb_cfg_dat_o(wb_s2_dat_i),
	.wb_cfg_adr_i(wb_s2_adr_o),
	.wb_cfg_sel_i(wb_s2_sel_o),
	.wb_cfg_we_i (wb_s2_we_o ),
	.wb_cfg_cyc_i(wb_s2_cyc_o),
	.wb_cfg_stb_i(wb_s2_stb_o),
	.wb_cfg_ack_o(wb_s2_ack_i),
	
		
	.hb_clk_o   (hb_clk),
	.hb_cs_o    (hb_cs),
	.hb_rwds_o  (hb_rwds_o),
	.hb_rwds_i  (hb_rwds_i),
	.hb_rwds_dir(hb_rwds_dir),
	.hb_dq_o    (hb_dq_o),
	.hb_dq_i    (hb_dq_i),
	.hb_dq_dir  (hb_dq_dir),
	.hb_rst_o   (hb_rst)
	);

	hyper_wrapper psram_wrap (
		.hb_clk_o   (hb_clk),
		.hb_cs_o    (hb_cs),
		.hb_rwds_o  (hb_rwds_o),
		.hb_rwds_i  (hb_rwds_i),
		.hb_rwds_dir(hb_rwds_dir),
		.hb_dq_o    (hb_dq_o),
		.hb_dq_i    (hb_dq_i),
		.hb_dq_dir  (hb_dq_dir),
		.hb_rst_o   (hb_rst)
	);


endmodule