module wb_stream_writer_ctrl
  #(parameter WB_AW = 32,
    parameter WB_DW = 32,
    parameter FIFO_AW = 0,
    parameter MAX_BURST_LEN = 0)
  (//Stream data output
   input 		  wb_clk_i,
   input 		  wb_rst_i,
   output [WB_AW-1:0] 	  wbm_adr_o,
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
   output [WB_DW-1:0] 	  fifo_d,
   output 		  fifo_wr,
   input [FIFO_AW:0] 	  fifo_cnt,
   //Configuration interface
   output reg 		  busy,
   input 		  enable,
   output reg [WB_DW-1:0] tx_cnt,
   input [WB_AW-1:0] 	  start_adr,
   input [WB_AW-1:0] 	  buf_size,
   input [WB_AW-1:0] 	  burst_size);

   wire			    active;

   wire 		    timeout = 1'b0;
   reg 			    last_adr;
   reg [$clog2(MAX_BURST_LEN-1):0] burst_cnt;

   //FSM states
   localparam S_IDLE   = 0;
   localparam S_ACTIVE = 1;
   
   reg [1:0] 			      state;

   wire 			      burst_end = (burst_cnt == burst_size-1);
   wire fifo_ready = (fifo_cnt+burst_size <= 2**FIFO_AW);

   always @(active or burst_end) begin
      wbm_cti_o = !active     ? 3'b000 :
		  burst_end   ? 3'b111 :
		  3'b010; //LINEAR_BURST;
   end

   assign active = (state == S_ACTIVE);
   assign fifo_d = wbm_dat_i;
   assign fifo_wr = wbm_ack_i;

   assign wbm_sel_o = 4'hf;
   assign wbm_we_o = 1'b0;
   assign wbm_cyc_o = active;
   assign wbm_stb_o = active;
   assign wbm_bte_o = 2'b00;
   assign wbm_dat_o = {WB_DW{1'b0}};
   assign wbm_adr_o = start_adr + tx_cnt*4;

   always @(posedge wb_clk_i) begin
      //Address generation
      last_adr = (tx_cnt == buf_size[WB_AW-1:2]-1);
      if (wbm_ack_i)
	 if (last_adr)
	   tx_cnt <= 0;
	 else
	   tx_cnt <= tx_cnt+1;

      //Burst counter
      if(!active)
	burst_cnt <= 0;
      else
	if(wbm_ack_i)
	  burst_cnt <= burst_cnt + 1;
      
      //FSM
      case (state)
	S_IDLE : begin
	   if (busy & fifo_ready)
	     state <= S_ACTIVE;
	   if (enable)
	     busy <= 1'b1;
	end
	S_ACTIVE : begin
	   if (burst_end & wbm_ack_i) begin
	      state <= S_IDLE;
	      if (last_adr)
		busy <= 1'b0;
	   end
	end
	default : begin
	   state <= S_IDLE;
	end
      endcase // case (state)
      
      if(wb_rst_i) begin
	 state <= S_IDLE;
	 tx_cnt <= 0;
	 busy <= 1'b0;
      end
   end
   
endmodule
