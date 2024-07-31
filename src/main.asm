%include "src/constants.asm"
%include "src/gui.asm"
%include "src/random.asm"
%include "src/utils.asm"

SECTION .bss
cols                 resq 1
rows                 resq 1
grid_size            resq 1
bytes_per_grid       resq 1

current_grid_pointer resq 1
next_grid_pointer    resq 1

SECTION .rodata
msg_invalid_usage db "Invalid usage. Expected `./main [cols] [rows]`", NULL

sleep_interval:  ; 5 FPS
    sleep_sec  dq 0
    sleep_nsec dq 200_000_000

SECTION .text
global _start

_start:
    call parseColsAndRows
    call computeGridConstants
    call allocateGrids
    call initializeGrid
    call mainLoop
    call deallocateGrids
    jmp exitOk

; void parseColsAndRows()
; Parses the command line arguments and loads the `cols` and `rows`
; variables, as 64-bit unsigned integers
parseColsAndRows:
    pop rdx                              ; address of the calling function
    pop rcx                              ; argc
    cmp rcx, 3                           ; 3 arguments: program_name cols rows
    jne errInvalidUsage
    add rsp, 8                           ; skip program_name

    pop rdi
    push rdx                             ; address of the calling function
    call parseU64
    jc errInvalidUsage                   ; argument is not a valid u64
    cmp rax, 0
    je errInvalidUsage
    mov [cols], rax

    pop rdx                              ; address of the calling function
    pop rdi
    push rdx
    call parseU64
    jc errInvalidUsage                   ; argument is not a valid u64
    cmp rax, 0
    je errInvalidUsage
    mov [rows], rax
    ret

errInvalidUsage:
    mov rdi, msg_invalid_usage
    jmp exitError

; void computeGridConstants()
; Computed constants related to the grid size
; and updates the corresponding variables in the bss segment.
computeGridConstants:
    mov rax, [cols]
    imul rax, [rows]
    jc errInvalidUsage                   ; u64 overflow
    mov [grid_size], rax
    mov [bytes_per_grid], rax
    ret

; void allocateGrids()
; Allocates the memory needed for the two grids
; and updates the corresponding pointers in the bss segment.
allocateGrids:
    call .allocateGrid
    mov [current_grid_pointer], rax
    call .allocateGrid
    mov [next_grid_pointer], rax
    ret

; void allocateGrid()
; Allocates `bytes_per_grid` bytes of memory
; Returns:
;   rax: The pointer to this memory space
.allocateGrid:
    mov rax, SYS_MMAP
    xor rdi, rdi                         ; address will be chosen by the OS
    mov rsi, [bytes_per_grid]
    lea rdx, [PROT_READ | PROT_WRITE]
    lea r10, [MAP_PRIVATE | MAP_ANONYMOUS]
    mov r8, -1                           ; no file descriptor
    xor r9, r9                           ; no offset
    syscall
    ret

; void initializeGrid()
; Randomly generates the initial state of the grid
initializeGrid:
    call initRandomGenerator
    mov rcx, [current_grid_pointer]
    mov rdx, rcx
    add rdx, [grid_size]                 ; address where we are no longer on the grid
.loopOverCells:
    call randomBoolean
    mov [rcx], al                        ; set the value of the cell
    inc rcx                              ; point to next cell
    cmp rcx, rdx                         ; check for the end of the grid
    jne .loopOverCells

    ret

; void deallocateGrids()
; Deallocates the memory that was allocated for the grids
deallocateGrids:
    mov rdi, [current_grid_pointer]
    call .deallocateGrid
    mov rdi, [next_grid_pointer]
    call .deallocateGrid
    ret

; void deallocateGrid()
; Deallocates the memory that was allocated for the given grid
; Arguments:
;   rdi: The pointer to the grid to deallocate
.deallocateGrid:
    mov rax, SYS_MUNMAP
    mov rsi, [bytes_per_grid]
    syscall
    ret

mainLoop:
    call drawGrid
    call sleep
    ret

; void sleep()
; Sleeps until it is time for the next frame
sleep:
    mov rax, SYS_NANOSLEEP
    mov rdi, sleep_interval
    xor rsi, rsi                         ; don't write anything to memory if interrupted
    syscall
    ret
