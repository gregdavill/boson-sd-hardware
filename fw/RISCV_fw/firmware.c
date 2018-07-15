#include <stdint.h>
#include <stdbool.h>

#include "FatFs/ff.h"

// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

#define reg_spictrl     (*(volatile uint32_t*)0x02000000)
#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000100)
#define reg_uart_data   (*(volatile uint32_t*)0x02000104)
#define reg_leds        (*(volatile uint32_t*)0x02000200)


#define reg_hyperram_ctrl_a (*(volatile uint32_t *)0x02010010)
#define reg_hyperram_ctrl_b (*(volatile uint32_t *)0x02010014)

// --------------------------------------------------------

extern uint32_t flashio_worker_begin;
extern uint32_t flashio_worker_end;

void flashio(uint8_t *data, int len, uint8_t wrencmd)
{
	uint32_t func[&flashio_worker_end - &flashio_worker_begin];

	uint32_t *src_ptr = &flashio_worker_begin;
	uint32_t *dst_ptr = func;

	while (src_ptr != &flashio_worker_end)
		*(dst_ptr++) = *(src_ptr++);

	((void(*)(uint8_t*, uint32_t, uint32_t))func)(data, len, wrencmd);
}

void set_flash_qspi_flag()
{
	uint8_t buffer_rd[2] = {0x05, 0};
	flashio(buffer_rd, 2, 0);

	uint8_t status_1 = buffer_rd[1];

	buffer_rd[0] = 0x35;
	flashio(buffer_rd, 2, 0);

	uint8_t status_2 = buffer_rd[1];

	/* Enable QSPI */
	status_2 |= (1 << 1);

	uint8_t buffer_wr[3] = {0x01, status_1, status_2};
	flashio(buffer_wr, 3, 0);
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
	reg_uart_data = c;
}

void print(const char *p)
{
	while (*p)
		putchar(*(p++));
}

void print_hex(uint32_t v, int digits)
{
	for (int i = 7; i >= 0; i--) {
		char c = "0123456789abcdef"[(v >> (4*i)) & 15];
		if (c == '0' && i >= digits) continue;
		putchar(c);
		digits = i;
	}
}

void print_dec(uint32_t v)
{
	if (v >= 100) {
		print(">=100");
		return;
	}

	if      (v >= 90) { putchar('9'); v -= 90; }
	else if (v >= 80) { putchar('8'); v -= 80; }
	else if (v >= 70) { putchar('7'); v -= 70; }
	else if (v >= 60) { putchar('6'); v -= 60; }
	else if (v >= 50) { putchar('5'); v -= 50; }
	else if (v >= 40) { putchar('4'); v -= 40; }
	else if (v >= 30) { putchar('3'); v -= 30; }
	else if (v >= 20) { putchar('2'); v -= 20; }
	else if (v >= 10) { putchar('1'); v -= 10; }

	if      (v >= 9) { putchar('9'); v -= 9; }
	else if (v >= 8) { putchar('8'); v -= 8; }
	else if (v >= 7) { putchar('7'); v -= 7; }
	else if (v >= 6) { putchar('6'); v -= 6; }
	else if (v >= 5) { putchar('5'); v -= 5; }
	else if (v >= 4) { putchar('4'); v -= 4; }
	else if (v >= 3) { putchar('3'); v -= 3; }
	else if (v >= 2) { putchar('2'); v -= 2; }
	else if (v >= 1) { putchar('1'); v -= 1; }
	else putchar('0');
}

char getchar_prompt(char *prompt)
{
	int32_t c = -1;
	int flip = 0;

	uint32_t cycles_begin, cycles_now, cycles;
	__asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));

	if (prompt)
		print(prompt);

	reg_leds = 0x00010001;
	while (c == -1) {
		__asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
		if (cycles > 12000000) {
			if (prompt)
				print(prompt);
			cycles_begin = cycles_now;
			reg_leds = 0x00010000 | flip;
			flip ^= 1;
		}
		c = reg_uart_data;
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
	uint8_t buffer[17] = { 0x9F, /* zeros */ };
	flashio(buffer, 17, 0);

	for (int i = 1; i <= 16; i++) {
		putchar(' ');
		print_hex(buffer[i], 2);
	}
	putchar('\n');
}

// --------------------------------------------------------

uint8_t cmd_read_flash_regs_print(uint32_t addr, const char *name)
{
	set_flash_latency(8);

	uint8_t buffer[6] = {0x65, addr >> 16, addr >> 8, addr, 0, 0};
	flashio(buffer, 6, 0);

	print("0x");
	print_hex(addr, 6);
	print(" ");
	print(name);
	print(" 0x");
	print_hex(buffer[5], 2);
	print("\n");

	return buffer[5];
}

