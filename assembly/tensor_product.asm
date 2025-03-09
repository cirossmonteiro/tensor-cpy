[BITS 64]

section .bss
    p_a resq 1
    p_b resq 1
    pos_a resq 1
    pos_b resq 1
    new_pos resq 1
    new_value resq 1
    v_a resq 1
    v_b resq 1
    rcx2 resq 1


section .text
    global tensor_product
    extern product

    syscall_mmap  equ 9     ; syscall para mmap
    syscall_munmap equ 11   ; syscall para munmap

; free use: r15

; rdi(r10): order_a
; rsi(r11): *dimensions_a
; rdx(r12): *values_a
; rcx(r13): order_b
; r8: *dimensions_b
; r9: *values_b
; [rbp+16](r14): *new_values
tensor_product:
    push rbp               ; Salva o valor original de rbp
    mov rbp, rsp           ; Configura novo frame da pilha

    mov r10, rdi
    mov r11, rsi
    mov r12, rdx ; free rdx for division
    mov r13, rcx ; free rcx for loop
    mov r14, [rbp+16]

    ; for(i = 0; i < order_a; i++) {
    ;     p_a *= dimensions_a[i];
    ; }
    call product
    mov [p_a], rax

    mov rdi, r13
    mov rsi, r8
    ; for(i = 0; i < order_b; i++) {
    ;     p_b *= dimensions_b[i];
    ; }
    call product
    mov [p_b], rax

    mov qword [pos_a], 0
    mov rax, [p_a]
    mov [rcx2], rax
    for_a:
        mov qword [pos_b], 0
        mov rcx, [p_b]
        for_b:
            ; newpos2 = pos1 * p2 + pos2
            mov rax, [pos_a]
            mul qword [p_b]
            add rax, [pos_b]
            mov [new_pos], rax

            mov rax, [pos_a]
            mov rax, [r12+rax*8]
            mov [v_a], rax ; v_a

            mov rax, [pos_b]
            mov rax, [r9+rax*8]
            mov [v_b], rax ; v_b

            ; newt.assign(newpos, v1 * v2)
            mov rax, [v_a]
            mul qword [v_b]
            mov r15, [new_pos]
            mov [r14+r15*8], rax

            inc qword [pos_b]
            dec rcx
            jnz for_b

        inc qword [pos_a]
        dec qword [rcx2]
        jnz for_a

    pop rbp ; Restaura rbp
    ret