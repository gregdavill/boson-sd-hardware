EESchema Schematic File Version 4
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
$Comp
L bosonFrameGrabber:ICE40HX8K U3
U 1 1 5AB8AD0D
P 10100 2100
F 0 "U3" H 10000 3050 60  0000 L CNN
F 1 "ICE40HX8K" H 9800 2950 60  0000 L CNN
F 2 "bosonFrameGrabber:csBGA_132" H 10100 2900 60  0001 C CNN
F 3 "" H 10100 2900 60  0001 C CNN
	1    10100 2100
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ICE40HX8K U3
U 2 1 5AB8AD3E
P 1800 2250
F 0 "U3" H 1700 3200 60  0000 L CNN
F 1 "ICE40HX8K" H 1550 3100 60  0000 L CNN
F 2 "bosonFrameGrabber:csBGA_132" H 1800 3050 60  0001 C CNN
F 3 "" H 1800 3050 60  0001 C CNN
	2    1800 2250
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ICE40HX8K U3
U 3 1 5AB8AD69
P 4950 2250
F 0 "U3" H 4850 3200 60  0000 L CNN
F 1 "ICE40HX8K" H 4700 3100 60  0000 L CNN
F 2 "bosonFrameGrabber:csBGA_132" H 4950 3050 60  0001 C CNN
F 3 "" H 4950 3050 60  0001 C CNN
	3    4950 2250
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ICE40HX8K U3
U 4 1 5AB8AD90
P 1800 5650
F 0 "U3" H 1700 6600 60  0000 L CNN
F 1 "ICE40HX8K" H 1550 6500 60  0000 L CNN
F 2 "bosonFrameGrabber:csBGA_132" H 1800 6450 60  0001 C CNN
F 3 "" H 1800 6450 60  0001 C CNN
	4    1800 5650
	-1   0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:ICE40HX8K U3
U 5 1 5AB8ADB9
P 4950 5650
F 0 "U3" H 4900 6600 60  0000 L CNN
F 1 "ICE40HX8K" H 4700 6500 60  0000 L CNN
F 2 "bosonFrameGrabber:csBGA_132" H 4950 6450 60  0001 C CNN
F 3 "" H 4950 6450 60  0001 C CNN
	5    4950 5650
	-1   0    0    -1  
$EndComp
Text Notes 2500 1350 0    60   ~ 0
Top Bank (0): \n  VDD: 1.8V\n  HYPERBUS
Text Notes 2500 4850 0    60   ~ 0
Bottom Bank (2):\n  VDD: 3V3\n  USER I/O \n  Debug and SPI Config
Text Notes 5700 4850 0    60   ~ 0
Left Bank (3):\n  VDD: 3v3\n  sdmmc
Text Notes 5700 1450 0    60   ~ 0
Right Bank (1):\n  VDD 1V8:\n  BOSON
$Comp
L bosonFrameGrabber:+3V3 #PWR018
U 1 1 5AB972DE
P 7200 2050
F 0 "#PWR018" H 7200 1900 50  0001 C CNN
F 1 "+3V3" V 7204 2156 50  0000 L CNN
F 2 "" H 7200 2050 50  0001 C CNN
F 3 "" H 7200 2050 50  0001 C CNN
	1    7200 2050
	0    -1   -1   0   
$EndComp
$Comp
L bosonFrameGrabber:+1V8 #PWR019
U 1 1 5AB97303
P 7200 1650
F 0 "#PWR019" H 7200 1500 50  0001 C CNN
F 1 "+1V8" V 7204 1756 50  0000 L CNN
F 2 "" H 7200 1650 50  0001 C CNN
F 3 "" H 7200 1650 50  0001 C CNN
	1    7200 1650
	0    -1   -1   0   
