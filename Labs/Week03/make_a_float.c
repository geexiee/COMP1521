// make_a_float ... read in bit strings to build a float value
// COMP1521 Lab03 exercises
// Written by John Shepherd, August 2017
// Completed by ...

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

typedef uint32_t Word;

struct _float {
   // define bit_fields for sign, exp and frac
   // obviously they need to be larger than 1-bit each
   // and may need to be defined in a different order
   unsigned int frac:23, exp:8, sign:1  ;
};
typedef struct _float Float32;

union _bits32 {
   float   fval;  // interpret the bits as a float
   Word    xval;  // interpret as a single 32-bit word
   Float32 bits;  // manipulate individual bits
};
typedef union _bits32 Union32;

void    checkArgs(int, char **);
Union32 getBits(char *, char *, char *);
char   *showBits(Word, char *);
int     justBits(char *, int);

int main(int argc, char **argv)
{
   union _bits32 u;
   char out[50];

   // here's a hint ...
   u.bits.sign = u.bits.exp = u.bits.frac = 0;

   // check command-line args (all strings of 0/1
   // kills program if args are bad
   checkArgs(argc, argv);

   // convert command-line args into components of
   // a Float32 inside a Union32, and return the union
   u = getBits(argv[1], argv[2], argv[3]);

   printf("bits : %s\n", showBits(u.xval,out));
   printf("float: %0.10f\n", u.fval);

   return 0;
}

// convert three bit-strings (already checked)
// into the components of a struct _float
Union32 getBits(char *sign, char *exp, char *frac)
{
   Union32 new;

   // this line is just to keep gcc happy
   // delete it when you have implemented the function
  // new.bits.sign = new.bits.exp = new.bits.frac = 0;
        

   // convert char *sign into a single bit in new.bits
	new.bits.sign = sign[0] - '0';
   // convert char *exp into an 8-bit value in new.bits
	int i, mask, final = 0;
	for (i = 0; i < 8; i++) {
		mask = exp[i] - '0';
		mask = mask << (7 - i);
		final = final + mask;
	}
	new.bits.exp = final;
   // convert char *frac into a 23-bit value in new.bits
	int j, mask2, final2 = 0;
	for (j = 0; j < 23; j++) {
		mask2 = frac[j] - '0';
		mask2 = mask2 << (22 - j);
		final2 = final2 + mask2;
	}	
	new.bits.frac = final2;
   return new;
}

// convert a 32-bit bit-stringin val into a sequence
// of '0' and '1' characters in an array buf
// assume that buf has size > 32
// return a pointer to buf
char *showBits(Word val, char *buf)
{
   // this line is just to keep gcc happy
   // delete it when you have implemented the function  
    int mask = 0, i, flag = 0;
	for (i = 0; i < 34; i++) {
		if (i == 1) {
			buf[i] = ' ';
			flag++;
			continue;
		}
		if (i == 10) {
			buf[i] = ' ';
			flag++;
			continue;
		}
		mask = 0;
	    mask = mask + val;
	    mask = mask << (i-flag);
		if (mask < 0) {
			buf[i] = '1';
		}
		else {
			buf[i] = '0';
		}
//	    mask = mask >> 31;
//	    final = final + mask;
//	    buf[i] = final;
//		printf("%d, %d, %d\n", mask, final, buf[i]);
//		printf("%d\n", mask);
	}
	buf[34] = '\0';
   return buf;
}

// checks command-line args
// need at least 3, and all must be strings of 0/1
// never returns if it finds a problem
void checkArgs(int argc, char **argv)
{
   if (argc < 3) {
      printf("Usage: %s Sign Exp Frac\n", argv[0]);
      exit(1);
   }
   if (!justBits(argv[1],1)) {
      printf("%s: invalid Sign: %s\n", argv[0], argv[1]);
      exit(1);
   }
   if (!justBits(argv[2],8)) {
      printf("%s: invalid Exp: %s\n", argv[0], argv[2]);
      exit(1);
   }
   if (!justBits(argv[3],23)) {
      printf("%s: invalid Frac: %s\n", argv[0], argv[3]);
      exit(1);
   }
   return;
}

// check whether a string is all 0/1 and of a given length
int justBits(char *str, int len)
{
   if (strlen(str) != len) return 0;

   while (*str != '\0') {
      if (*str != '0' && *str != '1') return 0;
      str++;
   }
   return 1;
}
