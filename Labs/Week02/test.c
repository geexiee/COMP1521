// COMP1521 18s1 Week 02 Lab
// Add two numbers (numbers can be LARGE)

#include <stdio.h>
#include "BigNum.h"

int main(int argc, char **argv)
{
   BigNum num1;  // first input number

   initBigNum(&num1, 20);


    num1.bytes[0] = '2';
    num1.bytes[1] = '0';
    num1.bytes[2] = '1';

    showBigNum(num1);
    printf("\n");

   return 0;

}
