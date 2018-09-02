module stream_fifo
  #(parameter DW = 0,
    parameter AW = 0)
   (input 	    clk,
    input 	    rst,
    input [DW-1:0]  s_data_i, 
    input 	    s_valid_i,
    output 	    s_ready_o,

    output [DW-1:0] m_data_o,
    output 	    m_valid_o,
    input 	    m_ready_i);

   wire 	    empty;
   wire 	    full;

   fifo_fwft
     #(.DATA_WIDTH  (DW),
       .DEPTH_WIDTH (AW))
   fifo
     (.clk   (clk),
      .rst   (rst),
      .din   (s_data_i),
      .wr_en (s_valid_i & ~(full | rst)),
      .full  (full),
      .dout  (m_data_o),
      .rd_en (m_ready_i & ~empty),
      .empty (empty));

   assign m_valid_o = ~empty;
   assign s_ready_o = ~(full | rst);

endmodule
