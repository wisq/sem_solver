# From https://github.com/marekrei/convertvec (by Marek Rei)
# Used here under the Apache License 2.0

CC = gcc
CFLAGS = -lm -pthread -Ofast -march=native -Wall -funroll-loops -Wno-unused-result

all: convertvec

vec2vec : convertvec.c
	$(CC) convertvec.c -o convertvec $(CFLAGS)

clean:
	rm -rf convertvec
