EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
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
L R R4
U 1 1 5641CCDB
P 4300 3300
F 0 "R4" V 4380 3300 50  0000 C CNN
F 1 "1k" V 4300 3300 50  0000 C CNN
F 2 "" V 4230 3300 30  0000 C CNN
F 3 "" H 4300 3300 30  0000 C CNN
	1    4300 3300
	1    0    0    -1  
$EndComp
$Comp
L R R5
U 1 1 5641CD79
P 4300 3800
F 0 "R5" V 4380 3800 50  0000 C CNN
F 1 "1k" V 4300 3800 50  0000 C CNN
F 2 "" V 4230 3800 30  0000 C CNN
F 3 "" H 4300 3800 30  0000 C CNN
	1    4300 3800
	1    0    0    -1  
$EndComp
$Comp
L R R6
U 1 1 5641CE0F
P 4300 4300
F 0 "R6" V 4380 4300 50  0000 C CNN
F 1 "2k" V 4300 4300 50  0000 C CNN
F 2 "" V 4230 4300 30  0000 C CNN
F 3 "" H 4300 4300 30  0000 C CNN
	1    4300 4300
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 5641CE54
P 3850 4050
F 0 "R3" V 3930 4050 50  0000 C CNN
F 1 "2k" V 3850 4050 50  0000 C CNN
F 2 "" V 3780 4050 30  0000 C CNN
F 3 "" H 3850 4050 30  0000 C CNN
	1    3850 4050
	0    1    1    0   
$EndComp
$Comp
L R R2
U 1 1 5641CE93
P 3850 3550
F 0 "R2" V 3930 3550 50  0000 C CNN
F 1 "2k" V 3850 3550 50  0000 C CNN
F 2 "" V 3780 3550 30  0000 C CNN
F 3 "" H 3850 3550 30  0000 C CNN
	1    3850 3550
	0    1    1    0   
$EndComp
$Comp
L R R1
U 1 1 5641CED7
P 3850 3050
F 0 "R1" V 3930 3050 50  0000 C CNN
F 1 "2k" V 3850 3050 50  0000 C CNN
F 2 "" V 3780 3050 30  0000 C CNN
F 3 "" H 3850 3050 30  0000 C CNN
	1    3850 3050
	0    1    1    0   
$EndComp
Wire Wire Line
	4000 3050 4850 3050
Wire Wire Line
	4300 3050 4300 3150
Wire Wire Line
	4300 3450 4300 3650
Wire Wire Line
	4300 3950 4300 4150
Wire Wire Line
	4000 4050 4300 4050
Connection ~ 4300 4050
Wire Wire Line
	4000 3550 4300 3550
Connection ~ 4300 3550
Wire Wire Line
	3700 3050 3450 3050
Wire Wire Line
	3700 3550 3450 3550
Wire Wire Line
	3700 4050 3450 4050
Text Label 3250 3100 0    60   ~ 0
F2
Text Label 3250 3600 0    60   ~ 0
F1
Text Label 3250 4100 0    60   ~ 0
F0
$Comp
L GND #PWR1
U 1 1 5641D015
P 4300 4450
F 0 "#PWR1" H 4300 4200 50  0001 C CNN
F 1 "GND" H 4300 4300 50  0000 C CNN
F 2 "" H 4300 4450 60  0000 C CNN
F 3 "" H 4300 4450 60  0000 C CNN
	1    4300 4450
	1    0    0    -1  
$EndComp
$Comp
L LM555N U2
U 1 1 5641D051
P 5550 3000
F 0 "U2" H 5550 3100 70  0000 C CNN
F 1 "LM555N" H 5550 2900 70  0000 C CNN
F 2 "" H 5550 3000 60  0000 C CNN
F 3 "" H 5550 3000 60  0000 C CNN
	1    5550 3000
	1    0    0    -1  
$EndComp
Connection ~ 4300 3050
$Comp
L R R7
U 1 1 5641D117
P 6550 2850
F 0 "R7" V 6630 2850 50  0000 C CNN
F 1 "10k" V 6550 2850 50  0000 C CNN
F 2 "" V 6480 2850 30  0000 C CNN
F 3 "" H 6550 2850 30  0000 C CNN
	1    6550 2850
	1    0    0    -1  
