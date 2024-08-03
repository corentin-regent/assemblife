%include "src/constants.asm"
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
    jmp mainLoop
    ret

; void updateGameState()
; Updates the game to its next state (new iteration)
updateGameState:
    push rbx
    push r12
    push r13
    push r14

    xor rbx, rbx                           ; row 0
.loopOverRows:
    xor r12, r12                           ; column 0
.loopOverCols:
    ; cell_address = cols_per_row * row + col + start_address
    mov rax, [cols]
    mul rbx
    add rax, r12
    mov r13, rax
    mov r14, [next_grid]
    add r14, r13                           ; address on the next grid
    add r13, [current_grid]                ; address on the current grid

    mov rdi, r12
    mov rsi, rbx
    call countNeighbors

    mov r10b, byte [r13]                   ; current value of the cell
    cmp r10b, 1
    je .wasAlive

    ; was dead:
    cmp al, 3                              ; dead cell becomes alive if it has exactly 3 neighbors
    je .becomeAlive
    jmp .becomeDead

.wasAlive:
    ; If 2 or 3 neighbors the cell stays alive, otherwise it dies:
    cmp al, 2
    je .becomeAlive
    cmp al, 3
    je .becomeAlive
    jmp .becomeDead

.becomeAlive:
    mov byte [r14], 1
    jmp .continueLoop

.becomeDead:
    mov byte [r14], 0

.continueLoop:
    inc r12
    cmp r12, [cols]                        ; check for end of row
    jne .loopOverCols

    inc rbx
    cmp rbx, [rows]                        ; check for end of the grid
    jne .loopOverRows

    ; swap grids:
    mov rdx, [current_grid]
    mov rcx, [next_grid]
    mov [current_grid], rcx
    mov [next_grid], rdx

    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; char countNeighbors(unsigned long long col, unsigned long long row)
; Arguments:
;   rdi: The column of the cell
;   rsi: The row    of the cell
; Returns:
;   al: The number of neighbors of the cell at position (col, row)
countNeighbors:
    xor r10b, r10b                         ; init number of neighbors to 0
    mov r11, -1                            ; delta row
.loopOverRows:
    mov rcx, -1                            ; delta column
.loopOverCols:
    ; check if we are on the input cell <=> delta is (0, 0)
    mov r8, rcx
    or r8, r11
    test r8, r8
    jz .continue

    ; Compute neighbor indices (and stitch borders together):
    ; row:
    mov r8, rsi
    add r8, r11
    cmp r8, -1
    je .stitchToLastRow
    cmp r8, [rows]
    je .stitchToFirstRow

.computeNeighborCol:
    mov r9, rdi
    add r9, rcx
    cmp r9, -1
    je .stitchToLastCol
    cmp r9, [cols]
    je .stitchToFirstCol

.checkNeighbor:
    ; cell_address = cols_per_row * row + col + start_address
    mov rax, [cols]
    mul r8
    add rax, r9
    add rax, [current_grid]
    add r10b, [rax]                        ; increment counter if neighbor cell is alive

.continue:
    inc rcx
    cmp rcx, 2                             ; check if we are no longer on a neighbor
    jne .loopOverCols

    inc r11
    cmp r11, 2                             ; check if we are no longer on a neighbor
    jne .loopOverRows

    mov al, r10b
    ret

.stitchToLastRow:
    mov r8, [rows]
    dec r8
    jmp .computeNeighborCol

.stitchToFirstRow:
    xor r8, r8
    jmp .computeNeighborCol

.stitchToLastCol:
    mov r9, [cols]
    dec r9
    jmp .checkNeighbor

.stitchToFirstCol:
    xor r9, r9
    jmp .checkNeighbor

; void sleep()
; Sleeps until it is time for the next frame
sleep:
    mov rax, SYS_NANOSLEEP
    mov rdi, sleep_interval
    xor rsi, rsi                           ; don't write anything to memory if interrupted
    syscall
    ret
