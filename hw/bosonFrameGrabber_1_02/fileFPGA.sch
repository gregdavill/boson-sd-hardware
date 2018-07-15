EESchema Schematic File Version 4
LIBS:bosonFrameGrabber-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 6
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 9450 3300 2    60   Input ~ 0
FPGA_CDONE
Text GLabel 5650 6650 2    60   Input ~ 0
SD_DAT0
Text GLabel 5650 7050 2    60   Input ~ 0
SD_DAT1
Text GLabel 5650 5250 2    60   Input ~ 0
SD_DAT2
Text GLabel 5650 5750 2    60   Input ~ 0
SD_DAT3
Text GLabel 5650 6450 2    60   Input ~ 0
SD_CMD
Text GLabel 5650 6550 2    60   Input ~ 0
SD_CK
Text GLabel 5650 5350 2    60   Input ~ 0
SD_CD
Text GLabel 5650 1550 2    60   Input ~ 0
HYPERBUS_CS#
Text GLabel 2550 4950 2    60   Input ~ 0
HYPERBUS_RESET#
Text GLabel 5650 2150 2    60   Input ~ 0
HYPERBUS_CK
Text GLabel 5650 2050 2    60   Input ~ 0
HYPERBUS_CK#
Text GLabel 5650 2250 2    60   Input ~ 0
HYPERBUS_DQ0
Text GLabel 5650 2350 2    60   Input ~ 0
HYPERBUS_DQ1
Text GLabel 5650 1350 2    60   Input ~ 0
HYPERBUS_DQ2
Text GLabel 5650 3350 2    60   Input ~ 0
HYPERBUS_DQ3
Text GLabel 5650 2650 2    60   Input ~ 0
HYPERBUS_DQ4
Text GLabel 5650 3550 2    60   Input ~ 0
HYPERBUS_DQ5
Text GLabel 5650 3250 2    60   Input ~ 0
HYPERBUS_DQ6
Text GLabel 5650 3850 2    60   Input ~ 0
HYPERBUS_DQ7
Text GLabel 2550 7250 2    60   Input ~ 0
BOSON_DATA0
Text GLabel 2550 6350 2    60   Input ~ 0
BOSON_DATA1
Text GLabel 2550 2400 2    60   Input ~ 0
BOSON_DATA2
Text GLabel 2550 1100 2    60   Input ~ 0
BOSON_DATA3
Text GLabel 2550 4750 2    60   Input ~ 0
BOSON_DATA4
Text GLabel 2550 4850 2    60   Input ~ 0
BOSON_DATA5
Text GLabel 2550 4650 2    60   Input ~ 0
BOSON_DATA6
Text GLabel 2550 4250 2    60   Input ~ 0
BOSON_DATA7
Text GLabel 2550 5050 2    60   Input ~ 0
BOSON_DATA8
Text GLabel 2550 2500 2    60   Input ~ 0
BOSON_DATA9
Text GLabel 2550 3750 2    60   Input ~ 0
BOSON_DATA10
Text GLabel 2550 2200 2    60   Input ~ 0
BOSON_DATA11
Text GLabel 2550 2600 2    60   Input ~ 0
BOSON_DATA12
Text GLabel 2550 3650 2    60   Input ~ 0
BOSON_DATA13
Text GLabel 2550 5250 2    60   Input ~ 0
BOSON_DATA14
Text GLabel 2550 3850 2    60   Input ~ 0
BOSON_DATA15
Text GLabel 2550 7350 2    60   Input ~ 0
BOSON_DATA_EN
Text GLabel 2550 1300 2    60   Input ~ 0
BOSON_CK
Text GLabel 2550 1500 2    60   Input ~ 0
BOSON_VSYNC
Text GLabel 2550 7150 2    60   Input ~ 0
BOSON_HSYNC
Text GLabel 2550 3950 2    60   Input ~ 0
BOSON_RXD
Text GLabel 2550 3350 2    60   Input ~ 0
BOSON_TXD
Text GLabel 2550 4550 2    60   Input ~ 0
BOSON_RESET
Text GLabel 9250 2250 2    60   Input ~ 0
SPI_CONFIG_SS
Text GLabel 9250 2900 2    60   Input ~ 0
SPI_CONFIG_SCK
Text GLabel 9250 1850 2    60   Input ~ 0
SPI_CONFIG_MISO
Text GLabel 9250 1950 2    60   Input ~ 0
SPI_CONFIG_MOSI
$Comp
L bosonFrameGrabber:+2V5 #PWR051
U 1 1 5AC13A0C
P 9550 5800
F 0 "#PWR051" H 9550 5650 50  0001 C CNN
F 1 "+2V5" V 9554 5906 50  0000 L CNN
F 2 "" H 9550 5800 50  0001 C CNN
F 3 "" H 9550 5800 50  0001 C CNN
	1    9550 5800
	0    -1   -1   0   
