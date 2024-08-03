SECTION .bss
lcg_current_value resq 1

SECTION .text

; void initRandomGenerator()
; Initializes the Linear Congruential Generator
; with a seed based on the CPU clock cycle count
initRandomGenerator:
    rdtsc                         ; load lower-order 32 bits of CPU cycle count into eax register
    mov [lcg_current_value], eax
    ret

; char randomBoolean()
; Returns:
;   al: A pseudo-randomly generated boolean
randomBoolean:
    call random64bits
    shr rax, 63                   ; keep the most significant bit
    ret

; void *random64bits()
; Returns:
;   rax: A pseudo-randomly generated 64-bit value
random64bits:
    ; lcg_current_value = (lcg_current_value*LCG_MULTIPLIER + LCG_INCREMENT) % (1<<64)
    ;                   =  lcg_current_value*LCG_MULTIPLIER + LCG_INCREMENT
    ; due to the carry values being lost beyond the 64-bit limit
    ; Note that NASM issues a `[-w+number-overflow]` warning, but this overflow is intentional
    mov rax, [lcg_current_value]
    imul rax, LCG_MULTIPLIER
    add rax, LCG_INCREMENT
    mov [lcg_current_value], rax
    ret
