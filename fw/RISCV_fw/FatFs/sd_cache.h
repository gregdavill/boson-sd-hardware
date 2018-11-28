/*
 * sd_cache.h
 *
 *  Created on: 24Mar.,2017
 *      Author: greg
 */

#ifndef SD_CACHE_H__
#define SD_CACHE_H__

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

void sd_cache_init(uint32_t cache_address, uint32_t numOfBlocks);

/* Attempt to find a memory address in cache. write data to pData if found and return true */
bool sd_cache_read(void* pData, uint32_t ReadAddr, uint32_t NumOfBlocks);
/* write new entry into the cache */
bool sd_cache_create(void* pData, uint32_t ReadAddr, uint32_t NumOfBlocks);
/* update new entry into the cache */
bool sd_cache_update(void* pData, uint32_t ReadAddr, uint32_t NumOfBlocks);

#ifdef __cplusplus
}
#endif


#endif /* SST_PUBLIC_sd_cache_H_ */
