SECTION .text

; void exitOk()
; Exits the program with exit code 0
exitOk:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

; void exitError(char *message)
; Prints the error message to stderr before exiting with non-zero code
; Arguments:
;   rdi: Pointer to the error message
exitError:
    mov rsi, rdi
    mov rdi, STDERR
    call println

    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

; void println(int fd, char *message)
; Arguments:
;   rdi: File Descriptor (STDOUT or STDERR)
;   rsi: Pointer to the message
println:
    mov rax, SYS_WRITE
    mov rdx, 1                   ; print characters 1 by 1

.printChar:
    mov cl, [rsi]                ; load current character
    cmp cl, NULL_TERMINATOR      ; check for end of string
    je .done
    syscall
    inc rsi                      ; move pointer to next character
    jmp .printChar

.done:
    mov rsi, newline
    syscall
    ret

; unsigned long long parseU64(char *str)
; Parses the given string as a 64-bit unsigned integer
; Arguments:
;   rdi: Input string
; Returns:
;   rax: The string parsed as a 64-bit unsigned integer
; Raises:
;   Carry Flag: The given string is not a valid 64-bit unsigned integer
parseU64:
    xor rax, rax                 ; clear result register

.parseChar:
    mov cl, [rdi]                ; load current character
    cmp cl, NULL_TERMINATOR      ; check for end of string
    je .done
    sub cl, '0'                  ; convert ASCII to digit
    cmp cl, 9
    ja .invalidInput             ; not a digit

    movzx rcx, cl                ; zero-extend the character to 64 bits
    mov rdx, 10
    mul rdx                      ; shift rax by one digit
    jc .invalidInput             ; does not fit in 64 bits
    add rax, rcx                 ; add the new digit
    jc .invalidInput             ; does not fit in 64 bits
    inc rdi                      ; move pointer to next character
    jmp .parseChar

.done:
    ret

.invalidInput:
    stc
    ret
