#include <stdint.h>
#include <stdbool.h>
#include "uart.h"

#include "FatFs/ff.h"


#define HRAM0 (uint32_t *)(0x04000000)

#define SPI_REG *(uint32_t *)0x02000000
#define SPI_DATA *(uint8_t *)0x02000004
#define SPI_DATA32 *(uint32_t *)0x02000004
#define SPI_DATA32_SWAP *(uint32_t *)0x0200000C

#define GPIO (*(volatile uint32_t *)0x02000200)

#define FPGA_RESET *(uint32_t *)0x02001300

#define BB_EN 0x80000000
#define D0_EN 0x0100
#define D1_EN 0x0200
#define D2_EN 0x0400
#define D3_EN 0x0800
#define CS_BIT 0x20
#define CLK_BIT 0x10
#define D0_BIT 0x01
#define D1_BIT 0x02
#define D2_BIT 0x04
#define D3_BIT 0x08


// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

uint32_t funcStorage0[1024];
const void (*bootloaderFunc)(uint32_t) = (void (*)(uint32_t))funcStorage0;


void programFlash(uint32_t pageCount)
{
	/* Enable MEMIO mode */
	uint32_t spi = SPI_REG;
	spi &= ~(BB_EN | CLK_BIT | D1_EN | D2_EN | D3_EN);  /* Bit1, Bit2, Bit3 as Inputs. Clk LOW */
	spi |= (D0_EN | CS_BIT | D0_BIT | D2_BIT | D3_BIT); /* Bit0 as Output */
	SPI_REG = spi;

	uint32_t spi_csl = spi & ~(CS_BIT);
	uint32_t spi_csh = spi | (CS_BIT);

	uint32_t *dataPtr = HRAM0;

	for (uint32_t blockNumber = 0; blockNumber < pageCount; blockNumber++)
	{

		/* Execute a WEN command */
		SPI_REG = spi_csl; /* CS_L */
		SPI_DATA = 0x06;
		SPI_REG = spi_csh; /* CS_H */

		/* Execute a Flash Block Erase (64kb) */
		{
			SPI_REG = spi_csl; /* CS_L */
			SPI_DATA32 = 0xD8000000 | (blockNumber << 16);
			SPI_REG = spi_csh; /* CS_H */
		}

		/* wait for erase time  */
		uint8_t status_reg;
		do
		{

			SPI_REG = spi_csl; /* CS_L */
			SPI_DATA = 0x05;
			SPI_DATA = 0x00;
			status_reg = SPI_DATA;
			SPI_REG = spi_csh; /* CS_H */

		} while ((status_reg & 0x01) != 0);

		for (int currentPage = 0; currentPage < 256; currentPage++)
		{
			/* Execute a WEN command */
			SPI_REG = spi_csl; /* CS_L */
			SPI_DATA = 0x06;
			SPI_REG = spi_csh; /* CS_H */

			/* Execute a WEN command */
			SPI_REG = spi_csl; /* CS_L */
			SPI_DATA32 = 0x02000000 | (blockNumber << 16) | (currentPage << 8);
			for (uint32_t i = 0; i < 256 / 4; i++)
				SPI_DATA32_SWAP = *dataPtr++;
			SPI_REG = spi_csh; /* CS_H */

			/* wait for program to complete  */
			uint8_t status_reg;
			do
			{

				SPI_REG = spi_csl; /* CS_L */
				SPI_DATA = 0x05;
				SPI_DATA = 0x00;
				status_reg = SPI_DATA;
				SPI_REG = spi_csh; /* CS_H */

			} while ((status_reg & 0x01) != 0);
		}
	}

	/* We have just erased and reflashed the FLASH.
	 * We can never return. Instead we'll reboot the FPGA */

	/* This reset will result in the FPGA 
	 * reconfiguring itself. */
	FPGA_RESET = 0xDEADBEEF;

	/* Sanity check catch all */
	while(1);
}

inline void memcpy(uint32_t* dst_ptr, const uint32_t* src_ptr, int size){
	do{
		*dst_ptr++ = *src_ptr++;
	}while(--size);
}


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

	uartInit();

	print("\r\nBosonBootloader " __DATE__ " " __TIME__ "\r\n");

	/* Check if we have a uSD card in the slot. */

	FATFS FatFs;
	FIL Fil;

	/* Read File into Memory */
	FRESULT res;
	res = f_mount(&FatFs, "", 0); /* Give a work area to the default drive */

	print("Checking for File on SD\r\n");

	if ((res = f_open(&Fil, "bosonFirmware.bin", FA_READ)) == FR_OK)
	{

		print("File Found Sucessfully\r\n");
		print("Loading");
		
		/* Copy binary data into the RAM */
		uint8_t *ptr = (uint8_t *)HRAM0;
		unsigned int bw = 0;
		
		do
		{
			res = f_read(&Fil, ptr, 512, &bw);
			ptr += bw;
			
			print(".");

		}while((bw == 512) && (res == FR_OK));

		print("OK\r\n");

		print("File Loaded");

		/* File is loaded in RAM. */
		/* Perform a CRC error check on the file to determine it's integrity */

		/* TODO: CRC Check */

		
		/* We can save some space by only programming what we have available */
		uint32_t len = ((uint32_t)ptr - (uint32_t)HRAM0);
		uint32_t pageCounts = (len / 0x10000) + (len % 0x10000) ? 1 : 0;
		/* Otherwise 16 pages will replace the entire FLASH */
		//uint32_t pageCounts = 16;
		


		/* I'm not sure how to check how big a function in C is.
		 * Se just use space on the stack that is 'big enough' */
		memcpy(funcStorage0, (uint32_t*)programFlash, sizeof(funcStorage0)/4);

		/* Call our function this will begin executing from RAM */
		((void (*)(uint32_t))bootloaderFunc)(pageCounts);
	}
	else
	{
		/* Handle Errors */
		if (res == FR_NO_FILE)
			print("Error: File does not exist.\r\n");
		else
			print("Error: Trouble finding file\r\n");
	}
}
