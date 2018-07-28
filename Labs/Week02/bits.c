// COMP1521 18s1 Week 02 Lab (warm-up)

#include <stdio.h>

int main()
{
	// Code to generate and display the largest "int" value
    
    int mask = 1, x = 0, i = 0;
	for (i = 0; i < (sizeof(int)*8)-2; i++) {
	    x = (x | mask);
	    x = x << 1;
	}
	x = x+1;
	printf("int %x, %d\n", x, x);

	// Code to generate and display the largest "unsigned int" value

	unsigned int y = 0;
	int j = 0;
	for (j = 0; j < (sizeof(unsigned int)*8)-1; j++) {
	    y = (y|mask);
	    y = y << 1;
	}
	y = y + 1;
	printf("unsigned int %x, %u\n", y, y);
	// Code to generate and display the largest "long int" value
	long int xx = 0;
	int k = 0;
	for (k = 0; k < (sizeof(long int)*8)-2; k++) {
	    xx = (xx|mask);
	    xx = xx << 1;
	}
	xx = xx + 1;	
	printf("long int %lx, %ld\n", xx, xx);

	// Code to generate and display the largest "unsigned long int" value

	unsigned long int xy = 0;
	int l = 0;
	for (l = 0; l < (sizeof(unsigned long int)*8)-1; l++) {
	    xy = (xy|mask);
	    xy = xy << 1;
	}
	xy = xy + 1;
	printf("unsigned long int %lx, %lu\n", xy, xy);

	// Code to generate and display the largest "long long int" value

	long long int xxx = 0;
	int m = 0;
	for (m = 0; m < (sizeof(long long int)*8)-2; m++) {
	    xxx = (xxx|mask);
	    xxx = xxx << 1;
	}
	xxx = xxx + 1;		
	printf("long long int %llx, %lld\n", xxx, xxx);

	// Code to generate and display the largest "unsigned long long int" value

	unsigned long long int xxy = 0;
	int n = 0;
	for (n = 0; n < (sizeof(unsigned long long int)*8)-1; n++) {
	    xxy = (xxy|mask);
	    xxy = xxy << 1;
	}
	xxy = xxy + 1;
	printf("unsigned long long int %llx, %llu\n", xxy, xxy); 
	return 0;
} 

