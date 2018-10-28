#ifndef UART_H__
#define UART_H__

#include <stdint.h>

/* Public interface */
void uartInit();
void putchar(char c);
void print(const char *p);
void print_hex(uint32_t v, int digits);

#endif