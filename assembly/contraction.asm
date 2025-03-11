[BITS 64]

; void contraction (
;     unsigned int order,
;     unsigned int *dimensions,
;     unsigned int I,
;     unsigned int J,
;     unsigned int *values,
;     unsigned int *new_values
; )

; section .data
;     p dw 1
;     new_p dw 1
;     array_bytes dw 1
;     new_dimensions dw 1
;     index_array dw 1
;     new_index_array dw 1
;     I dw 1
;     J dw 1

section .bss
    p resq 1
    new_p resq 1
    array_bytes resq 1
    new_dimensions resq 1
    index_array resq 1
    new_index_array resq 1
    I resq 1
    J resq 1

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
    mov [I], rdx ; free rdx for division
    mov [J], rcx ; free rcx for loop

    ; allocate memory for index_array (order)
    push rdi
    mov rax, 8
    mul rdi ; rax == order*8
    mov rdi, rax
    call malloc
    pop rdi
    mov [index_array], rax

    ; allocate memory for new_index_array (order-2)
    mov rax, r8
    sub rax, 2
    mov rbx, 8
    mul rbx ; rax == (order-2)*8
    push rdi
    mov rdi, rax
    call malloc
    pop rdi
    mov [new_index_array], rax

    ; allocate memory for new_dimensions (new_order == order-2)
    mov rax, r8
    sub rax, 2
    mov rbx, 8
    mul rbx ; rax == new_order*8
    push rdi
    mov rdi, rax
    call malloc
    pop rdi
    mov [new_dimensions], rax

    mov r10, 0 ; current_i = 0;
    mov r11, 0 ; i = 0;
    mov rcx, rdi ; loop
    ; for(i = 0; i < order; i++)
    for:
        ; if (i == I || i == J) {
        ;     continue;
        ; }
        cmp r11, [I] ; i == I
        sete ah
        cmp r11, [J] ; i == J
        sete al
        or ah, al
        jnz for_continue

        ; new_dimensions[current_i] = dimensions[i];
        mov rax, [rsi+r11*8] ; rax == dimensions[i]
        mov [new_dimensions+r10*8], rax ; new_dimensions[current_i]
        inc r10

        for_continue:
            inc r11

        loop for

    ; new_p : product of elements of new_dimensions
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
        ; args pre-defined: rdi, rsi, rdx
        push rcx
        mov rcx, index_array
        call _compute_tensor_index
        pop rcx

        ; if (index[I] == index[J])
        mov rax, [I]
        mov rax, [index_array+rax*8] ; index[I]
        mov rbx, [J]
        mov rbx, [index_array+rbx*8] ; index[J]
        cmp rax, rbx
        jne for2_continue

        mov r10, 0 ; current_i = 0
        ; for(j = 0; j < order; j++)
        mov r11, 0 ; j = 0
        mov rcx, rdi ; loop
        for3:
            ; if (j == I || j == J)
            cmp r11, [I] ; j == I?
            sete ah
            cmp r11, [J]; j == J?
            sete al
            or ah, al
            jnz for3_continue

            ; new_index[current_i] = index[j];
            mov rax, [index_array+r11*8] ; index[j]
            mov [new_index_array+r10*8], rax ; new_index[current_i]

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
        mov rbx, [r8+rdx*8]
        add [r9+rax*8], rbx

        for2_continue:
            inc rdx

    ret