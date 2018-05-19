

module parallel_capture (
    input resetn,
    input clk,

    output [31:0] output_d,
    output output_rdy,
    input output_next,
    output output_error,
    

    /* RAM connections */
    input busy,
    input boson_frame_req,
    output boson_capture_active,
    


    /* I/O connections */
	input [15:0] CAM_CMOS_D,
	input  CAM_CMOS_CLK,
	input  CAM_CMOS_VALID,
	output BOSON_RESET,
	input CAM_CMOS_VSYNC,
	input CAM_CMOS_HSYNC
);

	/* Bason Data input */
	wire fifo_full;
	wire boson_clk;
	wire [15:0] boson_data;
	wire boson_valid;
	wire  boson_vsync,boson_hsync;

	wire fifo_empty;
    wire fifo_enq;

    assign boson_vsync = CAM_CMOS_VSYNC;
	assign boson_hsync = CAM_CMOS_HSYNC;
	assign boson_clk = CAM_CMOS_CLK;
	assign boson_data = CAM_CMOS_D;
	assign boson_valid = CAM_CMOS_VALID;

    assign output_rdy = !fifo_empty;
    assign fifo_enq = boson_valid && capture_active;

    assign boson_capture_active = dd_capture_active | frame_pending | output_rdy;

	reg frame_pending;
	reg capture_active = 0;
    reg [18:0] clk_cnt;


    reg d_frame_req,dd_frame_req;
    reg d_capture_active, dd_capture_active;

    /* Latch Frame Request */
    always @(posedge clk) begin
        if(boson_frame_req)
            frame_pending <= 1;

        if(dd_capture_active)
            frame_pending <= 0;
    end

    /* Capture_req: clk->boson_clk */
    always @(posedge boson_clk) begin
        d_frame_req <= frame_pending;
        dd_frame_req <= d_frame_req;
    end

    /* Capture_active: boson_clk->clk */
    always @(posedge clk) begin
        d_capture_active <= capture_active;
        dd_capture_active <= d_capture_active;
    end

    
    reg boson_fifo_clk_i;
    reg [15:0] boson_data_ff;

	always @(posedge boson_clk) begin
		if(!resetn) begin
            capture_active <= 0;
            clk_cnt <= 0;
            boson_fifo_clk_i <= 0;
		end 
        
        else begin
            /* If requested start a new capture on Vsync signal */
            if(boson_vsync == 1'b0 && dd_frame_req && !capture_active) begin
                capture_active <= 1;
                clk_cnt <= 0;
            end
            
            /* Stop Capture on next Vsync edge */
			//if(boson_vsync == 1'b0 && capture_active)
            //    capture_active <= 0;

            /* Stop capture after Image in recorded. */
            clk_cnt <= clk_cnt + capture_active;
            if(clk_cnt >= (1711 * 263)) begin
                capture_active <= 0;
                clk_cnt <= 0;
            end
            
            if(!boson_valid)
            boson_fifo_clk_i <= 0;
            else begin

                boson_fifo_clk_i <= ~boson_fifo_clk_i;
            end
                if(!boson_fifo_clk_i)
                    boson_data_ff <= boson_data;

		end
	end

    BramFifo  #( 
        .ADDR_LEN(9),
        .DATA_WIDTH(32)
    ) boson_fifo (
        .CLK0(clk),
        .RST0(!resetn),
        .Q(output_d), 
        .DEQ(output_next), 
        .EMPTY(fifo_empty),
        .CLK1(boson_fifo_clk_i), 
        .RST1(!resetn), 
        .D({boson_data_ff,boson_data}), 
        .ENQ(fifo_enq),  
        .FULL(fifo_full)
	 );

    endmodule