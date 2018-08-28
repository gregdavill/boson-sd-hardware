/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.10.2.115 */
/* Module Version: 5.7 */
/* C:\lscc\diamond\3.10_x64\ispfpga\bin\nt64\scuba.exe -w -n pll -lang verilog -synth synplify -bus_exp 7 -bb -arch sa5p00 -type pll -fin 24 -clkibuf LVCMOS33 -fclkop 48 -fclkop_tol 0.0 -fclkos 48 -fclkos_tol 0.0 -phases 90 -fclkos2 6 -fclkos2_tol 0.0 -phases2 0 -fclkos3 6 -fclkos3_tol 0.0 -phases3 90 -phase_cntl STATIC -lock -fb_mode 5 -fdc C:/Users/gregd/Documents/git/lattice_diamond/blk_ram_test/blk_ram/pll/pll.fdc  */
/* Sun Aug 26 11:03:05 2018 */


`timescale 1 ns / 1 ps
module pll (CLKI, CLKOP, CLKOS, CLKOS2, CLKOS3, LOCK)/* synthesis NGD_DRC_MASK=1 */;
    input wire CLKI;
    output wire CLKOP;
    output wire CLKOS;
    output wire CLKOS2;
    output wire CLKOS3;
    output wire LOCK;

    wire REFCLK;
    wire CLKOS3_t;
    wire CLKOS2_t;
    wire CLKOS_t;
    wire CLKOP_t;
    wire CLKFB_t;
    wire buf_CLKI;
    wire scuba_vhi;
    wire scuba_vlo;

    IB Inst1_IB (.I(CLKI), .O(buf_CLKI))
             /* synthesis IO_TYPE="LVCMOS33" */;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam PLLInst_0.PLLRST_ENA = "DISABLED" ;
    defparam PLLInst_0.INTFB_WAKE = "DISABLED" ;
    defparam PLLInst_0.STDBY_ENABLE = "DISABLED" ;
    defparam PLLInst_0.DPHASE_SOURCE = "DISABLED" ;
    defparam PLLInst_0.CLKOS3_FPHASE = 0 ;
    defparam PLLInst_0.CLKOS3_CPHASE = 119 ;
    defparam PLLInst_0.CLKOS2_FPHASE = 0 ;
    defparam PLLInst_0.CLKOS2_CPHASE = 95 ;
    defparam PLLInst_0.CLKOS_FPHASE = 0 ;
    defparam PLLInst_0.CLKOS_CPHASE = 14 ;
    defparam PLLInst_0.CLKOP_FPHASE = 0 ;
    defparam PLLInst_0.CLKOP_CPHASE = 11 ;
    defparam PLLInst_0.PLL_LOCK_MODE = 0 ;
    defparam PLLInst_0.CLKOS_TRIM_DELAY = 0 ;
    defparam PLLInst_0.CLKOS_TRIM_POL = "FALLING" ;
    defparam PLLInst_0.CLKOP_TRIM_DELAY = 0 ;
    defparam PLLInst_0.CLKOP_TRIM_POL = "FALLING" ;
    defparam PLLInst_0.OUTDIVIDER_MUXD = "DIVD" ;
    defparam PLLInst_0.CLKOS3_ENABLE = "ENABLED" ;
    defparam PLLInst_0.OUTDIVIDER_MUXC = "DIVC" ;
    defparam PLLInst_0.CLKOS2_ENABLE = "ENABLED" ;
    defparam PLLInst_0.OUTDIVIDER_MUXB = "DIVB" ;
    defparam PLLInst_0.CLKOS_ENABLE = "ENABLED" ;
    defparam PLLInst_0.OUTDIVIDER_MUXA = "DIVA" ;
    defparam PLLInst_0.CLKOP_ENABLE = "ENABLED" ;
    defparam PLLInst_0.CLKOS3_DIV = 96 ;
    defparam PLLInst_0.CLKOS2_DIV = 96 ;
    defparam PLLInst_0.CLKOS_DIV = 12 ;
    defparam PLLInst_0.CLKOP_DIV = 12 ;
    defparam PLLInst_0.CLKFB_DIV = 2 ;
    defparam PLLInst_0.CLKI_DIV = 1 ;
    defparam PLLInst_0.FEEDBK_PATH = "INT_OP" ;
    EHXPLLL PLLInst_0 (.CLKI(buf_CLKI), .CLKFB(CLKFB_t), .PHASESEL1(scuba_vlo), 
        .PHASESEL0(scuba_vlo), .PHASEDIR(scuba_vlo), .PHASESTEP(scuba_vlo), 
        .PHASELOADREG(scuba_vlo), .STDBY(scuba_vlo), .PLLWAKESYNC(scuba_vlo), 
        .RST(scuba_vlo), .ENCLKOP(scuba_vlo), .ENCLKOS(scuba_vlo), .ENCLKOS2(scuba_vlo), 
        .ENCLKOS3(scuba_vlo), .CLKOP(CLKOP_t), .CLKOS(CLKOS_t), .CLKOS2(CLKOS2_t), 
        .CLKOS3(CLKOS3_t), .LOCK(LOCK), .INTLOCK(), .REFCLK(REFCLK), .CLKINTFB(CLKFB_t))
             /* synthesis FREQUENCY_PIN_CLKOS3="6.000000" */
             /* synthesis FREQUENCY_PIN_CLKOS2="6.000000" */
             /* synthesis FREQUENCY_PIN_CLKOS="48.000000" */
             /* synthesis FREQUENCY_PIN_CLKOP="48.000000" */
             /* synthesis FREQUENCY_PIN_CLKI="24.000000" */
             /* synthesis ICP_CURRENT="5" */
             /* synthesis LPF_RESISTOR="16" */;

    assign CLKOS3 = CLKOS3_t;
    assign CLKOS2 = CLKOS2_t;
    assign CLKOS = CLKOS_t;
    assign CLKOP = CLKOP_t;


    // exemplar begin
    // exemplar attribute Inst1_IB IO_TYPE LVCMOS33
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKOS3 6.000000
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKOS2 6.000000
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKOS 48.000000
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKOP 48.000000
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKI 24.000000
    // exemplar attribute PLLInst_0 ICP_CURRENT 5
    // exemplar attribute PLLInst_0 LPF_RESISTOR 16
    // exemplar end

endmodule