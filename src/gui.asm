SECTION .bss
output_buffer      resq 1
output_buffer_size resq 1

SECTION .rodata
ansi_clear_terminal db 0x1b, "[2J", 0x1b, "[H"
ansi_clear_terminal_len equ $ - ansi_clear_terminal

alive_cell db 0xE2, 0xAC, 0x9C, 0x00  ; ⬜
dead_cell  db 0xE2, 0xAC, 0x9B, 0x00  ; ⬛
newline    db LF,   0x00, 0x00, 0x00

SECTION .text

; void setupGui()
setupGui:
    mov rax, [grid_size]
    add rax, [rows]                  ; there will be `row` newline characters
    mov rdx, BYTES_PER_UNICODE_CHAR
    mul rdx
    mov [output_buffer_size], rax

    mov rdi, rax
    call allocate
    mov [output_buffer], rax
    ret

; void teardownGui()
teardownGui:
    mov rdi, [output_buffer]
    mov rsi, [output_buffer_size]
    call deallocate
    ret

; void drawGrid()
; Draws the current state of the grid on the GUI
drawGrid:
    push rbx
    push r12
    push r13

    call clearScreen
    mov rbx, [current_grid]          ; position in the current grid

    xor r12, r12                     ; row 0
.loopOverRows:
    xor r13, r13                     ; column 0
.loopOverCols:
    cmp byte [rbx], 1
    je .alive

    mov rsi, dead_cell
    jmp .continueLoop

.alive:
    mov rsi, alive_cell

.continueLoop:
    mov rdi, STDOUT
    mov rdx, BYTES_PER_UNICODE_CHAR
    call write

    inc rbx
    inc r13
    cmp r13, [cols]                  ; check for end of row
    jne .loopOverCols

    mov rdi, STDOUT
    mov rsi, newline
    mov rdx, 1
    call write

    inc r12
    cmp r12, [rows]                  ; check for end of the grid
    jne .loopOverRows

    pop r13
    pop r12
    pop rbx
    ret

; void clearScreen()
; Clears the terminal and resets the cursor to the top left position
clearScreen:
    mov rdi, STDOUT
    mov rsi, ansi_clear_terminal
    mov rdx, ansi_clear_terminal_len
    call write
    ret