$EndComp
$Comp
L bosonFrameGrabber:+1V2 #PWR020
U 1 1 5AB97328
P 8500 3750
F 0 "#PWR020" H 8500 3600 50  0001 C CNN
F 1 "+1V2" V 8504 3856 50  0000 L CNN
F 2 "" H 8500 3750 50  0001 C CNN
F 3 "" H 8500 3750 50  0001 C CNN
	1    8500 3750
	0    -1   -1   0   
$EndComp
Text GLabel 9450 3450 0    60   Input ~ 0
FPGA_CDONE
NoConn ~ 9450 3150
$Comp
L device:C_Small C20
U 1 1 5AB973B5
P 9050 2350
F 0 "C20" H 9075 2425 30  0000 L CNN
F 1 "100n" H 9075 2275 30  0000 L CNN
F 2 "Capacitors_SMD:C_0402" H 9050 2350 50  0001 C CNN
F 3 "" H 9050 2350 50  0001 C CNN
	1    9050 2350
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small C16
U 1 1 5AB9771D
P 8800 2350
F 0 "C16" H 8825 2425 30  0000 L CNN
F 1 "100n" H 8825 2275 30  0000 L CNN
F 2 "Capacitors_SMD:C_0402" H 8800 2350 50  0001 C CNN
F 3 "" H 8800 2350 50  0001 C CNN
	1    8800 2350
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR021
U 1 1 5AB9774A
P 9050 2500
F 0 "#PWR021" H 9050 2250 50  0001 C CNN
F 1 "GND" H 9053 2374 50  0000 C CNN
F 2 "" H 8950 2150 50  0001 C CNN
F 3 "" H 9050 2500 50  0001 C CNN
	1    9050 2500
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR023
U 1 1 5AB9780D
P 8800 2500
F 0 "#PWR023" H 8800 2250 50  0001 C CNN
F 1 "GND" H 8803 2374 50  0000 C CNN
F 2 "" H 8700 2150 50  0001 C CNN
F 3 "" H 8800 2500 50  0001 C CNN
	1    8800 2500
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small C14
U 1 1 5AB97968
P 8400 2350
F 0 "C14" H 8425 2425 30  0000 L CNN
F 1 "100n" H 8425 2275 30  0000 L CNN
F 2 "Capacitors_SMD:C_0402" H 8400 2350 50  0001 C CNN
F 3 "" H 8400 2350 50  0001 C CNN
	1    8400 2350
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR024
U 1 1 5AB9796E
P 8400 2500
F 0 "#PWR024" H 8400 2250 50  0001 C CNN
F 1 "GND" H 8403 2374 50  0000 C CNN
F 2 "" H 8300 2150 50  0001 C CNN
F 3 "" H 8400 2500 50  0001 C CNN
	1    8400 2500
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small C12
U 1 1 5AB97999
P 8200 2350
F 0 "C12" H 8225 2425 30  0000 L CNN
F 1 "100n" H 8225 2275 30  0000 L CNN
F 2 "Capacitors_SMD:C_0402" H 8200 2350 50  0001 C CNN
F 3 "" H 8200 2350 50  0001 C CNN
	1    8200 2350
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR025
U 1 1 5AB9799F
P 8200 2500
F 0 "#PWR025" H 8200 2250 50  0001 C CNN
F 1 "GND" H 8203 2374 50  0000 C CNN
F 2 "" H 8100 2150 50  0001 C CNN
F 3 "" H 8200 2500 50  0001 C CNN
	1    8200 2500
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small C11
U 1 1 5AB981AD
P 7950 2350
F 0 "C11" H 7975 2425 30  0000 L CNN
F 1 "100n" H 7975 2275 30  0000 L CNN
F 2 "Capacitors_SMD:C_0402" H 7950 2350 50  0001 C CNN
F 3 "" H 7950 2350 50  0001 C CNN
	1    7950 2350
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR026
U 1 1 5AB981B3
P 7950 2500
F 0 "#PWR026" H 7950 2250 50  0001 C CNN
F 1 "GND" H 7953 2374 50  0000 C CNN
F 2 "" H 7850 2150 50  0001 C CNN
F 3 "" H 7950 2500 50  0001 C CNN
	1    7950 2500
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small C10
U 1 1 5AB981BA
P 7750 2350
F 0 "C10" H 7775 2425 30  0000 L CNN
F 1 "100n" H 7775 2275 30  0000 L CNN
F 2 "Capacitors_SMD:C_0402" H 7750 2350 50  0001 C CNN
F 3 "" H 7750 2350 50  0001 C CNN
	1    7750 2350
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR027
U 1 1 5AB981C0
P 7750 2500
F 0 "#PWR027" H 7750 2250 50  0001 C CNN
F 1 "GND" H 7753 2374 50  0000 C CNN
F 2 "" H 7650 2150 50  0001 C CNN
F 3 "" H 7750 2500 50  0001 C CNN
	1    7750 2500
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small C9
U 1 1 5AB994C8
P 7500 2350
F 0 "C9" H 7525 2425 30  0000 L CNN
F 1 "100n" H 7525 2275 30  0000 L CNN
F 2 "Capacitors_SMD:C_0402" H 7500 2350 50  0001 C CNN
F 3 "" H 7500 2350 50  0001 C CNN
	1    7500 2350
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR029
U 1 1 5AB994CE
P 7500 2500
F 0 "#PWR029" H 7500 2250 50  0001 C CNN
F 1 "GND" H 7503 2374 50  0000 C CNN
F 2 "" H 7400 2150 50  0001 C CNN
F 3 "" H 7500 2500 50  0001 C CNN
	1    7500 2500
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small C8
U 1 1 5AB994D5
P 7300 2350
F 0 "C8" H 7325 2425 30  0000 L CNN
F 1 "100n" H 7325 2275 30  0000 L CNN
F 2 "Capacitors_SMD:C_0402" H 7300 2350 50  0001 C CNN
F 3 "" H 7300 2350 50  0001 C CNN
	1    7300 2350
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR030
U 1 1 5AB994DB
P 7300 2500
F 0 "#PWR030" H 7300 2250 50  0001 C CNN
F 1 "GND" H 7303 2374 50  0000 C CNN
F 2 "" H 7200 2150 50  0001 C CNN
F 3 "" H 7300 2500 50  0001 C CNN
	1    7300 2500
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:+3V3 #PWR031
U 1 1 5AB9B177
P 7200 1850
F 0 "#PWR031" H 7200 1700 50  0001 C CNN
F 1 "+3V3" V 7204 1956 50  0000 L CNN
F 2 "" H 7200 1850 50  0001 C CNN
F 3 "" H 7200 1850 50  0001 C CNN
	1    7200 1850
	0    -1   -1   0   
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR032
U 1 1 5AB9E180
P 9350 5650
F 0 "#PWR032" H 9350 5400 50  0001 C CNN
F 1 "GND" H 9353 5524 50  0000 C CNN
F 2 "" H 9250 5300 50  0001 C CNN
F 3 "" H 9350 5650 50  0001 C CNN
	1    9350 5650
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small C21
U 1 1 5ABC7182
P 9100 4000
F 0 "C21" H 9125 4075 30  0000 L CNN
F 1 "100n" H 9125 3925 30  0000 L CNN
F 2 "Capacitors_SMD:C_0402" H 9100 4000 50  0001 C CNN
F 3 "" H 9100 4000 50  0001 C CNN
	1    9100 4000
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small C19
U 1 1 5ABC7188
P 8900 4000
F 0 "C19" H 8925 4075 30  0000 L CNN
F 1 "100n" H 8925 3925 30  0000 L CNN
F 2 "Capacitors_SMD:C_0402" H 8900 4000 50  0001 C CNN
F 3 "" H 8900 4000 50  0001 C CNN
	1    8900 4000
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small C17
U 1 1 5ABC718E
P 8700 4000
F 0 "C17" H 8725 4075 30  0000 L CNN
F 1 "100n" H 8725 3925 30  0000 L CNN
F 2 "Capacitors_SMD:C_0402" H 8700 4000 50  0001 C CNN
F 3 "" H 8700 4000 50  0001 C CNN
	1    8700 4000
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR033
U 1 1 5ABC7194
P 9100 4150
F 0 "#PWR033" H 9100 3900 50  0001 C CNN
F 1 "GND" H 9103 4024 50  0000 C CNN
F 2 "" H 9000 3800 50  0001 C CNN
F 3 "" H 9100 4150 50  0001 C CNN
	1    9100 4150
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR034
U 1 1 5ABC719A
P 8900 4150
F 0 "#PWR034" H 8900 3900 50  0001 C CNN
F 1 "GND" H 8903 4024 50  0000 C CNN
F 2 "" H 8800 3800 50  0001 C CNN
F 3 "" H 8900 4150 50  0001 C CNN
	1    8900 4150
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:GND #PWR035
U 1 1 5ABC71A0
P 8700 4150
F 0 "#PWR035" H 8700 3900 50  0001 C CNN
F 1 "GND" H 8703 4024 50  0000 C CNN
F 2 "" H 8600 3800 50  0001 C CNN
F 3 "" H 8700 4150 50  0001 C CNN
	1    8700 4150
	1    0    0    -1  
