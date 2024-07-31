SECTION .rodata
alive_cell db 0xE2, 0xAC, 0x9C, NULL  ; ⬜
dead_cell  db 0xE2, 0xAC, 0x9B, NULL  ; ⬛

SECTION .text

; void drawGrid()
; Draws the current state of the grid on the GUI
drawGrid:
    push rbx
    push r12
    push r13
    mov rbx, [current_grid_pointer]  ; position in the current grid

    xor r12, r12                     ; row 0
.loopOverRows:
    xor r13, r13                     ; column 0
.loopOverColumns:
    cmp byte [rbx], 1
    je .alive

    ; dead:
    mov rsi, dead_cell
    jmp .continueLoop

.alive:
    mov rsi, alive_cell

.continueLoop:
    ; print the cell:
    mov rdi, STDOUT
    call print

    inc rbx
    inc r13
    cmp r13, [cols]                  ; check for end of row
    jne .loopOverColumns

    mov rdi, STDOUT
    mov rsi, newline
    call print

    inc r12
    cmp r12, [rows]                  ; check for end of the grid
    jne .loopOverRows

    pop r13
    pop r12
    pop rbx
    ret
