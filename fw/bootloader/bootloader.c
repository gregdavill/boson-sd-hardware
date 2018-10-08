#include <stdint.h>
#include <stdbool.h>
#include "uart.h"

#include "FatFs/ff.h"

// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

#define HRAM0 ((volatile uint32_t *)(0x04000000))

#define SPI_REG *(uint32_t *)0x02000000
#define SPI_DATA *(uint32_t *)0x02000004

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
		SPI_DATA = 0x05;
		SPI_DATA = 0x00;
		uint8_t data = SPI_DATA;
		SPI_REG = spi_csh; /* CS_H */
		
		SPI_REG = spi_csl; /* CS_L */
		SPI_DATA = 0x00;
		SPI_DATA = data;
		SPI_REG = spi_csh; /* CS_L */
		
		/* Execute a WEN command */
		SPI_REG = spi_csl; /* CS_L */
		SPI_DATA = 0x06;
		SPI_REG = spi_csh; /* CS_H */

		/* Execute a WEN command */
		SPI_REG = spi_csl; /* CS_L */
		SPI_DATA = 0x05;
		SPI_DATA = 0x00;
		data = SPI_DATA;
		SPI_REG = spi_csh; /* CS_H */


		SPI_REG = spi_csl; /* CS_L */
		SPI_DATA = 0x80;
		SPI_DATA = 0x01;	
		SPI_REG = spi_csh; /* CS_L */
		
		
		SPI_REG = spi_csl; /* CS_L */
		SPI_DATA = 0x00;
		SPI_DATA = data;
		SPI_REG = spi_csh; /* CS_L */
		

		while(1);

		SPI_REG &= ~CS_BIT; /* CS_L */
		/* Execute a Flash Block Erase (64kb) */
		{
			uint32_t CMD = 0xD8000000 | (blockNumber << 16);
			for (uint32_t i = 0; i < 32; i++)
			{
				SPI_REG &= ~(D0_BIT | CLK_BIT);
				if (CMD & 0x80000000)
					SPI_REG |= D0_BIT;

				SPI_REG |= CLK_BIT;
				CMD <<= 1;
			}
		}
		SPI_REG |= CS_BIT; /* CS_H */

		/* wait for erase time  */
		{
			/* Typ erase time is 60ms for 4kb erase, max 300ms */
			/* TODO:: read out status reg to determine erase finish. */
			uint32_t cycles_begin, cycles_now, cycles;
			__asm__ volatile("rdcycle %0"
							 : "=r"(cycles_begin));

			uint32_t cycles_total = 300000 * 48;

			while (1)
			{
				__asm__ volatile("rdcycle %0"
								 : "=r"(cycles_now));
				cycles = cycles_now - cycles_begin;
				if (cycles > cycles_total)
				{
					break;
				}
			}
		}

		
		for (int currentPage = 0; currentPage < 256; currentPage++)
		{
			SPI_REG &= ~CS_BIT; /* CS_L */
			/* Execute a WEN command */
			{
				uint8_t CMD = 0x06;
				for (uint32_t i = 0; i < 8; i++)
				{
					SPI_REG &= ~(D0_BIT | CLK_BIT);
					if (CMD & 0x80)
						SPI_REG |= D0_BIT;

					SPI_REG |= CLK_BIT;
					CMD <<= 1;
				}
			}
			SPI_REG |= CS_BIT; /* CS_H */

			SPI_REG &= ~CS_BIT; /* CS_L */
			/* Program 1 Page 256 bytes */
			{
				uint32_t CMD = 0x02000000 | (blockNumber << 16) | (currentPage << 8);
				for (uint32_t i = 0; i < 32; i++)
				{
					SPI_REG &= ~(D0_BIT | CLK_BIT);
					if (CMD & 0x80000000)
						SPI_REG |= D0_BIT;

					SPI_REG |= CLK_BIT;
					CMD <<= 1;
				}

				for (uint32_t i = 0; i < 256 / 4; i++)
				{
					uint32_t dataByte = *dataPtr++;

					for (uint32_t j = 0; j < 32; j++)
					{
						SPI_REG &= ~(D0_BIT | CLK_BIT);
						if (dataByte & 0x80000000)
							SPI_REG |= D0_BIT;

						SPI_REG |= CLK_BIT;
						dataByte <<= 1;
					}
				}
			}
			SPI_REG |= CS_BIT; /* CS_H */

			{
			/* Typ erase time is 60ms for 4kb erase, max 300ms */
			/* TODO:: read out status reg to determine erase finish. */
			uint32_t cycles_begin, cycles_now, cycles;
			__asm__ volatile("rdcycle %0"
							 : "=r"(cycles_begin));

			uint32_t cycles_total = 5000 * 48;

			while (1)
			{
				__asm__ volatile("rdcycle %0"
								 : "=r"(cycles_now));
				cycles = cycles_now - cycles_begin;
				if (cycles > cycles_total)
				{
					break;
				}
			}
		}
		}
	}

	/* we can never return, the Flash */

	/* This reset will result in the FPGA 
	 * reconfiguring itself. */
	FPGA_RESET = 0xDEADBEEF;

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

	
		uint32_t pageCounts = 16;

		uint32_t func[1024];
		uint32_t *src_ptr = (uint32_t *)programFlash;
		uint32_t *dst_ptr = func;

		while (src_ptr != ((uint32_t *)programFlash + 1024))
			*(dst_ptr++) = *(src_ptr++);

		((void (*)(uint32_t))func)(pageCounts);

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

	}
	else
	{
		if (res == FR_NO_FILE)
			print("Error: File does not exist.\r\n");
		else
			print("Error: Trouble finding file\r\n");
	}
}
