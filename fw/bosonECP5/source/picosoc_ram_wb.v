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
    output wire    wb_ack_o
    
	);
	
	reg ack_o;
	
	assign wb_ack_o = ack_o;
	
	always @(posedge wb_clk_i)
		ack_o <= wb_stb_i && wb_cyc_i && ~ack_o; 
	
	picosoc_mem #(.WORDS(MEM_WORDS)) memory (
		.clk(wb_clk_i),
		.wen((wb_cyc_i && wb_we_i) ? wb_sel_i : 4'b0),
		.addr(wb_cyc_i ? wb_adr_i[23:2] : 22'b0),
		.wdata(wb_dat_i),
		.rdata(wb_dat_o)
	);
	
endmodule