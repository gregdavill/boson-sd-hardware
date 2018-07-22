

module cc_data_host(
		   input wire cmos_clk_i,
           input rst,
           //Rx Fifo
           output reg [31:0] data_out,
           output reg we,
           //tristate data
		   input wire [15:0] cmos_data_i, 
		   input wire cmos_vsync_i,
		   input wire cmos_hsync_i,
		   input wire cmos_valid_i,
		   output wire cmos_reset_o,
           //Control signals
		   input wire start,
		   // data out
		   output data_count_reg
       );


parameter SIZE = 6;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
parameter IDLE       = 6'b000001;
parameter WRITE_DAT  = 6'b000010;
parameter WRITE_CRC  = 6'b000100;
parameter WRITE_BUSY = 6'b001000;
parameter READ_WAIT  = 6'b010000;
parameter READ_DAT   = 6'b100000;


reg [31:0] data_byte_counter;
reg [31:0] data_count_reg;

assign cmos_reset_o = !rst;


	always @(posedge cmos_clk_i) begin
	  if(rst) begin
		data_byte_counter <= 0;
		state <= IDLE;
	  end else begin
		case (state)
			IDLE: begin
				if(cmos_vsync_i == 0) begin
					data_byte_counter <= 0;
					data_count_reg <= data_byte_counter;
				end
				if(cmos_valid_i) begin
					data_byte_counter <= data_byte_counter + 1; 
				end
				
				data_count_reg <= {16'b0,cmos_data_i};
				
			end
			default: begin
				
				end
		endcase
	  end
	end


endmodule





