module stream_dual_clock_fifo
  #(parameter DW = 0,
    parameter AW = 0)
   (input wire           wr_clk,
    input wire           wr_rst,
    input wire [DW-1:0]  stream_s_data_i, 
    input wire           stream_s_valid_i,
    output wire          stream_s_ready_o,

    input wire           rd_clk,
    input wire          rd_rst,
    output wire [DW-1:0] stream_m_data_o,
    output  wire        stream_m_valid_o,
    input   wire         stream_m_ready_i);
   
   

   wire             fifo_rd_en;
   wire [DW-1:0]    fifo_dout;
   wire             fifo_empty;
   wire             full;
   
   assign stream_s_ready_o = !(full | wr_rst);
   
  /*      
   // orig_fifo is just a normal (non-FWFT) synchronous or asynchronous FIFO
   dual_clock_fifo
     #(.ADDR_WIDTH (AW),
       .DATA_WIDTH (DW))
   dual_clock_fifo
     (.wr_rst_i  (wr_rst),       
      .wr_clk_i  (wr_clk),
      .wr_en_i   (stream_s_valid_i & stream_s_ready_o),
      .wr_data_i (stream_s_data_i),
      .full_o    (full),

      .rd_rst_i  (rd_rst),       
      .rd_clk_i  (rd_clk),
      .rd_en_i   (fifo_rd_en),
      .rd_data_o (fifo_dout),
      .empty_o   (fifo_empty));
*/
   fifo_ram
   dual_clock_fifo
     (.Reset  (wr_rst),       
      .WrClock  (wr_clk),
      .WrEn   (stream_s_valid_i & stream_s_ready_o),
      .Data (stream_s_data_i),
      .Full    (full),

      .RPReset  (rd_rst),       
      .RdClock  (rd_clk),
      .RdEn   (fifo_rd_en),
      .Q (fifo_dout),
      .Empty   (fifo_empty));


   stream_fifo_if
     #(.DW (DW))
   stream_if
   (.clk              (rd_clk),
    .rst              (rd_rst),
    .fifo_data_i      (fifo_dout),
    .fifo_rd_en_o     (fifo_rd_en),
    .fifo_empty_i     (fifo_empty),
    .stream_m_data_o  (stream_m_data_o),
    .stream_m_valid_o (stream_m_valid_o),
    .stream_m_ready_i (stream_m_ready_i));
   
endmodule


