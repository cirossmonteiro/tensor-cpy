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
    p resq 1
    new_p resq 1
    ind resq 1
    ind2 resq 1
    ind3 resq 1
    array_bytes resq 1
    new_dimensions resq 1
    index_array resq 1
    new_index_array resq 1
    I resq 1
    J resq 1
    ; ptemp resq 1

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
; rdx([I]): I
; rcx([J]): J
; r8: *values
; r9: *new_values
contraction:
    ; mov rdi
    ; mov rsi
    mov [I], rdx ; free rdx for division
    mov [J], rcx ; free rcx for loop
    line47:

    ; for(i = 0; i < order; i++) {
    ;     p *= dimensions[i];
    ; }
    call product
    mov [p], rax

    ; allocate memory for index_array (order)
    mov rax, rdi
    mov r10, 8
    mul r10 ; rax == order*8
    push rdi
    mov rdi, rax
    call malloc
    pop rdi
    mov [index_array], rax

    ; allocate memory for new_index_array (order-2)
    mov rax, r8
    sub rax, 2
    mov r10, 8
    mul r10 ; rax == (order-2)*8
    push rdi
    mov rdi, rax
    call malloc
    pop rdi
    mov [new_index_array], rax

    ; allocate memory for new_dimensions (new_order == order-2)
    mov rax, r8
    sub rax, 2
    mov r10, 8
    mul r10 ; rax == new_order*8
    push rdi
    mov rdi, rax
    call malloc
    pop rdi
    mov [new_dimensions], rax

    mov qword r10, 0 ; current_i = 0;
    mov qword r11, 0 ; i = 0;
    mov rcx, rdi
    line93:
        line94:

    ; for(i = 0; i < order; i++)
    for:
        ; if (i == I || i == J) {
        ;     continue;
        ; }
        mov r10, [I]
        cmp [ind], r10 ; i == I
        sete r10b
        mov r10, [J]
        cmp [ind], r10 ; i == J
        sete r11b
        or r10b, r11b
        jnz for_continue

        ; new_dimensions[current_i] = dimensions[i];
        mov r12, [rsi+r11*8] ; r12 == dimensions[i]
        mov [new_dimensions+r10*8], r12 ; new_dimensions[current_i]
        inc r10

        for_continue:
            inc r11

        loop for

    ; new_p = product of elements of new_dimensions
    push rdi
    sub rdi, 2
    push rsi
    mov rsi, new_dimensions
    call product
    pop rsi
    pop rdi
    mov [new_p], rax

    ; new_values = [0,0,...,0,0]
    mov rcx, [new_p]
    zero_new_values:
        mov qword [r9+(rcx-1)*8], 0
        loop zero_new_values

    ; for(i = 0; i < p; i++)
    mov rdx, 0
    for2:
        ; _compute_tensor_index(order, dimensions, i, index);
        ; args pre-defined: rdi, rsi, rdx, rcx
        call _compute_tensor_index

        ; if (index[I] == index[J])
        mov r14, [I]
        mov r14, [index_array+r14*8] ; index[I]
        mov r15, [J]
        mov r15, [index_array+r15*8] ; index[J]
        cmp r14, r15
        jne for2_continue

        mov r10, 0 ; current_i = 0
        ; for(j = 0; j < order; j++)
        mov r11, 0 ; j = 0
        mov rcx, r8 ; loop
        for3:
            ; if (j == I || j == J)
            mov r12, [I]
            cmp r11, r12 ; j == I?
            sete r13b
            mov r12, [J]
            cmp r11, r12; j == J?
            sete r14b
            or r13b, r14b
            jnz for3_continue

            ; new_index[current_i] = index[j];
            mov r12, [index_array+r11*8] ; index[j]
            mov [new_index_array+r10*8], r12

            inc r10

            for3_continue:
                inc r11
            loop for3

        ; new_pos = _compute_linear_index(new_order, new_dimensions, new_index);
        push rdi
        sub rdi, 2
        push rsi
        mov rsi, new_dimensions
        push rdx
        mov rdx, new_index_array
        call _compute_linear_index
        pop rdx
        pop rsi
        pop rdi
        
        ; rax = new_pos
        ; new_values[new_pos] += values[i];
        mov r10, [r8+rdx*8]
        add [r9+rax*8], r10

        for2_continue:
            inc rdx

    ret