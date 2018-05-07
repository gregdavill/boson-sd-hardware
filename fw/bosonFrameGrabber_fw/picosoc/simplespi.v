/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

module simplespi (
	input clk,
	input resetn,

	output spi_clk,
	output spi_mosi,
	input  spi_miso,

	input   [3:0] reg_div_we,
	input  [31:0] reg_div_di,
	output [31:0] reg_div_do,

	input   [3:0] reg_conf_we,
	input  [31:0] reg_conf_di,
	output [31:0] reg_conf_do,

	input         reg_dat_we,
	input  [31:0] reg_dat_di,
	output [31:0] reg_dat_do
);
	reg [31:0] cfg_divider;

	reg [3:0] recv_state;
	reg [31:0] recv_divcnt;
	reg [7:0] recv_pattern;
	reg [7:0] recv_buf_data;
	reg recv_buf_valid;

	reg [9:0] send_pattern;
	reg [4:0] send_bitcnt;
	reg [31:0] send_divcnt;
	reg send_clk;

	assign reg_div_do = cfg_divider;
	assign reg_conf_do = {31'b0, spi_config_idle};

	assign reg_dat_do = recv_buf_data;

	always @(posedge clk) begin
		if (!resetn) begin
			cfg_divider <= 10;
		end else begin
			if (reg_div_we[0]) cfg_divider[ 7: 0] <= reg_div_di[ 7: 0];
			if (reg_div_we[1]) cfg_divider[15: 8] <= reg_div_di[15: 8];
			if (reg_div_we[2]) cfg_divider[23:16] <= reg_div_di[23:16];
			if (reg_div_we[3]) cfg_divider[31:24] <= reg_div_di[31:24];
		end
	end


	/* SW control over the CS pin */
	assign spi_mosi = send_pattern[7];
	assign spi_clk = send_clk;

	reg spi_config_idle;


	always @(posedge clk) begin
		send_divcnt <= send_divcnt + 1;
		if (!resetn) begin
			send_pattern <= ~0;
			send_bitcnt <= 0;
			send_divcnt <= 0;
			spi_config_idle <= 1;
			send_clk <= 0;
		end else begin
			if (reg_dat_we && !send_bitcnt) begin
				send_pattern <= {reg_dat_di[7:0]};
				send_bitcnt <= 16;
				send_divcnt <= 0;
				spi_config_idle <= 0;
				send_clk <= 0;
			end else
			if (send_divcnt >= cfg_divider && send_bitcnt) begin
				send_clk <= ~send_clk;

				if(!send_clk) begin
					recv_buf_data <= {recv_buf_data[6:0], spi_miso};
				end else begin
					send_pattern <= {send_pattern[6:0], 1'b0};
				end

				send_bitcnt <= send_bitcnt - 1;
				send_divcnt <= 0;
			end else
			if(send_bitcnt == 0) begin
				spi_config_idle <= 1;
				send_clk <= 0;
			end

		end
	end

	
endmodule