$EndComp
Text GLabel 2450 5000 2    60   Input ~ 0
SD_DAT0
Text GLabel 2450 5300 2    60   Input ~ 0
SD_DAT1
Text GLabel 2450 5700 2    60   Input ~ 0
SD_DAT2
Text GLabel 2450 5200 2    60   Input ~ 0
SD_DAT3
Text GLabel 2450 5600 2    60   Input ~ 0
SD_CMD
Text GLabel 2450 5100 2    60   Input ~ 0
SD_CK
Text GLabel 2450 5800 2    60   Input ~ 0
SD_CD
Text GLabel 2450 3200 2    60   Input ~ 0
HYPERBUS_RWDS
Text GLabel 2450 3800 2    60   Input ~ 0
HYPERBUS_CS#
Text GLabel 2450 3900 2    60   Input ~ 0
HYPERBUS_RESET#
Text GLabel 2450 2500 2    60   Input ~ 0
HYPERBUS_CK
Text GLabel 2450 2200 2    60   Input ~ 0
HYPERBUS_CK#
Text GLabel 2450 3400 2    60   Input ~ 0
HYPERBUS_DQ0
Text GLabel 2450 3000 2    60   Input ~ 0
HYPERBUS_DQ1
Text GLabel 2450 3500 2    60   Input ~ 0
HYPERBUS_DQ2
Text GLabel 2450 3600 2    60   Input ~ 0
HYPERBUS_DQ3
Text GLabel 2450 3700 2    60   Input ~ 0
HYPERBUS_DQ4
Text GLabel 2450 2700 2    60   Input ~ 0
HYPERBUS_DQ5
Text GLabel 2450 2600 2    60   Input ~ 0
HYPERBUS_DQ6
Text GLabel 2450 2300 2    60   Input ~ 0
HYPERBUS_DQ7
Text GLabel 5600 1900 2    60   Input ~ 0
BOSON_DATA0
Text GLabel 5600 2100 2    60   Input ~ 0
BOSON_DATA1
Text GLabel 5600 2000 2    60   Input ~ 0
BOSON_DATA2
Text GLabel 5600 2400 2    60   Input ~ 0
BOSON_DATA3
Text GLabel 5600 3800 2    60   Input ~ 0
BOSON_DATA4
Text GLabel 5600 4000 2    60   Input ~ 0
BOSON_DATA5
Text GLabel 5600 3900 2    60   Input ~ 0
BOSON_DATA6
Text GLabel 5600 3500 2    60   Input ~ 0
BOSON_DATA7
Text GLabel 5600 3400 2    60   Input ~ 0
BOSON_DATA8
Text GLabel 5600 2800 2    60   Input ~ 0
BOSON_DATA9
Text GLabel 5600 1800 2    60   Input ~ 0
BOSON_DATA10
Text GLabel 5600 3100 2    60   Input ~ 0
BOSON_DATA11
Text GLabel 5600 2600 2    60   Input ~ 0
BOSON_DATA12
Text GLabel 5600 3600 2    60   Input ~ 0
BOSON_DATA13
Text GLabel 5600 3000 2    60   Input ~ 0
BOSON_DATA14
Text GLabel 5600 3700 2    60   Input ~ 0
BOSON_DATA15
Text GLabel 5600 1700 2    60   Input ~ 0
BOSON_DATA_EN
Text GLabel 5600 3200 2    60   Input ~ 0
BOSON_CK
Text GLabel 5600 2300 2    60   Input ~ 0
BOSON_VSYNC
Text GLabel 5600 1600 2    60   Input ~ 0
BOSON_HSYNC
Text GLabel 2450 1800 2    60   Input ~ 0
BOSON_RXD
Text GLabel 2450 2100 2    60   Input ~ 0
BOSON_TXD
Text GLabel 2450 1600 2    60   Input ~ 0
BOSON_RESET
Text GLabel 2450 7100 2    60   Input ~ 0
SPI_CONFIG_SS
Text GLabel 2450 7000 2    60   Input ~ 0
SPI_CONFIG_SCK
Text GLabel 2450 6900 2    60   Input ~ 0
SPI_CONFIG_MISO
Text GLabel 2450 6800 2    60   Input ~ 0
SPI_CONFIG_MOSI
$Comp
L bosonFrameGrabber:+1V8 #PWR028
U 1 1 5ABB57BA
P 7200 1450
F 0 "#PWR028" H 7200 1300 50  0001 C CNN
F 1 "+1V8" V 7204 1556 50  0000 L CNN
F 2 "" H 7200 1450 50  0001 C CNN
F 3 "" H 7200 1450 50  0001 C CNN
	1    7200 1450
	0    -1   -1   0   
