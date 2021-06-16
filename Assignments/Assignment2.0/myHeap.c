// COMP1521 18s1 Assignment 2
// Implementation of heap management system

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "myHeap.h"

// minimum total space for heap
#define MIN_HEAP  4096
// minimum amount of space for a free Chunk (excludes Header)
#define MIN_CHUNK 32

#define ALLOC     0x55555555
#define FREE      0xAAAAAAAA

typedef unsigned int uint;   // counters, bit-strings, ...

typedef void *Addr;          // addresses

typedef struct {             // headers for Chunks
   uint  status;             // status (ALLOC or FREE)
   uint  size;               // #bytes, including header
} Header;

static Addr  heapMem;        // space allocated for Heap
static int   heapSize;       // number of bytes in heapMem
static Addr *freeList;       // array of pointers to free chunks
static int   freeElems;      // number of elements in freeList[]
static int   nFree;          // number of free chunks

// initialise heap
int initHeap(int size)
{
	int newsize = 0;
	if (size < MIN_HEAP) {												// If size < minheap, just use minheap
		newsize = MIN_HEAP;
		heapMem = malloc(newsize);
	}
	else if ( (size%4) != 0) {
		newsize = size + (4-(size%4));									// If size > min_heap and isn't a multiple of 4, make it the next highest multiple of 4
		heapMem = malloc(newsize);										// Allocate memory and zero it all out
	}
	else if (size%4 == 0) {												// If size is > min_heap and a multiple of 4, just malloc normally
		newsize = size;
		heapMem = malloc(newsize);
	}
	heapSize = newsize;
	freeElems = newsize/MIN_CHUNK*sizeof(Addr);
	nFree = 1;
	freeList = malloc((newsize/MIN_CHUNK) * sizeof(Addr));				// Allocate memory for freeList array
	memset(heapMem, 0, newsize);										// Zero the heap out
	Header *h = heapMem;												// Set heapMem to be a single free chunk of size N
	h->status = FREE;
	h->size = newsize;
	freeList[0] = h;													// Make this chunk the only one in freeList
    return 0;															// This just keeps the compiler quiet
}

// clean heap
void freeHeap()
{
   free(heapMem);
   free(freeList);
}

// allocate a chunk of memory
void *myMalloc(int size)
{
	void *datapointer;
	int i;
	int newsize = 0;													// The size as the next highest multiple as 4 (if applicable)
	if (size%4 != 0) {
		newsize = size + (4-(size%4));
	}
	else if (size%4 == 0) {
		newsize = size;
	}
	int minsize = newsize + sizeof(Header);								// The smallest size chunk we can use must be at least newsize+header bytes
	for (i = 0; i < nFree; i++) {										// Iterate through freeList to check free chunks
		Header *freechunk = freeList[i];
		if ((freechunk->size >= minsize) && (freechunk->size < minsize + MIN_CHUNK) ) {
			// Use whole chunk
			freechunk->status = ALLOC;
			freechunk->size = freechunk->size; // Using the whole chunk
			datapointer = freeList[i] + sizeof(Header);
			nFree--;							// 1 less free chunk
			fix_freeList(i);
			return datapointer;
		}
		else if (freechunk->size >= minsize + MIN_CHUNK) {
			int oldsize = freechunk->size;
			freechunk->status = ALLOC;
			freechunk->size = minsize;
			datapointer = freeList[i] + sizeof(Header);
			Header *newfree = freeList[i] + minsize;
			newfree->status = FREE;
			newfree->size = oldsize - freechunk->size;
			freeList[i] = newfree;
			return datapointer;
		}
	}


/*    int headersize = sizeof(Header);
	int realsize = 0;
	int i = 0;
	Addr *datablock;                                                    // Pointer to start of datablock in chunk
	if ( (size%4) != 0) {												// If size isn't a multiple of 4, make it the next highest multiple of 4
		realsize = size + (4-(size%4));
	}
	else if (size%4 == 0) {												// If size is a multiple of 4, no need to adjust it
		realsize = size;
	}
	int min_size = headersize + realsize;								// Minimum size of usable free chunk is headersize + N, where headersize is 8 bytes

	// Allocate a chunk to hold at least N bytes
	// scan freeList to find best-fit free chunk
	// If adjacent chunks are free, merge into single large free chunk
	// adjust freeList appropriately

	// Find smallest free chunk that's bigger than N + HeaderSize
	while (freeList[i] != NULL) {	                                                                // Iterate through array of free chunks
	    Header *freechunk = freeList[i];                                                                // Pointer to the free chunk we are using to allocate space
		if ((freechunk->size > min_size) && freechunk->size < min_size + MIN_CHUNK) {				    // If the chunk is larger than N + Headersize but smaller than N+Header+MIN_CHUNK
			Header *alloc_chunk = freeList[i];								                            // Allocate the whole chunk
			alloc_chunk->status = ALLOC;
			alloc_chunk->size = realsize + headersize;
			datablock = freeList[i] + headersize;                                                       // Pointer to first usable data space
			nFree--;                                                                                    // Decrement number of free chunks
			return datablock;
		}
		else if ( (freechunk->size) > min_size + MIN_CHUNK) {			                                // If the free chunk is larger than N+HEADER+MIN_CHUNK
			Header *alloc_chunk = freeList[i];                                                          // Allocate part of the chunk
			alloc_chunk->status = ALLOC;
			alloc_chunk->size = realsize + headersize;
			datablock = freeList[i] + headersize;
			//Now create a new free chunk
			Header *newfreechunk = freeList[i] + alloc_chunk->size;                                     // Header of new free chunk points to end of newly allocated chunk
			newfreechunk->status = FREE;
			newfreechunk->size = freechunk->size - alloc_chunk->size;                                   // Size of the new free chunk is size of original free chunk minus size of newly allocated chunk
			freeList[i] = newfreechunk;
			return datablock;
		}
		i++;
		//else {
			printf("No free space :(\n");
		//}
    }

	//	*datablock = freeList[i] + 8

// How do I iterate through heapMem? (It's a bunch of space)
// How to return a pointer to the data, not the header?
// How to split into 2 chunks?
// Should freeList point to the header or data block?
*/
   return NULL; // this just keeps the compiler quiet
}

