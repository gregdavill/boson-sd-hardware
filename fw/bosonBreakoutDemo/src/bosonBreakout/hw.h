
#pragma once

#include "gpio.h"

#define XOSC_FREQ 16000000UL
#define SYS_FREQ (XOSC_FREQ / 1)

#define BOOT_LED_POLARITY 0


#define interfacePut usartPut
#define interfaceGet usartGet
#define interfaceInit usartInit

#define spiSercom ((SercomUsart*)&SERCOM2->USART)


const SamPin<PIN_PB02> ledSdAct;
const SamPin<PIN_PB03> ledQspiAct;
const SamPin<PIN_PB08> ledUsbAct;

const SamPin<PIN_PA17> fpgaRst;
const SamPin<PIN_PA19> fpgaCs;
const SamPin<PIN_PA09> fpgaSpiMiso;
const SamPin<PIN_PA08> fpgaSpiMosi;
const SamPin<PIN_PB10> fpgaSpiClk;

const SamPin<PIN_PA20> fpgaCDone;


const SamPin<PIN_PA23> debugTx;

const SamPin<PIN_PA07> SdSel;




