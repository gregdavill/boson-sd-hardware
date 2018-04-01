EESchema Schematic File Version 4
LIBS:crushedICE-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 3 6
Title "Boson Breakout with ICE FPGA"
Date "2018-03-24"
Rev "v0_1"
Comp "GsD"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L crushedICE:Boson U?
U 1 1 5AB23880
P 1900 3750
AR Path="/5AB23880" Ref="U?"  Part="1" 
AR Path="/5AB2368D/5AB23880" Ref="U4"  Part="1" 
F 0 "U4" H 2004 5342 60  0000 C CNN
F 1 "Boson" H 2004 5236 60  0000 C CNN
F 2 "lib:DF40_80Pin" H 1900 5000 60  0001 C CNN
F 3 "" H 1900 5000 60  0001 C CNN
F 4 "H11919CT-ND" H 0   0   60  0001 C CNN "SN-DK"
	1    1900 3750
	1    0    0    -1  
$EndComp
$Comp
L crushedICE:Boson U?
U 2 1 5AB23887
P 4000 3850
AR Path="/5AB23887" Ref="U?"  Part="2" 
AR Path="/5AB2368D/5AB23887" Ref="U4"  Part="2" 
F 0 "U4" H 4104 5442 60  0000 C CNN
F 1 "Boson" H 4104 5336 60  0000 C CNN
F 2 "" H 4000 5100 60  0001 C CNN
F 3 "" H 4000 5100 60  0001 C CNN
F 4 "H11919CT-ND" H 0   0   60  0001 C CNN "SN-DK"
	2    4000 3850
	1    0    0    -1  
$EndComp
$Comp
L crushedICE:Boson U?
U 3 1 5AB2388E
P 4000 5500
AR Path="/5AB2388E" Ref="U?"  Part="3" 
AR Path="/5AB2368D/5AB2388E" Ref="U4"  Part="3" 
F 0 "U4" H 4129 7092 60  0000 C CNN
F 1 "Boson" H 4129 6986 60  0000 C CNN
F 2 "" H 4000 6750 60  0001 C CNN
F 3 "" H 4000 6750 60  0001 C CNN
F 4 "H11919CT-ND" H 0   0   60  0001 C CNN "SN-DK"
	3    4000 5500
	1    0    0    -1  
$EndComp
$Comp
L crushedICE:Boson U?
U 4 1 5AB23895
P 6700 3750
AR Path="/5AB23895" Ref="U?"  Part="4" 
AR Path="/5AB2368D/5AB23895" Ref="U4"  Part="4" 
F 0 "U4" H 6579 5342 60  0000 C CNN
F 1 "Boson" H 6579 5236 60  0000 C CNN
F 2 "" H 6700 5000 60  0001 C CNN
F 3 "" H 6700 5000 60  0001 C CNN
F 4 "H11919CT-ND" H 0   0   60  0001 C CNN "SN-DK"
	4    6700 3750
	1    0    0    -1  
$EndComp
$Comp
L crushedICE:Boson U?
U 5 1 5AB2389C
P 9150 3750
AR Path="/5AB2389C" Ref="U?"  Part="5" 
AR Path="/5AB2368D/5AB2389C" Ref="U4"  Part="5" 
F 0 "U4" H 9179 5342 60  0000 C CNN
F 1 "Boson" H 9179 5236 60  0000 C CNN
F 2 "" H 9150 5000 60  0001 C CNN
F 3 "" H 9150 5000 60  0001 C CNN
F 4 "H11919CT-ND" H 0   0   60  0001 C CNN "SN-DK"
	5    9150 3750
	1    0    0    -1  
$EndComp
Text GLabel 10000 3550 2    60   Input ~ 0
CAM_D11
Text GLabel 10000 3650 2    60   Input ~ 0
CAM_D12
Text GLabel 10000 3750 2    60   Input ~ 0
CAM_D13
Text GLabel 10000 3850 2    60   Input ~ 0
CAM_D14
Text GLabel 10000 3950 2    60   Input ~ 0
CAM_D15
Text GLabel 10000 3450 2    60   Input ~ 0
CAM_D10
Text GLabel 10000 3350 2    60   Input ~ 0
CAM_D9
Text GLabel 10000 3250 2    60   Input ~ 0
CAM_D8
Text GLabel 10000 3150 2    60   Input ~ 0
CAM_D7
Text GLabel 10000 3050 2    60   Input ~ 0
CAM_D6
Text GLabel 10000 2950 2    60   Input ~ 0
CAM_D5
Text GLabel 10000 2850 2    60   Input ~ 0
CAM_D4
Text GLabel 10000 2750 2    60   Input ~ 0
CAM_D3
Text GLabel 10000 2650 2    60   Input ~ 0
CAM_D2
Text GLabel 10000 2550 2    60   Input ~ 0
CAM_D1
Text GLabel 10000 4350 2    60   Input ~ 0
CAM_CLK
Text GLabel 10000 2450 2    60   Input ~ 0
CAM_D0
$Comp
L crushedICE:GND #PWR018
U 1 1 5AB238B4
P 2650 5450
F 0 "#PWR018" H 2650 5200 50  0001 C CNN
F 1 "GND" H 2650 5300 50  0000 C CNN
F 2 "" H 2650 5450 50  0001 C CNN
F 3 "" H 2650 5450 50  0001 C CNN
	1    2650 5450
	1    0    0    -1  
