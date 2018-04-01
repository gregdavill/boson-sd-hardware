EESchema Schematic File Version 4
LIBS:crushedICE-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 6
Title "Boson Breakout with ICE FPGA"
Date "2018-03-24"
Rev "v0_1"
Comp "GsD"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 3300 2650 2    60   Input ~ 0
CAM_D11
Text GLabel 2800 2750 0    60   Input ~ 0
CAM_D12
Text GLabel 3300 2750 2    60   Input ~ 0
CAM_D13
Text GLabel 2800 2850 0    60   Input ~ 0
CAM_D14
Text GLabel 3300 2850 2    60   Input ~ 0
CAM_D15
Text GLabel 2800 2650 0    60   Input ~ 0
CAM_D10
Text GLabel 3300 2550 2    60   Input ~ 0
CAM_D9
Text GLabel 2800 2550 0    60   Input ~ 0
CAM_D8
Text GLabel 3300 2450 2    60   Input ~ 0
CAM_D7
Text GLabel 2800 2450 0    60   Input ~ 0
CAM_D6
Text GLabel 3300 2350 2    60   Input ~ 0
CAM_D5
Text GLabel 2800 2350 0    60   Input ~ 0
CAM_D4
Text GLabel 3300 2250 2    60   Input ~ 0
CAM_D3
Text GLabel 2800 2250 0    60   Input ~ 0
CAM_D2
Text GLabel 3300 2150 2    60   Input ~ 0
CAM_D1
Text GLabel 2800 3050 0    60   Input ~ 0
CAM_CLK
Text GLabel 2800 2150 0    60   Input ~ 0
CAM_D0
Text GLabel 3300 3050 2    60   Input ~ 0
CAM_VALID
Text GLabel 2800 3150 0    60   Input ~ 0
CAM_VSYNC
Text GLabel 3300 3150 2    60   Input ~ 0
CAM_HSYNC
$Comp
L conn:Conn_02x12_Odd_Even J1
U 1 1 5AB212B3
P 3000 2550
F 0 "J1" H 3050 3267 50  0000 C CNN
F 1 "Conn_02x12_Odd_Even" H 3050 3176 50  0000 C CNN
F 2 "" H 3000 2550 50  0001 C CNN
F 3 "~" H 3000 2550 50  0001 C CNN
	1    3000 2550
	1    0    0    -1  
$EndComp
Text GLabel 3300 2050 2    60   Input ~ 0
BOSON_RXD
Text GLabel 2800 2050 0    60   Input ~ 0
BOSON_TXD
$Comp
L crushedICE:GND #PWR014
U 1 1 5AB212BC
P 3850 2950
F 0 "#PWR014" H 3850 2700 50  0001 C CNN
F 1 "GND" H 3850 2800 50  0000 C CNN
F 2 "" H 3850 2950 50  0001 C CNN
F 3 "" H 3850 2950 50  0001 C CNN
	1    3850 2950
	0    -1   -1   0   
$EndComp
$Comp
L crushedICE:GND #PWR08
U 1 1 5AB212C2
P 2250 2950
F 0 "#PWR08" H 2250 2700 50  0001 C CNN
F 1 "GND" H 2250 2800 50  0000 C CNN
F 2 "" H 2250 2950 50  0001 C CNN
F 3 "" H 2250 2950 50  0001 C CNN
	1    2250 2950
	0    1    1    0   
$EndComp
$Comp
L conn:Conn_02x12_Odd_Even J2
U 1 1 5AB212C8
P 3000 4450
F 0 "J2" H 3050 5167 50  0000 C CNN
F 1 "Conn_02x12_Odd_Even" H 3050 5076 50  0000 C CNN
F 2 "" H 3000 4450 50  0001 C CNN
F 3 "~" H 3000 4450 50  0001 C CNN
	1    3000 4450
	1    0    0    -1  
