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


	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
        clk = 0;
        clk90 = 0;
        resetn = 0;

        #2000
        resetn = 1;

		#100_000_000
		$finish;
	end

    
  reg [7:0]    dram_dq_in0;
  reg [7:0]    dram_dq_in1;
  wire [7:0]   dram_dq_out0;
  wire [7:0]   dram_dq_out1;
  wire         dram_dq_oe_l;
  reg          dram_rwds_in0;
  reg          dram_rwds_in1;
  wire         dram_rwds_out0;
  wire         dram_rwds_out1;
  wire         dram_rwds_oe_l;
  wire         dram_ck;
  wire         dram_rst_l;
  wire         dram_cs_l;
  wire [7:0]   sump_dbg;

  wire burst_wr_rdy;


  reg          rd_req = 0;
  wire          wr_req;
  reg          mem_or_reg = 0;
  reg  [3:0]   wr_byte_en = 4'hf;
  wire  [31:0]  addr;// = 32'hAAAAAAAA;
  reg  [31:0]  wr_d;
  reg  [31:0]  rd_buffer = 0;
  reg  [5:0]   rd_num_dwords = 1;
  wire [31:0]  rd_d;
  wire         rd_rdy;
  wire         busy;
  reg  [7:0]   latency_1x = 8'h09;
  reg  [7:0]   latency_2x = 8'h0B;

  reg resetn;

  reg clk_internal;
  reg clk;
  reg clk90;

always begin
  #10 clk <= 1;
  #10 clk90 <= 1;
  #10 clk <= 0;
  #10 clk90 <= 0;
end
        

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
    reg [31:0] write_address;
    reg write_jk;
  //  reg busy = 0;
    reg [9:0] state;
  //  reg [31:0] wr_d  = 0;
    reg wr_req_boson;
  //  reg burst_wr_rdy = 0;

  assign wr_req = wr_req_boson;
  assign addr = write_address;

    reg [5:0] word_count;

    always @(posedge clk) begin
		if(!resetn) begin
			write_jk <= 0;
			write_address <= 0;
			boson_active <= 0;
			wr_d <= 0;
			state <= 0;
			wr_req_boson <= 0;
            word_count <= 0;
		end else begin
			if(!write_jk && !CAM_CMOS_VSYNC) begin
				boson_active <= 1;
				write_jk <= 1;
			end

            	boson_req <= 0;
			wr_req_boson <= 0;
            
/* Pull data out off the FIFO into RAM */
			if(boson_active && boson_rdy) begin
				if(word_count < 9) begin

					if(state == 0) begin
						if(word_count == 0 && !busy || word_count > 0) begin
							wr_d[15:0] <= boson_d;
							boson_req <= 1;
							state <= 1;
						end
					end
					/* 1 */
					/* 2 */
					else if(state == 3) begin
						if(word_count == 0) begin
							if(!busy) begin
								boson_req <= 1;
								wr_req_boson <= 1;
								write_address <= write_address + 1;
								wr_d[31:16] <= boson_d;
								state <= 4;
							end
						end
						else if(busy) begin
							if(burst_wr_rdy) begin
								boson_req <= 1;
								wr_req_boson <= 1;
								write_address <= write_address + 1;
								wr_d[31:16] <=  boson_d;
								state <= 4;
							end
						end else begin
							state <= 3;
							word_count <= 0;
						end
					end
					/* 4 */
					else if(state >= 5) begin
							state <= 0;
							word_count <= word_count + 1;
					end
					else begin
						state <= state + 1;
					end
				end
				else begin
					word_count <= 0;
				end
			end

				/* 1 Frame */
				if(write_address >= (256*320)) begin
					boson_active <= 0;
				end
		

		end
	end





//-----------------------------------------------------------------------------
// Bridge LB To a HyperRAM
//-----------------------------------------------------------------------------
hyper_xface u_hyper_xface
(
  .reset             ( !resetn            ),
  .clk               ( clk                ),
  .clk90             ( clk90              ),
  .rd_req            ( rd_req             ),
  .wr_req            ( wr_req             ),
  .mem_or_reg        ( mem_or_reg         ),
  .wr_byte_en        ( wr_byte_en         ),
  .addr              ( addr[31:0]         ),
  .rd_num_dwords     ( rd_num_dwords[5:0] ),
  .wr_d              ( wr_d[31:0]         ),
  .rd_d              ( rd_d[31:0]         ),
  .rd_rdy            ( rd_rdy             ),
  .burst_wr_rdy      ( burst_wr_rdy       ),
  .busy              ( busy               ),
  .latency_1x        ( latency_1x[7:0]    ),
  .latency_2x        ( latency_2x[7:0]    ),
  .dram_dq_in0       ( dram_dq_in0[7:0]    ),
  .dram_dq_in1       ( dram_dq_in1[7:0]    ),
  .dram_dq_out0      ( dram_dq_out0[7:0]   ),
  .dram_dq_out1      ( dram_dq_out1[7:0]   ),
  .dram_dq_oe_l      ( dram_dq_oe_l       ),
  .dram_rwds_in0     ( dram_rwds_in0       ),
  .dram_rwds_in1     ( dram_rwds_in1       ),
  .dram_rwds_out0    ( dram_rwds_out0      ),
  .dram_rwds_out1    ( dram_rwds_out1      ),
  .dram_rwds_oe_l    ( dram_rwds_oe_l     ),
  .dram_ck           ( dram_ck            ),
  .dram_rst_l        ( dram_rst_l         ),
  .dram_cs_l         ( dram_cs_l          ),
  .sump_dbg          ( sump_dbg[7:0]      )
);// module hyper_xface


reg [7:0] hyperram_dq_int;
wire [7:0] hyperram_dq;

always @(posedge clk) hyperram_dq_int <= dram_dq_out0;
always @(negedge clk) hyperram_dq_int <= dram_dq_out1;


always @(posedge clk90) dram_dq_in1 <= hyperram_dq;
always @(negedge clk90) dram_dq_in0 <= hyperram_dq;


assign hyperram_dq = dram_dq_oe_l == 0 ? hyperram_dq_int : 8'bz;

wire hyperram_cs;
wire hyperram_ck;

reg  hyperram_rwds_int;
wire hyperram_rwds;

wire hyperram_reset;

assign hyperram_cs = dram_cs_l;
assign hyperram_ck = dram_ck;

always @(posedge clk) hyperram_rwds_int <= dram_rwds_out0;
always @(negedge clk) hyperram_rwds_int <= dram_rwds_out1;

always @(posedge clk90) dram_rwds_in0 <= hyperram_rwds;
always @(negedge clk90) dram_rwds_in1 <= hyperram_rwds;

assign hyperram_rwds = dram_rwds_oe_l == 0 ? hyperram_rwds_int : 1'bz;

assign hyperram_reset = resetn;




s27ks0641 hypersim
    (
    .DQ7      (hyperram_dq[7]),
    .DQ6      (hyperram_dq[6]),
    .DQ5      (hyperram_dq[5]),
    .DQ4      (hyperram_dq[4]),
    .DQ3      (hyperram_dq[3]),
    .DQ2      (hyperram_dq[2]),
    .DQ1      (hyperram_dq[1]),
    .DQ0      (hyperram_dq[0]),
    .RWDS     (hyperram_rwds ),

    .CSNeg    (hyperram_cs),
    .CK       (hyperram_ck),
    .CKNeg    (~hyperram_ck),
    .RESETNeg (hyperram_reset)
    );

    
endmodule
