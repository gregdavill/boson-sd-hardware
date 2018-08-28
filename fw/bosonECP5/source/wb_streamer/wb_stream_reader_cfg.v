`default_nettype none

module wb_stream_reader_cfg
  #(parameter WB_AW = 32,
    parameter WB_DW = 32)
  (
   input wire                 wb_clk_i,
   input wire                 wb_rst_i,
   //Wishbone IF
   input wire [4:0]            wb_adr_i,
   input wire [WB_DW-1:0]      wb_dat_i,
   input wire [WB_DW/8-1:0]    wb_sel_i,
   input wire                  wb_we_i ,
   input wire                  wb_cyc_i,
   input wire                  wb_stb_i,
   input wire [2:0]            wb_cti_i,
   input wire [1:0]            wb_bte_i,
   output reg [WB_DW-1:0]     wb_dat_o,
   output reg             wb_ack_o,
   output wire                wb_err_o,
   //Application IF
   output reg             irq,
   input wire                 busy,
   output reg             enable,
   input wire [WB_DW-1:0]      tx_cnt,
   output reg [WB_AW-1:0] start_adr,
   output reg [WB_AW-1:0] buf_size,
   output reg [WB_AW-1:0] burst_size);

   reg                    busy_r;
   always @(posedge wb_clk_i) begin
     if (wb_rst_i)
       busy_r <= 0;
     else
       busy_r <= busy;
	end



always @(posedge wb_clk_i)
begin
    if (wb_rst_i)begin
        wb_ack_o <= 0;
		
		enable     <= 1'b0;
        start_adr  <= 0; 
        buf_size   <= 100;
        burst_size <= 2; 
		
		irq        <= 0;
		
		wb_dat_o <= 0;
    end
    else
    begin
		if (!busy & busy_r)
			irq <= 1;
		wb_ack_o <= 0;
		
        if (wb_stb_i & wb_cyc_i)begin
            if (wb_we_i) begin
                case (wb_adr_i[4:2])
						//Read/Write logic
				0 : begin
					if (wb_dat_i[0]) enable <= 1;
					if (wb_dat_i[1]) irq <= 0;
				end
				1 : start_adr <= wb_dat_i;
				2 : buf_size  <= wb_dat_i;
				3 : burst_size <= wb_dat_i;
				endcase
			end else begin
				case (wb_adr_i[4:2])
					0: wb_dat_o <= {{(WB_DW-2){1'b0}}, irq, busy};
					1: wb_dat_o <= start_adr;
					2: wb_dat_o <= buf_size;
					3: wb_dat_o <= burst_size;
					4: wb_dat_o <= tx_cnt*4;	
				endcase	
			end
            wb_ack_o <= ~wb_ack_o;
        end
    end
end




   assign wb_err_o = 0;

endmodule
