all: main

main.o: src/*.asm
	nasm -f elf64 -o main.o src/main.asm

main: main.o
	ld -o main main.o

.PHONY: clean
clean:
	rm -f main.o main
