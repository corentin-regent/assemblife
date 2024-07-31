%define SYS_WRITE      1
%define SYS_MMAP       9
%define SYS_MUNMAP    11
%define SYS_NANOSLEEP 35
%define SYS_EXIT      60

%define STDOUT 1
%define STDERR 2

%define NULL 0
%define LF 10

%define WINDOW_WIDTH  320
%define WINDOW_HEIGHT 200

%define MAP_PRIVATE 2
%define MAP_ANONYMOUS 32

%define PROT_READ 1
%define PROT_WRITE 2

; Musl parameters for Linear Congruential Generator
; https://en.wikipedia.org/wiki/Linear_congruential_generator#Parameters_in_common_use
%define LCG_MULTIPLIER 6364136223846793005
%define LCG_INCREMENT                    1

SECTION .rodata
newline db LF, NULL