$EndComp
Text GLabel 2450 2000 2    60   Input ~ 0
BOSON_DATA8
Text GLabel 2450 1700 2    60   Input ~ 0
BOSON_DATA8
$Comp
L bosonFrameGrabber:+3V3 #PWR047
U 1 1 5ABD6AD7
P 3250 5400
F 0 "#PWR047" H 3250 5250 50  0001 C CNN
F 1 "+3V3" V 3254 5506 50  0000 L CNN
F 2 "" H 3250 5400 50  0001 C CNN
F 3 "" H 3250 5400 50  0001 C CNN
	1    3250 5400
	0    1    1    0   
$EndComp
$Comp
L device:C_Small C22
U 1 1 5ABDC786
P 9300 2450
F 0 "C22" H 9325 2525 30  0000 L CNN
F 1 "100n" H 9325 2375 30  0000 L CNN
F 2 "Capacitors_SMD:C_0402" H 9300 2450 50  0001 C CNN
F 3 "" H 9300 2450 50  0001 C CNN
	1    9300 2450
	1    0    0    -1  
$EndComp
$Comp
L device:C_Small C23
U 1 1 5ABDC7D2
P 9300 2850
F 0 "C23" H 9150 2900 30  0000 L CNN
F 1 "100n" H 9150 2750 30  0000 L CNN
F 2 "Capacitors_SMD:C_0402" H 9300 2850 50  0001 C CNN
F 3 "" H 9300 2850 50  0001 C CNN
	1    9300 2850
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:+1V2 #PWR048
U 1 1 5ABF4890
P 9050 2750
F 0 "#PWR048" H 9050 2600 50  0001 C CNN
F 1 "+1V2" V 9054 2856 50  0000 L CNN
F 2 "" H 9050 2750 50  0001 C CNN
F 3 "" H 9050 2750 50  0001 C CNN
	1    9050 2750
	0    -1   -1   0   
