#include <stdint.h>
#include <stdbool.h>

#include "ff.h" /* Declarations of FatFs API */

#define reg_spictrl (*(volatile uint32_t *)0x02000000)
#define reg_uart_clkdiv (*(volatile uint32_t *)0x02000004)
#define reg_uart_data (*(volatile uint32_t *)0x02000008)

#define reg_spi_clkdiv (*(volatile uint32_t *)0x02000010)
#define reg_spi_conf (*(volatile uint32_t *)0x02000014)
#define reg_spi_data (*(volatile uint32_t *)0x02000018)

#define reg_gpio (*(volatile uint32_t *)0x03000000)
#define reg_gpio_in (*(volatile uint32_t *)0x03000004)

#define SPI_CONF_IDLE 0x2

#define reg_boson_ctrl (*(volatile uint32_t *)0x03000008)

#define reg_hyperram_ctrl_a (*(volatile uint32_t *)0x03000010)
#define reg_hyperram_ctrl_b (*(volatile uint32_t *)0x03000014)

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

	((void (*)(uint8_t *, uint32_t, uint32_t))func)(data, len, wrencmd);
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

	uint8_t buffer_wr[3] = {0x06, status_1, status_2};
	flashio(buffer_wr, 1, 0);

	buffer_wr[0] = 0x01;
	flashio(buffer_wr, 3, 0x06);
}

void set_flash_latency(uint8_t value)
{
	reg_spictrl = (reg_spictrl & ~0x007f0000) | ((value & 15) << 16);

	uint32_t addr = 0x800004;
	uint8_t buffer_wr[5] = {0x71, addr >> 16, addr >> 8, addr, 0x70 | value};
	flashio(buffer_wr, 5, 0x06);
}

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
	set_latency(0x4, 0x7);
}

// --------------------------------------------------------

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
	uint32_t digits = 1;
	uint32_t divisor = 100000;

	for (int i = 5; i >= 0; i--)
	{
		char c = ((v / divisor) % 10) + '0';
		divisor /= 10;
		if (c == '0' && i >= digits)
			continue;
		putchar(c);
		digits = i;
	}
}

