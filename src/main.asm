%include "src/constants.asm"
%include "src/core.asm"
%include "src/gui.asm"
%include "src/random.asm"
%include "src/utils.asm"

SECTION .bss
cols         resq 1
rows         resq 1
grid_size    resq 1

current_grid resq 1
next_grid    resq 1

SECTION .rodata
invalid_usage_msg db "Invalid usage. Expected `./main [cols] [rows]`", LF
invalid_usage_msg_len equ $ - invalid_usage_msg

sleep_interval:  ; 10 FPS
    sleep_sec  dq           0
    sleep_nsec dq 100_000_000

SECTION .text
global _start

_start:
    call parseColsAndRows
    call computeGridSize
    call allocateGrids
    call initializeGrid
    call setupGui

    call mainLoop

    call teardownGui
    call deallocateGrids

    xor rdi, rdi                           ; exit code 0
    call exit

; void parseColsAndRows()
; Parses the command line arguments and loads the `cols` and `rows`
; variables, as 64-bit unsigned integers
parseColsAndRows:
    pop rdx                                ; address of the calling function
    pop rcx                                ; argc
    cmp rcx, 3                             ; 3 arguments: program_name cols rows
    jne errInvalidUsage
    add rsp, 8                             ; skip program_name

    pop rdi
    push rdx                               ; address of the calling function
    call parseU64
    jc errInvalidUsage                     ; argument is not a valid u64
    cmp rax, 3                             ; minimum size of the grid is 3x3
    jl errInvalidUsage
    mov [cols], rax

    pop rdx                                ; address of the calling function
    pop rdi
    push rdx
    call parseU64
    jc errInvalidUsage                     ; argument is not a valid u64
    cmp rax, 3                             ; minimum size of the grid is 3x3
    jl errInvalidUsage
    mov [rows], rax
    ret

errInvalidUsage:
    mov rdi, STDERR
    mov rsi, invalid_usage_msg
    mov rdx, invalid_usage_msg_len
    call write

    mov rdi, 1                             ; non-zero exit code
    call exit

; void computeGridSize()
; Computes the grid size and updates the corresponding variable in the bss segment.
computeGridSize:
    mov rax, [cols]
    mul qword [rows]
    mov [grid_size], rax
    ret

; void allocateGrids()
; Allocates the memory needed for the two grids
; and updates the corresponding pointers in the bss segment.
allocateGrids:
    mov rdi, [grid_size]
    call allocate
    mov [current_grid], rax

    mov rdi, [grid_size]
    call allocate
    mov [next_grid], rax
    ret

; void deallocateGrids()
; Frees the memory that was allocated for the grids
deallocateGrids:
    mov rdi, [current_grid]
    mov rsi, [grid_size]
    call deallocate

    mov rdi, [next_grid]
    mov rsi, [grid_size]
    call deallocate
    ret

; void initializeGrid()
; Randomly generates the initial state of the grid
initializeGrid:
    call initRandomGenerator
    mov rcx, [current_grid]
    mov rdx, rcx
    add rdx, [grid_size]                   ; address where we are no longer on the grid

.loopOverCells:
    call randomBoolean
    mov [rcx], al                          ; set the value of the cell
    inc rcx                                ; point to next cell
    cmp rcx, rdx                           ; check for the end of the grid
    jne .loopOverCells

    ret

; void mainLoop()
mainLoop:
    call drawGrid
    call sleep
    call updateGameState

    call areCurrentAndNextGridEqual
    test al, al
    jz mainLoop

    ret

; void sleep()
; Sleeps until it is time for the next frame
sleep:
    mov rax, SYS_NANOSLEEP
    mov rdi, sleep_interval
    xor rsi, rsi                           ; don't write anything to memory if interrupted
    syscall
    ret
