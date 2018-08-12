///////////////////////////////////////////////////////////////////////////////
//  File name : s27ks0641.v
///////////////////////////////////////////////////////////////////////////////
//  Copyright (C) 2015 Spansion, LLC.
//
//  MODIFICATION HISTORY :
//
//  version:  | author:        |   date:    | changes made:
//    V1.0     M.Stojanovic     15 June 24    Initial release
//
///////////////////////////////////////////////////////////////////////////////
///  PART DESCRIPTION:
//
//  Library:        Spansion
//  Technology:     RAM
//  Part:           S27KS0641
//
//  Description:   Reduced Pin Count Pseudo Static RAM,
//                 64Mb high-speed CMOS 1.8 Volt Core, x8 data bus
//
//
//////////////////////////////////////////////////////////////////////////////
//  Comments :
//      For correct simulation, simulator resolution should be set to 1 ps
//
//////////////////////////////////////////////////////////////////////////////
//  Known Bugs:
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// MODULE DECLARATION                                                       //
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ps/1 ps

module s27ks0641
    (
    DQ7      ,
    DQ6      ,
    DQ5      ,
    DQ4      ,
    DQ3      ,
    DQ2      ,
    DQ1      ,
    DQ0      ,
    RWDS     ,

    CSNeg    ,
    CK       ,
    CKNeg    ,
    RESETNeg
    );

