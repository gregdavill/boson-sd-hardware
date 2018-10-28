module wb_crc32
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
   output                 wb_err_o);

	reg [31:0] din;
	reg update;
	reg sw_rst;
	
	wire [31:0] crc_flipped;

	CRC32_Ethernet_x32 crc32 (
		.clk        (wb_clk_i   ),
		.reset      (wb_rst_i | sw_rst),
		.update     (update     ),
		.din        (din        ),
		.crc_flipped(crc_flipped)
	);

   // Read
   assign wb_dat_o = wb_adr_i[4:2] == 0 ? 0 :
		     		 wb_adr_i[4:2] == 1 ? crc_flipped :
                     0;

   always @(posedge wb_clk_i) begin
      // Ack generation
      if (wb_ack_o)
	wb_ack_o <= 0;
      else if (wb_cyc_i & wb_stb_i & !wb_ack_o)
	wb_ack_o <= 1;

		update <= 1'b0;
      //Read/Write logic
      if (wb_stb_i & wb_cyc_i & wb_we_i & wb_ack_o) begin
	 case (wb_adr_i[4:2])
	   0 : begin
		din <= wb_dat_i;
		update <= 1'b1;
	   end
	   2 : begin
		sw_rst <= 1;
	   end
	   default : ;
	 endcase
      end

   
      if (wb_rst_i | sw_rst) begin
		wb_ack_o   <= 0;
		update <= 0;
		din <= 0;
		sw_rst <= 1'b0;
	   end
   end
   assign wb_err_o = 0;

endmodule
