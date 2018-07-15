EESchema Schematic File Version 4
LIBS:bosonFrameGrabber-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 7
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 9150 2900 2    60   Input ~ 0
FPGA_CDONE
Text GLabel 1900 1050 2    60   Input ~ 0
SD_DAT0
Text GLabel 1900 950  2    60   Input ~ 0
SD_DAT1
Text GLabel 1900 1750 2    60   Input ~ 0
SD_DAT2
Text GLabel 1900 1550 2    60   Input ~ 0
SD_DAT3
Text GLabel 1900 1450 2    60   Input ~ 0
SD_CMD
Text GLabel 1900 1150 2    60   Input ~ 0
SD_CK
Text GLabel 1900 1950 2    60   Input ~ 0
SD_CD
Text GLabel 3850 3950 2    60   Input ~ 0
HYPERBUS_CS#
Text GLabel 3850 2350 2    60   Input ~ 0
HYPERBUS_RESET#
Text GLabel 3850 2250 2    60   Input ~ 0
HYPERBUS_CK
Text GLabel 3850 2150 2    60   Input ~ 0
HYPERBUS_CK#
Text GLabel 3850 1550 2    60   Input ~ 0
HYPERBUS_DQ0
Text GLabel 3850 1650 2    60   Input ~ 0
HYPERBUS_DQ1
Text GLabel 3850 2050 2    60   Input ~ 0
HYPERBUS_DQ2
Text GLabel 3850 1150 2    60   Input ~ 0
HYPERBUS_DQ3
Text GLabel 3850 1050 2    60   Input ~ 0
HYPERBUS_DQ4
Text GLabel 3850 950  2    60   Input ~ 0
HYPERBUS_DQ5
Text GLabel 3850 850  2    60   Input ~ 0
HYPERBUS_DQ6
Text GLabel 3850 1450 2    60   Input ~ 0
HYPERBUS_DQ7
Text GLabel 1900 4650 2    60   Input ~ 0
BOSON_DATA0
Text GLabel 1900 4950 2    60   Input ~ 0
BOSON_DATA1
Text GLabel 1900 6250 2    60   Input ~ 0
BOSON_DATA2
Text GLabel 1900 6650 2    60   Input ~ 0
BOSON_DATA3
Text GLabel 1900 7150 2    60   Input ~ 0
BOSON_DATA4
Text GLabel 1900 5150 2    60   Input ~ 0
BOSON_DATA5
Text GLabel 1900 6550 2    60   Input ~ 0
BOSON_DATA6
Text GLabel 1900 5550 2    60   Input ~ 0
BOSON_DATA7
Text GLabel 1900 7450 2    60   Input ~ 0
BOSON_DATA8
Text GLabel 1900 5650 2    60   Input ~ 0
BOSON_DATA9
Text GLabel 1900 6050 2    60   Input ~ 0
BOSON_DATA10
Text GLabel 1900 5850 2    60   Input ~ 0
BOSON_DATA11
Text GLabel 1900 5250 2    60   Input ~ 0
BOSON_DATA12
Text GLabel 1900 6450 2    60   Input ~ 0
BOSON_DATA13
Text GLabel 1900 7250 2    60   Input ~ 0
BOSON_DATA14
Text GLabel 1900 5350 2    60   Input ~ 0
BOSON_DATA15
Text GLabel 1900 5050 2    60   Input ~ 0
BOSON_DATA_EN
Text GLabel 1900 7350 2    60   Input ~ 0
BOSON_CK
Text GLabel 1900 6750 2    60   Input ~ 0
BOSON_VSYNC
Text GLabel 1900 4550 2    60   Input ~ 0
BOSON_HSYNC
Text GLabel 1900 4450 2    60   Input ~ 0
BOSON_RXD
Text GLabel 1900 6150 2    60   Input ~ 0
BOSON_TXD
Text GLabel 1900 4350 2    60   Input ~ 0
BOSON_RESET
Text GLabel 9150 2100 2    60   Input ~ 0
SPI_CONFIG_SS
Text GLabel 9150 2700 2    60   Input ~ 0
SPI_CONFIG_SCK
Text GLabel 9150 1900 2    60   Input ~ 0
SPI_CONFIG_MISO
Text GLabel 9150 2000 2    60   Input ~ 0
SPI_CONFIG_MOSI
$Comp
L bosonFrameGrabber:+2V5 #PWR051
U 1 1 5AC13A0C
P 9650 5400
F 0 "#PWR051" H 9650 5250 50  0001 C CNN
F 1 "+2V5" V 9654 5506 50  0000 L CNN
F 2 "" H 9650 5400 50  0001 C CNN
F 3 "" H 9650 5400 50  0001 C CNN
	1    9650 5400
	0    -1   -1   0   
