[BITS 64]

; void _compute_tensor_index(
;     unsigned int order,
;     unsigned int *dimensions,
;     unsigned long index,
;     unsigned int *final
; )

; section .data
;     ; Mensagens de teste
;     debug_msg db "here", 0xA
;     debug_len equ $ - debug_msg

section .bss
    p resq 1
    ptemp resq 1
    r resq 1

section .text
    ; global _start
    global _compute_tensor_index
    extern product

; _start:
    ; call _compute_tensor_index

; rdi(r8): order
; rsi: *dimensions
; rdx(r9): index
; rcx(r10): *final
_compute_tensor_index:
    mov r8, rdi
    mov r9, rdx ; free rdx for division
    mov r10, rcx ; free rcx for loop

    ; compute product
    ; mov rdi, rdi ; coincidence
    ; mov rsi , rsi ; coincidence
    call product

    mov [p], rax
    mov [ptemp], rax
    mov rdi, 0
    mov rcx, r8

    _compute_tensor_index_main:
        ; p (ptemp) /= dimensions[i];
        mov rax, [ptemp]
        mov rdx, 0 ; prepare for division
        div qword [rsi+rdi*8]
        mov [ptemp], rax

        ; final[i] = (index - r) / p (ptemp);
        mov rax, r9
        sub rax, [r]
        mov rdx, 0 ; prepare for division
        div qword [ptemp]
        mov [r10+rdi*8], rax

        mov r13, [r10+0*8] ; overflow

        ; r += final[i] * p (ptemp);
        mov rax, [r10+rdi*8]
        imul rax, [ptemp]
        add [r], rax

        inc rdi
        ; loop main
        dec rcx      ; Decrementa ECX manualmente
        jnz _compute_tensor_index_main  ; Substitui `loop` por `jnz`

    ; mov r12, rax
    ; mov r13, rdi
    ; mov r14, rax
    ; mov r15, [r10+0*8]

    ret