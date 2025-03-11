[BITS 64]

; void _compute_tensor_index(
;     unsigned int order,
;     unsigned int *dimensions,
;     unsigned long index,
;     unsigned int *final
; )

section .text
    global _compute_tensor_index
    extern product

; rdi: order
; rsi: *dimensions
; rdx(r8): index
; rcx(r9): *final
_compute_tensor_index:
    push rax
    push rdx
    push rcx
    push r8
    push r9
    push r10
    push r11
    push r12

    mov r8, rdx ; free rdx for division
    mov r9, rcx ; free rcx for loop

    ; compute product
    ; mov rdi, rdi ; coincidence
    ; mov rsi , rsi ; coincidence
    call product

    mov r10, rax ; product p
    mov r12, 0 ; r

    mov r11, 0 ; i
    mov rcx, rdi
    _compute_tensor_index_main:
        ; p /= dimensions[i];
        mov rax, r10
        mov rdx, 0 ; prepare for division
        div qword [rsi+r11*8]
        mov r10, rax

        ; final[i] = (index - r) / p (ptemp);
        mov rax, r8
        sub rax, r12
        mov rdx, 0 ; prepare for division
        div r10
        mov [r9+r11*8], rax

        ; r += final[i] * p (ptemp);
        mov rax, [r9+r11*8]
        mul r10
        add r12, rax

        inc r11
        loop _compute_tensor_index_main
    
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rax

    ret