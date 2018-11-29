#ifndef PROFILER_H__
#define PROFILER_H__

#include <stdint.h>

typedef struct {
	uint32_t start_time;
	uint32_t end_time;
} profiler_t;

void profiler_init(profiler_t* p);
void profiler_start(profiler_t* p);
void profiler_stop(profiler_t* p);
uint32_t profiler_read(profiler_t* p);


#endif