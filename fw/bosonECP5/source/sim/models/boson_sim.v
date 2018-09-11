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
 
`timescale 1 ns/1 ns

module bosonCamera (
	input reset,
	
	output reg [15:0] CMOS_DQ,
	output reg CMOS_CLK,
	output reg CMOS_VSYNC,
	output reg CMOS_HSYNC,
	output reg CMOS_VALID
);

	reg [31:0] frame_counter = 0;
	reg [31:0] frame_clk = 16'h2860; /* skip to first image line for simulation */

	initial begin	
			CMOS_DQ = 16'b0;
			CMOS_CLK = 1'b0;
			CMOS_VSYNC = 1'b0;
			CMOS_HSYNC = 1'b0;
			CMOS_VALID = 1'b0;

	end

	/* Output clk at 13.5Mhz ~37ns period
	 * We expect this clock to be async to device clock. 
	 * So we can run it a little fast. */
	always begin
			#37 
			CMOS_CLK = ~CMOS_CLK;
	end

	reg [31:0] pixel_cnt = 0;


	always @(negedge CMOS_CLK) begin
		/* counter used to determine image features */
		frame_clk = frame_clk + 1;

		if((frame_clk / 1711) < 7) begin
			CMOS_VALID = 0;
			CMOS_VSYNC = 0;
		end	else begin 
			CMOS_VSYNC = 1;
			if((frame_clk % 1711) < 7)
				CMOS_HSYNC = 0; 
			else 
				CMOS_HSYNC = 1;

			if(((frame_clk % 1711) > 692) && ((frame_clk % 1711) < (692 + 320))) begin
				CMOS_VALID = 1; 
				//CMOS_DQ = pixel_cnt;
				if((pixel_cnt + 1) % 4 < 2)
				CMOS_DQ = 16'hFFFF;
				else
				CMOS_DQ = 16'h0000;
			end else begin
				CMOS_VALID = 0;
				CMOS_DQ = 16'b0;
			end

				pixel_cnt = pixel_cnt + 1;

				
		end

		if(frame_clk >= (1711 * 263)) begin
			pixel_cnt = 0;
			frame_clk = 0;
		end


	end
endmodule