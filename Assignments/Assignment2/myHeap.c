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
#define HEADER_SIZE 8

#define ALLOC     0x55555555
#define FREE      0xAAAAAAAA

void fix_freeList(int n);	 // Helper function to adjust freeList after nFree changes
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
		if ((freechunk->size >= minsize) && (freechunk->size < minsize + MIN_CHUNK) ) {			// If free chunk is larger than minsize and smaller than minsize + min_chunk
			// Use the whole chunk
			freechunk->status = ALLOC;										
			datapointer = freeList[i] + sizeof(Header);
			nFree--;							// Decrement free chunks
			fix_freeList(i);					// Helper function to adjust freeList positions
			return datapointer;
		}
		else if (freechunk->size >= minsize + MIN_CHUNK) {				// If size of free chunk is greater than minsize + MIN_CHUNK, split into 2 chunks
			int oldsize = freechunk->size;								// Store the size of the original free chunk 
			freechunk->status = ALLOC;									// Allocate only the first part of the free chunk
			freechunk->size = minsize;
			datapointer = freeList[i] + sizeof(Header);
			Header *newfree = freeList[i] + minsize;					// Create header at the end of the newly allocated chunk (for the new free chunk)
			newfree->status = FREE;										// Initialise the new free chunk's header
			newfree->size = oldsize - freechunk->size;
			freeList[i] = newfree;										// Update freeList to include the newly created free chunk
			return datapointer;
		}
	}
   return NULL; // this just keeps the compiler quiet
}

// free a chunk of memory
void myFree(void *block)
{
    Header *currhead = (Header *)block;
    currhead = (Header *)((char *)currhead - HEADER_SIZE);

	// Error checking
    if (heapOffset(currhead) == -1 || currhead->status != ALLOC) {
		fprintf(stderr, "Attempt to free unallocated chunk\n");
        exit(1); 
    }

	// Edge case for if entire chunk is allocated
	if (nFree == 0) {
		currhead->status = FREE;
		nFree++;
		freeList[0] = currhead;
	}
	   
	else {
		int i;
		int currsize = currhead->size;
		int prevchunkindex = 0;
		int nextchunkindex = 0;
		int nextfree = 0;
		int existsFreeAfter = 0;
			
		// Iterate through freeList until we find a free chunk to the right of the block and 
		// store the index of the first free chunks to the left and right of the block and 
		// let nextfree = 1 if that happens
		for (i = 0; i < nFree; i++){
			if (heapOffset(currhead) < heapOffset(freeList[i])){
				prevchunkindex = i - 1;
				nextchunkindex = i;
				nextfree = 1;
				break;
			 }
		 }
		// If no free chunk to right of block, set index for the prev free chunk to last element in freeList
		if (nextfree == 0){
			prevchunkindex = nFree - 1;
		} 
		// If there is a free chunk to right of block
		else {
			Header *nextheader = (Header *)freeList[nextchunkindex];
			if (heapOffset(currhead) + currhead->size == heapOffset(nextheader)) {			// If free chun to the right is adjacent
				currsize += nextheader->size;												// Merge the two chunks
				existsFreeAfter = 1;														// Set existsFreeAfter to 1 to indicate that there is a free adjacent chunk to the right
			}
		}
		// If a free chunk before block exists
		if (prevchunkindex >= 0) {
			Header *prevheader = (Header *)freeList[prevchunkindex];
         // If free chunk before block is adjacent, merge them 
			if (heapOffset(prevheader) + prevheader->size == heapOffset(currhead)) {
				currsize += prevheader->size;
				prevheader->size = currsize;
				freeList[prevchunkindex] = (Addr *)prevheader;
				// If there exists a free adjacent chunk after the current block, remove it from freeList,
				// adjust list positions, decrement nFrees
				if (existsFreeAfter == 1) {
					for (i = nextchunkindex; i < nFree; i++) {
						freeList[i] = freeList[i+1];
					}
					freeList[nFree] = NULL;
					nFree--;
				 }
			} 
			// If the free chunk before current block is NOT adjacent
			else {								
				if (existsFreeAfter == 0) {							// If free chunk after the block is also NOT adjacent
					nFree++;										// Increment number of free chunks
					for (i = nFree-1; i > prevchunkindex; i--){		// Adjust freeList positions
						freeList[i] = freeList[i-1];
					}
				}
				currhead->status = FREE;							// Update status and size
				currhead->size = currsize;
				freeList[nextchunkindex] = (Addr *)currhead;		// Insert address in correct index
			}
		} 
		// If no free chunk before current block exists
		else {
			if (existsFreeAfter == 0) {								// If free chunk after block is NOT adjacent
				nFree++;											// Increment nFree
				for (i = nFree-1; i >= 0; i--) {					// Adjust list positions
					freeList[i] = freeList[i-1];
				 }
			}
			freeList[0] = (Addr *)currhead;							// Update status, size and positions
			currhead->status = FREE;
			currhead->size = currsize;
		}
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

// Helper function to adjust freeList after number of elems changes
void fix_freeList(int n) {
	while (n < nFree) {
		freeList[n] = freeList[n+1];
		n++;
	}
}

