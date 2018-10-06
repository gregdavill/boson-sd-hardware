#include <stdint.h>
#include <stdbool.h>

#include "FatFs/ff.h"

// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

#define HRAM0 ((volatile uint32_t *)(0x04000000))

#define SPI_REG *(uint32_t*)0x02000000
#define FPGA_RESET *(uint32_t*)0x02000000

#define ENABLE 0x80
#define CS_BIT 0x20
#define CLK_BIT 0x10
#define D0_BIT 0x01

void programFlash(uint32_t pageCount) {

	/* Enable MEMIO mode (Bitbang) */
	uint32_t spi = SPI_REG;
	spi &= ~(ENABLE | CLK_BIT); 
	spi |= (CS_BIT | D0_BIT); /* Enable Bit0 as Output */
	SPI_REG = spi;

	uint32_t* dataPtr = 0x04000000;

	for(uint32_t blockNumber = 0; blockNumber < pageCount; blockNumber++){

		SPI_REG &= ~(1 << CS_BIT); /* CS_L */
		/* Execute a WEN command */
		{
			uint8_t CMD = 0x06;
			for(uint32_t i = 0; i < 8; i++){
					SPI_REG &= ~(D0_BIT | CLK_BIT);
				if(CMD & 0x80) 
					SPI_REG |= D0_BIT;
				
				SPI_REG |= CLK_BIT;
				CMD <<= 1;
			}
		}
		SPI_REG |= (1 << CS_BIT); /* CS_H */
		


		SPI_REG &= ~(1 << CS_BIT); /* CS_L */
		/* Execute a Flash Block Erase (4kb) */
		{
			uint32_t CMD = 0x20000000 | (blockNumber << 12);
			for(uint32_t i = 0; i < 32; i++){
					SPI_REG &= ~(D0_BIT | CLK_BIT);
				if(CMD & 0x80000000) 
					SPI_REG |= D0_BIT;
				
				SPI_REG |= CLK_BIT;
				CMD <<= 1;
			}
		}
		SPI_REG |= (1 << CS_BIT); /* CS_H */
		

		/* wait for erase time  */
		{

		}


		/* Program our new data into the FLASH */
		SPI_REG &= ~(1 << CS_BIT); /* CS_L */
		/* Execute a Flash Block Erase (4kb) */
		{
			uint32_t CMD = 0x20000000 | (blockNumber << 12);
			for(uint32_t i = 0; i < 32; i++){
					SPI_REG &= ~(D0_BIT | CLK_BIT);
				if(CMD & 0x80000000) 
					SPI_REG |= D0_BIT;
				
				SPI_REG |= CLK_BIT;
				CMD <<= 1;
			}
		}
		SPI_REG |= (1 << CS_BIT); /* CS_H */


		SPI_REG &= ~(1 << CS_BIT); /* CS_L */
		/* Execute a WEN command */
		{
			uint8_t CMD = 0x06;
			for(uint32_t i = 0; i < 8; i++){
					SPI_REG &= ~(D0_BIT | CLK_BIT);
				if(CMD & 0x80) 
					SPI_REG |= D0_BIT;
				
				SPI_REG |= CLK_BIT;
				CMD <<= 1;
			}
		}
		SPI_REG |= (1 << CS_BIT); /* CS_H */

		SPI_REG &= ~(1 << CS_BIT); /* CS_L */
		/* Execute a Flash Block Erase (4kb) */
		{
			uint32_t CMD = 0x02000000 | (blockNumber << 12);
			for(uint32_t i = 0; i < 32; i++) {
					SPI_REG &= ~(D0_BIT | CLK_BIT);
				if(CMD & 0x80000000) 
					SPI_REG |= D0_BIT;
				
				SPI_REG |= CLK_BIT;
				CMD <<= 1;
			}

			for(uint32_t i = 0; i < 256; i++) {
				uint8_t dataByte = *dataPtr++;

				for(uint32_t i = 0; i < 8; i++) {
						SPI_REG &= ~(D0_BIT | CLK_BIT);
					if(dataByte & 0x80) 
						SPI_REG |= D0_BIT;
					
					SPI_REG |= CLK_BIT;
					dataByte <<= 1;
				}
			}
		}
		SPI_REG |= (1 << CS_BIT); /* CS_H */

	}

	/* we can never return, the Flash */
	/* This reset will result in the FPGA 
	 * reconfiguring itself. */
	
	FPGA_RESET = 0xDEADBEEF;
}


FATFS FatFs;
FIL Fil;

extern uint32_t _sidata, _sdata, _edata, _sbss, _ebss;

void main()
{
	// copy data section
	for (uint32_t *src = &_sidata, *dest = &_sdata; dest < &_edata;)
	{

		*dest++ = *src++;
	}
	// zero out .bss section
	for (uint32_t *dest = &_sbss; dest < &_ebss;)
	{
		*dest++ = 0;
	}

	/* Check if we have a uSD card in the slot. */


	/* Read File into Memory */
	FRESULT res;
	res = f_mount(&FatFs, "", 0); /* Give a work area to the default drive */

	if ((res = f_open(&Fil, "bosonFirmware.bin", FA_WRITE | FA_CREATE_ALWAYS)) == FR_OK)
	{ 
		/* Copy binary data into the RAM */
		uint8_t *ptr = 0x04000000;

		uint32_t bw = 0;
		uint32_t totalSize = 0;

		while(true) {
			res = f_read(&Fil, ptr, 512, &bw);
			totalSize += bw;

			if(bw != 512) {
				/* EOF? */
				break;
			}

			if(res != FR_OK){
				break;
			}
		}

		/* File is loaded in RAM. */
		/* Perform a CRC error check on the file to determine it's integrity */
		
		/* TODO: CRC Check */

		uint32_t pageCounts = 16;


		uint32_t func[512];

		uint32_t *src_ptr = programFlash;
		uint32_t *dst_ptr = func;

		while (src_ptr != ((uint32_t)programFlash + 512))
			*(dst_ptr++) = *(src_ptr++);

		((void (*)(uint32_t))func)(pageCounts);


	}

}
