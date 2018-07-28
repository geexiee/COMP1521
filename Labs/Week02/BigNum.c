// BigNum.h ... LARGE positive integer values

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <ctype.h>
#include "BigNum.h"
#include <math.h>

// Initialise a BigNum to N bytes, all zero
void initBigNum(BigNum *n, int Nbytes)
{
    n->bytes = calloc(Nbytes, sizeof(Byte));
    memset(n->bytes, '0', sizeof(Byte));
    assert(n != NULL);    
    n->nbytes = Nbytes;
    return;
}

// Add two BigNums and store result in a third BigNum
void addBigNums(BigNum n, BigNum m, BigNum *res)
{
    int i;
    int safe_length=0; //Max length res can end up being
    if (n.nbytes>=m.nbytes) {
        safe_length = n.nbytes+1; //+1 to allow for trailing 0
    }
    else if (m.nbytes>n.nbytes) {
        safe_length = m.nbytes+1;
    }   
    int *temp_array = calloc(safe_length,sizeof(int));
	if (n.nbytes==m.nbytes) { //The arrays are of equal length
        for (i=0;i<safe_length-1;i++) {
            if ((n.bytes[i]-'0')+(m.bytes[i]-'0')+temp_array[i]>=10) {
                temp_array[i+1]++;
                temp_array[i] = ((n.bytes[i]-'0'))+((m.bytes[i]-'0'))+temp_array[i]-10;
            }
            else {
                temp_array[i] = (n.bytes[i]-'0')+(m.bytes[i]-'0')+temp_array[i];
            }
        }
    }
    else if (n.nbytes<m.nbytes) { //Requires different treatment if the arrays are not of equal length
        for (i=0;i<n.nbytes-1;i++) {
            if ((n.bytes[i]-'0')+(m.bytes[i]-'0')+temp_array[i]>=10) { //If a carry over is required
				temp_array[i+1]++;
				temp_array[i] = (n.bytes[i]-'0')+(m.bytes[i]-'0')+temp_array[i]-10;
            }
            else { //If no carry over is required
				temp_array[i] = (n.bytes[i]-'0')+(m.bytes[i]-'0')+temp_array[i];
            }
        }
        for (i=n.nbytes-1;i<safe_length-1;i++) {
			if ((m.bytes[i]-'0')+temp_array[i]>=10) { //This can actually occur because of previous carry overs
				temp_array[i+1]++;
				temp_array[i] = (m.bytes[i]-'0')+temp_array[i]-10;
			}
			else {
				temp_array[i] = (m.bytes[i]-'0')+temp_array[i];
			}
        }
    }
	else if (m.nbytes<n.nbytes) { //Requires different treatment if the arrays are not of equal length
        for (i=0;i<m.nbytes-1;i++) {
            if ((n.bytes[i]-'0')+(m.bytes[i]-'0')+temp_array[i]>=10) { //If a carry over is required
				temp_array[i+1]++;
				temp_array[i] = (n.bytes[i]-'0')+(m.bytes[i]-'0')+temp_array[i]-10;
            }
            else { //If no carry over is required
				temp_array[i] = (n.bytes[i]-'0')+(m.bytes[i]-'0')+temp_array[i];
            }
        }
        for (i=m.nbytes-1;i<safe_length-1;i++) {
			if ((n.bytes[i]-'0')+temp_array[i]>=10) { //This can actually occur because of previous carry overs
				temp_array[i+1]++;
				temp_array[i] = (n.bytes[i]-'0')+temp_array[i]-10;
			}
			else {
				temp_array[i] = (n.bytes[i]-'0')+temp_array[i];
			}
        }
    }

    if (temp_array[safe_length-1]==0) { //Array is too long
        initBigNum(res,safe_length-1);
		for (i=0;i<safe_length-1;i++) {
			res->bytes[i] = temp_array[i] + '0';
		}
    }
    else {
        initBigNum(res,safe_length-1);
		for (i=0;i<safe_length-1;i++) {
			res->bytes[i] = temp_array[i] + '0';
		}
    }
    return;
}

// Set the value of a BigNum from a string of digits
// Returns 1 if it *was* a string of digits, 0 otherwise
int scanBigNum(char *s, BigNum *n)
{
	int string_length=strlen(s);
    int array_length=0;
    int found_digit=0;
    int i,j, flag = 0;
    for (i=0;i<string_length;i++) { //First how many digits we have
        if (s[i]>'9' || s[i]<'0') {
            continue;
        }
        else if (s[i] <= '9' && s[i] >= '0') {
			array_length++;
			found_digit=1;
        }
        
    }
    if (!found_digit) {
		return 0;
    }
    array_length++; //Add a 0 at the end 
    n->nbytes = array_length;
    n->bytes = malloc(array_length*sizeof(Byte));
    for (i=0;i<array_length;i++) {
		n->bytes[i]='0';
    }
    j=array_length-2; //Leave a trailing 0 as required in specs
    for (i=0;i<string_length;i++) { //Then copy the string into the destination array in reverse order
        if (s[i]>'9' || s[i]<'0') {
			continue;
        }
        n->bytes[j] = s[i];
        j--;
    }
    for (i = 0; i < string_length; i++) {
        if (s[i] != '0') {
            flag = 1;
        }
    }
    if (flag == 0) {
        for (i = 0; i<string_length;i++) {
            n->bytes[j] = s[i];
            j--;
        }
    }

    return 1;
/*	int i = 0, end = n->nbytes-1;
	while (s[i] != '\0') {
		if (s[i] >= '0' && s[i] <= '9') {
			n->bytes[end] = s[i];
			end--;
		}
		i++;
	}
	return 1; */
}

// Display a BigNum in decimal format
void showBigNum(BigNum n)
{
	int i = (n.nbytes)-1, flag, k, sum = 0;
	for (k = 0; k <= (n.nbytes)-1; k++) {
	    sum = sum + n.bytes[k];
	}
	if (sum%48 == 0) {
	    printf("%d", 0);
	}
	
	//starting at the end of the array, iterate backwards until a non-zero integer is in the array
	while (n.bytes[i] == '0') {
		i--;
		flag = 1;
	}
	//edge case for if array is filled with only 0s
	if (i == 0 && flag != 1) {
		printf("%d\n", 0);
	} 
	while (i >= 0) {
		printf("%c", n.bytes[i]);
		i--;
	}	  
	return;
}