void cmd_read_flash_regs()
{
	print("\n");
	uint8_t sr1v = cmd_read_flash_regs_print(0x800000, "SR1V");
	uint8_t sr2v = cmd_read_flash_regs_print(0x800001, "SR2V");
	uint8_t cr1v = cmd_read_flash_regs_print(0x800002, "CR1V");
	uint8_t cr2v = cmd_read_flash_regs_print(0x800003, "CR2V");
	uint8_t cr3v = cmd_read_flash_regs_print(0x800004, "CR3V");
	uint8_t vdlp = cmd_read_flash_regs_print(0x800005, "VDLP");
}

// --------------------------------------------------------

uint32_t cmd_benchmark(bool verbose, uint32_t *instns_p)
{
	uint8_t data[256];
	uint32_t *words = (void*)data;

	uint32_t x32 = 314159265;

	uint32_t cycles_begin, cycles_end;
	uint32_t instns_begin, instns_end;
	__asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));
	__asm__ volatile ("rdinstret %0" : "=r"(instns_begin));

	for (int i = 0; i < 20; i++)
	{
		for (int k = 0; k < 256; k++)
		{
			x32 ^= x32 << 13;
			x32 ^= x32 >> 17;
			x32 ^= x32 << 5;
			data[k] = x32;
		}

		for (int k = 0, p = 0; k < 256; k++)
		{
			if (data[k])
				data[p++] = k;
		}

		for (int k = 0, p = 0; k < 64; k++)
		{
			x32 = x32 ^ words[k];
		}
	}

	__asm__ volatile ("rdcycle %0" : "=r"(cycles_end));
	__asm__ volatile ("rdinstret %0" : "=r"(instns_end));

	if (verbose)
	{
		print("Cycles: 0x");
		print_hex(cycles_end - cycles_begin, 8);
		putchar('\n');

		print("Instns: 0x");
		print_hex(instns_end - instns_begin, 8);
		putchar('\n');

		print("Chksum: 0x");
		print_hex(x32, 8);
		putchar('\n');
	}

	if (instns_p)
		*instns_p = instns_end - instns_begin;

	return cycles_end - cycles_begin;
}

// --------------------------------------------------------

void cmd_benchmark_all()
{
	uint32_t instns = 0;

	print("default        ");
	reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00000000;
	print(": ");
	print_hex(cmd_benchmark(false, &instns), 8);
	putchar('\n');

	for (int i = 8; i > 0; i--)
	{
		print("dspi-");
		print_dec(i);
		print("         ");

		set_flash_latency(i);
		reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00400000;

		print(": ");
		print_hex(cmd_benchmark(false, &instns), 8);
		putchar('\n');
	}

	for (int i = 8; i > 0; i--)
	{
		print("dspi-crm-");
		print_dec(i);
		print("     ");

		set_flash_latency(i);
		reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00500000;

		print(": ");
		print_hex(cmd_benchmark(false, &instns), 8);
		putchar('\n');
	}

	for (int i = 8; i > 0; i--)
	{
		print("qspi-");
		print_dec(i);
		print("         ");

		set_flash_latency(i);
		reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00200000;

		print(": ");
		print_hex(cmd_benchmark(false, &instns), 8);
		putchar('\n');
	}

	for (int i = 8; i > 0; i--)
	{
		print("qspi-crm-");
		print_dec(i);
		print("     ");

		set_flash_latency(i);
		reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00300000;

		print(": ");
		print_hex(cmd_benchmark(false, &instns), 8);
		putchar('\n');
	}

	for (int i = 8; i > 0; i--)
	{
		print("qspi-ddr-");
		print_dec(i);
		print("     ");

		set_flash_latency(i);
		reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00600000;

		print(": ");
		print_hex(cmd_benchmark(false, &instns), 8);
		putchar('\n');
	}

	for (int i = 8; i > 0; i--)
	{
		print("qspi-ddr-crm-");
		print_dec(i);
		print(" ");

		set_flash_latency(i);
		reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00700000;

		print(": ");
		print_hex(cmd_benchmark(false, &instns), 8);
		putchar('\n');
	}

	print("instns         : ");
	print_hex(instns, 8);
	putchar('\n');
}

// --------------------------------------------------------


FATFS FatFs;		/* FatFs work area needed for each volume */
FIL Fil;			/* File object needed for each open file */


