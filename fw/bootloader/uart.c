#include "uart.h"
#include <stdint.h>

/* Register defines */
#define UART0_BASE 0x02001100
#define UART0_SETUP (*(volatile uint32_t *)((UART0_BASE) + 0x0))
#define UART0_FIFO (*(volatile uint32_t *)((UART0_BASE) + 0x4))
#define UART0_RXREG (*(volatile uint32_t *)((UART0_BASE) + 0x8))
#define UART0_TXREG (*(volatile uint32_t *)((UART0_BASE) + 0xc))


void uartInit()
{
	UART0_SETUP = 417;
}

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
