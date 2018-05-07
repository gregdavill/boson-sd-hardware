/*
 * SD_cache.h
 *
 *  Created on: 24Mar.,2017
 *      Author: greg
 */

#ifndef SST_PUBLIC_SD_CACHE_H_
#define SST_PUBLIC_SD_CACHE_H_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef bool
typedef uint8_t bool;
#endif

void SD_cache_init(uint32_t cache_address, uint32_t numOfBlocks);

/* Attempt to find a memory address in cache. write data to pData if found and return true */
bool SD_cache_read(void* pData, uint32_t ReadAddr, uint32_t NumOfBlocks);
/* write new entry into the cache */
bool SD_cache_create(void* pData, uint32_t ReadAddr, uint32_t NumOfBlocks);
/* update new entry into the cache */
bool SD_cache_update(void* pData, uint32_t ReadAddr, uint32_t NumOfBlocks);

#ifdef __cplusplus
}
#endif


#endif /* SST_PUBLIC_SD_CACHE_H_ */
