#include <stdint.h>
#include <stdbool.h>
#include "uart.h"

#include "FatFs/ff.h"

// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

#define HRAM0 ((volatile uint32_t *)(0x04000000))

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


uint32_t print_func[128];

void programFlash(uint32_t pageCount)
{

	/* Enable MEMIO mode (Bitbang) */
	uint32_t spi = SPI_REG;
	spi &= ~(BB_EN | CLK_BIT | D1_EN | D2_EN | D3_EN);
	spi |= (D0_EN | CS_BIT | D0_BIT | D2_BIT | D3_BIT); /* Enable Bit0 as Output */
	SPI_REG = spi;

	uint32_t spi_csl = spi & ~(CS_BIT);
	uint32_t spi_csh = spi | (CS_BIT);

	uint32_t *dataPtr = (uint32_t *)0x04000000;

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
		do {

			SPI_REG = spi_csl; /* CS_L */
			SPI_DATA = 0x05;
			SPI_DATA = 0x00;
			status_reg = SPI_DATA;
			SPI_REG = spi_csh; /* CS_H */

		} while((status_reg & 0x01) != 0);
		
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
			do {

				SPI_REG = spi_csl; /* CS_L */
				SPI_DATA = 0x05;
				SPI_DATA = 0x00;
				status_reg = SPI_DATA;
				SPI_REG = spi_csh; /* CS_H */

			} while((status_reg & 0x01) != 0);

		}
	}

	/* We have just erased and reflashed the FLASH.
	 * We can never return. Instead we'll reboot the FPGA */

	/* This reset will result in the FPGA 
	 * reconfiguring itself. */
	//FPGA_RESET = 0xDEADBEEF;

	while (1)
	{
		GPIO = 0x00010001;
	}
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
		uint8_t *ptr = (uint8_t *)0x04000000;

		UINT bw = 0;
		uint32_t totalSize = 0;

		while (true)
		{
			res = f_read(&Fil, ptr, 512, &bw);
			totalSize += bw;
			ptr += bw;

			if (bw != 512)
			{
				/* EOF? */
				break;
			}

			if (res != FR_OK)
			{
				break;
			}

			print(".");
		}

		print("OK\r\n");

		print("File Loaded");

		/* File is loaded in RAM. */
		/* Perform a CRC error check on the file to determine it's integrity */

		/* TODO: CRC Check */

		uint32_t pageCounts = 16;

		uint32_t func[1024];
		uint32_t *src_ptr = (uint32_t *)programFlash;
		uint32_t *dst_ptr = func;

		while (src_ptr != ((uint32_t *)programFlash + 1024))
			*(dst_ptr++) = *(src_ptr++);

		((void (*)(uint32_t))func)(pageCounts);

	}
	else
	{
		if (res == FR_NO_FILE)
			print("Error: File does not exist.\r\n");
		else
			print("Error: Trouble finding file\r\n");
	}
}
