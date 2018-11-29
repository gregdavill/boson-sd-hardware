#include <stdint.h>
#include <stdbool.h>

#include "FatFs/ff.h"
#include "FatFs/diskio.h"

#include "crc32.h"
#include "profiler.h"
// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

#define UART0_BASE 0x02001100
#define UART0_SETUP (*(volatile uint32_t *)((UART0_BASE) + 0x0))
#define UART0_FIFO (*(volatile uint32_t *)((UART0_BASE) + 0x4))
#define UART0_RXREG (*(volatile uint32_t *)((UART0_BASE) + 0x8))
#define UART0_TXREG (*(volatile uint32_t *)((UART0_BASE) + 0xc))

#define UART1_BASE 0x02001200
#define UART1_SETUP (*(volatile uint32_t *)((UART1_BASE) + 0x0))
#define UART1_FIFO (*(volatile uint32_t *)((UART1_BASE) + 0x4))
#define UART1_RXREG (*(volatile uint32_t *)((UART1_BASE) + 0x8))
#define UART1_TXREG (*(volatile uint32_t *)((UART1_BASE) + 0xc))

#define reg_spictrl (*(volatile uint32_t *)0x02000000)
#define reg_leds (*(volatile uint32_t *)0x02000200)

#define reg_hyperram_ctrl_a (*(volatile uint32_t *)0x02010010)
#define reg_hyperram_ctrl_b (*(volatile uint32_t *)0x02010014)

#define CCC_BASE 0x02100100
#define CCC_STATUS (*(volatile uint32_t *)(CCC_BASE + 0x04))

#define CC_FRAME_CNT (*(volatile uint32_t *)(0x02002100))
#define CC_ENABLE (*(volatile uint32_t *)(0x02002104))
#define CC_FRAME_LEN (*(volatile uint32_t *)(0x02002108))
#define CC_PIXEL_CNT (*(volatile uint32_t *)(0x0200210c))

#define CCC_STREAMER_BASE 0x02002000
#define CCC_STREAM_STATUS (*(volatile uint32_t *)(CCC_STREAMER_BASE + 0x00))
#define CCC_STREAM_START_ADR (*(volatile uint32_t *)(CCC_STREAMER_BASE + 0x04))
#define CCC_STREAM_BUF_SIZE (*(volatile uint32_t *)(CCC_STREAMER_BASE + 0x08))
#define CCC_STREAM_BURST_SIZE (*(volatile uint32_t *)(CCC_STREAMER_BASE + 0x0C))
#define CCC_STREAM_TX_CNT (*(volatile uint32_t *)(CCC_STREAMER_BASE + 0x10))

#define HRAM0_CFG (*(volatile uint32_t *)(0x02200000))

#define HRAM0 (volatile uint32_t *)(0x04000000)



void print(const char *p);


profiler_t profilingCounter;

// --------------------------------------------------------

extern uint32_t flashio_worker_begin;
extern uint32_t flashio_worker_end;


inline void memcpy(uint32_t* dst_ptr, const uint32_t* src_ptr, int size){
	do{
		*dst_ptr++ = *src_ptr++;
	}while(--size);
}


void flashio(uint8_t *data, int len, uint8_t wrencmd)
{
	uint32_t funcStorage0[256];
	memcpy(funcStorage0, &flashio_worker_begin, 255);

	((void (*)(uint8_t *, uint32_t, uint32_t))funcStorage0)(data, len, wrencmd);
}

void set_flash_qspi_flag(bool bSet)
{
	uint8_t buffer_rd[2] = {0x05, 0};
	flashio(buffer_rd, 2, 0);

	uint8_t status_reg = buffer_rd[1];

	/* Enable QSPI on MX25R1635 FLASH IC*/
	if(bSet)
		status_reg |= (1 << 6);
	else
		status_reg &= ~(1 << 6);

	uint8_t buffer_wr[2] = {0x01, status_reg};
	flashio(buffer_wr, 2, 0x6);

}

void set_flash_latency(uint8_t value)
{
	reg_spictrl = (reg_spictrl & ~0x007f0000) | ((value & 15) << 16);
}

// --------------------------------------------------------

void set_latency(uint32_t latency_1x, uint32_t latency_2x)
{
	reg_hyperram_ctrl_a = (latency_2x << 8) | latency_1x;
}

#define DEEP_PWR_DOWN (1 << 15)
#define DRIVE_STRENGTH(x) ((x & 0xe) << 12)
#define RESERVED_1 (0xe << 8)
#define INITIAL_LATENCY(x) ((x & 0xf) << 4)
#define FIXED_LATENCY (1 << 3)
#define HYBRID_BURST (1 << 2)
#define BURST_LENGTH(x) ((x & 0x3) << 0)