$EndComp
Text GLabel 10000 4150 2    60   Input ~ 0
CAM_VALID
Text GLabel 10000 4450 2    60   Input ~ 0
CAM_VSYNC
Text GLabel 10000 4550 2    60   Input ~ 0
CAM_HSYNC
Text GLabel 2550 3150 2    60   Input ~ 0
EXT_SYNC
Text GLabel 2550 3050 2    60   Input ~ 0
BOSON_RESET
$Comp
L crushedICE:+3V3 #PWR017
U 1 1 5AB238BF
P 2650 2350
F 0 "#PWR017" H 2650 2200 50  0001 C CNN
F 1 "+3V3" H 2653 2501 50  0000 C CNN
F 2 "" H 2650 2350 50  0001 C CNN
F 3 "" H 2650 2350 50  0001 C CNN
	1    2650 2350
	1    0    0    -1  
$EndComp
Text GLabel 7450 2450 2    60   Input ~ 0
BOSON_RXD
Text GLabel 7450 2550 2    60   Input ~ 0
BOSON_TXD
NoConn ~ 7450 4050
NoConn ~ 7450 3950
NoConn ~ 7450 3850
NoConn ~ 7450 3750
NoConn ~ 7450 3550
NoConn ~ 7450 3450
NoConn ~ 7450 3350
NoConn ~ 7450 3150
NoConn ~ 7450 3050
NoConn ~ 7450 2850
NoConn ~ 7450 2750
NoConn ~ 7450 3250
Wire Wire Line
	2550 3550 2650 3550
Wire Wire Line
	2650 3550 2650 5450
Wire Wire Line
	2550 3650 2650 3650
Connection ~ 2650 3650
Wire Wire Line
	2550 3750 2650 3750
Connection ~ 2650 3750
Wire Wire Line
	2550 3850 2650 3850
Connection ~ 2650 3850
Wire Wire Line
	2550 3950 2650 3950
Connection ~ 2650 3950
Wire Wire Line
	2550 4050 2650 4050
Connection ~ 2650 4050
Wire Wire Line
	2550 4150 2650 4150
Connection ~ 2650 4150
Wire Wire Line
	2550 4250 2650 4250
Connection ~ 2650 4250
Wire Wire Line
	2550 4350 2650 4350
Connection ~ 2650 4350
Wire Wire Line
	2550 4450 2650 4450
Connection ~ 2650 4450
Wire Wire Line
	2550 4550 2650 4550
Connection ~ 2650 4550
Wire Wire Line
	2550 4650 2650 4650
Connection ~ 2650 4650
Wire Wire Line
	2550 4750 2650 4750
Connection ~ 2650 4750
Wire Wire Line
	2550 4850 2650 4850
Connection ~ 2650 4850
Wire Wire Line
	2550 4950 2650 4950
Connection ~ 2650 4950
Wire Wire Line
	2550 5050 2650 5050
Connection ~ 2650 5050
Wire Wire Line
	2550 5150 2650 5150
Connection ~ 2650 5150
Wire Wire Line
	2550 5250 2650 5250
Connection ~ 2650 5250
Wire Wire Line
	2550 5350 2650 5350
Connection ~ 2650 5350
Wire Wire Line
	2550 2750 2650 2750
Wire Wire Line
	2650 2350 2650 2750
Wire Wire Line
	2550 2650 2650 2650
Connection ~ 2650 2650
Wire Wire Line
	2550 2550 2650 2550
Connection ~ 2650 2550
Wire Wire Line
	2550 2450 2650 2450
Connection ~ 2650 2450
NoConn ~ 2550 3250
$EndSCHEMATC
