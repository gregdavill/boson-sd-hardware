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

module clockPhaseGenerator (
	input clk_in,
	output reg clk_out_0, clk_out_90
);
	//reg clk_out_0 = 0,clk_out_90 = 0;
    reg [1:0] phase = 0;

    always @(posedge clk_in) begin
		case(phase)
			0: begin
				clk_out_0 <= 1;
				clk_out_90 <= 0;
				phase <= 2'b01;
			end
			1: begin
				clk_out_0 <= 1;
				clk_out_90 <= 1;
				phase <= 2'b10;
			end
			2: begin
				clk_out_0 <= 0;
				clk_out_90 <= 1;
				phase <= 2'b11;
			end
			default: begin
				clk_out_0 <= 0;
				clk_out_90 <= 0;
				phase <= 2'b00;
			end
		endcase
	end
endmodule


module hyperram_ctrl (
	input		      clk,
	input 		      reset_,

	// SRAM core issue interface
	input 		      sram_req,
	output reg		  sram_ready,
	input 		      sram_rd,
	input [11:0]      sram_addr,
	input [15:0]      sram_wr_data,

	// SRAM core read data interface
	output reg 	      sram_rd_data_vld,
	output reg [15:0] sram_rd_data,
	
	// 
	output            hyperram_io_clk,
	output            hyperram_clk,
	output reg        hyperram_rwds_dir,
	output reg        hyperram_dq_dir,

	output reg		  hyperram_ce_to_pad_,
	output reg		  hyperram_rst_to_pad_,

	output reg [7:0]  hyperram_dq_to_pad_0,
	output reg [7:0]  hyperram_dq_to_pad_1,
	output reg 		  hyperram_rwds_to_pad_0,
	output reg 		  hyperram_rwds_to_pad_1,

	input [7:0]       hyperram_dq_from_pad_0,
	input [7:0]       hyperram_dq_from_pad_1,
	input             hyperram_rwds_from_pad_0,
	input             hyperram_rwds_from_pad_1
	);

	// --- Change data at 0 degrees, Change clock at 90 degrees ---
	assign hyperram_io_clk = hyperram_clk_0;
	assign hyperram_clk = hram_clk_hold ? 1'b0 : hyperram_clk_90;

	// ---- Clock Generator ----
	// TODO: This should be replaced eventually with the PLL module. 
	//    Which can generate the 90 degree phase shift clk.
	wire hyperram_clk_0;
	wire hyperram_clk_90;
	clockPhaseGenerator cpg(
		.clk_in(clk),
		.clk_out_0(hyperram_clk_0),
		.clk_out_90(hyperram_clk_90)
	);

	// ---- Hyper RAM state Machine ----
	reg [3:0] hyperram_state;

	// --- states ---
	localparam hr_state_idle        = 4'b0_0_00;
	localparam hr_state_read        = 4'b0_1_00;
	localparam hr_state_read_wait   = 4'b0_1_01;
	localparam hr_state_read_xfer   = 4'b0_1_10;
	localparam hr_state_read_fin    = 4'b0_1_11;
	localparam hr_state_write       = 4'b1_0_00;
	localparam hr_state_write_wait  = 4'b1_0_01;
	localparam hr_state_write_xfer  = 4'b1_0_10;
	localparam hr_state_write_fin   = 4'b1_0_11;

	reg [4:0] hyperram_counter;

	// --- HyperRam Command Address bit mapping ---
	wire [47:0] hyperram_CA;

	reg [32:0] hyperram_CA_addr;
    reg hyperram_CA_rw;
	reg hyperram_CA_as;
	reg hyperram_CA_bt;

	assign  hyperram_CA[47] = hyperram_CA_rw;
	assign  hyperram_CA[46] = hyperram_CA_as;
	assign  hyperram_CA[45] = hyperram_CA_bt;
	assign  hyperram_CA[44:35] = 0;
	assign {hyperram_CA[34:16],hyperram_CA[2:0]} = hyperram_CA_addr;
	assign {hyperram_CA[15:03]} = 0;

	reg read_word_en = 0;
	reg write_word_en = 0;
	reg hram_clk_hold = 0;	
	

	always @(posedge hyperram_clk_0) begin
		if(!reset_) begin
			hyperram_state <= hr_state_idle;
			
			hyperram_ce_to_pad_ <= 1;
			hyperram_rst_to_pad_ <= 0;

			hyperram_dq_to_pad_0 <= 0;
			hyperram_dq_to_pad_1 <= 0;
			hyperram_dq_dir <= 0;

			hyperram_rwds_to_pad_0 <= 0;
			hyperram_rwds_to_pad_1 <= 0;
			hyperram_rwds_dir <= 0;

			hyperram_counter <= 0;
			
			hram_clk_hold <= 1;
		end
		else begin
			hyperram_rst_to_pad_ <= 1;

			case(hyperram_state)
				hr_state_idle: begin
					if(sram_rd) begin
						hyperram_ce_to_pad_ <= 1'b0; /* Enable CS */


						hyperram_state <= hr_state_read;
						hyperram_counter <= 0;

						/* Decode address into CA */
						hyperram_CA_rw <= 1; /* READ */
						hyperram_CA_as <= 0; /* Memory Space */
						hyperram_CA_bt <= 1; /* Burst: Linear */
						
						hyperram_CA_addr <= sram_addr; /* Set address */
					end else if(sram_req) begin
						hyperram_ce_to_pad_ <= 1'b0; /* Enable CS */


						hyperram_state <= hr_state_write;
						hyperram_counter <= 0;

						/* Decode address into CA */
						hyperram_CA_rw <= 0; /* READ */
						hyperram_CA_as <= 0; /* Memory Space */
						hyperram_CA_bt <= 1; /* Burst: Linear */
						
						hyperram_CA_addr <= sram_addr; /* Set address */
					end
				end

				/* --- Read Init --- */
				hr_state_read: begin
					case(hyperram_counter)
						/* Phase One Transfer CA */
						0: begin
							hram_clk_hold <= 0;
							hyperram_dq_dir <= 1;
							hyperram_dq_to_pad_0 <= hyperram_CA[47:40];
							hyperram_dq_to_pad_1 <= hyperram_CA[39:32];
							hyperram_counter <= 1;
						end
						1: begin
							hyperram_dq_to_pad_0 <= hyperram_CA[31:24];
							hyperram_dq_to_pad_1 <= hyperram_CA[23:16];
							hyperram_counter <= 2;
						end
						2: begin
							hyperram_dq_to_pad_0 <= hyperram_CA[15:8];
							hyperram_dq_to_pad_1 <= hyperram_CA[7:0];
							hyperram_counter <= 3;
						end

						default: begin
							//read_word_en <= 0;
							hyperram_dq_to_pad_0 <= 0;
							hyperram_dq_to_pad_1 <= 0;
							hyperram_dq_dir <= 0;
							hyperram_state <= hr_state_read_wait;
							hyperram_counter <= 10;
						end
					endcase
				end

				/* --- Read Wait --- */
				hr_state_read_wait: begin
					if(hyperram_counter != 0) begin
						hyperram_counter <= hyperram_counter - 1;
					end else begin
						hyperram_state <= hr_state_read_xfer;
					end
				end

				/* --- Read Transfer --- */
				hr_state_read_xfer:	begin
					if(!sram_rd || hyperram_counter >= 8) begin
						hyperram_state <= hr_state_read_fin;

						hram_clk_hold <= 1;
					end

					read_word_en <= 1;
					hyperram_counter <= hyperram_counter + 1;
				end

				/* --- Read Cleanup --- */
				hr_state_read_fin: begin
					hyperram_state <= hr_state_idle;
					hyperram_ce_to_pad_ <= 1'b1;	
				end
				

				/* --- Write Init --- */
				hr_state_write: begin
					case(hyperram_counter)
						/* Phase One Transfer CA */
						0: begin
							hram_clk_hold <= 0;
							hyperram_dq_dir <= 1;
							hyperram_dq_to_pad_0 <= hyperram_CA[47:40];
							hyperram_dq_to_pad_1 <= hyperram_CA[39:32];
							hyperram_counter <= 1;
						end
						1: begin
							hyperram_dq_to_pad_0 <= hyperram_CA[31:24];
							hyperram_dq_to_pad_1 <= hyperram_CA[23:16];
							hyperram_counter <= 2;
						end
						2: begin
							hyperram_dq_to_pad_0 <= hyperram_CA[15:8];
							hyperram_dq_to_pad_1 <= hyperram_CA[7:0];
							hyperram_counter <= 3;
						end

						default: begin
							hyperram_dq_to_pad_0 <= 0;
							hyperram_dq_to_pad_1 <= 0;

							hyperram_rwds_dir <= 1;
							hyperram_rwds_to_pad_0 <= 0;
							hyperram_rwds_to_pad_1 <= 0;

							
							hyperram_counter <= 9;
							hyperram_state <= hr_state_write_wait;
						end
					endcase
				end

				/* --- Write Wait --- */
				hr_state_write_wait: begin
					if(hyperram_counter != 0) begin
						hyperram_counter <= hyperram_counter - 1;
					end else begin
						hyperram_state <= hr_state_write_xfer;
						hyperram_counter <= 30;		// --- max words to write.
					end
				end

				/* --- Write Transfer --- */
				hr_state_write_xfer:	begin
					hyperram_dq_to_pad_0 <= sram_wr_data[15:8];
					hyperram_dq_to_pad_1 <= sram_wr_data[7:0];

					
					if(!sram_req || hyperram_counter == 0) begin
						hyperram_state <= hr_state_write_fin;

						hram_clk_hold <= 1;
						hyperram_rwds_dir <= 0;
						hyperram_dq_to_pad_0 <= 0;
						hyperram_dq_to_pad_1 <= 0;
					end else
						write_word_en <= 1;

					hyperram_counter <= hyperram_counter - 1;
				end

				/* --- Write Cleanup --- */
				hr_state_write_fin: begin
					hyperram_state <= hr_state_idle;
					hyperram_ce_to_pad_ <= 1'b1;	
				end

			endcase
		end
	end


	// --- Clock out valid data back to system ---
	always @(posedge clk) begin
		sram_rd_data <= {hyperram_dq_from_pad_0, hyperram_dq_from_pad_1};
		
		if(read_word_en)
			sram_rd_data_vld <= 1;
		else
			sram_rd_data_vld <= 0;

		read_word_en <= 0;
	end


	// --- Clock in new data ---
	always @(posedge clk) begin
		if(write_word_en)
			sram_ready <= 1;
		else
			sram_ready <= 0;

		write_word_en <= 0;
	end

endmodule