$EndComp
Text GLabel 2800 4450 0    60   Input ~ 0
HB_CK
Text GLabel 3300 4450 2    60   Input ~ 0
HB_CK#
Text GLabel 2800 4050 0    60   Input ~ 0
HB_DQ0
Text GLabel 3300 4050 2    60   Input ~ 0
HB_DQ1
Text GLabel 2800 4150 0    60   Input ~ 0
HB_DQ2
Text GLabel 3300 4150 2    60   Input ~ 0
HB_DQ3
Text GLabel 2800 4250 0    60   Input ~ 0
HB_DQ4
Text GLabel 3300 4250 2    60   Input ~ 0
HB_DQ5
Text GLabel 2800 4350 0    60   Input ~ 0
HB_DQ6
Text GLabel 3300 4350 2    60   Input ~ 0
HB_DQ7
Text GLabel 3300 4550 2    60   Input ~ 0
HB_CS#
Text GLabel 2800 4650 0    60   Input ~ 0
HB_RWDS
Text GLabel 2800 4550 0    60   Input ~ 0
HB_RESET#
$Comp
L crushedICE:GND #PWR015
U 1 1 5AB212DC
P 3850 3950
F 0 "#PWR015" H 3850 3700 50  0001 C CNN
F 1 "GND" H 3850 3800 50  0000 C CNN
F 2 "" H 3850 3950 50  0001 C CNN
F 3 "" H 3850 3950 50  0001 C CNN
	1    3850 3950
	0    -1   -1   0   
$EndComp
$Comp
L crushedICE:GND #PWR013
U 1 1 5AB212E2
P 2250 3950
F 0 "#PWR013" H 2250 3700 50  0001 C CNN
F 1 "GND" H 2250 3800 50  0000 C CNN
F 2 "" H 2250 3950 50  0001 C CNN
F 3 "" H 2250 3950 50  0001 C CNN
	1    2250 3950
	0    1    1    0   
$EndComp
$Comp
L crushedICE:GND #PWR016
U 1 1 5AB212E8
P 3850 4650
F 0 "#PWR016" H 3850 4400 50  0001 C CNN
F 1 "GND" H 3850 4500 50  0000 C CNN
F 2 "" H 3850 4650 50  0001 C CNN
F 3 "" H 3850 4650 50  0001 C CNN
	1    3850 4650
	0    -1   -1   0   
$EndComp
Text GLabel 3300 4850 2    60   Input ~ 0
FPGA_CS
$Comp
L conn:Conn_02x05_Odd_Even J5
U 1 1 5AB43A6F
P 3000 5900
F 0 "J5" H 3050 6317 50  0000 C CNN
F 1 "Conn_02x05_Odd_Even" H 3050 6226 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x05_Pitch2.54mm" H 3000 5900 50  0001 C CNN
F 3 "~" H 3000 5900 50  0001 C CNN
	1    3000 5900
	1    0    0    -1  
$EndComp
$Comp
L crushedICE:GND #PWR024
U 1 1 5AB43AA3
P 3300 6100
F 0 "#PWR024" H 3300 5850 50  0001 C CNN
F 1 "GND" H 3300 5950 50  0000 C CNN
F 2 "" H 3300 6100 50  0001 C CNN
F 3 "" H 3300 6100 50  0001 C CNN
	1    3300 6100
	0    -1   -1   0   
$EndComp
Text GLabel 2800 5900 0    60   Input ~ 0
SD_CMD
Text GLabel 3300 5900 2    60   Input ~ 0
SD_CLK
Text GLabel 3300 5800 2    60   Input ~ 0
SD_D3
Text GLabel 2800 5800 0    60   Input ~ 0
SD_D2
Text GLabel 3300 6000 2    60   Input ~ 0
SD_D1
Text GLabel 2800 6000 0    60   Input ~ 0
SD_D0
Text GLabel 2800 4750 0    60   Input ~ 0
SD_CMD/QSPI_D0
Text GLabel 2800 4850 0    60   Input ~ 0
SD_DAT0/QSPI_D1
Text GLabel 2800 4950 0    60   Input ~ 0
SD_DAT1/QSPI_D2
Text GLabel 2800 5050 0    60   Input ~ 0
SD_DAT2/QSPI_D3
$Comp
L crushedICE:+3V3 #PWR029
U 1 1 5AB4B801
P 8100 1800
F 0 "#PWR029" H 8100 1650 50  0001 C CNN
F 1 "+3V3" H 8103 1951 50  0000 C CNN
F 2 "" H 8100 1800 50  0001 C CNN
F 3 "" H 8100 1800 50  0001 C CNN
	1    8100 1800
	1    0    0    -1  