$EndComp
Wire Wire Line
	9050 2500 9050 2450
Wire Wire Line
	8800 2500 8800 2450
Wire Wire Line
	8400 2500 8400 2450
Wire Wire Line
	8200 2500 8200 2450
Wire Wire Line
	7950 2500 7950 2450
Wire Wire Line
	7750 2500 7750 2450
Wire Wire Line
	7500 2500 7500 2450
Wire Wire Line
	7300 2500 7300 2450
Wire Wire Line
	9350 4350 9350 4450
Wire Wire Line
	9350 4350 9450 4350
Wire Wire Line
	9450 4450 9350 4450
Connection ~ 9350 4450
Wire Wire Line
	9350 4550 9450 4550
Connection ~ 9350 4550
Wire Wire Line
	9450 4650 9350 4650
Connection ~ 9350 4650
Wire Wire Line
	9450 4750 9350 4750
Connection ~ 9350 4750
Wire Wire Line
	9450 4850 9350 4850
Connection ~ 9350 4850
Wire Wire Line
	9450 4950 9350 4950
Connection ~ 9350 4950
Wire Wire Line
	9450 5050 9350 5050
Connection ~ 9350 5050
Wire Wire Line
	9450 5150 9350 5150
Connection ~ 9350 5150
Wire Wire Line
	9450 5250 9350 5250