$EndComp
Text GLabel 9150 1800 2    60   Input ~ 0
QSPI_D2
Text GLabel 9150 1700 2    60   Input ~ 0
QSPI_D3
Text GLabel 10450 2800 2    60   Input ~ 0
FPGA_RESET
Text GLabel 6250 3450 2    60   Input ~ 0
LED_A
Text GLabel 6250 3750 2    60   Input ~ 0
IO_A_DIR
Text GLabel 6250 3550 2    60   Input ~ 0
IO_A_INTERNAL
Text GLabel 6250 3850 2    60   Input ~ 0
IO_B_DIR
Text GLabel 6250 3650 2    60   Input ~ 0
IO_B_INTERNAL
Text GLabel 6250 7400 2    60   Input ~ 0
16MHZ_IN
$Comp
L Oscillators:ASE-xxxMHz X1
U 1 1 5ABDAC6C
P 8400 5850
F 0 "X1" H 8650 6150 50  0000 L CNN
F 1 "ASDMB" H 8650 6050 50  0000 L CNN
F 2 "Oscillators:Oscillator_SMD_SeikoEpson_SG210-4pin_2.5x2.0mm" H 9100 5500 50  0001 C CNN
F 3 "http://www.abracon.com/Oscillators/ASV.pdf" H 8300 5850 50  0001 C CNN
F 4 " 1473-30509-1-ND " H 0   0   50  0001 C CNN "SN-DK"
F 5 " SIT8008BI-71-18E-24.000000G " H 0   0   50  0001 C CNN "PN"
	1    8400 5850
	1    0    0    -1  
$EndComp
Wire Wire Line
	8100 5850 8050 5850
Wire Wire Line
	8050 5850 8050 5450
Wire Wire Line
	8400 5550 8400 5450
$Comp
L bosonFrameGrabber:GND #PWR055
U 1 1 5ABE1600
P 8400 6250
F 0 "#PWR055" H 8400 6000 50  0001 C CNN
F 1 "GND" H 8403 6124 50  0000 C CNN
F 2 "" H 8300 5900 50  0001 C CNN
F 3 "" H 8400 6250 50  0001 C CNN
	1    8400 6250
	1    0    0    -1  
$EndComp
Wire Wire Line
	8400 6250 8400 6150
Text GLabel 8700 5850 2    60   Input ~ 0
16MHZ_IN
$Comp
L device:R R4
U 1 1 5AC144E9
P 10250 2550
F 0 "R4" H 10320 2596 50  0000 L CNN
F 1 "10k" H 10320 2505 50  0000 L CNN
F 2 "Resistors_SMD:R_0402" V 10180 2550 50  0001 C CNN
F 3 "" H 10250 2550 50  0001 C CNN
F 4 "P10KDECT-ND" H 0   0   50  0001 C CNN "SN-DK"
F 5 "ERA-2AED103X" H 0   0   50  0001 C CNN "PN"
	1    10250 2550
	-1   0    0    -1  
$EndComp
Wire Wire Line
	10450 2800 10250 2800
Wire Wire Line
	10250 2700 10250 2800
Connection ~ 10250 2800
$Comp
L bosonFrameGrabber:+3V3 #PWR059
U 1 1 5AC1A3A6
P 10250 2300
F 0 "#PWR059" H 10250 2150 50  0001 C CNN
F 1 "+3V3" V 10254 2406 50  0000 L CNN
F 2 "" H 10250 2300 50  0001 C CNN
F 3 "" H 10250 2300 50  0001 C CNN
	1    10250 2300
	-1   0    0    -1  