char getchar_prompt(char *prompt)
{
	int32_t c = -1;

	uint32_t cycles_begin, cycles_now, cycles;
	__asm__ volatile("rdcycle %0"
					 : "=r"(cycles_begin));

	if (prompt)
		print(prompt);

	reg_gpio |= 1;
	while (c == -1)
	{
		__asm__ volatile("rdcycle %0"
						 : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
		if (cycles > 12000000)
		{
			if (prompt)
				print(prompt);
			cycles_begin = cycles_now;
			reg_gpio ^= 1;
		}
		c = reg_uart_data;
	}
	reg_gpio &= ~1;
	return c;
}

char getchar()
{
	return getchar_prompt(0);
}

// -------------------------------------------------------

uint32_t cycles_begin, cycles_end;

void start_profiler()
{
	__asm__ volatile("rdcycle %0"
					 : "=r"(cycles_begin));
}

void end_profiler()
{
	__asm__ volatile("rdcycle %0"
					 : "=r"(cycles_end));
}

void print_profiler_results(char *func)
{
	print(func);

	print(" ");

	uint32_t cycles = cycles_end - cycles_begin;
	uint32_t time_ms = cycles / 24000;

	print_dec(time_ms);
	putchar('.');
	putchar((cycles / 2400 % 10 + '0'));
	putchar((cycles / 240 % 10 + '0'));
	print("ms\n");
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

// --------------------------------------------------------

uint8_t cmd_read_flash_regs_print(uint32_t addr, const char *name)
{
	//set_flash_latency(8);

	uint8_t buffer[2] = {addr, 0};
	flashio(buffer, 2, 0);

	print(name);
	print(" 0x");
	print_hex(buffer[1], 2);
	print("\n");

	return buffer[1];
}

void cmd_read_flash_regs()
{
	print("\n");
	uint8_t sr1v = cmd_read_flash_regs_print(0x05, "CONF1");
	uint8_t sr2v = cmd_read_flash_regs_print(0x35, "CONF2");
}

void delay(uint32_t cycles_total)
{

	uint32_t cycles_begin, cycles_now, cycles;
	__asm__ volatile("rdcycle %0"
					 : "=r"(cycles_begin));

	while (true)
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

bool sd_present()
{
	return reg_gpio_in & 0x00000001 ? false : true;
}

uint8_t spi_xfer(uint8_t data)
{
	reg_spi_data = data;

	uint32_t cycles_begin, cycles_now, cycles;
	__asm__ volatile("rdcycle %0"
					 : "=r"(cycles_begin));

	while (!(reg_spi_conf & SPI_CONF_IDLE))
	{
		__asm__ volatile("rdcycle %0"
						 : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
		if (cycles > 120000)
		{
			break;
		}
	}

	return reg_spi_data;
}

void spi_test()
{

	if (sd_present())
		print("SD_CD:PRESENT\n");
	else
		print("SD_CD:NOT_PRESENT\n");
}

FATFS fat_fs; /* FatFs work area needed for each volume */
FIL fil;	  /* File object needed for each open file */

void print_rc(char *func, uint32_t rc)
{
	print(func);
	print(": ");
	print_dec(rc);
	print("\n");
}

void capture_frame_to_ram()
{

	start_profiler();

	reg_boson_ctrl = 1;
	while (reg_boson_ctrl & 1)
	{
	};

	end_profiler();

	print_profiler_results("capture_frame_time:");
}

void print_ram()
{
	uint32_t data;
	uint32_t *ptr;

	ptr = 0x04000000;
	print("HyperRam Read\r\n");

	for (uint32_t i = 0; i < 32; i++)
	{
		print_hex(*ptr++, 8);
		if (i % 8 == 7)
			print("\r\n");
		else
			print(" ");
	}
}



void write_ram()
{
	uint32_t data;
	uint32_t *ptr;

	ptr = 0x04000000;
	print("HyperRam Write\r\n");

	for (uint32_t i = 0; i < 32; i++)
	{
		*ptr++ = 0xAABBCCDD;
		*ptr++ = 0x11223344;

		*ptr++ = 0x01020304;
		*ptr++ = 0x05060708;
	}
}

// --------------------------------------------------------

void save_ram_to_sd()
{

	UINT bw;
	FRESULT rc;

	uint8_t *ptr = 0x04000000;

	rc = f_mount(&fat_fs, "", 0); /* Give a work area to the default drive */
	rc = f_open(&fil, "test_002.raw", FA_WRITE | FA_CREATE_ALWAYS);

	if (rc == FR_OK)
	{
		start_profiler();
		//rc = f_expand(&fil, 256 * 320 * 2, 0);

		if (rc == FR_OK)
		{ /* Create a file */

			rc |= f_write(&fil, ptr, 256 * 320 * 2, &bw); /* Write data to the file */
			rc |= f_close(&fil);						  /* Close the file */

			if (rc == FR_OK)
			{
				end_profiler();
				print_profiler_results("sd_write_time (160kb):");
				return;
			}
		}
	}

	print_rc("SD error. rc: ", rc);
}

void print_spi_settings()
{
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
}

// --------------------------------------------------------
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

	reg_uart_clkdiv = 104;
	reg_uart_clkdiv = 208;

	set_flash_qspi_flag();
	reg_spictrl = (reg_spictrl & ~0x00700000) | 0x00300000;

	set_hyperram_speed();

	while (getchar_prompt("Press ENTER to continue..\n") != '\r')
	{ /* wait */
	}

	print("\r\n");
print("  __               __            __                 \r\n");
print(" |__) _  _ _  _   |_ _ _  _  _  / _  _ _ |_ |_  _ _ \r\n");
print(" |__)(_)_)(_)| )  | | (_||||(-  \\__)| (_||_)|_)(-|  \r\n");
print("                                                    \r\n");
print("  Boson Frame Grabber. Powered by PicoSoC, Icestorm\r\n");
print("    Build Date: "__DATE__" "__TIME__"\r\n");

	while (1)
	{
		print("\n");
		print("\n");

		print("\n");
		print("Select an action:\n");
		print("\n");
		print("   [1] Capture Frame to RAM\n");
		print("   [2] Save RAM to SD\n");
		print("   [3] Capture and Save\n");
		print("   [4] Print RAM Values\n");
		print("   [5] Write RAM Values\n");

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
				capture_frame_to_ram();
				break;
			case '2':
				save_ram_to_sd();
				break;
			case '3':
				capture_frame_to_ram();
				save_ram_to_sd();
				break;
			case '4':
				print_ram();
				break;
			case '5':
				write_ram();
				break;
			default:
				continue;
			}

			break;
		}
	}
}