// free a chunk of memory
void myFree(void *block)
{
	int i, prevfree = 0, nextfree = 0;
	Addr prevchunk, nextchunk;
	Addr currchunk = block - sizeof(Header);
	Header *h = currchunk;
	if (h->status == FREE) {
		fprintf(stderr, "Attempt to free unallocated chunk\n");
		exit(1);
	}

	// This block of code is for checking if the last free chunk before the current chunk is DIRECTLY BEFORE it
	for (i = 0; i < nFree; i++) {												// Iterate through freeList to find the start of the last free chunk before the current chunk
		if (freeList[i] < currchunk) {
			prevchunk = freeList[i];
		}
	}
	Header *prevchunkheader = prevchunk;
	if ((prevchunkheader + prevchunkheader->size) == currchunk) {				// If the last free chunk IS directly before the current chunk
		prevfree = 1;															// Make prevfree = 1 to indicate that the chunk directly before the current chunk is also free
	}

	// This block of code is for checking if the chunk DIRECTLY AFTER the current chunk is free
	nextchunk = currchunk + h->size;
	Header *nextchunkheader = nextchunk;
	if (nextchunkheader->status == FREE) {										// If the next chunk is free
		nextfree = 1;															// Make nextfree = 1 to indicate that the next chunk is free
	}


	if (h->status == ALLOC && prevfree == 0 && nextfree == 0) {					// If current chunk has been allocated and both the previous chunk and next chunk are NOT FREE
		h->status = FREE;
	}

	else if (h->status == ALLOC && prevfree == 1 && nextfree == 1) {			// If current chunk has been allocated and both prev and next chunks ARE FREE
		h->status = FREE;
		prevchunkheader->size = prevchunkheader->size + h->size + nextchunkheader->size;		// Increase size of prev chunk to fill up current and next chunk
		h->size = 0;
		nextchunkheader->size = 0;
	}

	if (h->status == ALLOC && prevfree == 1 && nextfree == 0) {					// If only prev chunk is FREE
		h->status = FREE;
		prevchunkheader->size = prevchunkheader->size + h->size;
		h->size = 0;
	}

	if (h->status == ALLOC && prevfree == 0 && nextfree == 1) {					// If only next chunk is FREE
		h->status = FREE;
		h->size = h->size + nextchunkheader->size;
		nextchunkheader->size = 0;
	}
}

// convert pointer to offset in heapMem
int  heapOffset(void *p)
{
   Addr heapTop = (Addr)((char *)heapMem + heapSize);
   if (p == NULL || p < heapMem || p >= heapTop)
      return -1;
   else
      return p - heapMem;
}

// dump contents of heap (for testing/debugging)
void dumpHeap()
{
   Addr    curr;
   Header *chunk;
   Addr    endHeap = (Addr)((char *)heapMem + heapSize);
   int     onRow = 0;
   curr = heapMem;
   while (curr < endHeap) {
      char stat;
      chunk = (Header *)curr;
      switch (chunk->status) {
      case FREE:  stat = 'F'; break;
      case ALLOC: stat = 'A'; break;
      default:    fprintf(stderr,"Corrupted heap %08x\n",chunk->status); exit(1); break;
      }
      printf("+%05d (%c,%5d) ", heapOffset(curr), stat, chunk->size);
      onRow++;
      if (onRow%5 == 0) printf("\n");
      curr = (Addr)((char *)curr + chunk->size);
   }
   if (onRow > 0) printf("\n");
}

void fix_freeList(int n) {
	while (n < nFree) {
		freeList[n] = freeList[n+1];
		n++;
	}
}

/* My Malloc
    if we find a free chunk thats bigger than minsize butsmaller than minsize + min chunk {
        allocate the whole free chunk
        initialise a header
        return a pointer to the start of data space NOT HEADER*/
