`default_nettype wire
//TODO: Allow burst size = 1
//TODO: Add timeout counter to clear out FIFO
module wb_stream_reader_ctrl
  #(parameter WB_AW = 32,
    parameter WB_DW = 32,
    parameter FIFO_AW = 0,
    parameter MAX_BURST_LEN = 0)
  (//Stream data output
   input 		  wb_clk_i,
   input 		  wb_rst_i,
   output reg [WB_AW-1:0] 	  wbm_adr_o,
   output [WB_DW-1:0] 	  wbm_dat_o,
   output [WB_DW/8-1:0]   wbm_sel_o,
   output 		  wbm_we_o ,
   output 		  wbm_cyc_o,
   output 		  wbm_stb_o,
   output reg [2:0] 	  wbm_cti_o,
   output [1:0] 	  wbm_bte_o,
   input [WB_DW-1:0] 	  wbm_dat_i,
   input 		  wbm_ack_i,
   input 		  wbm_err_i, 
   //FIFO interface
   input [WB_DW-1:0] 	  fifo_data,
   input                  fifo_valid,
   input          		  fifo_clk,
   //Configuration interface
   output reg 		  busy,
   input 		  enable,
   output reg [WB_DW-1:0] tx_cnt,
   input [WB_AW-1:0] 	  start_adr,
   input [WB_AW-1:0] 	  buf_size,
   input [WB_AW-1:0] 	  burst_size);

 

wire reset_fifo;

wire wb_empty_o;

assign fifo_rd = wbm_cyc_o & wbm_ack_i;

assign wbm_we_o =  !wb_empty_o;
assign wbm_cyc_o = enable;
assign wbm_stb_o = wbm_cyc_o;

generic_fifo_dc_gray #(
    .dw(32), 
    .aw(7)
    ) generic_fifo_dc_gray0 (
    .rd_clk(wb_clk_i),
    .wr_clk(fifo_clk), 
    .rst(!(wb_rst_i | !enable)), 
    .clr(1'b0), 
    .din(fifo_data), 
    .we(fifo_valid & enable),
    .dout(wbm_dat_o), 
    .re(enable & wbm_cyc_o & wbm_ack_i), 
    .full(), 
    .empty(wb_empty_o), 
    .wr_level(), 
    .rd_level() 
    );
    
 
always @(posedge wb_clk_i or posedge wb_rst_i)
    if (wb_rst_i) begin
        wbm_adr_o <= 0;
		busy <= 0;
    end
    else begin
        
        if (wbm_cyc_o & wbm_stb_o & wbm_ack_i)
            wbm_adr_o <= wbm_adr_o + 4;
        else if (!enable)
            wbm_adr_o <= start_adr;

		if(wbm_ack_i)
			tx_cnt <= tx_cnt + 1;
		if(tx_cnt > 32)
			busy <= 0;
    end

   
endmodule
