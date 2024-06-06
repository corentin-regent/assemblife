all: life

life.o: life.asm
	nasm -f elf64 life.asm

life: life.o
	ld -o life life.o

.PHONY: clean
clean:
	rm -f life.o life

.PHONY: setup
setup:
	echo "deb http://deb.debian.org/debian/ bookworm main" >> /etc/apt/sources.list
	echo "deb-src http://deb.debian.org/debian/ bookworm main" >> /etc/apt/sources.list
	sudo apt install nasm