$EndComp
$Comp
L bosonFrameGrabber:+3V3 #PWR052
U 1 1 5AC17167
P 9500 4900
F 0 "#PWR052" H 9500 4750 50  0001 C CNN
F 1 "+3V3" V 9504 5006 50  0000 L CNN
F 2 "" H 9500 4900 50  0001 C CNN
F 3 "" H 9500 4900 50  0001 C CNN
	1    9500 4900
	1    0    0    -1  
$EndComp
Text GLabel 9250 1750 2    60   Input ~ 0
QSPI_D2
Text GLabel 9250 1650 2    60   Input ~ 0
QSPI_D3
Text GLabel 10550 3500 2    60   Input ~ 0
FPGA_RESET
Text GLabel 5650 2850 2    60   Input ~ 0
LED_A
Text GLabel 5650 2950 2    60   Input ~ 0
IO_A_DIR
Text GLabel 5650 3650 2    60   Input ~ 0
IO_A_INTERNAL
Text GLabel 5650 3750 2    60   Input ~ 0
IO_B_DIR
Text GLabel 5650 3050 2    60   Input ~ 0
IO_B_INTERNAL
Text GLabel 2550 5150 2    60   Input ~ 0
16MHZ_IN
$Comp
L Oscillators:ASE-xxxMHz X1
U 1 1 5ABDAC6C
P 7750 5500
F 0 "X1" H 8000 5800 50  0000 L CNN
F 1 "ASDMB" H 8000 5700 50  0000 L CNN
F 2 "Oscillators:Oscillator_SMD_SeikoEpson_SG210-4pin_2.5x2.0mm" H 8450 5150 50  0001 C CNN
F 3 "http://www.abracon.com/Oscillators/ASV.pdf" H 7650 5500 50  0001 C CNN
	1    7750 5500
	1    0    0    -1  
$EndComp
Wire Wire Line
	7450 5500 7400 5500
Wire Wire Line
	7400 5500 7400 5100
Wire Wire Line
	7750 5200 7750 5100
$Comp
L bosonFrameGrabber:GND #PWR055
U 1 1 5ABE1600
P 7750 5900
F 0 "#PWR055" H 7750 5650 50  0001 C CNN
F 1 "GND" H 7753 5774 50  0000 C CNN
F 2 "" H 7650 5550 50  0001 C CNN
F 3 "" H 7750 5900 50  0001 C CNN
	1    7750 5900
	1    0    0    -1  
$EndComp
Wire Wire Line
	7750 5900 7750 5800
Text GLabel 8050 5500 2    60   Input ~ 0
16MHZ_IN
$Comp
L device:R R4
U 1 1 5AC144E9
P 10350 3250
F 0 "R4" H 10420 3296 50  0000 L CNN
F 1 "10k" H 10420 3205 50  0000 L CNN
F 2 "Resistors_SMD:R_0402" V 10280 3250 50  0001 C CNN
F 3 "" H 10350 3250 50  0001 C CNN
F 4 "P10KDECT-ND" H 0   0   50  0001 C CNN "SN-DK"
F 5 "ERA-2AED103X" H 0   0   50  0001 C CNN "PN"
	1    10350 3250
	-1   0    0    -1  
$EndComp
Wire Wire Line
	10550 3500 10350 3500
Wire Wire Line
	10350 3400 10350 3500
Connection ~ 10350 3500
$Comp
L bosonFrameGrabber:+3V3 #PWR059
U 1 1 5AC1A3A6
P 10350 3000
F 0 "#PWR059" H 10350 2850 50  0001 C CNN
F 1 "+3V3" V 10354 3106 50  0000 L CNN
F 2 "" H 10350 3000 50  0001 C CNN
F 3 "" H 10350 3000 50  0001 C CNN
	1    10350 3000
	-1   0    0    -1  
