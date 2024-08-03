%include "src/constants.asm"
%include "src/core.asm"
%include "src/utils.asm"

%include "tests/core/test_update_game_state.asm"

%define COLS 5
%define ROWS 4
%define GRID_SIZE 20

SECTION .rodata
cols      dq COLS
rows      dq ROWS
grid_size dq GRID_SIZE

all_tests_passed_msg db "All tests passed!", LF
all_tests_passed_msg_len equ $ - all_tests_passed_msg

SECTION .data
input_grid db 1, 0, 0, 1, 1
           db 0, 1, 0, 0, 0
           db 0, 0, 1, 0, 0
           db 1, 0, 0, 0, 0

temp_grid times GRID_SIZE db 0

; Declare pointers, so that variables behave the same as in the `main.asm` file
current_grid dq input_grid
next_grid    dq temp_grid


SECTION .text
global _start

_start:
    call testUpdateGameState               ; must be the last test of the suite as it modifies current_grid

    mov rdi, STDOUT
    mov rsi, all_tests_passed_msg
    mov rdx, all_tests_passed_msg_len
    call write

    xor rdi, rdi                           ; exit code 0
    call exit
