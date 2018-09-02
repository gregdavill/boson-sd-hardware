
module wb_stream_writer_fifo
  #(parameter DW = 0,
    parameter AW = 0)
   (input wire 	    clk,
    input wire	      rst,
    output wire [AW:0] cnt,
    input wire [DW-1:0]    stream_s_data_i, 
    input wire 	      stream_s_valid_i,
    output wire	      stream_s_ready_o,

    output wire [DW-1:0]   stream_m_data_o,
    output wire	      stream_m_valid_o,
    input 	wire      stream_m_ready_i);
   
   

   wire 	    fifo_rd_en;
   wire [DW-1:0]    fifo_dout;
   wire 	    fifo_empty;
   wire 	    full;
   
 //  wire  		    inc_cnt;
 //  wire  		    dec_cnt;

   assign stream_s_ready_o = !full;
   
   // orig_fifo is just a normal (non-FWFT) synchronous or asynchronous FIFO
 /*  fifo
     #(.DEPTH_WIDTH (AW),
       .DATA_WIDTH  (DW))
   fifo0
     (
       .clk       (clk),
       .rst       (rst),       
       .rd_en_i   (fifo_rd_en),
       .rd_data_o (fifo_dout),
       .empty_o   (fifo_empty),
       .wr_en_i   (stream_s_valid_i & ~full),
       .wr_data_i (stream_s_data_i),
       .full_o    (full));
*/

cd_fifo  fifo0
     (
       .Clock  (clk),
       .Reset  (rst),       
       .RdEn   (fifo_rd_en),
       .Data   (stream_s_data_i),
       .Empty  (fifo_empty),
       .WrEn   (stream_s_valid_i & ~full),
       .Q      (fifo_dout),
       .Full   (full),
	   .WCNT   (cnt));



   stream_fifo_if
     #(.DW (DW))
   stream_if
   (.clk              (clk),
    .rst              (rst),
    .fifo_data_i      (fifo_dout),
    .fifo_rd_en_o     (fifo_rd_en),
    .fifo_empty_i     (fifo_empty),
    .stream_m_data_o  (stream_m_data_o),
    .stream_m_valid_o (stream_m_valid_o),
    .stream_m_ready_i (stream_m_ready_i));
/*
   
   assign inc_cnt = stream_s_valid_i & stream_s_ready_o;
   assign dec_cnt = stream_m_valid_o & stream_m_ready_i;
   always @(posedge clk) begin

      if(inc_cnt & !dec_cnt)
	cnt <= cnt + 1;
      else if(dec_cnt & !inc_cnt)
	cnt <= cnt - 1;
      
      if (rst)
	cnt <= 0;
   end
   */
   
endmodule
