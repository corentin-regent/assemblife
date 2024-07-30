%define SYS_WRITE   1
%define SYS_MMAP    9
%define SYS_MUNMAP 11
%define SYS_EXIT   60

%define STDOUT 1
%define STDERR 2

%define NULL 0
%define LF 10

%define WINDOW_WIDTH  320
%define WINDOW_HEIGHT 200

%define MAP_PRIVATE_AND_ANONYMOUS 34

%define PROT_READ_AND_WRITE 3

%define VIDEO_MODE 19

%define INT_VIDEO_BIOS 16

SECTION .rodata
newline db LF