Connection ~ 9350 5250
Wire Wire Line
	9450 5350 9350 5350
Connection ~ 9350 5350
Wire Wire Line
	9450 5450 9350 5450
Connection ~ 9350 5450
Wire Wire Line
	9450 5550 9350 5550
Connection ~ 9350 5550
Wire Wire Line
	9450 4150 9350 4150
Wire Wire Line
	9350 3750 9350 3850
Wire Wire Line
	8500 3750 8700 3750
Connection ~ 9350 3750
Wire Wire Line
	9450 3850 9350 3850
Connection ~ 9350 3850
Wire Wire Line
	9350 3950 9450 3950
Connection ~ 9350 3950
Wire Wire Line
	9450 4050 9350 4050
Connection ~ 9350 4050
Wire Wire Line
	7200 2050 8800 2050
Wire Wire Line
	7200 1850 8200 1850
Wire Wire Line
	7200 1650 7750 1650
Wire Wire Line
	7200 1450 7300 1450
Wire Wire Line
	7300 2250 7300 1450
Connection ~ 7300 1450
Wire Wire Line
	7500 2250 7500 1450
Connection ~ 7500 1450
Wire Wire Line
	7750 2250 7750 1650
Connection ~ 7750 1650
Wire Wire Line
	7950 2250 7950 1650
Connection ~ 7950 1650
Wire Wire Line
	8200 2250 8200 1850
Connection ~ 8200 1850
Wire Wire Line
	8400 2250 8400 1850
Connection ~ 8400 1850
Wire Wire Line
	8800 2050 8800 2250
Connection ~ 8800 2050
Wire Wire Line
	9050 2050 9050 2250
Connection ~ 9050 2050
Wire Wire Line
	9450 2250 9350 2250
Wire Wire Line
	9350 2050 9350 2150
Connection ~ 9350 2050
Wire Wire Line
	9450 2150 9350 2150
Connection ~ 9350 2150
Wire Wire Line
	9450 1950 9350 1950
Wire Wire Line
	9350 1950 9350 1850
Connection ~ 9350 1850
Wire Wire Line
	9450 1750 9350 1750
Wire Wire Line
	9350 1750 9350 1650
Connection ~ 9350 1650
Wire Wire Line
	9450 1550 9350 1550
Wire Wire Line
	9350 1550 9350 1450
Connection ~ 9350 1450
Wire Wire Line
	9100 4150 9100 4100
Wire Wire Line
	8900 4150 8900 4100
Wire Wire Line
	8700 4150 8700 4100
Wire Wire Line
	8700 3900 8700 3750
Connection ~ 8700 3750
Wire Wire Line
	8900 3900 8900 3750
