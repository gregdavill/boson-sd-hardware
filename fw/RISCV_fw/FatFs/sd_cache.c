
#include <stdint.h>
#include "sd_cache.h"
#include <string.h>
#include "rb_tree.h"

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

struct cache_block {
	uint8_t data[512]; /* block of data */
};

/* SD cache itself is located in external SDRAM */
static struct cache_block* sd_cache;
static uint32_t sd_cache_blocks;
static uint32_t sd_cache_used;

static rb_red_blk_tree rbTree_address;

/* Note head points to head and tail */
static rb_red_blk_node sd_cache_list_head;

#define SD_CACHE_NODES 8
static const uint32_t sd_cache_rb_nodes_total = SD_CACHE_NODES;
static rb_red_blk_node sd_cache_rb_nodes[SD_CACHE_NODES];
static rb_red_blk_node* sd_cache_rb_nodes_list = 0;
static uint32_t sd_cache_rb_nodes_used = 0;

bool sd_cache_locate(uint32_t address, struct cache_block** cache_object);
//bool sd_cache_new(struct cache_block** cache_object);

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
void sd_cache_lru_update(rb_red_blk_node* node) {
	doubly_linkedlist_remove(node);

	/* Add node after head of list */
	node->next = sd_cache_list_head.next;
	node->prev = &sd_cache_list_head;

	sd_cache_list_head.next->prev = node;
	sd_cache_list_head.next = node;
}

/* Return a free memory block */
void* sd_cache_malloc(int core_node) {

	/* Take Last node in LRU list */
	rb_red_blk_node* newNode = sd_cache_list_head.prev;

	/* Remove node from rb tree */
	if (newNode->left) {
		RBDelete(&rbTree_address, newNode);
	}

	/* rb_tree code requires 2 core nodes, that cannot be re-assigned */
	if (core_node) {
		doubly_linkedlist_remove(newNode);
	} else {
		sd_cache_lru_update(newNode);
	}

	/* Return freed node to app */
	return newNode;
}

void sd_cache_init(uint32_t cache_address, uint32_t numOfBlocks) {
	sd_cache = (struct cache_block*) cache_address;
	sd_cache_blocks = sd_cache_rb_nodes_total;
	sd_cache_used = 0;

	/* Init head LRU list */
	sd_cache_list_head.next = &sd_cache_list_head;
	sd_cache_list_head.prev = &sd_cache_list_head;

	/* Init LRU list and assign data blocks to nodes */
	/* Needs to support a repeated call. */
	for (uint32_t i = 0; i < sd_cache_rb_nodes_total; i++) {
		sd_cache_rb_nodes[i].left = 0;
		sd_cache_rb_nodes[i].right = 0;
		sd_cache_rb_nodes[i].prev = 0;
		sd_cache_rb_nodes[i].next = 0;
		sd_cache_rb_nodes[i].key = 0;
		sd_cache_rb_nodes[i].info = &sd_cache[i];
		sd_cache_lru_update(&sd_cache_rb_nodes[i]);
	}

	/* Init rb tree */
	RBTreeCreate(&rbTree_address, IntComp, IntDest, InfoDest, IntPrint,
			InfoPrint, sd_cache_malloc);

}

bool sd_cache_locate(uint32_t address, struct cache_block** cache_object) {
	rb_red_blk_node* node = RBExactQuery(&rbTree_address, (void*) address);

	if (node == 0 || node->info == 0) {
		return false;
	}

	*cache_object = (struct cache_block*) node->info;
	sd_cache_lru_update(node);

	if (*cache_object == 0) {
		return false;
	}

	return true;

}

bool sd_cache_new(uint32_t key, struct cache_block** cache_object) {
	rb_red_blk_node* node = RBTreeInsert(&rbTree_address, (void*) key, 0);

	*cache_object = (struct cache_block*) node->info;

	if (*cache_object == 0) {
		return false;
	}

	return true;

}

/* Attempt to find a memory address in cache. write data to pData if found and return true */
bool sd_cache_read(void* pData, uint32_t ReadAddr, uint32_t NumOfBlocks) {
	/* only support single blocks right now */
	if (NumOfBlocks > 1) {
		return false;
	}

	struct cache_block* cache_object = 0;

	if (sd_cache_locate(ReadAddr, &cache_object)) {
		memcpy(pData, cache_object->data, 512);
		return true;
	}

	return false;
}

/* write new entry into the cache */
bool sd_cache_create(void* pData, uint32_t ReadAddr, uint32_t NumOfBlocks) {
	/* only support single blocks right now */
	if (NumOfBlocks > 1) {
		return false;
	}

	struct cache_block* cache_object = 0;

	/* Update */
	if (sd_cache_locate(ReadAddr, &cache_object)) {
		memcpy(cache_object->data, pData, 512);
		return true;
	} else if (sd_cache_new(ReadAddr, &cache_object)) {
		memcpy(cache_object->data, pData, 512);
		return true;
	}

	return false;

}

/* update new entry into the cache */
bool sd_cache_update(void* pData, uint32_t ReadAddr, uint32_t NumOfBlocks) {
	/* only support single blocks right now */
	if (NumOfBlocks > 1) {
		return false;
	}

	struct cache_block* cache_object = 0;

	/* Update */
	if (sd_cache_locate(ReadAddr, &cache_object)) {
		memcpy(cache_object->data, pData, 512);
		return true;
	}
	return false;

}

