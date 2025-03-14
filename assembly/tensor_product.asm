[BITS 64]

; p_a - 0
; p_b - 1
; pos_a - 2
; pos_b - 3
; new_pos - 4
; new_value - 5
; v_a - 6
; v_b - 7
; rcx2 - 8

section .text
    global tensor_product
    extern product
    extern malloc

; rdi: order_a
; rsi: *dimensions_a
; rdx: *values_a
; rcx: order_b
; r8: *dimensions_b
; r9: *values_b
; [rbp+16]: *new_values
tensor_product:
    push rbp               ; Salva o valor original de rbp
    mov rbp, rsp           ; Configura novo frame da pilha

    ; allocate memory for .bss variables (9*8)
    push rdi
    mov rdi, 72
    call malloc
    pop rdi
    mov r15, rax ; store .bss variables

    ; for(i = 0; i < order_a; i++) {
    ;     p_a *= dimensions_a[i];
    ; }
    call product
    mov [r15+0*8], rax ; p_a

    ; for(i = 0; i < order_b; i++) {
    ;     p_b *= dimensions_b[i];
    ; }
    push rdi
    mov rdi, rcx
    push rsi
    mov rsi, r8
    call product
    pop rsi
    pop rdi
    mov [r15+1*8], rax ; p_b

    mov qword [r15+2*8], 0 ; pos_a
    mov rax, [r15+0*8] ; p_a
    mov [r15+8*8], rax
    for_a:
        mov qword [r15+3*8], 0 ; pos_b
        mov rcx, [r15+1*8] ; p_b
        for_b:
            ; newpos2 = pos1 * p2 + pos2
            mov rax, [r15+2*8] ; pos_a
            push rdx
            mul qword [r15+1*8] ; p_b
            pop rdx
            add rax, [r15+3*8] ; pos_b
            mov [r15+4*8], rax ; new_pos

            mov rax, [r15+2*8] ; pos_a
            mov rax, [rdx+rax*8]
            mov [r15+6*8], rax ; v_a ;

            mov rax, [r15+3*8] ; pos_b
            mov rax, [r9+rax*8]
            mov [r15+7*8], rax ; v_b

            ; newt.assign(newpos, v1 * v2)
            mov rax, [r15+6*8] ; v_a
            push rdx
            mul qword [r15+7*8] ; v_b
            pop rdx
            mov r14, [r15+4*8] ; new_pos
            mov rbx, [rbp+16]
            mov [rbx+r14*8], rax

            inc qword [r15+3*8] ; pos_b
            dec rcx
            jnz for_b

        inc qword [r15+2*8] ; pos_a
        dec qword [r15+8*8]
        jnz for_a

    pop rbp ; Restaura rbp
    ret