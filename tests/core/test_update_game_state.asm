SECTION .rodata
test_update_game_state_failed_msg db "Test failed for updating the game state.", LF
test_update_game_state_failed_msg_len equ $ - test_update_game_state_failed_msg

expected_updated_grid db 1, 1, 0, 0, 1
                      db 1, 1, 1, 1, 1
                      db 0, 1, 0, 0, 0
                      db 1, 1, 0, 1, 0

SECTION .text
; void testUpdateGameState()
testUpdateGameState:
    call updateGameState

    xor rax, rax                           ; the cell index (starts at 0)
    mov rcx, [current_grid]
    lea rdx, [expected_updated_grid]       ; lea because it is not a pointer to the array
.checkLoop:
    mov r8b, [rcx]
    cmp r8b, [rdx]
    jne .fail

    inc rax
    inc rcx
    inc rdx
    cmp rax, [grid_size]
    jne .checkLoop

    ret

.fail:
    mov rdi, STDERR
    mov rsi, test_update_game_state_failed_msg
    mov rdx, test_update_game_state_failed_msg_len
    call write

    mov rdi, 1                             ; non-zero exit code
    call exit