void set_hyperram_speed()
{
	//	set_latency(0x9, 0xB);
	reg_hyperram_ctrl_b = (DEEP_PWR_DOWN | DRIVE_STRENGTH(0b000) | RESERVED_1 | INITIAL_LATENCY(0b1110) | HYBRID_BURST | BURST_LENGTH(0b11)) << 16;
	set_latency(0x0B, 0x0B);
}

//--------------------------------------------------------

void putchar(char c)
{
	if (c == '\n')
		putchar('\r');

	while ((UART0_TXREG & (1 << 13)) != 0)
		;

	UART0_TXREG = c;
}

void print(const char *p)
{
	while (*p)
		putchar(*(p++));
}

void print_hex(uint32_t v, int digits)
{
	for (int i = 7; i >= 0; i--)
	{
		char c = "0123456789abcdef"[(v >> (4 * i)) & 15];
		if (c == '0' && i >= digits)
			continue;
		putchar(c);
		digits = i;
	}
}

void print_dec(uint32_t v)
{
	if (v >= 100)
	{
		print(">=100");
		return;
	}

	if (v >= 90)
	{
		putchar('9');
		v -= 90;
	}
	else if (v >= 80)
	{
		putchar('8');
		v -= 80;
	}
	else if (v >= 70)
	{
		putchar('7');
		v -= 70;
	}
	else if (v >= 60)
	{
		putchar('6');
		v -= 60;
	}
	else if (v >= 50)
	{
		putchar('5');
		v -= 50;
	}
	else if (v >= 40)
	{
		putchar('4');
		v -= 40;
	}
	else if (v >= 30)
	{
		putchar('3');
		v -= 30;
	}
	else if (v >= 20)
	{
		putchar('2');
		v -= 20;
	}
	else if (v >= 10)
	{
		putchar('1');
		v -= 10;
	}

	if (v >= 9)
	{
		putchar('9');
		v -= 9;
	}
	else if (v >= 8)
	{
		putchar('8');
		v -= 8;
	}
	else if (v >= 7)
	{
		putchar('7');
		v -= 7;
	}
	else if (v >= 6)
	{
		putchar('6');
		v -= 6;
	}
	else if (v >= 5)
	{
		putchar('5');
		v -= 5;
	}
	else if (v >= 4)
	{
		putchar('4');
		v -= 4;
	}
	else if (v >= 3)
	{
		putchar('3');
		v -= 3;
	}
	else if (v >= 2)
	{
		putchar('2');
		v -= 2;
	}
	else if (v >= 1)
	{
		putchar('1');
		v -= 1;
	}
	else
		putchar('0');
}

