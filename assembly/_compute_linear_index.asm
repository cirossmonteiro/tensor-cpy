[BITS 64]

; unsigned long _compute_linear_index(
;     unsigned int order,
;     unsigned int *dimensions,
;     unsigned int *index
; )

section .bss
    p resq 1
    ind resq 1
    ; ptemp resq 1

section .text
    global _compute_linear_index
    extern product

; rdi(r8): order
; rsi: *dimensions
; rdx(r9): *index
_compute_linear_index:
    mov r8, rdi
    mov r9, rdx ; free rdx for division
    mov r10, 0 ; final (return)

    mov qword [p], 1
    mov qword [ind], r8
    sub qword [ind], 1
    mov rcx, r8

    _compute_linear_index_main:
        ; final += index[order-i-1] * p
        mov r11, [ind] ; r11 == order-i-1
        mov rax, [r9+r11*8] ; rax == index[order-i-1]
        mov r11, [p] ; r11 == p
        mul r11 ; rax == index[order-i-1] * p
        add r10, rax

        ; p *= dimensions[order-i-1];
        mov r11, [ind] ; r11 == order-i-1
        mov rax, [rsi+r11*8]; rax == dimensions[order-i-1]
        mov r12, [p]
        mul r12
        mov [p], rax

        dec qword [ind]
        loop _compute_linear_index_main
        ; dec rcx      ; Decrementa ECX manualmente
        ; jnz _compute_linear_index_main  ; Substitui `loop` por `jnz`

    mov rax, r10
    
    ret