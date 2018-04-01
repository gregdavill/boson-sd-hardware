EESchema Schematic File Version 4
LIBS:crushedICE-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 6
Title "Boson Breakout with ICE FPGA"
Date "2018-03-24"
Rev "v0_1"
Comp "GsD"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 10550 6250 0    60   ~ 0
To Add:\n\nFT230X\nRegulators\nLEDs\nSWD\n
$Sheet
S 8750 5500 1600 850 
U 5AB2115D
F0 "Testpoints" 60
F1 "ciTestpoints.sch" 60
$EndSheet
$Sheet
S 2100 3200 1600 850 
U 5AB2368D
F0 "Boson" 60
F1 "ciBoson.sch" 60
$EndSheet
$Sheet
S 4800 3200 1600 850 
U 5AB241B4
F0 "FPGA" 60
F1 "ciFPGA.sch" 60
$EndSheet
$Sheet
S 7750 3200 1600 850 
U 5AB247CC
F0 "Microcontroller" 60
F1 "ciMicrocontroller.sch" 60
$EndSheet
$Sheet
S 4800 1750 1600 950 
U 5AB24CCA
F0 "Power" 60
F1 "ciPower.sch" 60
$EndSheet
Text Notes 2400 3750 0    200  ~ 0
Boson
Text Notes 4900 3900 0    200  ~ 0
FPGA\nHyperRAM
Text Notes 3850 3650 0    60   ~ 0
CMOS 16bit\n[27Mhz] 64Mbit/s
Text Notes 6950 3650 0    60   ~ 0
QSPI
Text Notes 8000 3900 0    200  ~ 0
SAMD51\nSDMMC
$EndSCHEMATC
