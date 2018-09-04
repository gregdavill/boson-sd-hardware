module wb_cc_cfg
  #(parameter WB_AW = 32,
    parameter WB_DW = 32)
  (
   input                  wb_clk_i,
   input                  wb_rst_i,
   //Wishbone IF
   input [4:0]            wb_adr_i,
   input [WB_DW-1:0]      wb_dat_i,
   input [WB_DW/8-1:0]    wb_sel_i,
   input                  wb_we_i ,
   input                  wb_cyc_i,
   input                  wb_stb_i,
   input [2:0]            wb_cti_i,
   input [1:0]            wb_bte_i,
   output [WB_DW-1:0]     wb_dat_o,
   output reg             wb_ack_o,
   output                 wb_err_o,
   // v_sync input
   input                  frame_start,
   input 				  capture_done,
   //Application IF
   output reg             enable);


	reg ready_armed;

	reg [1:0] frame_start_sr;

	/* Syncronise our v_sync signal */
   always @(posedge wb_clk_i) begin
		if (wb_rst_i) begin
			frame_start_sr <= 2'b0;
		end else begin
			frame_start_sr <= {frame_start_sr[0],frame_start};
		end
	end


   // Read
   assign wb_dat_o = wb_adr_i[4:2] == 0 ? {{(WB_DW-2){1'b0}}, enable, ready_armed} :
                     0;

   always @(posedge wb_clk_i) begin
      // Ack generation
      if (wb_ack_o)
	wb_ack_o <= 0;
      else if (wb_cyc_i & wb_stb_i & !wb_ack_o)
	wb_ack_o <= 1;

      //Read/Write logic
      if (wb_stb_i & wb_cyc_i & wb_we_i & wb_ack_o) begin
	 case (wb_adr_i[4:2])
	   0 : begin
	      if (wb_dat_i[0]) ready_armed <= 1;
	   end
	   default : ;
	 endcase
      end

	if(frame_start_sr[1] & ready_armed) begin
		enable <= 1'b1;
		ready_armed <= 1'b0;
	end

	if(capture_done) begin
		enable <= 1'b0;
	end

      if (wb_rst_i) begin
	 wb_ack_o   <= 0;
	 enable     <= 1'b0;
	 ready_armed <= 0;
      end
   end
   assign wb_err_o = 0;

endmodule
