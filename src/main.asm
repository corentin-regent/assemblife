%include "src/constants.asm"
%include "src/utils.asm"

SECTION .bss
cols              resq 1
rows              resq 1
bytes_to_allocate resq 1
grids_pointer     resq 1

SECTION .rodata
msg_invalid_usage db "Invalid usage. Expected `./main [cols] [rows]`", NULL

SECTION .text
global _start

_start:
    call .parseColsAndRows
    call .computeBytesToAllocate
    call .allocateGrids
    call .deallocateGrids
    jmp exitOk

; void parseColsAndRows()
; Parses the command line arguments and loads the `cols` and `rows`
; variables, as 64-bit unsigned integers
.parseColsAndRows:
    pop rdx                       ; address of the calling function
    pop rcx                       ; argc
    cmp rcx, 3                    ; 3 arguments: program_name cols rows
    jne .errInvalidUsage
    add rsp, 8                    ; skip program_name

    pop rdi
    push rdx                      ; address of the calling function
    call parseU64
    jc .errInvalidUsage           ; argument is not a valid u64
    cmp rax, 0
    je .errInvalidUsage
    mov [cols], rax

    pop rdx                       ; address of the calling function
    pop rdi
    push rdx
    call parseU64
    jc .errInvalidUsage           ; argument is not a valid u64
    cmp rax, 0
    je .errInvalidUsage
    mov [rows], rax
    ret

; void computeBytesToAllocate()
; Computes the number of bytes to allocate in order to
; have one byte per cell, for two grids (current and next state).
; Updates the corresponding variable in the bss segment.
.computeBytesToAllocate:
    mov rax, [cols]
    mov rcx, [rows]
    imul rax, rcx
    ; jc .errInvalidUsage                 ; u64 overflow
    shl rax, 1                          ; twice as much memory, for two grids
    ; jc .errInvalidUsage                 ; u64 overflow
    mov [bytes_to_allocate], rax
    ret

.errInvalidUsage:
    mov rdi, msg_invalid_usage
    jmp exitError

; void allocateGrids()
; Allocates `bytes_to_allocate` bytes of memory
; and makes the `grids_pointer` variable point to this area
.allocateGrids:
    mov rax, SYS_MMAP
    xor rdi, rdi                        ; address will be chosen by the OS
    mov rsi, [bytes_to_allocate]
    mov rdx, PROT_READ_AND_WRITE
    mov r10, MAP_PRIVATE_AND_ANONYMOUS
    mov r8,  -1                         ; not backed by a file descriptor
    xor r9,  r9                         ; no offset
    syscall
    mov [grids_pointer], rax
    ret

; void deallocateGrids()
; Deallocates the memory that was allocated for the grids
.deallocateGrids:
    mov rax, SYS_MUNMAP
    mov rdi, [grids_pointer]
    mov rsi, [bytes_to_allocate]
    syscall
    ret