$EndComp
Wire Wire Line
	10350 3100 10350 3000
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 1 1 5B09968A
P 2550 1100
F 0 "U3" H 3400 1250 60  0000 L CNN
F 1 "ECP5U25" H 2750 1250 60  0000 L CNN
F 2 "" H 2550 1100 50  0001 C CNN
F 3 "" H 2550 1100 50  0001 C CNN
	1    2550 1100
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 2 1 5B09970F
P 2550 2200
F 0 "U3" H 3400 2350 60  0000 L CNN
F 1 "ECP5U25" H 2750 2350 60  0000 L CNN
F 2 "" H 2550 2200 50  0001 C CNN
F 3 "" H 2550 2200 50  0001 C CNN
	2    2550 2200
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 3 1 5B099786
P 2550 3250
F 0 "U3" H 3450 3400 60  0000 L CNN
F 1 "ECP5U25" H 2750 3400 60  0000 L CNN
F 2 "" H 2550 3250 50  0001 C CNN
F 3 "" H 2550 3250 50  0001 C CNN
	3    2550 3250
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 4 1 5B0997FD
P 5650 1250
F 0 "U3" H 6750 1450 60  0000 L CNN
F 1 "ECP5U25" H 5850 1450 60  0000 L CNN
F 2 "" H 5650 1250 50  0001 C CNN
F 3 "" H 5650 1250 50  0001 C CNN
	4    5650 1250
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 5 1 5B099856
P 5650 4950
F 0 "U3" H 6750 5150 60  0000 L CNN
F 1 "ECP5U25" H 5850 5150 60  0000 L CNN
F 2 "" H 5650 4950 50  0001 C CNN
F 3 "" H 5650 4950 50  0001 C CNN
	5    5650 4950
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 6 1 5B0998E9
P 2550 5750
F 0 "U3" H 3500 5900 60  0000 L CNN
F 1 "ECP5U25" H 2750 5900 60  0000 L CNN
F 2 "" H 2550 5750 50  0001 C CNN
F 3 "" H 2550 5750 50  0001 C CNN
	6    2550 5750
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 7 1 5B099944
P 9250 1250
F 0 "U3" H 10850 1450 60  0000 L CNN
F 1 "ECP5U25" H 9450 1450 60  0000 L CNN
F 2 "" H 9250 1250 50  0001 C CNN
F 3 "" H 9250 1250 50  0001 C CNN
	7    9250 1250
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 8 1 5B0999B9
P 9250 2900
F 0 "U3" H 10050 3100 60  0000 L CNN
F 1 "ECP5U25" H 9450 3100 60  0000 L CNN
F 2 "" H 9250 2900 50  0001 C CNN
F 3 "" H 9250 2900 50  0001 C CNN
	8    9250 2900
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 9 1 5B099A65
P 9850 5900
F 0 "U3" H 10245 4710 60  0000 C CNN
F 1 "ECP5U25" H 10245 4816 60  0000 C CNN
F 2 "" H 9850 5900 50  0001 C CNN
F 3 "" H 9850 5900 50  0001 C CNN
	9    9850 5900
	1    0    0    1   
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR0101
U 1 1 5B0ACE72
P 9750 6000
F 0 "#PWR0101" H 9750 5750 50  0001 C CNN
F 1 "GND" H 9753 5874 50  0000 C CNN
F 2 "" H 9650 5650 50  0001 C CNN
F 3 "" H 9750 6000 50  0001 C CNN
	1    9750 6000
	1    0    0    -1  
$EndComp
Wire Wire Line
	9750 6000 9750 5900
Wire Wire Line
	9750 5900 9850 5900
Text GLabel 5650 2550 2    60   Input ~ 0
HYPERBUS_RWDS
Text Notes 4650 900  0    80   ~ 0
BANK 3
Text Notes 4800 1000 0    50   ~ 0
1V8
NoConn ~ 5650 1250
NoConn ~ 5650 1650
NoConn ~ 5650 1750
NoConn ~ 5650 1850
NoConn ~ 5650 1950
NoConn ~ 5650 2450
NoConn ~ 5650 2750
NoConn ~ 5650 3150
NoConn ~ 5650 3450
$Comp
L bosonFrameGrabber:+1V8 #PWR0102
U 1 1 5B1008C8
P 9300 4900
F 0 "#PWR0102" H 9300 4750 50  0001 C CNN
F 1 "+1V8" V 9304 5006 50  0000 L CNN
F 2 "" H 9300 4900 50  0001 C CNN
F 3 "" H 9300 4900 50  0001 C CNN
	1    9300 4900
	1    0    0    -1  
$EndComp
Wire Wire Line
	9850 5400 9300 5400
Wire Wire Line
	9300 5400 9300 5200
Wire Wire Line
	9550 5800 9850 5800
Wire Wire Line
	9850 5100 9500 5100
Wire Wire Line
	9500 4900 9500 5100
$Comp
L bosonFrameGrabber:+1V1 #PWR0103
U 1 1 5B11CCCB
P 9700 4900
F 0 "#PWR0103" H 9700 4750 50  0001 C CNN
F 1 "+1V1" H 9703 5051 50  0000 C CNN
F 2 "" H 9700 4900 50  0001 C CNN
F 3 "" H 9700 4900 50  0001 C CNN
	1    9700 4900
	1    0    0    -1  
$EndComp
Wire Wire Line
	9700 4900 9700 5000
Wire Wire Line
	9700 5000 9850 5000
