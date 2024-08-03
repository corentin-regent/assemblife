all: main test

main.o: src/*.asm
	nasm -f elf64 -o main.o src/main.asm

main: main.o
	ld -o main main.o

test.o: src/*.asm tests/*.asm tests/core/*.asm
	nasm -f elf64 -o test.o tests/test.asm

test: test.o
	ld -o test test.o

.PHONY: clean
clean:
	rm -f main.o main test.o test