$EndComp
$Comp
L device:LED_Small_ALT D1
U 1 1 5AB4B94D
P 7750 2500
F 0 "D1" H 7850 2600 50  0000 C CNN
F 1 "led green" H 7750 2644 50  0001 C CNN
F 2 "LEDs:LED_0805" V 7750 2500 50  0001 C CNN
F 3 "" V 7750 2500 50  0001 C CNN
	1    7750 2500
	1    0    0    -1  
$EndComp
$Comp
L device:R_Pack04 RN1
U 1 1 5AB4B9F9
P 8300 2150
F 0 "RN1" H 8488 2196 50  0000 L CNN
F 1 "R_Pack04" H 8488 2105 50  0000 L CNN
F 2 "Resistors_SMD:R_Array_Convex_4x0603" V 8575 2150 50  0001 C CNN
F 3 "" H 8300 2150 50  0001 C CNN
	1    8300 2150
	1    0    0    -1  
$EndComp
Wire Wire Line
	2250 2950 2800 2950
Wire Wire Line
	3300 2950 3850 2950
Wire Wire Line
	2250 3950 2800 3950
Wire Wire Line
	3300 3950 3850 3950
Wire Wire Line
	3300 4650 3850 4650
Wire Wire Line
	8100 1800 8100 1950
Wire Wire Line
	8100 1850 8400 1850
Wire Wire Line
	8200 1850 8200 1950
Connection ~ 8100 1850
Wire Wire Line
	8300 1850 8300 1950
Connection ~ 8200 1850
Wire Wire Line
	8400 1850 8400 1950
Connection ~ 8300 1850
Wire Wire Line
	7850 2500 8100 2500
Wire Wire Line
	8100 2500 8100 2350
Wire Wire Line
	7650 2500 7500 2500
Wire Wire Line
	7850 2750 8200 2750
Wire Wire Line
	8200 2750 8200 2350
Wire Wire Line
	8300 2350 8300 3000
Wire Wire Line
	8300 3000 7850 3000
Wire Wire Line
	7650 2750 7500 2750
Wire Wire Line
	7650 3000 7500 3000
Text GLabel 7500 2500 0    60   Input ~ 0
LED_A
Text GLabel 7500 2750 0    60   Input ~ 0
LED_B
Text GLabel 7500 3000 0    60   Input ~ 0
LED_C
$Comp
L device:LED_Small_ALT D2
U 1 1 5ABD99AB
P 7750 2750
F 0 "D2" H 7850 2850 50  0000 C CNN
F 1 "led green" H 7750 2894 50  0001 C CNN
F 2 "LEDs:LED_0805" V 7750 2750 50  0001 C CNN
F 3 "" V 7750 2750 50  0001 C CNN
	1    7750 2750
	1    0    0    -1  
$EndComp
$Comp
L device:LED_Small_ALT D3
U 1 1 5ABD99D1
P 7750 3000
F 0 "D3" H 7850 3100 50  0000 C CNN
F 1 "led green" H 7750 3144 50  0001 C CNN
F 2 "LEDs:LED_0805" V 7750 3000 50  0001 C CNN
F 3 "" V 7750 3000 50  0001 C CNN
	1    7750 3000
	1    0    0    -1  
