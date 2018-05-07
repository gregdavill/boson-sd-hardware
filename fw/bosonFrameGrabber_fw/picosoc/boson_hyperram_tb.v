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

module testbench (
);

    reg frame_request = 1;
    reg resetn = 0;
    reg clk = 0;

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);

        #5
        resetn = 1;

		#100_000_000
		$finish;
	end

    always #10 clk <= !clk;
        

    wire [15:0] boson_DQ;
    wire boson_CLK;
    wire CAM_CMOS_VSYNC;
    wire boson_HSYNC;
    wire boson_VALID;

    bosonCamera cam (
        .reset(resetn),
        
	    .CMOS_DQ   (boson_DQ),
	    .CMOS_CLK  (boson_CLK),
	    .CMOS_VSYNC(CAM_CMOS_VSYNC),
	    .CMOS_HSYNC(boson_HSYNC),
	    .CMOS_VALID(boson_VALID) 
    );


    wire [15:0] boson_d;
    wire boson_rdy;
    reg boson_req;
    wire boson_error;

    /* Patch in Camera connections */
    parallel_capture pc (   
    .resetn(resetn),
    .boson_frame_req(frame_request),
    .clk(clk),

    
    .output_d      ( boson_d     ),
    .output_rdy    ( boson_rdy   ),
    .output_next   ( boson_req   ),
    .output_error  ( boson_error ),

	.CAM_CMOS_D    (boson_DQ),
	.CAM_CMOS_CLK  (boson_CLK),
	.CAM_CMOS_VALID(boson_VALID),
	.CAM_CMOS_VSYNC(CAM_CMOS_VSYNC),
	.CAM_CMOS_HSYNC(boson_HSYNC)
    );

    reg boson_active;
    reg [31:0] write_address = 0;
    reg write_jk = 0;
    reg busy = 0;
    reg [9:0] state = 0;
    reg [31:0] wr_d  = 0;
    reg wr_req_boson = 0;
    reg burst_wr_rdy = 0;

    always @(posedge clk) begin
		if(!resetn) begin
			write_jk <= 0;
			write_address <= 0;
			boson_active <= 0;
			wr_d <= 0;
			state <= 0;
			wr_req_boson <= 0;
		end else begin
			if(!write_jk && !CAM_CMOS_VSYNC) begin
				boson_active <= 1;
				write_jk <= 1;
			end

			boson_req <= 0;
			wr_req_boson <= 0;

			/* Pull data out off the FIFO into RAM */
			if(boson_active && boson_rdy) begin
				if(state == 0) begin
                    if(!busy) begin
					    wr_d[31:16] <= boson_d;
					    boson_req <= 1;
                        state <= 1;
                    end
				end
                /* 1 */
				/* 2 */
				else if(state == 3) begin
                    if(!busy) begin
					boson_req <= 1;
					wr_req_boson <= 1;
                    write_address <= write_address + 1;
					wr_d[15:0] <= boson_d;
					state <= 4;
                    end
				end 
				/* 4 */
				/* 5 */
				else if(state == 6) begin
                        wr_d[31:16] <= boson_d;
					    boson_req <= 1;
                        state <= 7;
				end
                /* 7 */
				/* 8 */
				else if(state == 9) begin
					if(busy) begin
                        if(burst_wr_rdy) begin
                            boson_req <= 1;
                            wr_req_boson <= 1;
                            write_address <= write_address + 1;
                            wr_d[15:0] <=  boson_d;
                            state <= 0;
                        end
                    end else begin
                        state <= 3;

                    end
				end 
				
				else if(state >= 10) begin
					state <= 0;
				end 
				
				else begin
					state <= state + 1;
                end

				/* 1 Frame */
				if(write_address >= (256*320)) begin
					boson_active <= 0;
				end
			end

		end
	end

    always @(posedge clk) begin
        if(boson_req) begin
            busy = 1;
            #400
            burst_wr_rdy = 1;
            #20
            burst_wr_rdy = 0;
            busy = 0;
        end
    end


endmodule
