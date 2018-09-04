module wb_stream_reader
  #(parameter WB_DW = 32,
    parameter WB_AW = 32,
    parameter FIFO_AW = 0,
    parameter MAX_BURST_LEN = 2**FIFO_AW)
   (input 		 clk,
    input                rst,
    //Wisbhone memory interface
    output [WB_AW-1:0]   wbm_adr_o,
    output [WB_DW-1:0]   wbm_dat_o,
    output [WB_DW/8-1:0] wbm_sel_o,
    output               wbm_we_o ,
    output               wbm_cyc_o,
    output               wbm_stb_o,
    output [2:0]         wbm_cti_o,
    output [1:0]         wbm_bte_o,
    input [WB_DW-1:0]    wbm_dat_i,
    input                wbm_ack_i,
    input                wbm_err_i,
    //Stream interface
    input [WB_DW-1:0]    stream_s_data_i,
    input                stream_s_valid_i,
    output               stream_s_ready_o,
    output               irq_o,
    //Configuration interface
    input [4:0]          wbs_adr_i,
    input [WB_DW-1:0]    wbs_dat_i,
    input [WB_DW/8-1:0]  wbs_sel_i,
    input                wbs_we_i ,
    input                wbs_cyc_i,
    input                wbs_stb_i,
    input [2:0]          wbs_cti_i,
    input [1:0]          wbs_bte_i,
    output [WB_DW-1:0]   wbs_dat_o,
    output               wbs_ack_o,
    output               wbs_err_o);

   //FIFO interface
   wire [WB_DW-1:0] 	 fifo_dout;
   wire [FIFO_AW:0] 	 fifo_cnt;
   wire 		 fifo_rd;

   //Configuration parameters
   wire 		 enable;
   wire [WB_DW-1:0] 	 tx_cnt;
   wire [WB_AW-1:0] 	 start_adr; 
   wire [WB_AW-1:0] 	 buf_size;
   wire [WB_AW-1:0] 	 burst_size;

   wire 		 busy;
   
   wb_stream_reader_ctrl
     #(.WB_AW (WB_AW),
       .WB_DW (WB_DW),
       .FIFO_AW (FIFO_AW),
       .MAX_BURST_LEN (MAX_BURST_LEN))
   ctrl
     (.wb_clk_i    (clk),
      .wb_rst_i    (rst),
      //Stream data output
      .wbm_adr_o (wbm_adr_o),
      .wbm_dat_o (wbm_dat_o),
      .wbm_sel_o (wbm_sel_o),
      .wbm_we_o  (wbm_we_o),
      .wbm_cyc_o (wbm_cyc_o),
      .wbm_stb_o (wbm_stb_o),
      .wbm_cti_o (wbm_cti_o),
      .wbm_bte_o (wbm_bte_o),
      .wbm_dat_i (wbm_dat_i),
      .wbm_ack_i (wbm_ack_i),
      .wbm_err_i (wbm_err_i),
      //FIFO interface
      .fifo_d   (fifo_dout),
      .fifo_cnt (fifo_cnt),
      .fifo_rd  (fifo_rd),
      //Configuration interface
      .busy       (busy),
      .enable     (enable),
      .tx_cnt     (tx_cnt),
      .start_adr  (start_adr),
      .buf_size   (buf_size),
      .burst_size (burst_size));

   wb_stream_reader_cfg
     #(.WB_AW (WB_AW),
       .WB_DW (WB_DW))
   cfg
     (.wb_clk_i  (clk),
      .wb_rst_i  (rst),
      //Wishbone IF
      .wb_adr_i (wbs_adr_i),
      .wb_dat_i (wbs_dat_i),
      .wb_sel_i (wbs_sel_i),
      .wb_we_i  (wbs_we_i),
      .wb_cyc_i (wbs_cyc_i),
      .wb_stb_i (wbs_stb_i),
      .wb_cti_i (wbs_cti_i),
      .wb_bte_i (wbs_bte_i),
      .wb_dat_o (wbs_dat_o),
      .wb_ack_o (wbs_ack_o),
      .wb_err_o (wbs_err_o),
      //Application IF
      .irq       (irq_o),
      .busy      (busy),
      .enable    (enable),
      .tx_cnt    (tx_cnt),
      .start_adr (start_adr),
      .buf_size  (buf_size),
      .burst_size (burst_size));

   wb_stream_writer_fifo
     #(.DW (WB_DW),
       .AW (FIFO_AW))
   fifo
   (.clk   (clk),
    .rst   (rst),

    .stream_s_data_i  (stream_s_data_i),
    .stream_s_valid_i (stream_s_valid_i),
    .stream_s_ready_o (stream_s_ready_o),

    .stream_m_data_o  (fifo_dout),
    .stream_m_valid_o (),
    .stream_m_ready_i (fifo_rd),

    .cnt   (fifo_cnt));

endmodule