$EndComp
Wire Wire Line
	10250 2400 10250 2300
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 1 1 5B09968A
P 1900 850
F 0 "U3" H 2750 1000 60  0000 L CNN
F 1 "ECP5U25" H 2100 1000 60  0000 L CNN
F 2 "" H 1900 850 50  0001 C CNN
F 3 "" H 1900 850 50  0001 C CNN
F 4 " 220-2052-ND " H 0   0   50  0001 C CNN "SN-DK"
F 5 " LFE5U-25F-6BG381I " H 0   0   50  0001 C CNN "PN"
F 6 "Lattice" H 0   0   50  0001 C CNN "Mfg"
	1    1900 850 
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 2 1 5B09970F
P 1900 4350
F 0 "U3" H 2750 4500 60  0000 L CNN
F 1 "ECP5U25" H 2100 4500 60  0000 L CNN
F 2 "" H 1900 4350 50  0001 C CNN
F 3 "" H 1900 4350 50  0001 C CNN
F 4 " 220-2052-ND " H 0   0   50  0001 C CNN "SN-DK"
F 5 " LFE5U-25F-6BG381I " H 0   0   50  0001 C CNN "PN"
F 6 "Lattice" H 0   0   50  0001 C CNN "Mfg"
	2    1900 4350
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 3 1 5B099786
P 3850 850
F 0 "U3" H 4750 1000 60  0000 L CNN
F 1 "ECP5U25" H 4050 1000 60  0000 L CNN
F 2 "" H 3850 850 50  0001 C CNN
F 3 "" H 3850 850 50  0001 C CNN
F 4 " 220-2052-ND " H 0   0   50  0001 C CNN "SN-DK"
F 5 " LFE5U-25F-6BG381I " H 0   0   50  0001 C CNN "PN"
F 6 "Lattice" H 0   0   50  0001 C CNN "Mfg"
	3    3850 850 
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 4 1 5B0997FD
P 6250 4400
F 0 "U3" H 7350 4600 60  0000 L CNN
F 1 "ECP5U25" H 6450 4600 60  0000 L CNN
F 2 "" H 6250 4400 50  0001 C CNN
F 3 "" H 6250 4400 50  0001 C CNN
F 4 " 220-2052-ND " H 0   0   50  0001 C CNN "SN-DK"
F 5 " LFE5U-25F-6BG381I " H 0   0   50  0001 C CNN "PN"
F 6 "Lattice" H 0   0   50  0001 C CNN "Mfg"
	4    6250 4400
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 5 1 5B099856
P 6250 850
F 0 "U3" H 7350 1050 60  0000 L CNN
F 1 "ECP5U25" H 6450 1050 60  0000 L CNN
F 2 "" H 6250 850 50  0001 C CNN
F 3 "" H 6250 850 50  0001 C CNN
F 4 " 220-2052-ND " H 0   0   50  0001 C CNN "SN-DK"
F 5 " LFE5U-25F-6BG381I " H 0   0   50  0001 C CNN "PN"
F 6 "Lattice" H 0   0   50  0001 C CNN "Mfg"
	5    6250 850 
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 6 1 5B0998E9
P 3850 4400
F 0 "U3" H 4800 4550 60  0000 L CNN
F 1 "ECP5U25" H 4050 4550 60  0000 L CNN
F 2 "" H 3850 4400 50  0001 C CNN
F 3 "" H 3850 4400 50  0001 C CNN
F 4 " 220-2052-ND " H 0   0   50  0001 C CNN "SN-DK"
F 5 " LFE5U-25F-6BG381I " H 0   0   50  0001 C CNN "PN"
F 6 "Lattice" H 0   0   50  0001 C CNN "Mfg"
	6    3850 4400
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 7 1 5B099944
P 9150 1300
F 0 "U3" H 10750 1500 60  0000 L CNN
F 1 "ECP5U25" H 9350 1500 60  0000 L CNN
F 2 "" H 9150 1300 50  0001 C CNN
F 3 "" H 9150 1300 50  0001 C CNN
F 4 " 220-2052-ND " H 0   0   50  0001 C CNN "SN-DK"
F 5 " LFE5U-25F-6BG381I " H 0   0   50  0001 C CNN "PN"
F 6 "Lattice" H 0   0   50  0001 C CNN "Mfg"
	7    9150 1300
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ECP5U25 U3
U 8 1 5B0999B9
P 9850 5600
F 0 "U3" H 10650 5800 60  0000 L CNN
F 1 "ECP5U25" H 10050 5800 60  0000 L CNN
F 2 "" H 9850 5600 50  0001 C CNN
F 3 "" H 9850 5600 50  0001 C CNN
F 4 " 220-2052-ND " H 0   0   50  0001 C CNN "SN-DK"
F 5 " LFE5U-25F-6BG381I " H 0   0   50  0001 C CNN "PN"
F 6 "Lattice" H 0   0   50  0001 C CNN "Mfg"
	8    9850 5600
	1    0    0    1   
