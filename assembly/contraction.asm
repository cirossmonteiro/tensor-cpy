[BITS 64]

; void contraction (
;     unsigned int order,
;     unsigned int *dimensions,
;     unsigned int I,
;     unsigned int J,
;     unsigned int *values,
;     unsigned int *new_values
; )

section .bss
    new_index_array resq 1

section .text
    global contraction
    extern malloc
    extern product
    extern _compute_tensor_index
    extern _compute_linear_index

    syscall_mmap  equ 9     ; syscall para mmap
    syscall_munmap equ 11   ; syscall para munmap

; free use: r10-r15

; rdi: order
; rsi: *dimensions
; rdx(r10): I
; rcx(r11): J
; r8: *values
; r9: *new_values
contraction:
    mov r10, rdx ; free rdx for division
    mov r11, rcx ; free rcx for loop

    ; allocate memory for index_array (order)
    push rdi
    mov rax, 8
    mul rdi ; rax == order*8
    mov rdi, rax
    call malloc
    pop rdi
    mov r14, rax

    ; allocate memory for new_index_array (order-2)
    mov rax, r8
    sub rax, 2
    mov rbx, 8
    mul rbx ; rax == (order-2)*8
    push rdi
    mov rdi, rax
    call malloc
    pop rdi
    mov r15, rax

    ; allocate memory for new_dimensions (new_order == order-2)
    mov rax, r8
    sub rax, 2
    mov rbx, 8
    mul rbx ; rax == new_order*8
    push rdi
    mov rdi, rax
    call malloc
    pop rdi
    mov r13, rax

    mov rcx, 0 ; current_i = 0;
    mov rbx, 0 ; i = 0;
    ; for(i = 0; i < order; i++)
    for:
        ; if (i == I || i == J) {
        ;     continue;
        ; }
        cmp rbx, r10 ; i == I
        sete ah
        cmp rbx, r11 ; i == J
        sete al
        or ah, al
        jnz for_continue

        ; new_dimensions[current_i] = dimensions[i];
        mov rax, [rsi+rbx*8] ; rax == dimensions[i]
        mov [r13+rcx*8], rax ; new_dimensions[current_i]
        inc rcx

        for_continue:
            inc rbx

        cmp rbx, rdi
        jne for
    
    ; p : product of elements of dimensions
    call product
    mov r12, rax

    ; new_p : product of elements of new_dimensions
    push rdi
    sub rdi, 2
    push rsi
    mov rsi, r13
    call product
    pop rsi
    pop rdi
    mov rcx, rax

    ; new_values = [0,0,...,0,0]
    zero_new_values:
        mov qword [r9+(rcx-1)*8], 0
        loop zero_new_values

    ; line118:
        
    ; for(i = 0; i < p; i++)
    mov rdx, 0
    for2:
        ; _compute_tensor_index(order, dimensions, i, index);
        ; args pre-defined: rdi, rsi, rdx
        push rcx
        mov rcx, r14
        call _compute_tensor_index
        pop rcx

        ; if (index[I] == index[J])
        mov rax, r10
        mov rax, [r14+rax*8] ; index[I]
        mov rbx, r11
        mov rbx, [r14+rbx*8] ; index[J]
        cmp rax, rbx
        jne for2_continue

        push rdx
        mov rdx, 0 ; current_i = 0
        ; for(j = 0; j < order; j++)
        mov rbx, 0 ; j = 0
        for3:
            ; if (j == I || j == J)
            cmp rbx, r10 ; j == I?
            sete ah
            cmp rbx, r11; j == J?
            sete al
            or ah, al
            jnz for3_continue

            ; new_index[current_i] = index[j];
            mov rax, [r14+rbx*8] ; index[j]
            mov [r15+rdx*8], rax ; new_index[current_i]

            inc rdx

            for3_continue:
                inc rbx
            cmp rbx, rdi
            jne for3
        
        pop rdx

        ; new_pos = _compute_linear_index(new_order, new_dimensions, new_index);
        push rdi
        sub rdi, 2
        push rsi
        mov rsi, r13
        push rdx
        mov rdx, r15
        call _compute_linear_index
        pop rdx
        pop rsi
        pop rdi
        
        ; rax = new_pos
        ; new_values[new_pos] += values[i];
        mov rbx, [r8+rdx*8]
        add [r9+rax*8], rbx

        for2_continue:
            inc rdx
        cmp rdx, r12 ; i < p
        jne for2

    ret

; Segmentation fault (core dumped)
; for2 without end