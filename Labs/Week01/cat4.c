// Copy input to output
// COMP1521 18s1

#include <stdlib.h>
#include <stdio.h>

void copy(FILE *, FILE *);

int main(int argc, char *argv[])
{
    FILE *fp;
    if (argc == 1) {
	    copy(stdin,stdout);
	}
	else {
	    for (int i = 1; i <= argc; i++) {
	        fp = fopen(argv[i], "r");
	        if (fp == NULL) {
	            printf("Cant read");
	        }
	        else {
	            copy(fp, stdout);
	            fclose(fp);
	        }	     
	    }
	}
	return EXIT_SUCCESS;
}

// Copy contents of input to output, char-by-char
// Assumes both files open in appropriate mode

void copy(FILE *input, FILE *output)
{
    char string[BUFSIZ];
    while (fgets(string, BUFSIZ, input) != NULL) {
        fputs(string, output); 
    }
}