char getchar_prompt(char *prompt)
{
	int32_t c = 0x100;
	int flip = 0;

	uint32_t cycles_begin, cycles_now, cycles;
	__asm__ volatile("rdcycle %0"
					 : "=r"(cycles_begin));

	if (prompt)
		print(prompt);

	reg_leds = 0x00010001;
	while (c & 0x100)
	{
		__asm__ volatile("rdcycle %0"
						 : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
		if (cycles > 12000000)
		{
			if (prompt)
				print(prompt);
			cycles_begin = cycles_now;
			reg_leds = 0x00010000 | flip;
			flip ^= 1;
		}
		c = UART0_RXREG;
	}
	reg_leds = 0x00010000;
	return c;
}

char getchar()
{
	return getchar_prompt(0);
}

// --------------------------------------------------------

void cmd_read_flash_id()
{
	uint8_t buffer[17] = {0x9F, /* zeros */};
	flashio(buffer, 17, 0);

	for (int i = 1; i <= 16; i++)
	{
		putchar(' ');
		print_hex(buffer[i], 2);
	}
	putchar('\n');
}


void cmd_read_status_reg()
{
	uint8_t buffer[2] = {0x05, /* zeros */};
	flashio(buffer, 2, 0);

	print("Status Reg: ");
	print_hex(buffer[1], 2);
	
	putchar('\n');
}

// --------------------------------------------------------

static void dly_us(UINT n) /* Delay n microseconds (avr-gcc -Os) */
{

	uint32_t cycles_begin, cycles_now, cycles;
	__asm__ volatile("rdcycle %0"
					 : "=r"(cycles_begin));

	uint32_t cycles_total = n * 48;

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

FATFS FatFs; /* FatFs work area needed for each volume */
FIL Fil;	 /* File object needed for each open file */


void put_dump(const BYTE *buff, DWORD ofs, WORD cnt)
{
	WORD i;

	//xprintf(PSTR("%08lX:"), ofs);
	print_hex(ofs, 8);
	print(":");

	for (i = 0; i < cnt; i++)
	{
		print(" ");
		print_hex(buff[i], 2);
	}

	print(" ");
	for (i = 0; i < cnt; i++)
	{
		{
			char c[2];
			c[0] = (buff[i] >= ' ' && buff[i] <= '~') ? buff[i] : '.';
			c[1] = 0;
			print(c);
		}
	}

	print("\r\n");
	//xputc('\n');
}

void dump(const BYTE *buff, WORD cnt)
{
	const char *bp;
	WORD ofs;

	for (bp = buff, ofs = 0; ofs < 0x200; bp += 16, ofs += 16)
		put_dump(bp, cnt + ofs, 16);
}


void short_delay()
{
	uint32_t cycles_begin, cycles_now, cycles;
	__asm__ volatile("rdcycle %0"
					 : "=r"(cycles_begin));

	while (true)
	{
		__asm__ volatile("rdcycle %0"
						 : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
		if (cycles > 48000000)
		{
			break;
		}
	}
}

int flip = 0;


void hram_test()
{
	static uint32_t counter = 0;
	uint32_t reader;

	*((uint32_t *)0x04000000) = 0x12345678;
	*((uint32_t *)0x04000004) = 0xAAAAAAAA;
	*((uint32_t *)0x04000008) = 0x55555555;
	*((uint32_t *)0x0400000C) = 0x01020408;

	*((uint32_t*) 0x04000010) = counter++;

	
	dump((const BYTE*)0x04000000, 0);
}

void hram_dump(){
	dump((const BYTE*)0x04000000, 0);
}


void hram_fill() {
	static uint32_t fill_value = 0x04030201;
	static uint8_t value;
	const uint32_t len = 64*1024;

	fill_value = (value + 3) << 24 | (value + 2) << 16 | (value + 1) << 8 | (value);

	volatile uint32_t* hram_ptr = (uint32_t *)0x04000000;
	uint32_t error_count = 0;

	/* Fill */	
	for(uint32_t i = 0; i < len; i++){
		hram_ptr[i] = fill_value;
	}


	/* Check */
	for(uint32_t i = 0; i < len; i++){
		uint32_t read_val = hram_ptr[i];
		if(read_val != fill_value)
		{
			error_count++;
			print("Error @ 0x");
			print_hex(i, 8);
			print(", 0x");
			print_hex(read_val, 8);
			print(" != 0x");
			print_hex(fill_value,8);
			print(" (re-read: 0x");
			print_hex(hram_ptr[i],8);
			print(")\r\n");
		}
	}

	print("\r\nTotal Errors: ");
	print_dec(error_count);
	print("\r\n");
}

void blink_led(int numBlinks)
{

	for (int i = 0; i < numBlinks; i++)
	{
		reg_leds = 0x00010001;
		dly_us(5000);
		reg_leds = 0x00010000;
		dly_us(5000);
	}

	dly_us(20000);
}


void set_filename(char *p, int i)
{
	*p++ = 'I';
	*p++ = 'M';
	*p++ = 'G';
	*p++ = '_';
	*p++ = '0' + i / 1000 % 10;
	*p++ = '0' + i / 100 % 10;
	*p++ = '0' + i / 10 % 10;
	*p++ = '0' + i % 10;
	*p++ = '.';
	*p++ = 'R';
	*p++ = 'A';
	*p++ = 'W';
	*p++ = 0;
}

void continuousCapture()
{

	char filename[13];
	int image_number = 0;

	dly_us(500000);

	FRESULT res;
	res = f_mount(&FatFs, "", 0); /* Give a work area to the default drive */

	print("Waiting for frame to determine size\r\n");

	/* Determine what camera we are connected to */
	uint32_t frame_cnt = CC_FRAME_CNT;
	while(frame_cnt == CC_FRAME_CNT);

	/* record last frame size in pixels */
	uint32_t pixel_cnt = CC_PIXEL_CNT;


	print("Frame captured\r\n");

	while (1)
	{

		
			print("New Frame");
		set_filename(filename, image_number++);

		/* sw reset of wb_streamer component */
		//CCC_STREAM_STATUS = 4;

		profiler_start(&profilingCounter);

		/* Capture our image length into external hyperRAM */
		/* Burst size is in DWORDS, 8 = 16 clock cycles */
		CCC_STREAM_START_ADR = (uint32_t)0x04000000;
		
		/* Set our pixel size to */
		CCC_STREAM_BUF_SIZE = pixel_cnt * 2;
		CCC_STREAM_BURST_SIZE = 64;

		/* Enable the Stream DMA and clear IRQ bit*/
		CCC_STREAM_STATUS = 3;

		/* enable data from the camera for next vsync period */
		CC_ENABLE = 1;

		/* Wait for IRQ signal to be set */
		reg_leds = 0x00010001;
		while (!(CCC_STREAM_STATUS & 2))
		{
			print(".");
		}
		reg_leds = 0x00010000;

		/* clear IRQ */
		CCC_STREAM_STATUS = 2;

		
		profiler_stop(&profilingCounter);
		print("Capture:");
		print_hex(profiler_read(&profilingCounter), 8);
		print("\r\n");

		blink_led(1);

		profiler_start(&profilingCounter);
		UINT bw = 0;

		/* Create a file */
		if ((res = f_open(&Fil, filename, FA_WRITE | FA_CREATE_ALWAYS)) == FR_OK)
		{ 
			uint8_t *ptr = (uint8_t*)0x04000000;

			/* Find and allocate a block the size of the image (16bit) for us */
			if ((res = f_expand(&Fil, pixel_cnt * 2, 1)) == FR_OK)
			{
				/* Accessing the contiguous file via low-level disk functions */

				/* Get physical location of the file data */
				BYTE drv = Fil.obj.fs->pdrv;
				DWORD lba = Fil.obj.fs->database + Fil.obj.fs->csize * (Fil.obj.sclust - 2);

				/* Write all the sectors from top of the file at a time 
					Each sector is 512bytes in size.
					Our image is frame_cnt pixels large, each pixel is 16bits.
				*/
				res = disk_write(drv, ptr, lba, (pixel_cnt / 256));
				
				if (res == FR_OK)
				{ /* Write data to the file */
					if ((res = f_close(&Fil)) == FR_OK)
					{ /* Close the file */
						blink_led(1);
					}
				}
			}

			if ((res = f_close(&Fil)) == FR_OK)
			{ /* Close the file */
				blink_led(2);
			}
		}

		
		profiler_stop(&profilingCounter);
		print("Save:");
		print_hex(profiler_read(&profilingCounter), 8);
		print("\r\n");

		if (res != FR_OK)
		{
			blink_led(5);
		}

		
			print("\r\nSaved.\r\n");
	}
}


void crc_test()
{
	crc32_clear();
	print("\n CRC test Initial Value: 0x");
	print_hex(crc32_value(), 8);
	print(" \n");

	crc32_input(0x00000000);
	print("CRC[0x00000000] = 0x");
	print_hex(crc32_value(), 8);
	print(" \n");

	crc32_clear();
	crc32_input(0x01020304);
	print("CRC[0x01020304] = 0x");
	print_hex(crc32_value(), 8);
	print(" \n");

	crc32_clear();
	crc32_input(0x04030201);
	print("CRC[0x04030201] = 0x");
	print_hex(crc32_value(), 8);
	print(" \n");


	crc32_clear();
	uint32_t* crc_ptr = 0x04000000;
	for(uint32_t i = 0; i < (768*1024); i++) {
			crc32_input(*crc_ptr++);
	}
	print("CRC(mem) = 0x");
	print_hex(crc32_value(), 8);
	print(" \n");

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
	UART0_SETUP = 417;
	

	//cmd_read_flash_id();

	set_flash_qspi_flag(true);
	set_flash_latency(4);
	
	/* Enable QSPI mode */ 
	reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00200000;
	//reg_spictrl = reg_spictrl | 0x00100000;
	
	
	HRAM0_CFG = 0x8f1f0000;




	//while (getchar_prompt("Press ENTER to continue..\n") != '\r')
	//{ /* wait */
	//}

	print("\r\n");
	print("  __               __            __                 \r\n");
	print(" |__) _  _ _  _   |_ _ _  _  _  / _  _ _ |_ |_  _ _ \r\n");
	print(" |__)(_)_)(_)| )  | | (_||||(-  \\__)| (_||_)|_)(-|  \r\n");
	print("                                                    \r\n");
	print("  Boson Frame Grabber. Powered by picorv32, ECP5\r\n");
	print("    Build Date: "__DATE__
		  " "__TIME__
		  "\r\n");

	//continuousCapture();
	
	while (1)
	{
		print("\n");

		print("\n");
		print("Select an action:\n");
		print("\n");
		print(" [1] Write\n");
		print(" [2] Dump\n");
		print(" [3] Fill and check\n");
		print(" [4] Low Latency\n");
		print(" [5] Default Latency\n");
		print("\n");

		for (int rep = 10; rep > 0; rep--)
		{
			print("Command> ");
			char cmd = getchar();
			if (cmd > 32 && cmd < 127)
				putchar(cmd);
			print("\n");

			switch (cmd)
			{
			case '1':
				hram_test();
				break;
			case '2':
				hram_dump();
				break;
			case '3':
				hram_fill();
				break;
			case '4':
				/* Reduce latency for HyperRAM Writes/Reads */
				HRAM0_CFG = 0x8fe40000;
				print("\n New HyperRAM value = 0x8fe4");
				break;
			case '5':
				/* Default latency for HyperRAM Writes/Reads */
				HRAM0_CFG = 0x8f1f0000;
				print("\n New HyperRAM value = 0x8f1f");
				break;

			case '6':
				crc_test();
				break;
			default:
				continue;
			}

			break;
		}
	}
}
