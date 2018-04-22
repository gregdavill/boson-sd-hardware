EESchema Schematic File Version 4
LIBS:bosonFrameGrabber-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 3 6
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 8550 3950 2    60   Input ~ 0
HYPERBUS_RWDS
Text GLabel 8550 3850 2    60   Input ~ 0
HYPERBUS_CS#
Text GLabel 8550 3750 2    60   Input ~ 0
HYPERBUS_RESET#
Text GLabel 7350 3250 0    60   Input ~ 0
HYPERBUS_CK
Text GLabel 7350 3350 0    60   Input ~ 0
HYPERBUS_CK#
Text GLabel 7350 3850 0    60   Input ~ 0
HYPERBUS_DQ0
Text GLabel 7350 3950 0    60   Input ~ 0
HYPERBUS_DQ1
Text GLabel 7350 4050 0    60   Input ~ 0
HYPERBUS_DQ2
Text GLabel 7350 4150 0    60   Input ~ 0
HYPERBUS_DQ3
Text GLabel 7350 4250 0    60   Input ~ 0
HYPERBUS_DQ4
Text GLabel 7350 4350 0    60   Input ~ 0
HYPERBUS_DQ5
Text GLabel 7350 4450 0    60   Input ~ 0
HYPERBUS_DQ6
Text GLabel 7350 4550 0    60   Input ~ 0
HYPERBUS_DQ7
$Comp
L bosonFrameGrabber:S27KS0641 U4
U 1 1 5ABD3939
P 7950 3900
F 0 "U4" H 7950 4840 60  0000 C CNN
F 1 "S27KS0641" H 7950 4734 60  0000 C CNN
F 2 "bosonFrameGrabber:BGA_24" H 7950 4850 60  0001 C CNN
F 3 "" H 7950 4850 60  0001 C CNN
F 4 " 428-3858-ND " H 0   0   50  0001 C CNN "SN-DK"
F 5 "S27KS0641DPBHI020" H 0   0   50  0001 C CNN "PN"
	1    7950 3900
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:+1V8 #PWR038
U 1 1 5ABB0386
P 8650 3150
F 0 "#PWR038" H 8650 3000 50  0001 C CNN
F 1 "+1V8" H 8653 3301 50  0000 C CNN
F 2 "" H 8650 3150 50  0001 C CNN
F 3 "" H 8650 3150 50  0001 C CNN
	1    8650 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	8550 3250 8650 3250
Wire Wire Line
	8650 3250 8650 3150
$Comp
L bosonFrameGrabber:GND #PWR039
U 1 1 5ABB03AC
P 8750 3550
F 0 "#PWR039" H 8750 3300 50  0001 C CNN
F 1 "GND" V 8754 3470 50  0000 R CNN
F 2 "" H 8650 3200 50  0001 C CNN
F 3 "" H 8750 3550 50  0001 C CNN
	1    8750 3550
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8550 3550 8750 3550
$Comp
L bosonFrameGrabber:GND #PWR040
U 1 1 5ABB03DC
P 8650 4700
F 0 "#PWR040" H 8650 4450 50  0001 C CNN
F 1 "GND" H 8653 4574 50  0000 C CNN
F 2 "" H 8550 4350 50  0001 C CNN
F 3 "" H 8650 4700 50  0001 C CNN
	1    8650 4700
	1    0    0    -1  
$EndComp
Wire Wire Line
	8550 4450 8650 4450
Wire Wire Line
	8650 4450 8650 4550
Wire Wire Line
	8550 4550 8650 4550
Connection ~ 8650 4550
$Comp
L bosonFrameGrabber:+1V8 #PWR041
U 1 1 5ABB0494
P 8750 4150
F 0 "#PWR041" H 8750 4000 50  0001 C CNN
F 1 "+1V8" V 8753 4256 50  0000 L CNN
F 2 "" H 8750 4150 50  0001 C CNN
F 3 "" H 8750 4150 50  0001 C CNN
	1    8750 4150
	0    1    1    0   
$EndComp
Wire Wire Line
	8750 4150 8650 4150
Wire Wire Line
	8550 4250 8650 4250
Wire Wire Line
	8650 4250 8650 4150
Connection ~ 8650 4150
$Comp
L bosonFrameGrabber:AT25SF081 U6
U 1 1 5ABD9FA9
P 4150 3950
F 0 "U6" H 4150 4391 60  0000 C CNN
F 1 "AT25SF081" H 4150 4285 60  0000 C CNN
F 2 "Housings_DFN_QFN:DFN-8-1EP_3x2mm_Pitch0.5mm" H 4150 4400 60  0001 C CNN
F 3 "" H 4150 4400 60  0001 C CNN
F 4 " 1265-1275-1-ND " H 0   0   50  0001 C CNN "SN-DK"
F 5 " AT25SF081-MAHD-T " H 0   0   50  0001 C CNN "PN"
	1    4150 3950
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR04
U 1 1 5ABD9FB0
P 3500 4200
F 0 "#PWR04" H 3500 3950 50  0001 C CNN
F 1 "GND" H 3503 4074 50  0000 C CNN
F 2 "" H 3400 3850 50  0001 C CNN
F 3 "" H 3500 4200 50  0001 C CNN
	1    3500 4200
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:+3V3 #PWR05
U 1 1 5ABD9FB6
P 4800 3700
F 0 "#PWR05" H 4800 3550 50  0001 C CNN
F 1 "+3V3" V 4804 3806 50  0000 L CNN
F 2 "" H 4800 3700 50  0001 C CNN
F 3 "" H 4800 3700 50  0001 C CNN
	1    4800 3700
	1    0    0    -1  
$EndComp
Text GLabel 3600 3800 0    60   Input ~ 0
SPI_CONFIG_SS
Text GLabel 4700 4000 2    60   Input ~ 0
SPI_CONFIG_SCK
Text GLabel 3600 3900 0    60   Input ~ 0
SPI_CONFIG_MISO
Text GLabel 4700 4100 2    60   Input ~ 0
SPI_CONFIG_MOSI
Wire Wire Line
	4700 3800 4800 3800
Wire Wire Line
	4800 3800 4800 3700
Wire Wire Line
	3500 4200 3500 4100
Wire Wire Line
	3500 4100 3600 4100
Text GLabel 4700 3900 2    60   Input ~ 0
QSPI_D3
Text GLabel 3600 4000 0    60   Input ~ 0
QSPI_D2
Wire Wire Line
	8650 4550 8650 4700
Wire Wire Line
	8650 4150 8550 4150
$EndSCHEMATC
