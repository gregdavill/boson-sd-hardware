module wb_hyper (
	wire        wb_clk_i, 
	wire        wb_rst_i, 
	wire [31:0] wb_dat_i, 
	wire [31:0] wb_dat_o,
	wire [31:0] wb_adr_i, 
	wire [3:0]  wb_sel_i, 
	wire        wb_we_i, 
	wire        wb_cyc_i, 
	wire        wb_stb_i, 
	wire        wb_ack_o,
    // HyperBus
	wire        hb_clk_p_o,
	wire        hb_clk_n_o,
	wire        hb_cs_o,
	wire        hb_rwds_o,
	wire        hb_rwds_i,
	wire        hb_rwds_dir,
	wire [7:0]  hb_dq_o,
	wire [7:0]  hb_dq_i,
	wire        hb_dq_dir,
	wire        hb_rst_o,
	// Debug 
	wire [7:0]  sump_dbg
);



/* translate from wishbone to hyper_xface */
always @(posedge wb_clk_i) begin
	/* Generate a pulse from our stb */
	stb_sr <= {stb_sr[0], wb_stb_i & !busy};

	if(wb_rst_i) begin
	end
end

/* wb_slave to handle config registers of hyperram */
always @(posedge wb_clk_i) begin
	/* Generate a pulse from our stb */
	stb_sr <= {stb_sr[0], wb_stb_i & !busy};

	if(wb_rst_i) begin
	end
end



/* wb control registers */
reg [7:0] hyperbus_latency_1x;
reg [7:0] hyperbus_latency_2x;


/* hyper_xface wires */
wire rd_req;
wire wr_req;
wire wr_byte_en;
wire read_burst_len;
wire wr_mem;
wire addr;
wire wr_d;
wire rd_d;
wire rd_rdy;
wire read_burst_len;
wire busy;
wire next_burst_rdy;

assign rd_req = (stb_sr == 2'b01) & wb_cyc_i & !wb_we_i;
assign wd_req = (stb_sr == 2'b01) & wb_cyc_i & wb_we_i;
assign wr_byte_en = wb_we_i;
assign addr = wb_adr_i;
assign wr_d = wb_dat_i;
assign wb_dat_o = rd_d;
assign wb_ack_o = rd_rdy | next_burst_rdy;

hyper_xface h_xface 
(
  .reset          (wb_rst_i),
  .clk            (wb_clk_i),
  .rd_req         (rd_req),
  .wr_req         (wr_req),
  .mem_or_reg     (wr_mem),
  .wr_byte_en     (wr_byte_en),
  .rd_num_dwords  (read_burst_len),
  .addr           (addr),
  .wr_d           (wr_d),
  .rd_d           (rd_d),
  .rd_rdy         (read_valid),
  .busy           (busy),
  .burst_wr_rdy   (next_burst_rdy),
  .latency_1x     (hyperbus_latency_1x),
  .latency_2x     (hyperbus_latency_2x),

  .dram_dq_in     (hb_dq_i),
  .dram_dq_out    (hb_dq_o),
  .dram_dq_oe_l   (hb_dq_dir),

  .dram_rwds_in   (hb_rwds_i),
  .dram_rwds_out  (hb_rwds_o),
  .dram_rwds_oe_l (hb_rwds_dir),

  .dram_ck        (dram_ck),
  .dram_rst_l     (dram_rst),
  .dram_cs_l      (dram_cs),
  .sump_dbg       (sump_dbg)
);// module hyper_xface 



endmodule