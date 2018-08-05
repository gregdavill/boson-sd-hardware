

module cc_data_host(
		   input wire cmos_clk_i,
           input wire rst,
           //Camera data / Control signals
		   input wire [15:0] cmos_data_i, 
		   input wire cmos_vsync_i,
		   input wire cmos_hsync_i,
		   input wire cmos_valid_i,
		   output wire cmos_reset_o,
		   
		   output wire cmos_en_o,
		   
           //Control signals
		   input wire arm,
		   // data out
		   output reg [31:0] data_count_reg
       );


parameter SIZE = 6;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
parameter IDLE       = 6'b000001;
parameter ARM        = 6'b000010;
parameter PASS       = 6'b000100;


/* Vsync Detect will generate a 1 cycle pulse ever line */
reg [1:0] vsync_sr;
always @(posedge cmos_clk_i) 
	vsync_sr[1:0] <= {vsync_sr[0], cmos_hsync_i};
//	vsync_sr[1:0] <= {vsync_sr[0], cmos_vsync_i};

wire vsync_detect;
assign vsync_detect = (vsync_sr == 2'b10);

/* Mask data based on state machine */
assign cmos_en_o   = (state == PASS) ? cmos_valid_i : 1'b0;


reg [31:0] data_byte_counter;

assign cmos_reset_o = !rst;

	always @(posedge cmos_clk_i) begin
	  if(rst) begin
		data_byte_counter <= 0;
		state <= IDLE;
	  end else begin
		case (state)
			IDLE: begin
				if(arm == 1) begin
					state <= ARM;
				end
			end
			
			ARM: begin
				/* Frame begin */
				if(vsync_detect) begin
					state <= PASS;
				end				
			end
			PASS: begin
				/* Frame over */
				if(vsync_detect) begin
					state <= IDLE;
				end				
			end
			
			default: begin
				
				end
		endcase
	  end
	end


endmodule





