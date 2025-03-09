[BITS 64]

; void contraction (
;     unsigned int order,
;     unsigned int *dimensions,
;     unsigned int I,
;     unsigned int J,
;     unsigned int *values,
;     unsigned int *new_values
; )

section .data


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
    ; ptemp resq 1

section .text
    global contraction
    extern product
    extern _compute_tensor_index
    extern _compute_linear_index

    syscall_mmap  equ 9     ; syscall para mmap
    syscall_munmap equ 11   ; syscall para munmap

; free use: r14,r15

; rdi(r8): order
; rsi(r9): *dimensions
; rdx(r10): I
; rcx(r11): J
; r12: *values
; r13: *new_values
contraction:
    mov r8, rdi
    mov r9, rsi
    mov r10, rdx ; free rdx for division
    mov r11, rcx ; free rcx for loop

    ; for(i = 0; i < order; i++) {
    ;     p *= dimensions[i];
    ; }
    call product
    mov [p], rax

    ; allocate memory for index_array (order)
    mov rax, r8
    mov r14, 8
    mul r14 ; rax == order*8
    mov [array_bytes], rax

    ; --- Chamada mmap para alocar new_order*8 bytes ---
    mov rax, 9                  ; syscall mmap
    mov rdi, 0                  ; endereço (0 = escolha automática)
    mov rsi, [array_bytes]      ; tamanho
    mov rdx, 3                  ; PROT_READ | PROT_WRITE (0x1 | 0x2 = 0x3)
    syscall                     ; Executa mmap

    mov [index_array], rax

    ; --- fim de mmap

    ; allocate memory for new_index_array (order-2)
    mov rax, r8
    sub rax, 2
    mov r14, 8
    mul r14 ; rax == (order-2)*8
    mov [array_bytes], rax

    ; --- Chamada mmap para alocar new_order*8 bytes ---
    mov rax, 9                  ; syscall mmap
    mov rdi, 0                  ; endereço (0 = escolha automática)
    mov rsi, [array_bytes]      ; tamanho
    mov rdx, 3                  ; PROT_READ | PROT_WRITE (0x1 | 0x2 = 0x3)
    syscall                     ; Executa mmap

    mov [new_index_array], rax

    ; --- fim de mmap

    ; allocate memory for new_dimensions (new_order == order-2)
    mov rax, r8
    sub rax, 2
    mov r14, 8
    mul r14 ; rax == new_order*8
    mov [array_bytes], rax

    ; --- Chamada mmap para alocar new_order*8 bytes ---
    mov rax, 9                  ; syscall mmap
    mov rdi, 0                  ; endereço (0 = escolha automática)
    mov rsi, [array_bytes]      ; tamanho
    mov rdx, 3                  ; PROT_READ | PROT_WRITE (0x1 | 0x2 = 0x3)
    syscall                     ; Executa mmap

    mov [new_dimensions], rax

    ; --- fim de mmap

    mov qword [ind], 0 ; current_i = 0;
    mov qword [ind2], 0 ; i = 0;
    mov rcx, r8

    ; for(i = 0; i < order; i++)
    for:
        ; if (i == I || i == J) {
        ;     continue;
        ; }
        cmp [ind], r10 ; i == I
        sete r14b
        cmp [ind], r11 ; i == J
        sete r15b
        or r14b, r15b
        jnz for_continue

        ; new_dimensions[current_i] = dimensions[i];
        mov rsi, r9
        mov r14, [ind]
        mov r15, [ind2]
        mov r15, [rsi+r15*8] ; r12 == dimensions[i]
        mov [new_dimensions+r14*8], r15; new_dimensions[current_i]
        inc qword [ind]

        for_continue:
            inc qword [ind2]
            ; call for
        loop for

        
    ; new_p = product of elements of new_dimensions
    mov rdi, r10
    sub rdi, 2
    mov rsi, new_dimensions
    call product
    mov [new_p], rax

    ; new_values = [0,0,...,0,0]
    mov rcx, [new_p]
    mov qword [ind], 0
    zero_values:
        mov r14, [ind]
        mov qword [r13+r14*8], 0
        inc qword [ind]
        loop zero_values

    mov qword [ind], 0 ; ind == i
    ; for(i = 0; i < p; i++)
    for2:
        ; _compute_tensor_index(order, dimensions, i, index);
        mov rdi, r8
        mov rsi, r9
        mov rdx, [ind]
        mov rcx, [index_array]
        call _compute_tensor_index

        ; if (index[I] == index[J])
        mov r15, [index_array+r12*8]
        cmp [index_array+r11*8], r15
        jne for2_continue

        mov qword [ind2], 0 ; current_i = 0
        mov qword [ind3], 0 ; j = 0
        ; for(j = 0; j < order; j++)
        mov rcx, r8
        for3:
            ; if (j == I || j == J)
            cmp [ind3], r10 ; j == I
            sete r14b
            cmp [ind3], r11 ; j == J
            sete r15b
            or r14b, r15b
            jnz for3_continue

            ; new_index[current_i] = index[j];
            mov r14, [ind2]
            mov r15, [ind3]
            add r15, [index_array]
            mov qword [new_index_array+r14], r15

            inc qword [ind2]

            for3_continue:
                inc qword [ind3]
            loop for3
                
        ; new_pos = _compute_linear_index(new_order, new_dimensions, new_index);
        mov rdi, r8
        mov rsi, r9
        mov rdx, new_index_array
        call _compute_linear_index
        
        ; new_values[new_pos] += values[i];
        mov r14, [ind]
        mov r14, [r12+r14*8]
        add [r13+rax*8], r14

        for2_continue:
            inc qword [ind]
    
    ret