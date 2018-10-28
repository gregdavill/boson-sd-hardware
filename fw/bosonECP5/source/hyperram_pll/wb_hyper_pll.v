`default_nettype none

module wb_hyper (
	input wire         wb_clk_i, 
	input wire         wb_rst_i, 
	input wire		   clk90,
	// Wishbone Hyperbus Slave
	input wire [31:0]  wb_dat_i, 
	output reg [31:0]  wb_dat_o,
	input wire [31:0]  wb_adr_i, 
	input wire [3:0]   wb_sel_i,
	input wire [2:0]   wb_cti_i, 
	input wire         wb_we_i, 
	input wire         wb_cyc_i, 
	input wire         wb_stb_i, 
	output reg         wb_ack_o,
	// Wishbone Cfg Slave
	input wire  [31:0] wb_cfg_dat_i, 
	output wire [31:0] wb_cfg_dat_o,
	input wire  [31:0] wb_cfg_adr_i, 
	input wire  [3:0]  wb_cfg_sel_i, 
	input wire         wb_cfg_we_i, 
	input wire         wb_cfg_cyc_i, 
	input wire         wb_cfg_stb_i, 
	output reg         wb_cfg_ack_o,
    // HyperBus
	output wire        hb_clk_o,
	output wire        hb_clk_n_o,
	output wire        hb_cs_o,
	output wire        hb_rwds_o,
	input  wire        hb_rwds_i,
	output wire        hb_rwds_dir,
	output wire [7:0]  hb_dq_o,
	input  wire [7:0]  hb_dq_i,
	output wire        hb_dq_dir,
	output wire        hb_rst_o,
	// Debug 
	output wire [31:0] sump_dbg
);


/* wb control registers */
reg [31:0] hyperbus_cfg_word;
reg hyperbus_cfg_en;

reg [5:0] ack_count;

reg rd_req;

reg wr_mem;

reg [31:0] addr;
reg [31:0] wr_d;
wire [31:0] rd_d;

wire [3:0] wr_byte_en;
wire read_burst_en;

wire busy;
wire next_burst_rdy;
wire read_valid;

assign wr_byte_en = wb_sel_i;
assign read_burst_en = (wb_cti_i == 3'b010) && wb_cyc_i;

/* translate from wishbone to hyper_xface */
always @(posedge wb_clk_i) begin
	/* Generate our first_byte signal */
	if((wb_cyc_i && wb_stb_i) == 0)
		ack_count <= 0;
	else if(wb_ack_o)
		ack_count <= ack_count + 1;
end

assign wb_cfg_dat_o = hyperbus_cfg_word;

/* wb_slave to handle config registers of hyperram */
always @(posedge wb_clk_i ) begin

	hyperbus_cfg_en <= 1'b0;
	wb_cfg_ack_o <= 1'b0;
	
	if(wb_cfg_stb_i & wb_cfg_cyc_i & !wb_cfg_ack_o) begin
		wb_cfg_ack_o <= 1'b1;
		if(wb_cfg_we_i) begin
			case (wb_cfg_adr_i[3:2])
				2'b00: begin 
					hyperbus_cfg_word <= wb_cfg_dat_i;
					hyperbus_cfg_en <= 1'b1;
					end
			endcase
		end
	end
end

wire wb_read_req;
wire wb_write_req;
assign wb_read_req = wb_stb_i & wb_cyc_i & !wb_we_i & !wb_ack_o & !{busy,busy_sr[2]};
assign wb_write_req = wb_stb_i & wb_cyc_i & wb_we_i & !wb_ack_o & !{busy,busy_sr[2]};

reg ack_f;
reg [2:0] busy_sr;
reg hyperbus_cfg_loc;
reg [31:0] wb_cfg_dat_loc;


always @(posedge wb_clk_i) begin
 wb_ack_o <= ((next_burst_rdy && (wb_cti_i != 3'b000)) | read_valid | (ack_count == 0 && wb_write_req)) && wb_cyc_i && wb_stb_i;
 wb_dat_o <= rd_d;
end

wire continue_burst;
assign continue_burst = (wb_stb_i & wb_cyc_i & wb_we_i & (wb_cti_i != 3'b000));

reg wr_req_r;
wire wr_req = wr_req_r | (wb_ack_o && continue_burst);

/* Handle different types of requests */ 
always @(posedge wb_clk_i) begin
  wr_req_r <= 1'b0;	 
  rd_req <= 1'b0;

  ack_f <= wb_ack_o;
  busy_sr <= {busy_sr[1:0], busy};  

	wb_cfg_dat_loc <= wb_cfg_dat_i;
	hyperbus_cfg_loc <= hyperbus_cfg_en;

  if(!(|{busy_sr,busy,rd_req,wr_req})) begin
  	if(hyperbus_cfg_en) begin
	  /* special address required for config writes */
	  addr <= 32'h0000_0800;
	  wr_mem <= 1'b1;
	  wr_req_r <= 1'b1;	
	  wr_d <= hyperbus_cfg_word;
	end else if(wb_read_req) begin 
	  addr <= wb_adr_i[23:2];
	  wr_mem <= 1'b0;
	  rd_req <= 1'b1;
	end else if(wb_write_req) begin 
	  addr <= wb_adr_i[23:2];
	  wr_d <= wb_dat_i;
	  wr_mem <= 1'b0;
	  wr_req_r <= 1'b1;
	end
  end else if(continue_burst && next_burst_rdy) begin
	  addr <= wb_adr_i[23:2];
	  wr_mem <= 1'b0;
	  wr_d <= wb_dat_i;
	end
end




hyper_xface_pll h_xface 
(
  .reset          (wb_rst_i      ),
  .clk            (wb_clk_i      ),
  .clk_90p        (clk90         ),
  .rd_req         (rd_req        ),
  .wr_req         (wr_req        ),
  .mem_or_reg     (wr_mem        ),
  .rd_burst_en    (read_burst_en ),
  .addr           (addr          ),
  .wr_d           (wr_d          ),
  .rd_d           (rd_d          ),
  .rd_rdy         (read_valid    ),
  .busy           (busy          ),
  .burst_wr_rdy   (next_burst_rdy),

  .simulation_en  (1'b0          ),

  .dram_dq_in     (hb_dq_i       ),
  .dram_dq_out    (hb_dq_o       ),
  .dram_dq_oe_l   (hb_dq_dir     ),

  .dram_rwds_in   (hb_rwds_i     ),
  .dram_rwds_out  (hb_rwds_o     ),
  .dram_rwds_oe_l (hb_rwds_dir   ),

  .dram_ck        (hb_clk_o      ),
  .dram_ck_n      (hb_clk_n_o    ),
  .dram_rst_l     (hb_rst_o      ),
  .dram_cs_l      (hb_cs_o       ),
  .sump_dbg       (sump_dbg      )
);// module hyper_xface 


endmodule