////////////////////////////////////////////////////////////////////////
// Port / Part Pin Declarations
////////////////////////////////////////////////////////////////////////
    inout  DQ7;
    inout  DQ6;
    inout  DQ5;
    inout  DQ4;
    inout  DQ3;
    inout  DQ2;
    inout  DQ1;
    inout  DQ0;
    inout  RWDS;

    input  CSNeg;
    input  CK;
    input  CKNeg;
    input  RESETNeg;

    // interconnect path delay signals
    wire CSNeg_ipd;
    wire CK_ipd;
    wire CKNeg_ipd;
    wire RESETNeg_ipd;
    wire DQ7_ipd;
    wire DQ6_ipd;
    wire DQ5_ipd;
    wire DQ4_ipd;
    wire DQ3_ipd;
    wire DQ2_ipd;
    wire DQ1_ipd;
    wire DQ0_ipd;
    wire RWDS_ipd;

    wire [7:0] Din;
    assign Din = { DQ7_ipd,
                   DQ6_ipd,
                   DQ5_ipd,
                   DQ4_ipd,
                   DQ3_ipd,
                   DQ2_ipd,
                   DQ1_ipd,
                   DQ0_ipd};

    wire [7:0] Dout;
    assign Dout = { DQ7,
                    DQ6,
                    DQ5,
                    DQ4,
                    DQ3,
                    DQ2,
                    DQ1,
                    DQ0 };
    wire RWDSin;
    assign RWDSin = RWDS_ipd;

    //  internal delays
    reg DPD_in           = 0;
    reg DPD_out          = 0;
    reg RPH_in           = 0;
    reg RPH_out          = 0;
    reg REF_in          = 0;
    reg REF_out         = 0;
    reg PO_in           = 0;
    reg PO_out          = 0;

    wire   DPDExt_in;       // DPD Exit event
    reg    DPDExt_out  = 0; // DPD Exit event confirmed
    reg    DPDExt      = 0; // DPD Exit event detected

    // event control registers
    reg rising_edge_PoweredUp  = 0;
    reg rising_edge_CKDiff     = 0;
    reg falling_edge_CKDiff    = 0;
    reg rising_edge_CSNeg      = 0;
    reg falling_edge_CSNeg     = 0;
    reg rising_edge_REF_out    = 0;
    reg rising_edge_PO_out     = 0;
    reg rising_edge_RPH_out    = 0;
    reg rising_edge_DPD_in     = 0;
    reg rising_edge_DPD_out    = 0;
    reg rising_edge_RESETNeg   = 0;
    reg falling_edge_RESETNeg  = 0;

    integer DQt_01;
    integer RWDSt_01;
    integer RWDSRt_01;
    time half_period = 0;
    time prev_CK;
    reg glitch_dq = 1'b0;
    reg glitch_rwds = 1'b0;
    reg glitch_rwdsR = 1'b0;
    reg Viol = 1'b0;

    reg [7:0] Dout_zd = 8'bzzzzzzzz;
    reg RWDSout_zd = 1'bz;

    wire  DQ7_zd   ;
    wire  DQ6_zd   ;
    wire  DQ5_zd   ;
    wire  DQ4_zd   ;
    wire  DQ3_zd   ;
    wire  DQ2_zd   ;
    wire  DQ1_zd   ;
    wire  DQ0_zd   ;

    assign {DQ7_zd,
            DQ6_zd,
            DQ5_zd,
            DQ4_zd,
            DQ3_zd,
            DQ2_zd,
            DQ1_zd,
            DQ0_zd  } = Dout_zd;

    wire RWDS_zd;
    assign RWDS_zd = RWDSout_zd;

    reg [7:0] Dout_zd_tmp = 8'bzzzzzzzz;
    reg RWDSout_zd_tmp = 1'bz;

    reg [7:0] Dout_zd_latchH ;
    reg [7:0] Dout_zd_latchL ;
    reg RWDS_zd_latchH ;
    reg RWDS_zd_latchL ;

    wire RESETNeg_pullup;
    assign RESETNeg_pullup = (RESETNeg === 1'bZ) ? 1 : RESETNeg;

    reg CKDiff = 1'bz ;
    reg RW     = 0;

    reg REFCOLL = 0;
    reg REFCOLL_ACTIV = 0; // = 1 : refresh collision occured

    reg t_RWR_CHK = 1'b0;

    parameter UserPreload     = 1;
    parameter mem_file_name   = "none";//"s27ks0641.mem";

    parameter TimingModel = "DefaultTimingModel";

    parameter PartID   = "S27KS0641";
    parameter MaxData  = 16'hFFFF;
    parameter MemSize  = 25'h3FFFFF;
    parameter HiAddrBit = 34;
    parameter AddrRANGE = 25'h3FFFFF;

///////////////////////////////////////////////////////////////////////////////
//Interconnect Path Delay Section
///////////////////////////////////////////////////////////////////////////////
    buf   (DQ7_ipd , DQ7 );
    buf   (DQ6_ipd , DQ6 );
    buf   (DQ5_ipd , DQ5 );
    buf   (DQ4_ipd , DQ4 );
    buf   (DQ3_ipd , DQ3 );
    buf   (DQ2_ipd , DQ2 );
    buf   (DQ1_ipd , DQ1 );
    buf   (DQ0_ipd , DQ0 );
    buf   (RWDS_ipd , RWDS );

    buf   (CK_ipd       , CK      );
    buf   (CKNeg_ipd    , CKNeg   );
    buf   (RESETNeg_ipd , RESETNeg);
    buf   (CSNeg_ipd    , CSNeg   );


///////////////////////////////////////////////////////////////////////////////
// Propagation  delay Section
///////////////////////////////////////////////////////////////////////////////
    nmos   (DQ7 ,   DQ7_zd  , 1);
    nmos   (DQ6 ,   DQ6_zd  , 1);
    nmos   (DQ5 ,   DQ5_zd  , 1);
    nmos   (DQ4 ,   DQ4_zd  , 1);
    nmos   (DQ3 ,   DQ3_zd  , 1);
    nmos   (DQ2 ,   DQ2_zd  , 1);
    nmos   (DQ1 ,   DQ1_zd  , 1);
    nmos   (DQ0 ,   DQ0_zd  , 1);
    nmos   (RWDS ,  RWDS_zd , 1);

    wire Dout_Z;
    assign Dout_Z = Dout_zd==8'bzzzzzzzz;

    wire RWDSout_Z;
    assign RWDSout_Z = RWDSout_zd==1'bz & RW == 0;

    wire tRWR_CHK;
    assign tRWR_CHK = t_RWR_CHK;

    specify
    // tipd delays: interconnect path delays , mapped to input port delays.
    // In Verilog is not necessary to declare any tipd_ delay variables,
    // they can be taken from SDF file
    // With all the other delays real delays would be taken from SDF file

        // tpd delays
    specparam  tpd_CSNeg_RWDS           = 1; //tDSZ
    specparam  tpd_CK_RWDS_REFCOLL_EQ_1 = 1; //tRIV
    specparam  tpd_CK_RWDS_REFCOLL_EQ_0 = 1; //tCKDS
    specparam  tpd_CSNeg_DQ0            = 1; //tDSZ
    specparam  tpd_CK_DQ0               = 1; //tCKDS+tDSS

        //tsetup values
    specparam  tsetup_CSNeg_CK          = 1;  //tCSS  edge /
    specparam  tsetup_DQ0_CK            = 1;  //tIS

        //thold values
    specparam  thold_CSNeg_CK           = 1;  //tCSH  edge \
    specparam  thold_DQ0_CK             = 1;  //tIH
    specparam  thold_CSNeg_RESETNeg     = 1;  //tRH

    specparam  trecovery_CSNeg_CK       = 1;  //tRWR
    specparam  tskew_CSNeg_CSNeg        = 1;  //tCSM

        //tpw values: pulse width
    specparam  tpw_CK_negedge           = 1; //tCL
    specparam  tpw_CK_posedge           = 1; //tCH
    specparam  tpw_CSNeg_posedge        = 1; //tCSHI
    specparam  tpw_RESETNeg_negedge     = 1; //tRP

        //tperiod values
    specparam  tperiod_CK               = 1; //tCK

     //tdevice values: values for internal delays
     // power-on reset
    `define tdevice_VCS     150e6
    // Deep Power Down to Idle wake up time
    `define tdevice_DPD     150e6
    // Exit Event from Deep Power Down
    `define tdevice_DPDCSL  200e3;
    // Warm HW reset
    `define tdevice_RPH     400e3;
    // Refresh time
    `define tdevice_REF166  36e3;
    // Page Open Time
    `define tdevice_PO166  36e3;

///////////////////////////////////////////////////////////////////////////////
// Input Port  Delays  don't require Verilog description
///////////////////////////////////////////////////////////////////////////////
// Path delays                                                               //
///////////////////////////////////////////////////////////////////////////////

    // Data output paths
    (CSNeg => DQ0) = tpd_CSNeg_DQ0;
    (CSNeg => DQ1) = tpd_CSNeg_DQ0;
    (CSNeg => DQ2) = tpd_CSNeg_DQ0;
    (CSNeg => DQ3) = tpd_CSNeg_DQ0;
    (CSNeg => DQ4) = tpd_CSNeg_DQ0;
    (CSNeg => DQ5) = tpd_CSNeg_DQ0;
    (CSNeg => DQ6) = tpd_CSNeg_DQ0;
    (CSNeg => DQ7) = tpd_CSNeg_DQ0;

    (CSNeg => RWDS) = tpd_CSNeg_RWDS;

    if (~glitch_dq) (CK => DQ0) = tpd_CK_DQ0;
    if (~glitch_dq) (CK => DQ1) = tpd_CK_DQ0;
    if (~glitch_dq) (CK => DQ2) = tpd_CK_DQ0;
    if (~glitch_dq) (CK => DQ3) = tpd_CK_DQ0;
    if (~glitch_dq) (CK => DQ4) = tpd_CK_DQ0;
    if (~glitch_dq) (CK => DQ5) = tpd_CK_DQ0;
    if (~glitch_dq) (CK => DQ6) = tpd_CK_DQ0;
    if (~glitch_dq) (CK => DQ7) = tpd_CK_DQ0;

    if (~glitch_rwds && ~REFCOLL) (CK => RWDS) = tpd_CK_RWDS_REFCOLL_EQ_0;
    if (~glitch_rwdsR && REFCOLL) (CK => RWDS) = tpd_CK_RWDS_REFCOLL_EQ_1;

    ///////////////////////////////////////////////////////////////////////////
    // Timing Violation                                                      //
    ///////////////////////////////////////////////////////////////////////////
    $setup (CSNeg, posedge CK,   tsetup_CSNeg_CK);

    $setup (DQ0 &&& Dout_Z, CK, tsetup_DQ0_CK);
    $setup (DQ1 &&& Dout_Z, CK, tsetup_DQ0_CK);
    $setup (DQ2 &&& Dout_Z, CK, tsetup_DQ0_CK);
    $setup (DQ3 &&& Dout_Z, CK, tsetup_DQ0_CK);
    $setup (DQ4 &&& Dout_Z, CK, tsetup_DQ0_CK);
    $setup (DQ5 &&& Dout_Z, CK, tsetup_DQ0_CK);
    $setup (DQ6 &&& Dout_Z, CK, tsetup_DQ0_CK);
    $setup (DQ7 &&& Dout_Z, CK, tsetup_DQ0_CK);

    $setup (RWDS &&& RWDSout_Z, CK, tsetup_DQ0_CK);

    $hold (negedge CK, CSNeg, thold_CSNeg_CK);

    $hold (CK, DQ0 &&& Dout_Z, thold_DQ0_CK, Viol);
    $hold (CK, DQ1 &&& Dout_Z, thold_DQ0_CK, Viol);
    $hold (CK, DQ2 &&& Dout_Z, thold_DQ0_CK, Viol);
    $hold (CK, DQ3 &&& Dout_Z, thold_DQ0_CK, Viol);
    $hold (CK, DQ4 &&& Dout_Z, thold_DQ0_CK, Viol);
    $hold (CK, DQ5 &&& Dout_Z, thold_DQ0_CK, Viol);
    $hold (CK, DQ6 &&& Dout_Z, thold_DQ0_CK, Viol);
    $hold (CK, DQ7 &&& Dout_Z, thold_DQ0_CK, Viol);

    $hold (CK, RWDS &&& RWDSout_Z, thold_DQ0_CK, Viol);

    $hold (posedge RESETNeg, CSNeg, thold_CSNeg_RESETNeg);

    $recovery (posedge CSNeg, negedge CK &&& tRWR_CHK, trecovery_CSNeg_CK, Viol);

    $skew (negedge CSNeg, posedge CSNeg, tskew_CSNeg_CSNeg, Viol);

    $width (posedge CK                 , tpw_CK_posedge);
    $width (negedge CK                 , tpw_CK_negedge);
    $width (posedge CSNeg              , tpw_CSNeg_posedge);
    $width (negedge RESETNeg           , tpw_RESETNeg_negedge);

    $period(posedge CK  ,tperiod_CK);

    endspecify

///////////////////////////////////////////////////////////////////////////////
// Main Behavior Block                                                       //
///////////////////////////////////////////////////////////////////////////////

    // FSM states
    parameter POWER_ON     = 3'd0;
    parameter ACT          = 3'd1;
    parameter RESET_STATE  = 3'd2;
    parameter DPD_STATE    = 3'd3;
    reg [2:0] current_state = POWER_ON;
    reg [2:0] next_state    = POWER_ON;

    //Bus cycle state
    parameter STAND_BY        = 2'd0;
    parameter CA_BITS         = 2'd1;
    parameter DATA_BITS       = 2'd2;
    reg [1:0] bus_cycle_state;

    // Parameters that define read mode, burst or continuous
    parameter LINEAR     = 4'd0;
    parameter CONTINUOUS = 4'd1;
    reg [1:0] RD_MODE = CONTINUOUS;

    integer Mem [0:MemSize];

    reg PoweredUp = 0;

    reg DPD_ACT        = 0;
    integer Address; // entire address

    reg [15:0] Config_reg = 16'h8F1F;
    reg UByteMask             = 0;
    reg LByteMask             = 0;
    reg Target                = 0;
    integer BurstDelay;
    integer RefreshDelay = 4;
    integer BurstLength;

    //varaibles to resolve architecture used
    reg [24*8-1:0] tmp_timing;//stores copy of TimingModel
    reg [7:0] tmp_char1; //Identify Speed option
    integer found = 1'b0;

    reg SPEED166 = 1;

    //Power Up time;
    initial
    begin
        # 150e6 PoweredUp = 1'b1;
    end

    initial
    begin: InitTimingModel
    integer i;
    integer j;
        //assumptions:
        //1. TimingModel has format as S27KS0641XXXXXXXX
        //it is important that 11-th character from first one is "P"
        //2. TimingModel does not have more then 24 characters
        tmp_timing = TimingModel;//copy of TimingModel

        i = 23;
        while ((i >= 0) && (found != 1'b1))//search for first non null character
        begin        //i keeps position of first non null character
            j = 7;
            while ((j >= 0) && (found != 1'b1))
            begin
                if (tmp_timing[i*8+j] != 1'd0)
                    found = 1'b1;
                else
                    j = j-1;
            end
            i = i - 1;
        end
        i = i +1;
        if (found)//if non null character is found
        begin
            for (j=0;j<=7;j=j+1)
            begin
            //Speed is 11.
                tmp_char1[j] = TimingModel[(i-10)*8+j];
            end
        end
        if (tmp_char1 == "P")
            SPEED166 = 1;
    end

    // ------------------------------------------------------------------------
    // Deep Power Down time
    // ------------------------------------------------------------------------
    // DPDExit_in is any write or read access for which CSNeg_ipd is asserted
    // more than tDPDCSL time
    assign DPDExt_in = ((falling_edge_CSNeg == 1'b1) && (DPD_in == 1'b1)) ?
                         1'b1 : 1'b0;

    always @(posedge DPDExt_in)
    begin : DPDExtEvent
      #(200e6 - 1) DPDExt_out = 1'b1;
      #1 DPDExt_out = 1'b0;
    end
    // Generate event to trigger exiting from DPD mode
    always @(posedge DPDExt_out or CSNeg_ipd or RESETNeg or falling_edge_RESETNeg or
             DPD_in)
    begin : DPDExtDetected
      if ((DPDExt_out == 1'b1) && (CSNeg_ipd == 1'b0) ||
          (!RESETNeg && falling_edge_RESETNeg && DPD_in))
      begin
        DPDExt = 1'b1;
        #1 DPDExt = 1'b0;
      end
    end
    // DPD exit event, generated after tDPDOUT time (maximal: 150 us)
    always @(posedge DPDExt)
    begin : DPDTime
        DPD_out = 1'b0;
        #(150e6 - 1) DPD_out = 1'b1;
    end

    // Timing control
    // Deep Power Down to Idle
    always @(posedge DPD_in)
    begin:DPDr
        #150e6 DPD_out = DPD_in;
    end
    always @(negedge DPD_in)
    begin:DPDf
        #1 DPD_out = DPD_in;
    end
    // Warm HW reset
    always @(posedge RPH_in)
    begin:RPHr
        #400e3 RPH_out = RPH_in;
    end
    always @(negedge RPH_in)
    begin:RPHf
        #1 RPH_out = RPH_in;
    end

    //  Refresh Collision Time
    always @(posedge REF_in)
    begin:REFr
        if (SPEED166)
            #36e3 REF_out = REF_in;
    end
    always @(negedge REF_in)
    begin:REFf
        #1 REF_out = REF_in;
    end

    //  Page Open Time
    always @(posedge PO_in)
    begin:POr
        if (SPEED166)
            #36e3 PO_out = PO_in;
    end
    always @(negedge PO_in)
    begin:POf
        #1 PO_out = PO_in;
    end

    // initialize memory and load preoload files if any
    initial
    begin: InitMemory
    integer i;
        for (i=0;i<=MemSize;i=i+1)
           Mem[i]=MaxData;

        if (UserPreload && !(mem_file_name == "none"))
            $readmemh(mem_file_name,Mem);
    end
    ///////////////////////////////////////////////////////////////////////////
    // Process for generating differential clock from CK and CKNeg
    ///////////////////////////////////////////////////////////////////////////
    always @(CK, CKNeg)
    begin : DiffCK
        if (CK && ~CKNeg)
            CKDiff = 1'b1;
        if (~CK && CKNeg)
            CKDiff = 1'b0;
    end
    ///////////////////////////////////////////////////////////////////////////
    // Check if device is selected during power up
    ///////////////////////////////////////////////////////////////////////////
    always @(negedge CSNeg_ipd)
    begin:CheckCSOnPowerUP
        if (~PoweredUp)
            $display ("Device is selected during Power Up");
    end

    always @(rising_edge_CKDiff or falling_edge_CKDiff)
    begin : clock_period
        if (CSNeg_ipd == 1'b0)
        begin
            if (falling_edge_CKDiff)
                half_period = $time - prev_CK;
            if (rising_edge_CKDiff)
                prev_CK = $time;

            if (DQt_01 > half_period)
                glitch_dq = 1'b1;
            if (RWDSt_01 > half_period)
                glitch_rwds = 1'b1;
            if (RWDSRt_01 > half_period)
                glitch_rwdsR = 1'b1;
        end
    end

    ///////////////////////////////////////////////////////////////////////////
    // Bus Cycle Decode
    ///////////////////////////////////////////////////////////////////////////
    integer data_cycle  =  0;
    integer ca_cnt      = 48;
    reg [47:0] ca_in        ;
    reg [15:0] Data_in      ;
    reg RD_WRAP;
    integer Start_BurstAddr;
    reg RdWrStart        = 1'b0;
    reg ALTERNATE_64     = 1'b0;
    reg HYBRID           = 1'b0;

    always @(rising_edge_CSNeg or falling_edge_CSNeg or
           rising_edge_CKDiff or falling_edge_CKDiff or falling_edge_RESETNeg
            or rising_edge_REF_out or rising_edge_PO_out)
    begin: BusCycle
    integer i;

    if (current_state == ACT)
    begin
        case (bus_cycle_state)

        STAND_BY:
        begin
            if (falling_edge_CSNeg)
            begin
                ca_cnt        = 48;
                data_cycle    = 0;
                RW            = 1'b0;
                RD_WRAP       = 1'b0;
                RdWrStart     = 1'b0;
                REFCOLL       = 1'b0;
                REFCOLL_ACTIV   = 1'b0;
                ALTERNATE_64  = 1'b0;
                HYBRID        = 1'b0;
                bus_cycle_state = CA_BITS;
            end
        end

        CA_BITS:
        begin
            if (!CSNeg &&
            (rising_edge_CKDiff || falling_edge_CKDiff))
            begin
                for(i=1;i<=8;i=i+1)
                    ca_in[ca_cnt-i] = Din[8-i];
                ca_cnt = ca_cnt - 8;

                if (ca_cnt == 40)
                begin
                    REFCOLL = 1'b1;
                    if (Config_reg[3] == 1'b1)// fixed latency
                    begin
                        REFCOLL_ACTIV = 1'b1;
                        RWDSout_zd_tmp = 1'b1;
                    end
                    else if (Config_reg[3] == 1'b0)// variable latency
                        RWDSout_zd_tmp = 1'b0;
                end

                else if (ca_cnt == 24)
                    t_RWR_CHK = 1'b1;

                else if (ca_cnt == 16)
                begin
                    RW = ca_in[47];
                    Target = ca_in[46];
                    if (Target==1'b0 || (Target==1'b1 && RW==1'b1))
                    begin
                        if (REFCOLL_ACTIV)
                            REF_in = 1'b1;
                        else
                            PO_in = 1'b1;
                    end

                    if (Config_reg[2] == 1'b0)
                        HYBRID = 1'b1;

                    if ((Config_reg[1:0] == 2'b00) ||
                    (Config_reg[1:0] == 2'b01))
                    begin
                        BurstLength = 32;
                        if (Config_reg[1:0] == 2'b01)
                            ALTERNATE_64 = 1'b1;
                    end
                    else if (Config_reg[1:0] == 2'b10)
                        BurstLength = 8;
                    else if (Config_reg[1:0] == 2'b11)
                        BurstLength = 16;

                    if (Config_reg[7:4] == 4'b0000)
                        BurstDelay = 5;
                    else if (Config_reg[7:4] == 4'b0001)
                        BurstDelay = 6;
                    else if (Config_reg[7:4] == 4'b1111)
                        BurstDelay = 4;
                    else if (Config_reg[7:4] == 4'b1110)
                        BurstDelay = 3;

                    RefreshDelay = BurstDelay;
                end

                else if (ca_cnt == 8)
                begin
                    if (RW == 1'b1) // read
                        RWDSout_zd_tmp = 1'b0;
                    else  // write
                        RWDSout_zd_tmp = 1'bz;
                    t_RWR_CHK = 1'b0;
                end

                else if (ca_cnt == 0)
                begin
                    REFCOLL = 1'b0;
                    if (ca_in[45])
                        RD_MODE = CONTINUOUS;
                    else
                        RD_MODE = LINEAR;

                    Address   = {ca_in[HiAddrBit:16], ca_in[2:0]};
                    Start_BurstAddr = Address;

                    if (REFCOLL_ACTIV)
                        RefreshDelay = RefreshDelay - 1;
                    else
                        BurstDelay = BurstDelay - 1;
                    bus_cycle_state = DATA_BITS;
                end
            end
        end

        DATA_BITS:
        begin
            if (rising_edge_CKDiff && !CSNeg)
            begin
                if (Target==1'b1 && RW==1'b0)
                begin
                    Data_in[15:8] = Din;
                    data_cycle = data_cycle + 1;
                end
                else
                if (BurstDelay==0 && !PO_in)
                begin
                    RdWrStart = 1'b0;
                    if (RW == 1) // read
                    begin
                        RWDSout_zd_tmp = 1'b1;
                        if (Target == 0) // mem
                        begin
                            if (Mem[Address][15:8]==-1)
                                Dout_zd_tmp = 8'bxxxxxxxx;
                            else
                                Dout_zd_tmp=Mem[Address][15:8];
                        end
                        else // reg
                            Dout_zd_tmp = Config_reg[15:8];
                    end
                    else // (RW == 0) write
                    begin
                        Data_in[15:8] = Din;
                        data_cycle = data_cycle + 1;
                        UByteMask = RWDS;
                    end
                end
            end

            else if (falling_edge_CKDiff && !CSNeg)
            begin
                if (Target==1'b1 && RW==1'b0)
                begin
                    Data_in[7:0] = Din;
                    data_cycle = data_cycle + 1;
                    if (data_cycle == 2)
                    begin
                        if (!Data_in[15] && Config_reg[15])
                        begin
                            DPD_ACT = 1'b1;
                            DPD_ACT <= #5 1'b0;
                        end
                        Config_reg=Data_in;
                    end
                end
                else
                if (REFCOLL_ACTIV)
                begin
                    if (RefreshDelay > 0)
                        RefreshDelay = RefreshDelay - 1;
                    if (RefreshDelay == 0)
                    begin
                        if (!REF_in)
                        begin
                            PO_in = 1'b1;
                            REFCOLL_ACTIV = 1'b0;
                        end
                    end
                end
                else
                begin
                    if (BurstDelay>0)
                        BurstDelay = BurstDelay - 1;
                    else
                    begin
                        if (!PO_in)
                        begin
                            if (RdWrStart == 1'b1)
                                RdWrStart =1'b0;
                            else
                            begin
                                if (RW == 1) // read
                                begin
                                    RWDSout_zd_tmp = 1'b0;
                                    if (Target == 0) // mem
                                    begin
                                        if (Mem[Address][7:0]==-1)
                                            Dout_zd_tmp = 8'bxxxxxxxx;
                                        else
                                            Dout_zd_tmp = Mem[Address][7:0];
                                    end
                                    else // reg
                                        Dout_zd_tmp = Config_reg[7:0];
                                end
                                else // write
                                begin
                                    if (Target == 0)  // mem
                                    begin
                                        if (data_cycle >= 1)
                                        begin
                                            Data_in[7:0] = Din;
                                            data_cycle = data_cycle + 1;
                                            LByteMask = RWDS;
                                            if (data_cycle % 2 == 0)
                                            begin
                                                if (!LByteMask)
                                                    Mem[Address][7:0]=Data_in[7:0];
                                                if (!UByteMask)
                                                    Mem[Address][15:8]=Data_in[15:8];
                                            end
                                        end
                                    end
                                end

                                if (RD_MODE == CONTINUOUS)
                                begin
                                    if (Address == AddrRANGE)
                                        Address = 0;
                                    else
                                        Address = Address + 1;
                                end
                                else // wrapped burst
                                begin
                                    if (!HYBRID)//legacy wrapped burst
                                    begin
                                        if ((BurstLength==8) ||
                                        (BurstLength==16) ||
                                        (BurstLength==32 && !ALTERNATE_64))
                                        begin
                                            Address = Address + 1;
                                            if (Address % BurstLength == 0)
                                                Address= Address - BurstLength;
                                        end
                                        else if (BurstLength==32 && ALTERNATE_64)
                                        begin
                                            Address = Address + 1;
                                            if (Address % (BurstLength/2)== 0)
                                            begin
                                                if (!RD_WRAP)
                                                begin
                                                    Address= Address-(BurstLength/2);
                                                    RD_WRAP = 1'b1;
                                                end
                                                else
                                                begin
                                                    ALTERNATE_64 = 0;
                                                    if (Address[4] == 1'b0)
                                                        Address=Address-BurstLength;
                                                end
                                            end
                                            if ((Address == Start_BurstAddr) &&
                                            ALTERNATE_64)
                                            begin
                                                if (Address[4] == 1'b0)
                                                begin
                                                    Address =
                                                    (Start_BurstAddr/
                                                    BurstLength)*BurstLength
                                                        + BurstLength/2;
                                                end
                                                else if (Address[4] == 1'b1)
                                                    Address =
                                                    (Start_BurstAddr/
                                                    BurstLength)*BurstLength;
                                            end
                                        end
                                    end
                                    else // Hybrid burst sequencing
                                    begin
                                        if ((BurstLength==8) ||
                                        (BurstLength==16) ||
                                        (BurstLength==32 && !ALTERNATE_64))
                                        begin
                                            Address = Address + 1;
                                            if (Address % BurstLength == 0)
                                                Address= Address - BurstLength;
                                            if (Address == Start_BurstAddr)
                                            begin
                                                Address=
                                        (Start_BurstAddr/BurstLength)*BurstLength
                                                + BurstLength;
                                                if (Address==AddrRANGE + 1)
                                                    Address = 0;
                                                RD_MODE = CONTINUOUS;
                                            end
                                        end

                                        else if (BurstLength==32 && ALTERNATE_64)
                                        begin
                                            Address = Address + 1;
                                            if (Address % (BurstLength/2)== 0)
                                            begin
                                                if (!RD_WRAP)
                                                begin
                                                    Address= Address-(BurstLength/2);
                                                    RD_WRAP = 1'b1;
                                                end
                                                else
                                                begin
                                                    Address =
                                                    (Start_BurstAddr/
                                                    BurstLength)*BurstLength
                                                        + BurstLength;
                                                    if (Address==AddrRANGE + 1)
                                                        Address = 0;
                                                    RD_MODE = CONTINUOUS;
                                                end
                                            end
                                            if (Address == Start_BurstAddr)
                                            begin
                                                if (Address[4] == 1'b0)
                                                    Address =
                                                    (Start_BurstAddr/
                                                    BurstLength)*BurstLength
                                                    + BurstLength/2;
                                                else if (Address[4] == 1'b1)
                                                    Address =
                                                    (Start_BurstAddr/
                                                    BurstLength)*BurstLength;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        endcase

        if (rising_edge_CSNeg || falling_edge_RESETNeg)
        begin
            bus_cycle_state = STAND_BY;
            Dout_zd_tmp = 8'bzzzzzzzz;
            RWDSout_zd_tmp = 1'bz;
            Dout_zd = 8'bzzzzzzzz;
            RWDSout_zd = 1'bz;
            if (falling_edge_RESETNeg)
                Config_reg = 16'h8F1F;// default value
        end
        if (rising_edge_PO_out)
        begin
            PO_in = 1'b0;
            RdWrStart = 1'b1;
        end
        if (rising_edge_REF_out)
            REF_in = 1'b0;
    end

    else
      begin
        bus_cycle_state = STAND_BY;
        if (falling_edge_RESETNeg)
            Config_reg = 16'h8F1F;// default value
      end
    end

    always @(next_state)
    begin:CurrentStatGen
        current_state = next_state;
    end

    always @(rising_edge_PoweredUp or
            rising_edge_DPD_in or rising_edge_RPH_out or
            rising_edge_RESETNeg or rising_edge_DPD_out or
            falling_edge_RESETNeg)
    begin: StateGen
        case (current_state)

            POWER_ON:
            begin
                if (rising_edge_PoweredUp)
                    next_state <= ACT;
            end

            ACT:
            begin
                if (falling_edge_RESETNeg)
                    next_state <= RESET_STATE;
                else if (rising_edge_DPD_in)
                    next_state <= DPD_STATE;
            end

            RESET_STATE:
            begin
                if ((rising_edge_RPH_out && RESETNeg_pullup) ||
                (rising_edge_RESETNeg && !RPH_in))
                    next_state <= ACT;
            end

            DPD_STATE:
            begin
                if (falling_edge_RESETNeg)
                    next_state <= RESET_STATE;
                else if (rising_edge_DPD_out)
                    next_state <= ACT;
            end

        endcase
    end

    always @(falling_edge_RESETNeg or
            DPD_ACT or rising_edge_RPH_out or
            rising_edge_DPD_out)
    begin:Functional
        case (current_state)

            POWER_ON:
            begin
            end

            ACT:
            begin
                if (falling_edge_RESETNeg)
                    RPH_in = 1'b1;
                if (DPD_ACT)
                    DPD_in = 1'b1;
            end

            RESET_STATE:
            begin
                if (rising_edge_RPH_out)
                    RPH_in = 1'b0;
            end

            DPD_STATE:
            begin
                if (rising_edge_DPD_out)
                    DPD_in = 1'b0;
                if (falling_edge_RESETNeg)
                begin
                    RPH_in = 1'b1;
                    DPD_in = 1'b0;
                end
            end
        endcase
    end

 always @(posedge PoweredUp)
    begin
        rising_edge_PoweredUp = 1;
        #1 rising_edge_PoweredUp = 0;
    end

    always @(negedge CKDiff)
    begin
        falling_edge_CKDiff = 1;
        #1 falling_edge_CKDiff = 0;
    end

    always @(posedge CKDiff)
    begin
        rising_edge_CKDiff = 1;
        #1 rising_edge_CKDiff = 0;
    end

 always @(posedge CSNeg)
    begin
        rising_edge_CSNeg = 1;
        #1 rising_edge_CSNeg = 0;
    end
 always @(negedge CSNeg)
    begin
        falling_edge_CSNeg = 1;
        #1 falling_edge_CSNeg = 0;
    end

 always @(posedge REF_out)
    begin
        rising_edge_REF_out = 1;
        #1 rising_edge_REF_out = 0;
    end

 always @(posedge PO_out)
    begin
        rising_edge_PO_out = 1;
        #1 rising_edge_PO_out = 0;
    end

 always @(posedge RPH_out)
    begin
        rising_edge_RPH_out = 1;
        #1 rising_edge_RPH_out = 0;
    end

 always @(posedge DPD_in)
    begin
        rising_edge_DPD_in = 1;
        #1 rising_edge_DPD_in = 0;
    end

 always @(posedge DPD_out)
    begin
        rising_edge_DPD_out = 1;
        #1 rising_edge_DPD_out = 0;
    end

 always @(posedge RESETNeg)
    begin
        rising_edge_RESETNeg = 1;
        #1 rising_edge_RESETNeg = 0;
    end

 always @(negedge RESETNeg)
    begin
        falling_edge_RESETNeg = 1;
        #1 falling_edge_RESETNeg = 0;
    end

    always @(rising_edge_CSNeg)
    begin
        disable read_process_dq1;
        disable read_process_dq2;
        disable read_process_rwds1;
        disable read_process_rwds2;
        disable read_process_rwdsR1;
        disable read_process_rwdsR2;
    end

 always @(rising_edge_CKDiff)
    begin: read_process_dq1
        if (~CSNeg_ipd)
        begin
            if (glitch_dq)
            begin
                #1 Dout_zd_latchH = Dout_zd_tmp;
                #DQt_01 Dout_zd = Dout_zd_latchH;
            end
            else
            begin
                Dout_zd = Dout_zd_tmp;
            end
        end
    end

 always @(falling_edge_CKDiff)
    begin: read_process_dq2
        if (~CSNeg_ipd)
        begin
            if (glitch_dq)
            begin
                #1 Dout_zd_latchL = Dout_zd_tmp;
                #DQt_01 Dout_zd = Dout_zd_latchL;
            end
            else
            begin
                Dout_zd = Dout_zd_tmp;
            end
        end
    end

    always @(rising_edge_CKDiff)
    begin: read_process_rwds1
        if (~CSNeg_ipd)
        begin
            if (glitch_rwds && !REFCOLL)
            begin
                #1 RWDS_zd_latchH = RWDSout_zd_tmp;
                #RWDSt_01 RWDSout_zd = RWDS_zd_latchH;
            end
            else if (!REFCOLL)
            begin
                RWDSout_zd = RWDSout_zd_tmp;
            end
        end
    end

    always @(falling_edge_CKDiff)
    begin: read_process_rwds2
        if (~CSNeg_ipd)
        begin
            if (glitch_rwds && !REFCOLL)
            begin
                #1 RWDS_zd_latchL = RWDSout_zd_tmp;
                #RWDSt_01 RWDSout_zd = RWDS_zd_latchL;
            end
            else if (!REFCOLL)
            begin
                RWDSout_zd = RWDSout_zd_tmp;
            end
        end
    end

    always @(rising_edge_CKDiff)
    begin: read_process_rwdsR1
        if (~CSNeg_ipd)
        begin
            if (glitch_rwdsR && REFCOLL)
            begin
                #1 RWDS_zd_latchH = RWDSout_zd_tmp;
                #RWDSRt_01 RWDSout_zd = RWDS_zd_latchH;
            end
            else if (REFCOLL)
            begin
                RWDSout_zd = RWDSout_zd_tmp;
            end
        end
    end

    always @(falling_edge_CKDiff)
    begin: read_process_rwdsR2
        if (~CSNeg_ipd)
        begin
            if (glitch_rwdsR && REFCOLL)
            begin
                #1 RWDS_zd_latchL = RWDSout_zd_tmp;
                #RWDSRt_01 RWDSout_zd = RWDS_zd_latchL;
            end
            else if (REFCOLL)
            begin
                RWDSout_zd = RWDSout_zd_tmp;
            end
        end
    end

    reg  BuffInDQ;
    wire BuffOutDQ;

    reg  BuffInRWDS;
    wire BuffOutRWDS;

    reg  BuffInRWDSR;
    wire BuffOutRWDSR;

    BUFFER    BUF_DOut   (BuffOutDQ, BuffInDQ);
    BUFFER    BUF_RWDS    (BuffOutRWDS, BuffInRWDS);
    BUFFER    BUF_RWDSR   (BuffOutRWDSR, BuffInRWDSR);

    initial
    begin
        BuffInDQ   = 1'b1;
        BuffInRWDS  = 1'b1;
        BuffInRWDSR  = 1'b1;
    end

    always @(posedge BuffOutDQ)
    begin
        DQt_01 = $time;
    end

    always @(posedge BuffOutRWDS)
    begin
        RWDSt_01 = $time;
    end

    always @(posedge BuffOutRWDSR)
    begin
        RWDSRt_01 = $time;
    end

endmodule

module BUFFER (OUT,IN);
    input IN;
    output OUT;
    buf   ( OUT, IN);
endmodule
