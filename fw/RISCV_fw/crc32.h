#ifndef CRC32_H_
#define CRC32_H_

#include <stdint.h>

void crc32_clear();
uint32_t crc32_value();
void crc32_input(uint32_t value);

#endif