%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDOUT 1
%define STDERR 2

%define NULL_TERMINATOR 0
%define LF 10

%define WIDTH 320
%define HEIGHT 200

%define VIDEO_MODE 19

%define INT_VIDEO_BIOS 16

section .rodata
    newline db LF