Connection ~ 8900 3750
Wire Wire Line
	9100 3900 9100 3750
Connection ~ 9100 3750
Wire Wire Line
	3250 5400 2450 5400
Wire Wire Line
	9450 2450 9400 2450
Wire Wire Line
	9400 2450 9400 2350
Wire Wire Line
	9400 2350 9300 2350
Wire Wire Line
	9300 2550 9450 2550
Wire Wire Line
	9050 2750 9300 2750
Wire Wire Line
	9450 2850 9400 2850
Wire Wire Line
	9400 2850 9400 2950
Wire Wire Line
	9400 2950 9300 2950
Connection ~ 9300 2750
Wire Wire Line
	9300 2550 9300 2750
Connection ~ 9300 2550
$Comp
L bosonFrameGrabber:+2V5 #PWR051
U 1 1 5AC13A0C
P 9100 3050
F 0 "#PWR051" H 9100 2900 50  0001 C CNN
F 1 "+2V5" V 9104 3156 50  0000 L CNN
F 2 "" H 9100 3050 50  0001 C CNN
F 3 "" H 9100 3050 50  0001 C CNN
	1    9100 3050
	0    -1   -1   0   
$EndComp
Wire Wire Line
	9100 3050 9450 3050
$Comp
L bosonFrameGrabber:+3V3 #PWR052
U 1 1 5AC17167
P 9100 3250
F 0 "#PWR052" H 9100 3100 50  0001 C CNN
F 1 "+3V3" V 9104 3356 50  0000 L CNN
F 2 "" H 9100 3250 50  0001 C CNN
F 3 "" H 9100 3250 50  0001 C CNN
	1    9100 3250
	0    -1   -1   0   
$EndComp
Wire Wire Line
	9450 3250 9100 3250
Text GLabel 2450 6400 2    60   Input ~ 0
QSPI_D2
Text GLabel 2450 6200 2    60   Input ~ 0
QSPI_D3
Text GLabel 8350 3550 0    60   Input ~ 0
FPGA_RESET
Text GLabel 5600 5400 2    60   Input ~ 0
LED_A
Text GLabel 5600 5200 2    60   Input ~ 0
IO_A_DIR
Text GLabel 5600 5000 2    60   Input ~ 0
IO_A_INTERNAL
Text GLabel 5600 5300 2    60   Input ~ 0
IO_B_DIR
Text GLabel 5600 5100 2    60   Input ~ 0
IO_B_INTERNAL
Text GLabel 5600 6500 2    60   Input ~ 0
16MHZ_IN
$Comp
L Oscillators:ASE-xxxMHz X1
U 1 1 5ABDAC6C
P 7750 5850
F 0 "X1" H 8000 6150 50  0000 L CNN
F 1 "ASDMB" H 8000 6050 50  0000 L CNN
F 2 "Oscillators:Oscillator_SMD_SeikoEpson_SG210-4pin_2.5x2.0mm" H 8450 5500 50  0001 C CNN
F 3 "http://www.abracon.com/Oscillators/ASV.pdf" H 7650 5850 50  0001 C CNN
	1    7750 5850
	1    0    0    -1  
$EndComp
$Comp
L bosonFrameGrabber:+3V3 #PWR053
U 1 1 5ABDAF72
P 7400 5450
F 0 "#PWR053" H 7400 5300 50  0001 C CNN
F 1 "+3V3" V 7404 5556 50  0000 L CNN
F 2 "" H 7400 5450 50  0001 C CNN
F 3 "" H 7400 5450 50  0001 C CNN
	1    7400 5450
	1    0    0    -1  
$EndComp
Wire Wire Line
	7450 5850 7400 5850
Wire Wire Line
	7400 5850 7400 5450