void fatFS_write(void)
{
	UINT bw;
	FRESULT res;

	print("FatFs Test\r\n");
	

	res = f_mount(&FatFs, "", 0);		/* Give a work area to the default drive */
	if ((res = f_open(&Fil, "newfile.txt", FA_WRITE | FA_CREATE_ALWAYS)) == FR_OK) {	/* Create a file */
		if((res = f_write(&Fil, "It works!\r\n", 11, &bw)) == FR_OK){	/* Write data to the file */
			if((res = f_close(&Fil)) == FR_OK){								/* Close the file */
				if (bw == 11 && res == FR_OK) {		/* Lights green LED if data written well */
					print("It Works\r\n");
				}
			}
		}

	}

	if(res != FR_OK){
		print("Error\r\n");
		print_hex(res,2);
		print("\r\n");
		print_hex(bw,4);
		print("\r\n");
	}

	print("Test Complete\r\n");
		
}


uint8_t buff[512] __attribute__((aligned(8)));

void SD_ll()
{
	disk_initialize(0);

	for(int i = 0; i < 512; i++){
		if(i & 0x04){
			buff[i] = 0xFF;
		}
		else
			buff[i] = 0x00;
	}

	disk_write (
		0,
		buff,
		0x8000,
		1
	);

	dump(buff, 512);

}




void put_dump (const BYTE *buff, DWORD ofs, WORD cnt)
{
	WORD i;


	//xprintf(PSTR("%08lX:"), ofs);
	print_hex(ofs, 8);
	print(":");

	for(i = 0; i < cnt; i++){
		print(" ");
		print_hex(buff[i], 2);
		//xprintf(PSTR(" %02X"), buff[i]);
	}

	print(" ");
	for(i = 0; i < cnt; i++){
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

void dump (const BYTE *buff, WORD cnt)
{
	char* bp;
	WORD ofs;

for (bp=buff, ofs = 0; ofs < 0x200; bp+=16, ofs+=16)
					put_dump(bp, ofs, 16);
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
	reg_uart_clkdiv = 416;
	set_flash_qspi_flag();

	set_flash_latency(4);
	reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00300000;


	//set_hyperram_speed();

	
	//set_hyperram_speed();

	while (getchar_prompt("Press ENTER to continue..\n") != '\r')
	{ /* wait */
	}

	print("\r\n");
	print("  __               __            __                 \r\n");
	print(" |__) _  _ _  _   |_ _ _  _  _  / _  _ _ |_ |_  _ _ \r\n");
	print(" |__)(_)_)(_)| )  | | (_||||(-  \\__)| (_||_)|_)(-|  \r\n");
	print("                                                    \r\n");
	print("  Boson Frame Grabber. Powered by picorv32, ECP5\r\n");
	print("    Build Date: "__DATE__" "__TIME__"\r\n");

	while (1)
	{
		print("\n");
		print("\n");
		print("SPI State:\n");

		print("  LATENCY ");
		print_dec((reg_spictrl >> 16) & 15);
		print("\n");

		print("  DDR ");
		if ((reg_spictrl & (1 << 22)) != 0)
			print("ON\n");
		else
			print("OFF\n");

		print("  QSPI ");
		if ((reg_spictrl & (1 << 21)) != 0)
			print("ON\n");
		else
			print("OFF\n");

		print("  CRM ");
		if ((reg_spictrl & (1 << 20)) != 0)
			print("ON\n");
		else
			print("OFF\n");

		print("\n");
		print("Select an action:\n");
		print("\n");
		print("   [1] FATFS Write\n");
		print("   [2] Read SPI Config Regs\n");
		print("   [3] Switch to default mode\n");
		print("   [4] Switch to Dual I/O mode\n");
		print("   [5] Switch to Quad I/O mode\n");
		print("   [6] Switch to Quad DDR mode\n");
		print("   [7] Toggle continuous read mode\n");
		print("   [9] Run simplistic benchmark\n");
		print("   [0] Benchmark all configs\n");
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
				fatFS_write();
				break;
			case '2':
				SD_ll();
			case '3':
				reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00000000;
				break;
			case '4':
				reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00400000;
				break;
			case '5':
				reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00200000;
				break;
			case '6':
				reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00600000;
				break;
			case '7':
				reg_spictrl = reg_spictrl ^ 0x00100000;
				break;
			case '9':
				cmd_benchmark(true, 0);
				break;
			case '0':
				cmd_benchmark_all();
				break;
			default:
				continue;
			}

			break;
		}
	}
}

