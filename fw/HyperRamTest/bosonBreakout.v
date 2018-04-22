`timescale 1 ns / 1 ps

module bosonBreakoutTest(
	/* BOSON SIGNALS */


	/* LEDS */
	output LED_A,
	output LED_B,
	output LED_C,

	/* HYPER RAM SIGNALS */
	inout [1:0] HRAM_CK,
	inout HRAM_CS,
	inout HRAM_RWDS, 
	inout [7:0] HRAM_DQ

);

	wire led_a,led_b,led_c;

	SB_IO_OD #(
		.PIN_TYPE(6'b011000)
	) OpenDrainInst0 (
		.PACKAGEPIN (LED_A), 
		.DOUT0 (led_a) 
	);

	SB_IO_OD #(
		.PIN_TYPE(6'b011000)
	) OpenDrainInst1 (
		.PACKAGEPIN (LED_B),
		.DOUT0 (led_b) 
	);

	SB_IO_OD #(
		.PIN_TYPE(6'b011000)
	) OpenDrainInst2 (
		.PACKAGEPIN (LED_C), 
		.DOUT0 (led_c) 
	);



	SB_HFOSC #(
		.CLKHF_DIV("0b00")
	) hfosc (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(clkhf)
	); 


//	assign led_a = clkhf;
//	assign led_b = 1'b0;
//	assign led_c = ~clkhf;

hyperram_ctrl hram (
	.clk(clkhf),
	.reset_(resetn),
	// SRAM core issue interface
	.sram_req(hram_wen),
	.sram_ready(),
	.sram_rd(hram_ren),
	.sram_addr(hram_address),
	.sram_wr_data(hram_data),

	// SRAM core read data interface
	.sram_rd_data_vld(hram_data_out_clk),
	.sram_rd_data(hram_data_out),
	
	// 
	.hyperram_io_clk(hram_io_clk),
	.hyperram_clk(hram_clk),
	.hyperram_rwds_dir(hyperram_rwds_dir),
	.hyperram_dq_dir(hyperram_dq_dir),

	.hyperram_ce_to_pad_(hyperram_ce_to_pad_),
	.hyperram_rst_to_pad_(hyperram_rst_to_pad_),

	.hyperram_dq_to_pad_0(hyperram_dq_to_pad_0),
	.hyperram_dq_to_pad_1(hyperram_dq_to_pad_1),
	.hyperram_rwds_to_pad_0(hyperram_rwds_to_pad_0),
	.hyperram_rwds_to_pad_1(hyperram_rwds_to_pad_1)
/*
	.hyperram_dq_from_pad_0(),
	.hyperram_dq_from_pad_1(),
	.hyperram_rwds_from_pad_0(),
	.hyperram_rwds_from_pad_()
*/
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

	
	reg hram_ren = 0;	
	reg hram_wen = 0;	
	reg [15:0] hram_data = 0;
	reg [11:0] hram_address = 0;
	reg [10:0] pc = 0;



	always @(posedge clkhf) begin
		
		if(resetn) begin //{hram_ck,hram_cs, hram_rwds_dir, hram_rwds_dout, hram_dq_dir, hram_dq_dout} <= libretto[pc];
			pc <= pc + 1;

			if(pc == 10) begin
				hram_data <= 16'hAA55;
				hram_wen <= 1; /* Start transaction */
			end
			if(pc == 20) begin
				hram_wen <= 0; 
			
			end

			if(pc == 200) begin
				hram_ren <= 1; /* Start transaction */
			end
			
			if(pc == 210) begin
				hram_ren <= 0; 
			
			end

			if(pc == 400)
				pc <= 0;
		end
	end


	reg [7:0] counter = 0;
	reg resetn = 0;

	initial begin
		resetn <= 0;
		counter <= 0;
	end

	always @(posedge clkhf) begin
		if(!resetn) begin
			counter <= counter + 1;

		if(counter == 8'b1111_1111)
			resetn <= 1;
		
			end
	end


endmodule
