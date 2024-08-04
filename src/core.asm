SECTION .text

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

; char areCurrentAndNextGridEqual()
; Returns:
;   al: Whether the state of the game now remains the same after each iteration
areCurrentAndNextGridEqual:
    xor rax, rax                           ; the cell index (starts at 0)
    mov rcx, [current_grid]
    mov rdx, [next_grid]
.checkLoop:
    mov r8b, [rcx]
    cmp r8b, [rdx]
    jne .false

    inc rax
    inc rcx
    inc rdx
    cmp rax, [grid_size]
    jne .checkLoop

    ; true
    mov al, 1
    ret

.false:
    xor al, al
    ret
