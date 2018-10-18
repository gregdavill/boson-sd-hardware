module wb_reset_reg
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
   //Application IF
   output reg             reset_out);


   // Read
   assign wb_dat_o = 0;

   always @(posedge wb_clk_i) begin
      // Ack generation
      if (wb_ack_o)
	wb_ack_o <= 0;
      else if (wb_cyc_i & wb_stb_i & !wb_ack_o)
	wb_ack_o <= 1;

      //Read/Write logic
      if (wb_stb_i & wb_cyc_i & wb_we_i & wb_ack_o) begin
		if(wb_adr_i[4:2] == 0)
			if(wb_dat_i == 32'hDEADBEEF)
				reset_out <= 1'b1;
	  end

      if (wb_rst_i) begin
	 
		reset_out <= 1'b0;
      end
	  
   end
   assign wb_err_o = 0;

endmodule
