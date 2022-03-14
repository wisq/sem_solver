// Takes a word2vec file on stdin, outputs text representation on stdout.
// Based on https://github.com/marekrei/convertvec (by Marek Rei)
// Modified version used here under the Apache License 2.0

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>

const long long max_w = 2000;

int main(void) {
	FILE * fi = stdin;
	FILE * fo = stdout;
	
	long long words, size;
	fscanf(fi, "%lld", &words);
	fscanf(fi, "%lld", &size);
	fscanf(fi, "%*[ ]");
	fscanf(fi, "%*[\n]");

	fprintf(fo, "%lld %lld\n", words, size);

	char word[max_w];
	char ch;
	float value;
	int b, a;
	for (b = 0; b < words; b++) {
		if(feof(fi))
			break;

		word[0] = 0;
		fscanf(fi, "%[^ ]", word);
		fscanf(fi, "%c", &ch);
		
		fprintf(fo, "%s ", word);
		for (a = 0; a < size; a++) {
			fread(&value, sizeof(float), 1, fi);
			fprintf(fo, "%lf ", value);
		}
		fscanf(fi, "%*[\n]");
		fprintf(fo, "\n");
	}
}