$EndComp
Text GLabel 7500 4250 0    60   Input ~ 0
LED_D
Text GLabel 7500 4500 0    60   Input ~ 0
LED_E
Text GLabel 7500 4750 0    60   Input ~ 0
LED_F
$Comp
L crushedICE:+3V3 #PWR057
U 1 1 5ABDFD77
P 8100 3550
F 0 "#PWR057" H 8100 3400 50  0001 C CNN
F 1 "+3V3" H 8103 3701 50  0000 C CNN
F 2 "" H 8100 3550 50  0001 C CNN
F 3 "" H 8100 3550 50  0001 C CNN
	1    8100 3550
	1    0    0    -1  
$EndComp
$Comp
L device:LED_Small_ALT D4
U 1 1 5ABDFD7D
P 7750 4250
F 0 "D4" H 7850 4350 50  0000 C CNN
F 1 "led green" H 7750 4394 50  0001 C CNN
F 2 "LEDs:LED_0805" V 7750 4250 50  0001 C CNN
F 3 "" V 7750 4250 50  0001 C CNN
	1    7750 4250
	1    0    0    -1  
$EndComp
$Comp
L device:R_Pack04 RN2
U 1 1 5ABDFD83
P 8300 3900
F 0 "RN2" H 8488 3946 50  0000 L CNN
F 1 "R_Pack04" H 8488 3855 50  0000 L CNN
F 2 "Resistors_SMD:R_Array_Convex_4x0603" V 8575 3900 50  0001 C CNN
F 3 "" H 8300 3900 50  0001 C CNN
	1    8300 3900
	1    0    0    -1  
$EndComp
Wire Wire Line
	8100 3550 8100 3700
Wire Wire Line
	8100 3600 8400 3600
Wire Wire Line
	8200 3600 8200 3700
Connection ~ 8100 3600
Wire Wire Line
	8300 3600 8300 3700
Connection ~ 8200 3600
Wire Wire Line
	8400 3600 8400 3700
Connection ~ 8300 3600
Wire Wire Line
	7850 4250 8100 4250
Wire Wire Line
	8100 4250 8100 4100
Wire Wire Line
	7650 4250 7500 4250
Wire Wire Line
	7850 4500 8200 4500
Wire Wire Line
	8200 4500 8200 4100
Wire Wire Line
	8300 4100 8300 4750
Wire Wire Line
	8300 4750 7850 4750
Wire Wire Line
	7650 4500 7500 4500
Wire Wire Line
	7650 4750 7500 4750
$Comp
L device:LED_Small_ALT D5
U 1 1 5ABDFD9A
P 7750 4500
F 0 "D5" H 7850 4600 50  0000 C CNN
F 1 "led green" H 7750 4644 50  0001 C CNN
F 2 "LEDs:LED_0805" V 7750 4500 50  0001 C CNN
F 3 "" V 7750 4500 50  0001 C CNN
	1    7750 4500
	1    0    0    -1  
$EndComp
$Comp
L device:LED_Small_ALT D6
U 1 1 5ABDFDA0
P 7750 4750
F 0 "D6" H 7850 4850 50  0000 C CNN
F 1 "led green" H 7750 4894 50  0001 C CNN
F 2 "LEDs:LED_0805" V 7750 4750 50  0001 C CNN
F 3 "" V 7750 4750 50  0001 C CNN
	1    7750 4750
	1    0    0    -1  
$EndComp
Text GLabel 2800 6100 0    60   Input ~ 0
SDMMC_SEL
Text GLabel 3300 5700 2    60   Input ~ 0
USB_DATA_P
Text GLabel 2800 5700 0    60   Input ~ 0
USB_DATA_N
Text GLabel 3300 4750 2    60   Input ~ 0
SD_DAT3/QSPI_SCK
Text GLabel 3300 4950 2    60   Input ~ 0
CDONE/IO_C
$Comp
L conn:Conn_01x10 J7
U 1 1 5AC622C9
P 6000 5600
F 0 "J7" H 6080 5592 50  0000 L CNN
F 1 "Conn_01x10" H 6080 5501 50  0000 L CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x10_Pitch2.54mm" H 6000 5600 50  0001 C CNN
F 3 "~" H 6000 5600 50  0001 C CNN
	1    6000 5600
	1    0    0    -1  
