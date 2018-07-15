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

module hx8kdemo (
	input clk_in,

	output ser_tx,
	input ser_rx,


	output io_a_dir,
	output io_b_dir,

	output led,

	output flash_csb,
	output flash_clk,
	inout  flash_io0,
	inout  flash_io1,
	inout  flash_io2,
	inout  flash_io3,
	 
	output sd_spi_ck,
	output sd_spi_mosi,
	input sd_spi_miso,
	output sd_spi_cs,
	input sd_cd,



	/* HYPER RAM SIGNALS */
	inout [1:0] HRAM_CK,
	inout HRAM_CS,
	inout HRAM_RWDS, 
	inout [7:0] HRAM_DQ,
	output HRAM_RESET,



	input [15:0] CAM_CMOS_D,
	input  CAM_CMOS_CLK,
	input  CAM_CMOS_VALID,
	output BOSON_RESET,
	input CAM_CMOS_VSYNC,
	input CAM_CMOS_HSYNC

//	inout HRAM_DBG
);
	
	wire clk;
	wire clk_90;
    wire BYPASS;
    wire RESETB;
	wire LOCK;

    SB_PLL40_2F_CORE #(
        .FEEDBACK_PATH("PHASE_AND_DELAY"),
        .DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
        .DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
        .PLLOUT_SELECT_PORTA("SHIFTREG_0deg"),
		.PLLOUT_SELECT_PORTB("SHIFTREG_90deg"),
        .SHIFTREG_DIV_MODE(1'b0),
        .FDA_FEEDBACK(4'b0000),
        .FDA_RELATIVE(4'b0000),
        .DIVR(4'b0010),
        .DIVF(7'b0000010), // frecuency multiplier = 2+1 = 3
        .DIVQ(3'b010),
        .FILTER_RANGE(3'b001)
    ) uut (
        .REFERENCECLK   (clk_in),
        .PLLOUTGLOBALA   (clk), // output frequency = 3 * input frequency
        .PLLOUTGLOBALB   (clk_90), // output frequency = 3 * input frequency
        .BYPASS         (BYPASS),
        .RESETB         (RESETB),
        .LOCK (LOCK )
    );

    //assign LED = clk_new;
    assign BYPASS = 0;
	assign RESETB = 1;

	reg [7:0] reset_cnt = 0;
	wire resetn = &reset_cnt;

	always @(posedge clk) begin
		if(LOCK)
			reset_cnt <= reset_cnt + !resetn;
	end

	assign BOSON_RESET = resetn;

	// ---	FLASH IO  --- //
	wire flash_io0_oe, flash_io0_do, flash_io0_di;
	wire flash_io1_oe, flash_io1_do, flash_io1_di;
	wire flash_io2_oe, flash_io2_do, flash_io2_di;
	wire flash_io3_oe, flash_io3_do, flash_io3_di;

	SB_IO #(
		.PIN_TYPE(6'b 1010_01),
		.PULLUP(1'b 0)
	) flash_io_buf [3:0] (
		.PACKAGE_PIN({flash_io3, flash_io2, flash_io1, flash_io0}),
		.OUTPUT_ENABLE({flash_io3_oe, flash_io2_oe, flash_io1_oe, flash_io0_oe}),
		.D_OUT_0({flash_io3_do, flash_io2_do, flash_io1_do, flash_io0_do}),
		.D_IN_0({flash_io3_di, flash_io2_di, flash_io1_di, flash_io0_di})
	);

	wire        iomem_valid;
	reg         iomem_ready;
	wire [3:0]  iomem_wstrb;
	wire [31:0] iomem_addr;
	wire [31:0] iomem_wdata;
	reg  [31:0] iomem_rdata;

	reg [31:0] hyperram_ctrl_addr;
	reg hyperram_ctrl;

	reg [31:0] gpio;

	assign led = gpio[0];
	assign sd_spi_cs = gpio[2];

	assign io_a_dir = 1'b1;
	assign io_b_dir = 1'b0;


	wire boson_capture_active;
	reg boson_capture_start;

	always @(posedge clk) begin
		if (!resetn) begin
			gpio <= 0;
			boson_capture_start <= 0;
			
			hyperram_ctrl <= 0;
			hyperram_ctrl_addr <= 0;

			latency_1x <= 8'h12;
			latency_2x <= 8'h16;

			rd_jk <= 0;
		end else begin
			iomem_ready <= 0;
			if(iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 03) begin
				/* GPIO outputs  [0x0300 0000]*/
				if (iomem_addr[7:0] == 8'h 00) begin
					iomem_ready <= 1;
					iomem_rdata <= {gpio[31:0]};
					if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
					if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
					if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
					if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
				end
				/* GPIO inputs [0x0300 0004] */
				if (iomem_addr[7:0] == 8'h 04) begin
					iomem_ready <= 1;
					iomem_rdata <= {30'b0, sd_spi_miso, sd_cd};
				end
				/* boson_parallel_capture  [0x0300 0008] */
				if(iomem_addr[7:0] == 8'h 08) begin
					iomem_ready <= 1;
					iomem_rdata <= {31'b0, boson_capture_active};
					
					if (iomem_wstrb[0] && iomem_wdata[0]) begin
						boson_capture_start <= 1'b1;
						iomem_ready <= 0;
					end else begin
						iomem_ready <= 1;
					end

					if(boson_capture_start) begin
						boson_capture_start <= 0;
						iomem_ready <= 1;
					end
				end
				/* hyperram_ctrl_a [0x0300 0010] */
				if(iomem_addr[7:0] == 8'h 10) begin
					iomem_ready <= 1;
					iomem_rdata <= {16'b0,latency_2x,latency_1x};
					
					if (iomem_wstrb[0]) latency_1x <= iomem_wdata[ 7: 0];
					if (iomem_wstrb[1]) latency_2x <= iomem_wdata[15: 8];
				end
				/* hyperram_ctrl_b [0x0300 0014] */
				if(iomem_addr[7:0] == 8'h 14) begin
					/* Write */
					if (|iomem_wstrb) begin
						if(!busy) begin
							hyperram_ctrl <= 1;
							hyperram_ctrl_addr <= 32'h0000_0800;
							wr_req <= 1;	
						end

						if(wr_req) begin
							wr_req <= 0;
							iomem_ready <= 1;	/* No need to wait for writes */
							hyperram_ctrl <= 0;
						end
					end else begin
						
						if(!busy) begin
							hyperram_ctrl <= 1;
							hyperram_ctrl_addr <= 32'h0000_0800;
							rd_jk <= 1;
						end

						if(rd_rdy) begin
							iomem_ready <= 1;
							rd_jk <= 0;
							hyperram_ctrl <= 0;
						end
						iomem_rdata <= rd_d;
					end	
				end
			end
			/* HyperRAM mem-map  [0x0400 0000+] */
			if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 04 ) begin
				if (|iomem_wstrb) begin
					if(!busy) begin
						wr_req <= 1;	
					end

					if(wr_req) begin
						wr_req <= 0;
						iomem_ready <= 1;	/* No need to wait for writes */
					end
				end else begin
					rd_jk <= !busy;
					if(rd_rdy) begin
						iomem_ready <= 1;
						rd_jk <= 0;
					end
					iomem_rdata <= rd_d;
				end
			end
			
		end
	end


	/* Patch in SPI module */
	wire [31:0] mem_rdata = simplespi_reg_conf_sel ? 	simplespi_conf_o :
					 simplespi_reg_dat_sel  ? 	simplespi_data_o :
					 							iomem_rdata;

	wire mem_ready = spi_en ? 1'b1 :
							  iomem_ready;
	

	wire spi_dma_en_o;
	wire spi_dma_rd_o;
	wire [31:0] spi_dma_addr_o;
	wire [31:0] spi_dma_rdata_i = rd_d;
	wire spi_dma_rdata_rdy_i = rd_rdy;



	picosoc soc (
		.clk          (clk         ),
		.resetn       (resetn      ),

		.ser_tx       (ser_tx      ),
		.ser_rx       (ser_rx      ),

		//.spi_ck	      (sd_spi_ck   ),
		//.spi_mosi     (sd_spi_mosi ),
		//.spi_miso     (sd_spi_miso ),
		
		.flash_csb    (flash_csb   ),
		.flash_clk    (flash_clk   ),

		.flash_io0_oe (flash_io0_oe),
		.flash_io1_oe (flash_io1_oe),
		.flash_io2_oe (flash_io2_oe),
		.flash_io3_oe (flash_io3_oe),

		.flash_io0_do (flash_io0_do),
		.flash_io1_do (flash_io1_do),
		.flash_io2_do (flash_io2_do),
		.flash_io3_do (flash_io3_do),

		.flash_io0_di (flash_io0_di),
		.flash_io1_di (flash_io1_di),
		.flash_io2_di (flash_io2_di),
		.flash_io3_di (flash_io3_di),

		.irq_5        (1'b0        ),
		.irq_6        (1'b0        ),
		.irq_7        (1'b0        ),

		.iomem_valid  (iomem_valid ),
		.iomem_ready  (mem_ready ),
		.iomem_wstrb  (iomem_wstrb ),
		.iomem_addr   (iomem_addr  ),
		.iomem_wdata  (iomem_wdata ),
		.iomem_rdata  (mem_rdata )
	);


	wire        simplespi_reg_div_sel =   iomem_valid && (iomem_addr == 32'h 0300_0020);
	wire        simplespi_reg_conf_sel =  iomem_valid && (iomem_addr == 32'h 0300_0024);
	wire        simplespi_reg_dat_sel =   iomem_valid && (iomem_addr == 32'h 0300_0028);
	wire        simplespi_reg_count_sel = iomem_valid && (iomem_addr == 32'h 0300_002C);
	wire        simplespi_reg_addr_sel =  iomem_valid && (iomem_addr == 32'h 0300_0030);

	wire [31:0] simplespi_conf_o;
	wire [31:0] simplespi_data_o;


	wire spi_en = simplespi_reg_div_sel | simplespi_reg_conf_sel | simplespi_reg_dat_sel | simplespi_reg_count_sel | simplespi_reg_addr_sel;



	simplespi simplespi (
		.clk         (clk         ),
		.resetn      (resetn      ),

		.spi_clk     (sd_spi_ck      ),
		.spi_mosi    (sd_spi_mosi    ),
		.spi_miso    (sd_spi_miso    ),

		.reg_div_we  (simplespi_reg_div_sel ? iomem_wstrb : 4'b 0000),
		.reg_div_di  (iomem_wdata),

		.reg_conf_we  (simplespi_reg_conf_sel ? iomem_wstrb : 4'b 0000),
		.reg_conf_di  (iomem_wdata),
		.reg_conf_do  (simplespi_conf_o),

		.reg_dat_we  (simplespi_reg_dat_sel ? iomem_wstrb : 4'b 0000),
		.reg_dat_di  (iomem_wdata),
		.reg_dat_do  (simplespi_data_o),

		.reg_count_we    (simplespi_reg_count_sel ? iomem_wstrb : 4'b 0000),
		.reg_count_i     (iomem_wdata),

		.reg_addr_we     (simplespi_reg_addr_sel ? iomem_wstrb : 4'b 0000),
		.reg_addr_i      (iomem_wdata),

		.dma_en_o        (spi_dma_en_o),
		.dma_addr_o      (spi_dma_addr_o),
		.dma_rd_o        (spi_dma_rd_o),
		.dma_rdata_rdy_i (spi_dma_rdata_rdy_i),
		.dma_rdata_i     (spi_dma_rdata_i),
		.dma_busy_i		 (busy)
	);

	reg rd_jk;
	reg rd_latch;
	reg wr_jk;
	reg wr_latch;
	

	reg          rd_req;
	reg          wr_req;
	reg  [3:0]   wr_byte_en;
	wire  [31:0]  addr;
	reg  [31:0]  wr_d;
	reg  [31:0]  rd_buffer;
	reg  [5:0]   rd_num_dwords;
	wire [31:0]  rd_d;
	wire         rd_rdy;
	wire         busy;
	reg  [7:0]   latency_1x;
	reg  [7:0]   latency_2x;

	wire [7:0] dram_dq_in;
	wire [7:0] dram_dq_out;
	wire dram_dq_oe_l  ;
	wire dram_rwds_in  ;
	wire dram_rwds_out ;
	wire dram_rwds_oe_l;
	wire dram_ck       ;
	wire dram_rst_l    ;
	wire dram_cs_l     ;
	wire burst_wr_rdy;

	wire wr_req_;
	wire [31:0] wr_d_;


	assign addr =         
	        (boson_capture_active) 	? write_address : 
			spi_dma_en_o 			? spi_dma_addr_o :
			hyperram_ctrl 			? hyperram_ctrl_addr :
	        iomem_valid 			? {10'b0, iomem_addr[23:2]} : 
									  32'b0;

	wire rd_req_ = 
			spi_dma_en_o 			? spi_dma_rd_o : 
									  rd_req;

	assign wr_req_ = (boson_capture_active) ? wr_req_boson : wr_req;

	assign wr_d_ =  (boson_capture_active) ? wr_d : iomem_wdata;

	always @(posedge clk) begin
		if (!resetn) begin
			wr_byte_en <= 4'hF;
			rd_latch <= 0;	
		end

		if(rd_jk && !rd_latch) begin
			rd_latch <= 1;
			rd_req <= 1;
		end else 
			rd_req <= 0;

		if(!rd_jk)
			rd_latch <= 0;
	end



	
    wire [15:0] boson_d;
    wire boson_rdy;
    reg boson_req;
    wire boson_error;

    reg [31:0] write_address;
    reg [9:0] state;
	reg wr_req_boson;

    /* Patch in Camera connections */
    parallel_capture pc (   
    .resetn(resetn),
    .boson_frame_req(boson_capture_start),
	.boson_capture_active(boson_capture_active),

    .clk(clk),

    
    .output_d      ( boson_d     ),
    .output_rdy    ( boson_rdy   ),
    .output_next   ( boson_req   ),
    .output_error  ( boson_error ),

	.CAM_CMOS_D    (CAM_CMOS_D),
	.CAM_CMOS_CLK  (CAM_CMOS_CLK),
	.CAM_CMOS_VALID(CAM_CMOS_VALID),
	.CAM_CMOS_VSYNC(CAM_CMOS_VSYNC),
	.CAM_CMOS_HSYNC(CAM_CMOS_HSYNC)
    );
	
    reg [5:0] word_count;
    always @(posedge clk) begin
		if(!resetn) begin
			write_address <= 0;
			
			wr_d <= 0;
			state <= 0;
			wr_req_boson <= 0;
			word_count <= 0;
			
		end else begin
		
			boson_req <= 0;
			wr_req_boson <= 0;

			if(!boson_capture_active) begin
				write_address <= 0;
				state <= 0;
				word_count <= 0;
			end

			/* Pull data out off the FIFO into RAM */
			if(boson_capture_active && boson_rdy) begin
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

		end
	end


	hyper_xface u_hyper_xface
	(
		.reset             ( !resetn            ),
		.clk               ( clk                ),
		.rd_req            ( rd_req_             ),
		.wr_req            ( wr_req_             ),
		.mem_or_reg        ( hyperram_ctrl       ),
		.wr_byte_en        ( wr_byte_en         ),
		.addr              ( addr[31:0]         ),
		.rd_num_dwords     ( 6'b000001          ),
		.wr_d              ( wr_d_[31:0]         ),
		.rd_d              ( rd_d[31:0]         ),
		.rd_rdy            ( rd_rdy             ),
		.burst_wr_rdy	   ( burst_wr_rdy       ),
		.busy              ( busy               ),
		.latency_1x        ( latency_1x         ),
		.latency_2x        ( latency_2x         ),
		.dram_dq_in        ( dram_dq_in[7:0]    ),
		.dram_dq_out       ( dram_dq_out[7:0]   ),
		.dram_dq_oe_l      ( dram_dq_oe_l       ),
		.dram_rwds_in      ( dram_rwds_in       ),
		.dram_rwds_out     ( dram_rwds_out      ),
		.dram_rwds_oe_l    ( dram_rwds_oe_l     ),
		.dram_ck           ( dram_ck            ),
		.dram_rst_l        ( dram_rst_l         ),
		.dram_cs_l         ( dram_cs_l          )
	);

	


	SB_IO #( 
		.PIN_TYPE(6'b0110_01), 
		.PULLUP(1'b0)
	) hyperram_cs (
		.PACKAGE_PIN(HRAM_CS),
		.D_OUT_0(dram_cs_l)
	);

	SB_IO #( 
		.PIN_TYPE(6'b0110_01), 
		.PULLUP(1'b0)
	) hyperram_reset (
		.PACKAGE_PIN(HRAM_RESET),
		.D_OUT_0(1'b1)
	);


	SB_IO #( 
		.PIN_TYPE(6'b1010_01), 
		.PULLUP(1'b0)
	) hyperram_rwds (
		.PACKAGE_PIN(HRAM_RWDS),
		.OUTPUT_ENABLE(!dram_rwds_oe_l),
		.D_OUT_0(dram_rwds_out),
		.D_IN_0(dram_rwds_in)
	);

	SB_IO #( 
		.PIN_TYPE(6'b0110_01), 
		.PULLUP(1'b0)
	) hyperram_ck [1:0] (
		.PACKAGE_PIN(HRAM_CK),
		.D_OUT_0({!dram_ck, dram_ck})
	);


	SB_IO #( 
		.PIN_TYPE(6'b1010_01), 
		.PULLUP(1'b0)
	) hyperram_dq [7:0] (
		.PACKAGE_PIN(HRAM_DQ),
		.OUTPUT_ENABLE(!dram_dq_oe_l),
		.D_OUT_0(dram_dq_out),
		.D_IN_0(dram_dq_in)
	);




/*

	reg hyper_ram_ren;
	reg hyper_ram_wren;
	reg [15:0] hyper_ram_wr_data;
	


	wire hram_ren;
	wire hram_wen;	
	wire [15:0] hram_data;
	wire [15:0] hram_data_out;

	assign hram_ren = (iomem_addr[31:24] == 8'h 04 && iomem_valid && !(|iomem_wstrb));
	assign hram_wen = hyper_ram_wren;
	assign hram_data = hyper_ram_wr_data;

	//reg  [11:0] hram_address;

	wire [11:0] hram_address;
	assign hram_address = (iomem_addr[31:24] == 8'h 04 && iomem_valid) ? iomem_addr[11:0] : 12'b0;


	hyperram_ctrl hram (
		.clk(clk),
		.reset_(resetn),
		// SRAM core issue interface
		.sram_req(hram_wen),
		.sram_ready(hram_nxt),
		.sram_rd(hram_ren),
		.sram_addr(hram_address),
		.sram_wr_data(hram_data),

		// SRAM core read data interface
		.sram_rd_data_vld(hram_data_out_clk),
		.sram_rd_data(hram_data_out),
		
		// IO interface
		.hyperram_io_clk(hram_io_clk),
		.hyperram_clk(hram_clk),
		.hyperram_rwds_dir(hyperram_rwds_dir),
		.hyperram_dq_dir(hyperram_dq_dir),

		.hyperram_ce_to_pad_(hyperram_ce_to_pad_),
		.hyperram_rst_to_pad_(hyperram_rst_to_pad_),

		.hyperram_dq_to_pad_0(hyperram_dq_to_pad_0),
		.hyperram_dq_to_pad_1(hyperram_dq_to_pad_1),
		.hyperram_rwds_to_pad_0(hyperram_rwds_to_pad_0),
		.hyperram_rwds_to_pad_1(hyperram_rwds_to_pad_1),

		.hyperram_dq_from_pad_0(hyperram_dq_from_pad_0),
		.hyperram_dq_from_pad_1(hyperram_dq_from_pad_1)
	//	.hyperram_rwds_from_pad_0(),
	//	.hyperram_rwds_from_pad_()
	
		);

	wire [7:0] hyperram_dq_to_pad_0,hyperram_dq_to_pad_1;
	wire [7:0] hyperram_dq_from_pad_0,hyperram_dq_from_pad_1;

	wire hyperram_rwds_dir,hyperram_dq_dir;



    hyperram_io_ice40 hram_io (
	.io_clk(hram_io_clk),
	
	.clk(hram_clk),
	
	.hyperram_dq_dir(hyperram_dq_dir),
	.hyperram_rwds_dir(hyperram_rwds_dir),

	.hyperram_ce_to_pad_(hyperram_ce_to_pad_),
	.hyperram_rst_to_pad_(hyperram_rst_to_pad_),
	.hyperram_dq_to_pad_0(hyperram_dq_to_pad_0),
	.hyperram_dq_to_pad_1(hyperram_dq_to_pad_1),
	.hyperram_rwds_to_pad_0(hyperram_rwds_to_pad_0),
	.hyperram_rwds_to_pad_1(hyperram_rwds_to_pad_1),
	.hyperram_dq_from_pad_0(hyperram_dq_from_pad_0),
	.hyperram_dq_from_pad_1(hyperram_dq_from_pad_1),
	.hyperram_rwds_from_pad_0(hyperram_rwds_from_pad_0),
	.hyperram_rwds_from_pad_1(hyperram_rwds_from_pad_1),


	.HRAM_CS(HRAM_CS),
	.HRAM_RWDS(HRAM_RWDS),
	.HRAM_CK(HRAM_CK),
	.HRAM_DQ(HRAM_DQ)
	);
*/
endmodule
