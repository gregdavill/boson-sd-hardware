`default_nettype wire

module simpleuart_wb(
    input          wb_clk_i,
    input          wb_rst_i,
	
    input [3:0]  wb_adr_i,
    input [31:0]  wb_dat_i,
    input  [3:0]  wb_sel_i,
    input         wb_we_i,
    input         wb_cyc_i,
    input         wb_stb_i,
    output [31:0] wb_dat_o,
    output        wb_ack_o,
	
	output ser_tx,
	input  ser_rx
);
	
	
	wire o_busy;

	
	assign wb_ack_o = sel_reg_div ? (wb_cyc_i) : ((!o_busy && wb_we_i) || ( ! wb_we_i && wb_stb_i));
	//assign wb_dat_o = 32'b0;


	wire [31:0] reg_dat_dat_o, reg_div_dat_o;
	wire sel_reg_div = (wb_adr_i[3:0] == 4'h0) && wb_cyc_i && wb_stb_i;
	wire sel_reg_dat = (wb_adr_i[3:0] == 4'h4) && wb_cyc_i && wb_stb_i;

	assign wb_dat_o = sel_reg_div ? reg_div_dat_o : reg_dat_dat_o;

	simpleuart simpleuart (
	.clk(wb_clk_i),
	.resetn(!wb_rst_i),

	.ser_tx(ser_tx),
	.ser_rx(ser_rx),

	.reg_div_we(sel_reg_div ? wb_sel_i : 4'b0),
	.reg_div_di(wb_dat_i),
	.reg_div_do(reg_div_dat_o),

	.reg_dat_we(sel_reg_dat && wb_we_i && wb_sel_i[0]),
	.reg_dat_re(sel_reg_dat && !wb_we_i),
	.reg_dat_di(wb_dat_i),
	.reg_dat_do(reg_dat_dat_o),
	.reg_dat_wait(o_busy)
);

/*	
txuartlite tx_uart(
	.i_clk(clk), 
	.i_wr(wb_we_i && wb_stb_i && wb_cyc_i), 
	.i_data(wb_dat_i[7:0]), 
	.o_uart_tx(ser_tx), 
	.o_busy(b_busy)
);
*/
	
endmodule
