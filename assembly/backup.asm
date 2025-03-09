
    ; allocate memory for index_a (order_a)
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

    mov [index_a], rax

    ; --- fim de mmap

    ; allocate memory for index_b (order_b)
    mov rax, r11
    mov r14, 8
    mul r14 ; rax == order*8
    mov [array_bytes], rax

    ; --- Chamada mmap para alocar new_order*8 bytes ---
    mov rax, 9                  ; syscall mmap
    mov rdi, 0                  ; endereço (0 = escolha automática)
    mov rsi, [array_bytes]      ; tamanho
    mov rdx, 3                  ; PROT_READ | PROT_WRITE (0x1 | 0x2 = 0x3)
    syscall                     ; Executa mmap

    mov [index_b], rax

    ; --- fim de mmap

    ; allocate memory for new_pos (order_a+order_b)
    mov rax, r8
    add rax, r11
    mov r14, 8
    mul r14 ; rax == order*8
    mov [array_bytes], rax

    ; --- Chamada mmap para alocar new_order*8 bytes ---
    mov rax, 9                  ; syscall mmap
    mov rdi, 0                  ; endereço (0 = escolha automática)
    mov rsi, [array_bytes]      ; tamanho
    mov rdx, 3                  ; PROT_READ | PROT_WRITE (0x1 | 0x2 = 0x3)
    syscall                     ; Executa mmap

    mov [index_ab], rax

    ; --- fim de mmap

; index1 = self.compute_tensor_index(pos1)
        mov rdi, r8
        mov rsi, r9
        mov rdx, [pos_a]
        mov rcx, [index_a]
        call _compute_tensor_index

        ; index2 = self.compute_tensor_index(pos2)
        mov rdi, r11
        mov rsi, r12
        mov rdx, [pos_b]
        mov rcx, [index_b]
        call _compute_tensor_index

        ; newpos = newt.compute_linear_index([*index1, *index2])
        call _compute_linear_index