$EndComp
Text GLabel 3850 1850 2    60   Input ~ 0
HYPERBUS_RWDS
$Comp
L bosonFrameGrabber:GND #PWR0104
U 1 1 5B1207AF
P 9250 4350
F 0 "#PWR0104" H 9250 4100 50  0001 C CNN
F 1 "GND" H 9253 4224 50  0000 C CNN
F 2 "" H 9150 4000 50  0001 C CNN
F 3 "" H 9250 4350 50  0001 C CNN
	1    9250 4350
	1    0    0    -1  
$EndComp
Wire Wire Line
	9150 3200 9250 3200
Wire Wire Line
	9250 3200 9250 4350
Wire Wire Line
	9150 3000 9250 3000
Wire Wire Line
	9250 3000 9250 3200
Connection ~ 9250 3200
Text GLabel 1900 4750 2    60   Input ~ 0
BOSON_EXTSYNC
Wire Wire Line
	9150 2800 10250 2800
$Comp
L bosonFrameGrabber:+1V8 #PWR0105
U 1 1 5B19EB6D
P 8050 5450
F 0 "#PWR0105" H 8050 5300 50  0001 C CNN
F 1 "+1V8" V 8054 5556 50  0000 L CNN
F 2 "" H 8050 5450 50  0001 C CNN
F 3 "" H 8050 5450 50  0001 C CNN
	1    8050 5450
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:+1V8 #PWR0106
U 1 1 5B19EBA8
P 8400 5450
F 0 "#PWR0106" H 8400 5300 50  0001 C CNN
F 1 "+1V8" V 8404 5556 50  0000 L CNN
F 2 "" H 8400 5450 50  0001 C CNN
F 3 "" H 8400 5450 50  0001 C CNN
	1    8400 5450
	1    0    0    -1  
$EndComp
Text Notes 8050 900  0    80   ~ 0
BANK 8
$Comp
L bosonFrameGrabber:+3V3 #PWR0107
U 1 1 5B1B6FEA
P 9350 3100
F 0 "#PWR0107" H 9350 2950 50  0001 C CNN
F 1 "+3V3" V 9354 3206 50  0000 L CNN
F 2 "" H 9350 3100 50  0001 C CNN
F 3 "" H 9350 3100 50  0001 C CNN
	1    9350 3100
	0    1    -1   0   
$EndComp
Wire Wire Line
	9350 3100 9150 3100
Text Notes 8200 1000 0    50   ~ 0
3V3
Text Notes 7850 700  0    100  ~ 0
QSPI Config
Text Notes 2700 2800 1    100  ~ 0
HyperBus
Text Notes 750  2250 1    100  ~ 0
SDMMC
Text Notes 750  6400 1    100  ~ 0
16bit Camera IF
Text GLabel 9150 2200 2    60   Input ~ 0
FPGA_RESET
Text GLabel 9350 3600 2    60   Input ~ 0
JTAG_TMS
Text GLabel 9350 3300 2    60   Input ~ 0
JTAG_TDO
Text GLabel 9350 3500 2    60   Input ~ 0
JTAG_TDI
Text GLabel 9350 3400 2    60   Input ~ 0
JTAG_TCK
Wire Wire Line
	9150 3300 9350 3300
Wire Wire Line
	9350 3400 9150 3400
Wire Wire Line
	9150 3500 9350 3500
Wire Wire Line
	9350 3600 9150 3600
$Comp
L bosonFrameGrabber:GND #PWR0119
U 1 1 5B1085E7
P 9750 5700
F 0 "#PWR0119" H 9750 5450 50  0001 C CNN
F 1 "GND" H 9753 5574 50  0000 C CNN
F 2 "" H 9650 5350 50  0001 C CNN
F 3 "" H 9750 5700 50  0001 C CNN
	1    9750 5700
	1    0    0    -1  
$EndComp
Wire Wire Line
	9750 5700 9750 5600
Wire Wire Line
	9750 5600 9850 5600
$Comp
L bosonFrameGrabber:+1V1 #PWR0120
U 1 1 5B108EEB
P 9550 5500
F 0 "#PWR0120" H 9550 5350 50  0001 C CNN
F 1 "+1V1" V 9550 5700 50  0000 C CNN
F 2 "" H 9550 5500 50  0001 C CNN
F 3 "" H 9550 5500 50  0001 C CNN
	1    9550 5500
	0    -1   -1   0   