$EndComp
$Comp
L R R8
U 1 1 5641D198
P 6550 3150
F 0 "R8" V 6630 3150 50  0000 C CNN
F 1 "10k" V 6550 3150 50  0000 C CNN
F 2 "" V 6480 3150 30  0000 C CNN
F 3 "" H 6550 3150 30  0000 C CNN
	1    6550 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	6250 3000 6550 3000
Wire Wire Line
	6550 2700 6550 2300
Wire Wire Line
	6550 2300 4700 2300
Wire Wire Line
	4700 2300 4700 3300
Wire Wire Line
	4700 3300 4850 3300
Wire Wire Line
	6250 3200 6250 3500
Wire Wire Line
	6250 3300 6550 3300
$Comp
L +5V #PWR2
U 1 1 5641D211
P 6550 2300
F 0 "#PWR2" H 6550 2150 50  0001 C CNN
F 1 "+5V" H 6550 2440 50  0000 C CNN
F 2 "" H 6550 2300 60  0000 C CNN
F 3 "" H 6550 2300 60  0000 C CNN
	1    6550 2300
	1    0    0    -1  
$EndComp
Wire Wire Line
	4850 2800 4850 3500
Wire Wire Line
	4850 3500 6250 3500
Connection ~ 6250 3300
$Comp
L C C1
U 1 1 5641D261
P 6550 3600
F 0 "C1" H 6575 3700 50  0000 L CNN
F 1 "100n" H 6575 3500 50  0000 L CNN
F 2 "" H 6588 3450 30  0000 C CNN
F 3 "" H 6550 3600 60  0000 C CNN
	1    6550 3600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR3
U 1 1 5641D310
P 6550 3750
F 0 "#PWR3" H 6550 3500 50  0001 C CNN
F 1 "GND" H 6550 3600 50  0000 C CNN
F 2 "" H 6550 3750 60  0000 C CNN
F 3 "" H 6550 3750 60  0000 C CNN
	1    6550 3750
	1    0    0    -1  
$EndComp
Wire Wire Line
	6550 3300 6550 3450
Wire Wire Line
	6250 2800 6250 2550
Wire Wire Line
	6250 2550 7450 2550
$Comp
L 74LS27 U1
U 1 1 5641D3B1
P 5400 4000
F 0 "U1" H 5400 4050 60  0000 C CNN
F 1 "74LS27" H 5400 3950 60  0000 C CNN
F 2 "" H 5400 4000 60  0000 C CNN
F 3 "" H 5400 4000 60  0000 C CNN
	1    5400 4000
	1    0    0    -1  
$EndComp
Wire Wire Line
	3600 4050 3600 4150
Wire Wire Line
	3600 4150 4800 4150
Connection ~ 3600 4050
Wire Wire Line
	4800 4000 3600 4000
Wire Wire Line
	3600 4000 3600 3550
Connection ~ 3600 3550
Wire Wire Line
	3600 3050 3600 2900
Wire Wire Line
	3600 2900 4550 2900
Wire Wire Line
	4550 2900 4550 3850
Wire Wire Line
	4550 3850 4800 3850
Connection ~ 3600 3050
$Comp
L 74LS27 U1
U 2 1 5641D601
P 8050 2700
F 0 "U1" H 8050 2750 60  0000 C CNN
F 1 "74LS27" H 8050 2650 60  0000 C CNN
F 2 "" H 8050 2700 60  0000 C CNN
F 3 "" H 8050 2700 60  0000 C CNN
	2    8050 2700
	1    0    0    -1  
$EndComp
Wire Wire Line
	7450 2700 7450 4000
Wire Wire Line
	7450 4000 6000 4000
Text Label 8750 2700 0    60   ~ 0
AUDIOOUT
Text Notes 7500 7500 0    60   ~ 0
555 Based Audio Board
Text Notes 4900 4550 0    60   ~ 0
The gating circuitry around U1 is a later addition. The original\ncircuit relied on F0 = F1 = F2 = 0 => silence. 
Text Notes 2650 7600 0    60   ~ 0
This circuitry should be part of the main board, not a seperate one.
$EndSCHEMATC