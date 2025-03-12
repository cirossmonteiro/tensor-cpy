[BITS 64]

; unsigned long _compute_linear_index(
;     unsigned int order,
;     unsigned int *dimensions,
;     unsigned int *index
; )

section .text
    global _compute_linear_index
    extern product

; rdi: order
; rsi: *dimensions
; rdx(r11): *index
_compute_linear_index:
    push r9
    push r10
    push r11
    push rdx
    push rcx
    
    mov r9, 0 ; final (return)
    mov r10, 1 ; p
    mov r11, rdx ; free for mul

    mov rcx, rdi ; loop
    _compute_linear_index_main:
        ; final += index[order-i-1] * p
        mov rax, [r11+(rcx-1)*8]
        mul r10
        add r9, rax

        ; p *= dimensions[order-i-1];
        mov rax, [rsi+(rcx-1)*8]
        mul r10
        mov r10, rax
        loop _compute_linear_index_main

    mov rax, r9

    pop rcx
    pop rdx
    pop r11
    pop r10
    pop r9
    
    ret