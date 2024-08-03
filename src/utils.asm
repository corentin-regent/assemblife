SECTION .text

; unsigned long long parseU64(char *str)
; Parses the given string as a 64-bit unsigned integer.
; Arguments:
;   rdi: Input string
; Returns:
;   rax: The string parsed as a 64-bit unsigned integer
; Raises:
;   Carry Flag: The given string is not a valid 64-bit unsigned integer
parseU64:
    xor rax, rax                            ; clear result register
.parseChar:
    mov cl, [rdi]                           ; load current character
    cmp cl, NULL                            ; check for end of string
    je .done
    sub cl, '0'                             ; convert ASCII to digit
    cmp cl, 9
    ja .invalidInput                        ; not a digit

    movzx rcx, cl                           ; zero-extend the character to 64 bits
    mov rdx, 10
    mul rdx                                 ; shift rax by one digit
    jc .invalidInput                        ; does not fit in 64 bits
    add rax, rcx                            ; add the new digit
    jc .invalidInput                        ; does not fit in 64 bits
    inc rdi                                 ; move pointer to next character
    jmp .parseChar

.done:
    ret

.invalidInput:
    stc
    ret

; void write(int fd, char[] buffer, unsigned long long length)
; Writes a message to the given file descriptor
; Arguments:
;   rdi: The file descriptor
;   rsi: The pointer to the message to write
;   rdx: The number of bytes to write
write:
    mov rax, SYS_WRITE
    syscall
    ret

; void *allocate(unsigned long long size)
; Allocates the given amount of memory
; Arguments:
;   rdi: The amount of bytes to allocate
; Returns:
;   rax: The pointer to this memory space
allocate:
    mov rsi, rdi
    mov rax, SYS_MMAP
    xor rdi, rdi                            ; address will be chosen by the OS
    lea rdx, [PROT_READ | PROT_WRITE]
    lea r10, [MAP_PRIVATE | MAP_ANONYMOUS]
    mov r8, -1                              ; no file descriptor
    xor r9, r9                              ; no offset
    syscall
    ret

; void deallocate(void *memory, unsigned long long size)
; Deallocates the given memory
; Arguments:
;   rdi: The pointer to the memory region to free
;   rsi: The amount of bytes to deallocate
deallocate:
    mov rax, SYS_MUNMAP
    syscall
    ret

; void exit(int code)
; Exits the program with the given exit code
; Arguments:
;   rdi: The exit code
exit:
    mov rax, SYS_EXIT
    syscall