$Comp
L bosonFrameGrabber:GND #PWR0104
U 1 1 5B1207AF
P 9350 4350
F 0 "#PWR0104" H 9350 4100 50  0001 C CNN
F 1 "GND" H 9353 4224 50  0000 C CNN
F 2 "" H 9250 4000 50  0001 C CNN
F 3 "" H 9350 4350 50  0001 C CNN
	1    9350 4350
	1    0    0    -1  
$EndComp
Wire Wire Line
	9250 3200 9350 3200
Wire Wire Line
	9350 3200 9350 4350
Wire Wire Line
	9250 3000 9350 3000
Wire Wire Line
	9350 3000 9350 3200
Connection ~ 9350 3200
Text GLabel 2550 6950 2    60   Input ~ 0
BOSON_EXTSYNC
Wire Wire Line
	9250 3500 10350 3500
Wire Wire Line
	9250 3300 9450 3300
$Comp
L bosonFrameGrabber:+1V8 #PWR0105
U 1 1 5B19EB6D
P 7400 5100
F 0 "#PWR0105" H 7400 4950 50  0001 C CNN
F 1 "+1V8" V 7404 5206 50  0000 L CNN
F 2 "" H 7400 5100 50  0001 C CNN
F 3 "" H 7400 5100 50  0001 C CNN
	1    7400 5100
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:+1V8 #PWR0106
U 1 1 5B19EBA8
P 7750 5100
F 0 "#PWR0106" H 7750 4950 50  0001 C CNN
F 1 "+1V8" V 7754 5206 50  0000 L CNN
F 2 "" H 7750 5100 50  0001 C CNN
F 3 "" H 7750 5100 50  0001 C CNN
	1    7750 5100
	1    0    0    -1  
$EndComp
Text Notes 1700 5550 0    80   ~ 0
BANK 2
Text Notes 1700 3050 0    80   ~ 0
BANK 7
Text Notes 1750 2000 0    80   ~ 0
BANK 1
Text Notes 1750 900  0    80   ~ 0
BANK 0
Text Notes 4700 4600 0    80   ~ 0
BANK 6
Text Notes 8050 900  0    80   ~ 0
BANK 8
Wire Wire Line
	9850 5300 9500 5300
Wire Wire Line
	9500 5300 9500 5100
Connection ~ 9500 5100
Wire Wire Line
	9850 5700 9300 5700
Connection ~ 9300 5400
Wire Wire Line
	9850 5600 9300 5600
Wire Wire Line
	9300 5400 9300 5500
Connection ~ 9300 5600
Wire Wire Line
	9300 5600 9300 5700
Wire Wire Line
	9850 5500 9300 5500
Connection ~ 9300 5500
Wire Wire Line
	9300 5500 9300 5600
Wire Wire Line
	9850 5200 9300 5200
Wire Wire Line
	9300 5200 9300 4900
Connection ~ 9300 5200
$Comp
L bosonFrameGrabber:+3V3 #PWR0107
U 1 1 5B1B6FEA
P 9450 3100
F 0 "#PWR0107" H 9450 2950 50  0001 C CNN
F 1 "+3V3" V 9454 3206 50  0000 L CNN
F 2 "" H 9450 3100 50  0001 C CNN
F 3 "" H 9450 3100 50  0001 C CNN
	1    9450 3100
	0    1    -1   0   
$EndComp
Wire Wire Line
	9450 3100 9250 3100
Text Notes 8200 1000 0    50   ~ 0
3V3
Text Notes 7850 700  0    100  ~ 0
QSPI Config
Text Notes 4550 700  0    100  ~ 0
HyperBus
Text Notes 4850 4700 0    50   ~ 0
3V3
Text Notes 4650 4450 0    100  ~ 0
SDMMC
Text Notes 1500 700  0    100  ~ 0
16bit Camera IF
Text Notes 2250 900  0    50   ~ 0
1V8
Text Notes 2250 2000 0    50   ~ 0
1V8
Text Notes 2250 3050 0    50   ~ 0
1V8
Text Notes 2250 5550 0    50   ~ 0
1V8
Text GLabel 9250 2350 2    60   Input ~ 0
FPGA_RESET
Text GLabel 9500 3900 2    60   Input ~ 0
JTAG_TMS
Text GLabel 9500 3800 2    60   Input ~ 0
JTAG_TDO
Text GLabel 9500 3700 2    60   Input ~ 0
JTAG_TDI
Text GLabel 9500 3600 2    60   Input ~ 0
JTAG_TCK
Wire Wire Line
	9500 3900 9250 3900
Wire Wire Line
	9250 3800 9500 3800
Wire Wire Line
	9500 3700 9250 3700
Wire Wire Line
	9250 3600 9500 3600
NoConn ~ 9250 4000
NoConn ~ 9250 4100
NoConn ~ 9250 4200
NoConn ~ 9250 4300
$EndSCHEMATC