$EndComp
Wire Wire Line
	9550 5500 9850 5500
Wire Wire Line
	9650 5400 9850 5400
Text GLabel 6250 1050 2    63   Input ~ 0
CLKN
Text GLabel 6250 850  2    63   Input ~ 0
CLKP
Text GLabel 6250 2350 2    63   Input ~ 0
CLKN_BIAS
Text GLabel 6250 1450 2    63   Input ~ 0
CLKP_BIAS
Text GLabel 6250 1850 2    63   Input ~ 0
DATAN
Text GLabel 6250 1650 2    63   Input ~ 0
DATAP
Text GLabel 6250 2450 2    63   Input ~ 0
DATAN_BIAS
Text GLabel 6250 2150 2    63   Input ~ 0
DATAP_BIAS
Text GLabel 6250 3150 2    63   Input ~ 0
LCD_SYNC
Text GLabel 6250 3350 2    63   Input ~ 0
LCD_RESET
Text Notes 800  650  0    50   ~ 0
BANK0 - 3V3
$Comp
L bosonFrameGrabber:+3V3 #PWR0123
U 1 1 5B168282
P 9350 5300
F 0 "#PWR0123" H 9350 5150 50  0001 C CNN
F 1 "+3V3" V 9354 5406 50  0000 L CNN
F 2 "" H 9350 5300 50  0001 C CNN
F 3 "" H 9350 5300 50  0001 C CNN
	1    9350 5300
	0    -1   1    0   
$EndComp
Wire Wire Line
	9350 5300 9850 5300
$Comp
L bosonFrameGrabber:+1V8 #PWR0124
U 1 1 5B168CFE
P 9650 5100
F 0 "#PWR0124" H 9650 4950 50  0001 C CNN
F 1 "+1V8" V 9654 5206 50  0000 L CNN
F 2 "" H 9650 5100 50  0001 C CNN
F 3 "" H 9650 5100 50  0001 C CNN
	1    9650 5100
	0    -1   -1   0   
$EndComp
Wire Wire Line
	9850 5200 9750 5200
Wire Wire Line
	9750 5200 9750 5100
Wire Wire Line
	9750 5000 9850 5000
Wire Wire Line
	9850 5100 9750 5100
Connection ~ 9750 5100
Wire Wire Line
	9750 5100 9750 5000
Wire Wire Line
	9650 5100 9750 5100
$Comp
L bosonFrameGrabber:+3V3 #PWR0125
U 1 1 5B16B067
P 9350 4900
F 0 "#PWR0125" H 9350 4750 50  0001 C CNN
F 1 "+3V3" V 9354 5006 50  0000 L CNN
F 2 "" H 9350 4900 50  0001 C CNN
F 3 "" H 9350 4900 50  0001 C CNN
	1    9350 4900
	0    -1   1    0   
$EndComp
Wire Wire Line
	9350 4900 9850 4900
$Comp
L bosonFrameGrabber:+1V8 #PWR0126
U 1 1 5B16BD99
P 9650 4700
F 0 "#PWR0126" H 9650 4550 50  0001 C CNN
F 1 "+1V8" V 9654 4806 50  0000 L CNN
F 2 "" H 9650 4700 50  0001 C CNN
F 3 "" H 9650 4700 50  0001 C CNN
	1    9650 4700
	0    -1   -1   0   
$EndComp
Wire Wire Line
	9850 4700 9750 4700
Wire Wire Line
	9850 4800 9750 4800
Wire Wire Line
	9750 4800 9750 4700
Connection ~ 9750 4700
Wire Wire Line
	9750 4700 9650 4700
Text GLabel 3850 6200 2    63   Input ~ 0
LCD_LED_EN
Text GLabel 6250 5500 2    60   Input ~ 0
BUTTON_A
Text GLabel 6250 5600 2    60   Input ~ 0
BUTTON_B
Text GLabel 6250 5700 2    60   Input ~ 0
BUTTON_C
Text Notes 850  4150 0    50   ~ 0
BANK1 - 1V8
Text Notes 2800 4200 0    50   ~ 0
BANK7 - 1V8
Text Notes 2800 650  0    50   ~ 0
BANK2 - 1V8
Text Notes 5000 600  0    50   ~ 0
BANK6 - 1V8
Text Notes 5000 4150 0    50   ~ 0
BANK3 - 1V8
$EndSCHEMATC
