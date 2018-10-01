// ODDR1XF: Generic X1 ODDR implementation
// Lattice FPGA Libraries Reference Guide
module ODDRX1F
(
  output wire Q,     // 1-bit DDR output
  input wire SCLK,   // 1-bit clock input
  input wire D0,     // 1-bit data input (positive edge)
  input wire D1,     // 1-bit data input (negative edge)
  input wire RST     // 1-bit reset
);

   reg Q_b;
   reg QP0, QN0, R0, F0, R0_reg, F0_reg;
   reg last_SCLKB;
   wire QN_sig;
   wire RSTB, SCLKB;
   reg SCLKB1, SCLKB2, SCLKB3;
   reg SRN;

   assign QN_sig = Q_b; 

	wire OP, ON, RSTB1;

   buf (Q, QN_sig);
   buf (OP, D0);
   buf (ON, D1);
   buf (RSTB1, RST);
   buf (SCLKB, SCLK);

      function DataSame;
        input a, b;
        begin
          if (a === b)
            DataSame = a;
          else
            DataSame = 1'bx;
        end
      endfunction

initial
begin
QP0 = 0;
QN0 = 0;
R0 = 0;
F0 = 0;
R0_reg = 0;
F0_reg = 0;
SCLKB1 = 0;
SCLKB2 = 0;
SCLKB3 = 0;
end

initial
begin
last_SCLKB = 1'b0;
end

                              
  or INST1 (RSTB, RSTB1, 1'b0);

always @ (SCLKB)
begin
   last_SCLKB <= SCLKB;
end

always @ (SCLKB, SCLKB1, SCLKB2)
begin
   SCLKB1 <= SCLKB;
   SCLKB2 <= SCLKB1;
   SCLKB3 <= SCLKB2;
end

always @ (SCLKB or RSTB)
begin
   if (RSTB == 1'b1)
   begin
      QP0 <= 1'b0;
      QN0 <= 1'b0;
   end
   else
   begin
      if (SCLKB === 1'b1 && last_SCLKB === 1'b0)
         begin
            QP0 <= OP;
            QN0 <= ON;
         end
   end
end

always @ (SCLKB or RSTB)
begin
   if (RSTB == 1'b1)
   begin
      R0 <= 1'b0;
      F0 <= 1'b0;
      R0_reg <= 1'b0;
      F0_reg <= 1'b0;
   end
   else
   begin
      if (SCLKB === 1'b1 && last_SCLKB === 1'b0)
      begin
         R0 <= QP0;
         F0 <= QN0;
         F0_reg <= F0;
      end
      if (SCLKB === 1'b0 && last_SCLKB === 1'b1)     // neg
      begin
         R0_reg <= R0;
      end
   end
end

always @ (F0_reg or R0_reg or SCLKB1)
begin
   case (SCLKB1)
        1'b0 :  Q_b = F0_reg;
        1'b1 :  Q_b = R0_reg;
        default Q_b = DataSame(F0_reg, R0_reg);
   endcase
end



endmodule



// IDDR1XF: Generic X1 IDDR implementation
// Lattice FPGA Libraries Reference Guide
module IDDRX1F
(
  output wire Q0,     // 1-bit output for positive edge of clock
  output wire Q1,     // 1-bit output for negative edge of clock
  input wire SCLK,   // 1-bit clock input
  input wire D,      // 1-bit DDR data input
  input wire RST     // 1-bit reset
);

wire Db, SCLKb;

reg QP, QN, IP0, IN0;
reg last_SCLKB;
reg SRN;

wire SCLKB;
wire RSTB1;

buf (Db, D);
buf (SCLKB, SCLK);
buf (RSTB1, RST);

assign Q0 = IP0;
assign Q1 = IN0;


initial
begin
QP = 0;
QN = 0;
IP0 = 0;
IN0 = 0;
end

  
            wire RSTB2;                   
  or INST1 (RSTB2, RSTB1, 1'b0);

initial
begin
last_SCLKB = 1'b0;
end

always @ (SCLKB)
begin
   last_SCLKB <= SCLKB;
end

always @ (SCLKB or RSTB2)     // pos_neg edge
begin
   if (RSTB2 == 1'b1)
   begin
      QP <= 1'b0;
      QN <= 1'b0;
   end
   else
   begin
      if (SCLKB === 1'b1 && last_SCLKB === 1'b0)
      begin
         QP <= D;
      end
      if (SCLKB === 1'b0 && last_SCLKB === 1'b1)
      begin
         QN <= D;
      end
   end
end

always @ (SCLKB or RSTB2)     //  edge
begin
   if (RSTB2 == 1'b1)
   begin
      IP0 <= 1'b0;
      IN0 <= 1'b0;
   end
   else
   begin
      if (SCLKB === 1'b1 && last_SCLKB === 1'b0)
      begin
         IP0 <= QP;
         IN0 <= QN;
      end
   end
end


endmodule