$Comp
L bosonFrameGrabber:+3V3 #PWR054
U 1 1 5ABDE2AB
P 7750 5450
F 0 "#PWR054" H 7750 5300 50  0001 C CNN
F 1 "+3V3" V 7754 5556 50  0000 L CNN
F 2 "" H 7750 5450 50  0001 C CNN
F 3 "" H 7750 5450 50  0001 C CNN
	1    7750 5450
	1    0    0    -1  
$EndComp
Wire Wire Line
	7750 5550 7750 5450
$Comp
L bosonFrameGrabber:GND #PWR055
U 1 1 5ABE1600
P 7750 6250
F 0 "#PWR055" H 7750 6000 50  0001 C CNN
F 1 "GND" H 7753 6124 50  0000 C CNN
F 2 "" H 7650 5900 50  0001 C CNN
F 3 "" H 7750 6250 50  0001 C CNN
	1    7750 6250
	1    0    0    -1  
$EndComp
Wire Wire Line
	7750 6250 7750 6150
Text GLabel 8050 5850 2    60   Input ~ 0
16MHZ_IN
$Comp
L device:R R4
U 1 1 5AC144E9
P 8550 3300
F 0 "R4" H 8620 3346 50  0000 L CNN
F 1 "10k" H 8620 3255 50  0000 L CNN
F 2 "Resistors_SMD:R_0402" V 8480 3300 50  0001 C CNN
F 3 "" H 8550 3300 50  0001 C CNN
	1    8550 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	8350 3550 8550 3550
Wire Wire Line
	8550 3450 8550 3550
Connection ~ 8550 3550
$Comp
L bosonFrameGrabber:+3V3 #PWR059
U 1 1 5AC1A3A6
P 8550 3050
F 0 "#PWR059" H 8550 2900 50  0001 C CNN
F 1 "+3V3" V 8554 3156 50  0000 L CNN
F 2 "" H 8550 3050 50  0001 C CNN
F 3 "" H 8550 3050 50  0001 C CNN
	1    8550 3050
	1    0    0    -1  
$EndComp
Wire Wire Line
	8550 3150 8550 3050
Text Notes 7250 3450 0    60   ~ 0
Reset Pullup to VCCIO_2
Wire Wire Line
	9350 4450 9350 4550
Wire Wire Line
	9350 4550 9350 4650
Wire Wire Line
	9350 4650 9350 4750
Wire Wire Line
	9350 4750 9350 4850
Wire Wire Line
	9350 4850 9350 4950
Wire Wire Line
	9350 4950 9350 5050
Wire Wire Line
	9350 5050 9350 5150
Wire Wire Line
	9350 5150 9350 5250
Wire Wire Line
	9350 5250 9350 5350
Wire Wire Line
	9350 5350 9350 5450
Wire Wire Line
	9350 5450 9350 5550
Wire Wire Line
	9350 5550 9350 5650
Wire Wire Line
	9350 3750 9450 3750
Wire Wire Line
	9350 3850 9350 3950
Wire Wire Line
	9350 3950 9350 4050
Wire Wire Line
	9350 4050 9350 4150
Wire Wire Line
	7300 1450 7500 1450
Wire Wire Line
	7500 1450 9350 1450
Wire Wire Line
	7750 1650 7950 1650
Wire Wire Line
	7950 1650 9350 1650
Wire Wire Line
	8200 1850 8400 1850
Wire Wire Line
	8400 1850 9350 1850
Wire Wire Line
	8800 2050 9050 2050
Wire Wire Line
	9050 2050 9350 2050
Wire Wire Line
	9350 2050 9450 2050
Wire Wire Line
	9350 2150 9350 2250
Wire Wire Line
	9350 1850 9450 1850
Wire Wire Line
	9350 1650 9450 1650
Wire Wire Line
	9350 1450 9450 1450
Wire Wire Line
	8700 3750 8900 3750
Wire Wire Line
	8900 3750 9100 3750
Wire Wire Line
	9100 3750 9350 3750
Wire Wire Line
	9300 2750 9450 2750
Wire Wire Line
	8550 3550 9450 3550
$EndSCHEMATC
