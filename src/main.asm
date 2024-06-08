%include "src/constants.asm"
%include "src/utils.asm"

SECTION .bss
    cols resq 1
    rows resq 1

SECTION .rodata
    msg_invalid_usage db "Invalid usage. Expected `./main [cols] [rows]`", NULL_TERMINATOR
    msg_zero_arg db "Invalid usage. Columns and rows must be strictly positive", NULL_TERMINATOR

SECTION .text
global _start

_start:
    call .parseColsAndRows
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
    je .errZeroArg
    mov [cols], rax

    pop rdx                       ; address of the calling function
    pop rdi
    push rdx
    call parseU64
    jc .errInvalidUsage           ; argument is not a valid u64
    cmp rax, 0
    je .errZeroArg
    mov [rows], rax
    ret

; unsigned long long parseNextArg()
; Parses the next command-line argument on the stack, as a 64-bit unsigned integer
; Returns:
;   rax: The next command-line argument, as a 64-bit unsigned integer
.parseNextArg:
    pop rdx                       ; address of the calling function
    pop rdi
    push rdx
    call parseU64
    jc .errInvalidUsage           ; argument is not a valid u64
    cmp rax, 0
    je .errZeroArg
    ret

.errInvalidUsage:
    mov rdi, msg_invalid_usage
    jmp exitError

.errZeroArg:
    mov rdi, msg_zero_arg
    jmp exitError
