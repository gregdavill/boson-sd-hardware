

module cc_data_host(
		   input wire cmos_clk_i,
           input wire rst,
           //Camera data / Control signals
		   input wire [15:0] cmos_data_i, 
		   input wire cmos_vsync_i,
		   input wire cmos_hsync_i,
		   input wire cmos_valid_i,
		   output wire cmos_reset_o,
		   
		   output wire cc_enabled,
		   
           //Control signals
		   input wire arm,
		   output reg [31:0] frame_length,
		   output reg [31:0] bits_per_frame,
		   output reg [31:0] frame_count
       );


parameter SIZE = 6;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
parameter IDLE       = 6'b000001;
parameter ARM        = 6'b000010;
parameter PASS       = 6'b000100;


/* Vsync Detect will generate a 1 cycle pulse ever line */
reg vsync_sr;
always @(posedge cmos_clk_i) 
	vsync_sr <= cmos_vsync_i;

wire vsync_detect;
assign vsync_detect = ({vsync_sr,cmos_vsync_i} == 2'b01);

/* Mask data based on state machine */
assign cc_enabled   = (state == PASS);


/* Active variables */
reg [31:0] bits;
reg [31:0] len;


assign cmos_reset_o = !rst;

	always @(posedge cmos_clk_i) begin
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
		
		if(rst)
			state <= IDLE;
	end


	/* Frame information */
	always @(posedge cmos_clk_i) begin
		
		/* Increment bits every clock cmos_valid_i is active */
		if(cmos_valid_i)
			bits <= bits + 1;
		
		/* Increment len ever clock between vsync events */
		len <= len + 1;
		
		if(vsync_detect) begin
			/* On a vsync event save the old values and reset. */
			frame_length <= len;
			bits_per_frame <= bits;

			frame_count <= frame_count + 1;

			len <= 0;
			bits <= 0;
		end

		if(rst) begin
			frame_length <= 0;
			bits_per_frame <= 0;

			len <= 0;
			bits <= 0;
			frame_count <= 0;
		
		end
	end


endmodule





