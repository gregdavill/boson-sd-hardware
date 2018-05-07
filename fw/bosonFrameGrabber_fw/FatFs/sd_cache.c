/*
 * SD_cache.cpp
 *
 *  Created on: 24Mar.,2017
 *      Author: greg
 */

#include "sd_cache.h"
#include <string.h>
#include "rb_tree.h"

#ifndef true
#define true (1)
#endif
#ifndef false
#define false (0)
#endif

/*
 * SD cache:
 * 	512byte blocks
 * 	rb tree retrieval
 * 	Doubly linked list for LRU replacement
 * 	Fixed cache size set at compile time
 * 	Write through
 *
 * 	rb tree
 * 	 Key = SD sector address
 * 	 Value = pointer to 512 data block
 */

typedef struct cache_block_ {
	uint8_t data[512]; /* block of data */
}cache_block;

/* SD cache itself is located in external SDRAM */
static cache_block* SD_cache;
static uint32_t SD_cache_blocks;
static uint32_t SD_cache_used;

static rb_red_blk_tree rbTree_address;

/* Note head points to head and tail */
static rb_red_blk_node SD_cache_list_head;

#define  SD_cache_rb_nodes_total 32
rb_red_blk_node SD_cache_rb_nodes[SD_cache_rb_nodes_total];
rb_red_blk_node* SD_cache_rb_nodes_list = 0;
uint32_t SD_cache_rb_nodes_used = 0;

bool SD_cache_locate(uint32_t address, cache_block** cache_object);
//bool SD_cache_new(cache_block** cache_object);

void IntDest(void* a) {
	//free((int*)a);
}

int IntComp(const void* a, const void* b) {
	if ((int) a > (int) b)
		return (1);
	if ((int) a < (int) b)
		return (-1);
	return (0);
}
void IntPrint(const void* a) {
	//printf("%i",*(int*)a);
}

void InfoPrint(void* a) {
	;
}

void InfoDest(void *a) {
	;
}

/* Remove a node from the LRU list */
void doubly_linkedlist_remove(rb_red_blk_node* node) {
	if (node->next && node->prev) {
		/* If required Patch hole in linked list */
		node->prev->next = node->next;
		node->next->prev = node->prev;
	}

	/* Clear pointers in node */
	node->next = 0;
	node->prev = 0;
}

/* Move node to front of LL */
void SD_cache_lru_update(rb_red_blk_node* node) {
	doubly_linkedlist_remove(node);

	/* Add node after head of list */
	node->next = SD_cache_list_head.next;
	node->prev = &SD_cache_list_head;

	SD_cache_list_head.next->prev = node;
	SD_cache_list_head.next = node;
}

/* Return a free memory block */
void* SD_cache_malloc(int core_node) {

	/* Take Last node in LRU list */
	rb_red_blk_node* newNode = SD_cache_list_head.prev;

	/* Remove node from rb tree */
	if (newNode->left) {
		RBDelete(&rbTree_address, newNode);
	}

	/* rb_tree code requires 2 core nodes, that cannot be re-assigned */
	if (core_node) {
		doubly_linkedlist_remove(newNode);
	} else {
		SD_cache_lru_update(newNode);
	}

	/* Return freed node to app */
	return newNode;
}

void SD_cache_init(uint32_t cache_address, uint32_t numOfBlocks) {
	SD_cache = (cache_block*) cache_address;
	SD_cache_blocks = SD_cache_rb_nodes_total;
	SD_cache_used = 0;

	/* Init head LRU list */
	SD_cache_list_head.next = &SD_cache_list_head;
	SD_cache_list_head.prev = &SD_cache_list_head;

	/* Init LRU list and assign data blocks to nodes */
	/* Needs to support a repeated call. */
	for (uint32_t i = 0; i < SD_cache_rb_nodes_total; i++) {
		SD_cache_rb_nodes[i].left = 0;
		SD_cache_rb_nodes[i].right = 0;
		SD_cache_rb_nodes[i].prev = 0;
		SD_cache_rb_nodes[i].next = 0;
		SD_cache_rb_nodes[i].key = 0;
		SD_cache_rb_nodes[i].info = &SD_cache[i];
		SD_cache_lru_update(&SD_cache_rb_nodes[i]);
	}

	/* Init rb tree */
	RBTreeCreate(&rbTree_address, IntComp, IntDest, InfoDest, IntPrint,
			InfoPrint, SD_cache_malloc);

}

bool SD_cache_locate(uint32_t address, cache_block** cache_object) {
	rb_red_blk_node* node = RBExactQuery(&rbTree_address, (void*) address);

	if (node == 0 || node->info == 0) {
		return false;
	}

	*cache_object = (cache_block*) node->info;
	SD_cache_lru_update(node);

	if (*cache_object == 0) {
		return false;
	}

	return true;

}

bool SD_cache_new(uint32_t key, cache_block** cache_object) {
	rb_red_blk_node* node = RBTreeInsert(&rbTree_address, (void*) key, 0);

	*cache_object = (cache_block*) node->info;

	if (*cache_object == 0) {
		return false;
	}

	return true;

}

/* Attempt to find a memory address in cache. write data to pData if found and return true */
bool SD_cache_read(void* pData, uint32_t ReadAddr, uint32_t NumOfBlocks) {
	/* only support single blocks right now */
	if (NumOfBlocks > 1) {
		return false;
	}

	cache_block* cache_object = 0;

	if (SD_cache_locate(ReadAddr, &cache_object)) {
		memcpy(pData, cache_object->data, 512);
		return true;
	}

	return false;
}

/* write new entry into the cache */
bool SD_cache_create(void* pData, uint32_t ReadAddr, uint32_t NumOfBlocks) {
	/* only support single blocks right now */
	if (NumOfBlocks > 1) {
		return false;
	}

	cache_block* cache_object = 0;

	/* Update */
	if (SD_cache_locate(ReadAddr, &cache_object)) {
		memcpy(cache_object->data, pData, 512);
		return true;
	} else if (SD_cache_new(ReadAddr, &cache_object)) {
		memcpy(cache_object->data, pData, 512);
		return true;
	}

	return false;

}

/* update new entry into the cache */
bool SD_cache_update(void* pData, uint32_t ReadAddr, uint32_t NumOfBlocks) {
	/* only support single blocks right now */
	if (NumOfBlocks > 1) {
		return false;
	}

	cache_block* cache_object = 0;

	/* Update */
	if (SD_cache_locate(ReadAddr, &cache_object)) {
		memcpy(cache_object->data, pData, 512);
		return true;
	}
	return false;

}

