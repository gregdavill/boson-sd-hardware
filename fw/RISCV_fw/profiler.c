#include "profiler.h"

void profiler_init(profiler_t *p)
{
	p->end_time = p->start_time = 0;
}

void profiler_start(profiler_t *p)
{
	__asm__ volatile("rdcycle %0"
					 : "=r"(p->start_time));
}

void profiler_stop(profiler_t *p)
{
	__asm__ volatile("rdcycle %0"
					 : "=r"(p->end_time));
}

uint32_t profiler_read(profiler_t *p)
{
	return p->end_time - p->start_time;
}