$EndComp
$Comp
L crushedICE:GND #PWR02
U 1 1 5AC62372
P 5700 6200
F 0 "#PWR02" H 5700 5950 50  0001 C CNN
F 1 "GND" H 5703 6074 50  0000 C CNN
F 2 "" H 5600 5850 50  0001 C CNN
F 3 "" H 5700 6200 50  0001 C CNN
	1    5700 6200
	1    0    0    -1  
$EndComp
$Comp
L crushedICE:+5V #PWR012
U 1 1 5AC623A5
P 5700 5100
F 0 "#PWR012" H 5700 4950 50  0001 C CNN
F 1 "+5V" H 5703 5251 50  0000 C CNN
F 2 "" H 5700 5100 50  0001 C CNN
F 3 "" H 5700 5100 50  0001 C CNN
	1    5700 5100
	1    0    0    -1  
$EndComp
$Comp
L crushedICE:+3V3 #PWR070
U 1 1 5AC623D8
P 5450 5100
F 0 "#PWR070" H 5450 4950 50  0001 C CNN
F 1 "+3V3" H 5453 5251 50  0000 C CNN
F 2 "" H 5450 5100 50  0001 C CNN
F 3 "" H 5450 5100 50  0001 C CNN
	1    5450 5100
	1    0    0    -1  
$EndComp
$Comp
L crushedICE:+2V5 #PWR071
U 1 1 5AC6240B
P 5200 5100
F 0 "#PWR071" H 5200 4950 50  0001 C CNN
F 1 "+2V5" H 5203 5251 50  0000 C CNN
F 2 "" H 5200 5100 50  0001 C CNN
F 3 "" H 5200 5100 50  0001 C CNN
	1    5200 5100
	1    0    0    -1  
$EndComp
$Comp
L crushedICE:+1V8 #PWR072
U 1 1 5AC6243E
P 4950 5100
F 0 "#PWR072" H 4950 4950 50  0001 C CNN
F 1 "+1V8" H 4953 5251 50  0000 C CNN
F 2 "" H 4950 5100 50  0001 C CNN
F 3 "" H 4950 5100 50  0001 C CNN
	1    4950 5100
	1    0    0    -1  
$EndComp
$Comp
L crushedICE:+1V2 #PWR073
U 1 1 5AC62471
P 4700 5100
F 0 "#PWR073" H 4700 4950 50  0001 C CNN
F 1 "+1V2" H 4703 5251 50  0000 C CNN
F 2 "" H 4700 5100 50  0001 C CNN
F 3 "" H 4700 5100 50  0001 C CNN
	1    4700 5100
	1    0    0    -1  
$EndComp
Wire Wire Line
	5700 5100 5700 5200
Wire Wire Line
	5700 5200 5800 5200
Wire Wire Line
	5450 5100 5450 5300
Wire Wire Line
	5450 5300 5800 5300
Wire Wire Line
	5800 5400 5200 5400
Wire Wire Line
	5200 5400 5200 5100
Wire Wire Line
	5800 5500 4950 5500
Wire Wire Line
	4950 5500 4950 5100
Wire Wire Line
	5800 5600 4700 5600
Wire Wire Line
	4700 5600 4700 5100
Wire Wire Line
	5800 5700 5700 5700
Wire Wire Line
	5700 5700 5700 6200
Wire Wire Line
	5800 5800 5700 5800
Connection ~ 5700 5800
Wire Wire Line
	5800 5900 5700 5900
Connection ~ 5700 5900
Wire Wire Line
	5800 6000 5700 6000
Connection ~ 5700 6000
Wire Wire Line
	5800 6100 5700 6100
Connection ~ 5700 6100
Text GLabel 3300 5050 2    60   Input ~ 0
DEBUG_TX
$EndSCHEMATC
