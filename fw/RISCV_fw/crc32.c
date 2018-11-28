
#include "crc32.h"

#define CRC32_DATA (*(volatile uint32_t *)(0x02000300))
#define CRC32_VALUE (*(volatile uint32_t *)(0x02000304))
#define CRC32_CFG (*(volatile uint32_t *)(0x02000308))

void crc32_clear(){
	CRC32_CFG = 1;
}

uint32_t crc32_value(){
	return CRC32_VALUE;
}

void crc32_input(uint32_t value){
	CRC32_DATA = value;
}