// where_are_the_bits.c ... determine bit-field order
// COMP1521 Lab 03 Exercise
// Written by ...

#include <stdio.h>
#include <stdlib.h>

struct _bit_fields {
   unsigned int a : 4,
                b : 8,
                c : 20;
};

union bitfields {
	unsigned int z;
	struct _bit_fields bf;
};


int main(void)
{
   union bitfields b;
//   struct _bit_fields x;
   b.bf.a = 1;
   b.bf.b = 0;
   b.bf.c = 0;
   printf("%u\n", b.z);	
   return 0;
}
