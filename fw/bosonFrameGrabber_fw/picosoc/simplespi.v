/* 
 * MIT License
 * 
 * Copyright (c) 2018 Greg Davill
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
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

	input   [3:0] reg_conf_we,
	input  [31:0] reg_conf_di,
	output [31:0] reg_conf_do,

	input  [3:0]    reg_dat_we,
	input  [31:0] reg_dat_di,
	output [31:0] reg_dat_do,


	input   [3:0]  reg_count_we,
	input  [31:0]  reg_count_i,

    input   [3:0]  reg_addr_we,
	input  [31:0]  reg_addr_i,

    

	output          dma_en_o,
    output [31:0]   dma_addr_o,
    output          dma_rd_o,
    input           dma_rdata_rdy_i,
    input  [31:0]   dma_rdata_i,
    input           dma_busy_i
);
	reg [31:0] cfg_divider;

	reg [3:0] recv_state;
	reg [31:0] recv_divcnt;
	reg [7:0] recv_pattern;
	reg [7:0] recv_buf_data;
	reg recv_buf_valid;

	reg [31:0] send_pattern;
	reg [7:0] send_bitcnt;
	reg [31:0] send_divcnt;
	reg send_clk;

	reg [15:0] spi_dma_count;
    reg [31:0] spi_dma_addr;

    reg dma_rd_o;
    reg [31:0] dma_addr_o;

    assign dma_en_o = (|spi_dma_count);

    wire spi_idle;
    assign spi_idle = !spi_dma_count & spi_state == SPI_IDLE;
	assign reg_conf_do = {31'b0, spi_idle};

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


	/* Control over the HW outputs */
	assign spi_mosi = send_pattern[31];
	assign spi_clk = send_clk;


	// ---- Hyper RAM state Machine ----
	reg [1:0] spi_state;

	// --- states ---
	localparam SPI_IDLE           = 2'b00;
	localparam SPI_DMA_FETCH      = 2'b01;
	localparam SPI_DMA_FETCH_WAIT = 2'b10;
	localparam SPI_XMIT           = 2'b11;



	always @(posedge clk) begin
		send_divcnt <= send_divcnt + 1;
		if (!resetn) begin
			send_bitcnt <= 0;
			send_divcnt <= 0;
			spi_state <= SPI_IDLE;
			send_clk <= 0;	
            spi_dma_addr <= 0;
            spi_dma_count <= 0;

		end else begin
			case (spi_state)
			  SPI_IDLE: begin
                /* When IDLE accept writes to registers */
                if(reg_dat_we) begin
                    send_pattern <= {reg_dat_di[7:0],24'h0};
				    send_bitcnt <= 16;
				    send_divcnt <= 0;
                    spi_state <= SPI_XMIT;
                end

                if(|reg_count_we) begin
                    spi_dma_count <= reg_count_i[17:2]; /* Perform a /4 in hw*/
                    spi_state <= SPI_DMA_FETCH;
                end

                if(|reg_addr_we) begin
                    spi_dma_addr <= {10'b0, reg_addr_i[23:2]}; /* Perform a /4 in hw*/
                end

			  end
			  SPI_DMA_FETCH: begin
                if(!dma_busy_i) begin
                    /* Fetch new byte from RAM */
                    dma_rd_o <= 1;
                    dma_addr_o <= spi_dma_addr;
                    
                    spi_dma_addr <= spi_dma_addr + 1; /* DWORD addresses */
                    spi_state <= SPI_DMA_FETCH_WAIT;
                end

			  end
			  SPI_DMA_FETCH_WAIT: begin
                /* rd high for one cycle */
                dma_rd_o <= 0;

                /* When RAM module is ready it will output a DWORD to us. */
                if( dma_rdata_rdy_i ) begin
                    spi_dma_count <= spi_dma_count - 1;
                    /* Endian conversion */
                    //send_pattern <= dma_rdata_i;
                    send_pattern <= {dma_rdata_i[7:0],dma_rdata_i[15:8],dma_rdata_i[23:16],dma_rdata_i[31:24]};
                    
                    send_bitcnt <= 64;
                    send_divcnt <= 0;
                    spi_state <= SPI_XMIT;
                end
			  end
			  SPI_XMIT: begin
                /* Exit condition, Either get more data or return to IDLE */
                if(send_bitcnt == 0) begin
					spi_state <= spi_dma_count ? SPI_DMA_FETCH : SPI_IDLE; 
				end 

                /* Prescaler send_divcnt is incremented every clk  */
                else if (send_divcnt >= cfg_divider) begin
				    send_clk <= ~send_clk;

                    if(!send_clk) begin
                        recv_buf_data <= {recv_buf_data[6:0], spi_miso};
                    end else begin
                        send_pattern <= {send_pattern[30:0], 1'b0};
                    end

                    send_bitcnt <= send_bitcnt - 1;
                    send_divcnt <= 0;
			    end

			  end 
			  default: 
			  	spi_state <= SPI_IDLE;
			endcase

		end
	end

	
endmodule
