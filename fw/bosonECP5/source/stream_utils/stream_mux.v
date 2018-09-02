module stream_mux
  #(parameter DW=0)
  (input 	   sel,
   input [DW-1:0]  s0_data_i,
   input 	   s0_valid_i,
   output 	   s0_ready_o,
   input [DW-1:0]  s1_data_i,
   input 	   s1_valid_i,
   output 	   s1_ready_o,
   output [DW-1:0] m_data_o,
   output 	   m_valid_o,
   input 	   m_ready_i);

   assign m_data_o  = sel ? s1_data_i : s0_data_i;
   assign m_valid_o = sel ? s1_valid_i : s0_valid_i;
   assign s0_ready_o = !sel & m_ready_i;
   assign s1_ready_o = sel & m_ready_i;

endmodule
