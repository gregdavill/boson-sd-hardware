`default_nettype wire

module picosoc_ram_wb #(
	parameter integer MEM_WORDS = 256
)
   (input          wb_clk_i,
    input          wb_rst_i,
	input [31:0]   wb_adr_i,
	input [31:0]   wb_dat_i,
    input          wb_cyc_i,
    input          wb_stb_i,
    input  [3:0]   wb_sel_i,
    input          wb_we_i,
    output  [31:0] wb_dat_o,
    output         wb_ack_o
    
	);
	
	
	reg wb_ack_o;
	always @(posedge wb_clk_i)
		wb_ack_o <= wb_stb_i && wb_cyc_i; 
	//assign wb_ack_o = wb_stb_i && wb_cyc_i; 
	
	//always @(posedge wb_clk_i)
	//	ram_ready <= (int_wbm_stb_o && int_wbm_cyc_o) && !mem_ready && int_wbm_adr_o < 4*MEM_WORDS;

	picosoc_mem #(.WORDS(MEM_WORDS)) memory (
		.clk(wb_clk_i),
		.wen((wb_cyc_i && wb_we_i) ? wb_sel_i : 4'b0),
		.addr(wb_adr_i[23:2]),
		.wdata(wb_dat_i),
		.rdata(wb_dat_o)
	);
	
endmodule