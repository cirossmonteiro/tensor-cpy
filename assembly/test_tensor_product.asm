[BITS 64]

section .data
    ; Mensagens de teste
    pass_msg db "Test tensor_product passed!", 0xA
    pass_len equ $ - pass_msg
    fail_msg db "Teste tensor_product failed!", 0xA
    fail_len equ $ - fail_msg

    dimensions_a dq 2, 2
    dimensions_b dq 2, 2
    values_a dq 1, 2, 3, 4
    values_b dq 5, 6, 7, 8
    matrix_values dq 19, 22, 43 50
    tensor_values dq 5,6,7,8 , 10,12,14,16 , 15,18,21,24 , 20,24,28,32

section .bss
    new_values resq 16

section .text
    global test_tensor_product
    extern tensor_product

; Finaliza o programa
end:
    mov eax, 1       ; syscall: exit
    xor ebx, ebx     ; status 0
    int 0x80

test_passed:
    ; Se todos os testes passaram, exibe mensagem de sucesso
    mov eax, 4       ; syscall: write
    mov ebx, 1       ; file descriptor: stdout
    mov ecx, pass_msg ; mensagem de sucesso
    mov edx, pass_len ; tamanho da mensagem
    int 0x80         ; chama o kernel

    ret

test_failed:
    ; Exibe mensagem de falha
    mov eax, 4       ; syscall: write
    mov ebx, 1       ; file descriptor: stdout
    mov ecx, fail_msg ; mensagem de falha
    mov edx, fail_len ; tamanho da mensagem
    int 0x80         ; chama o kernel

    ret

; _start:
test_tensor_product:
    ; first test case
    mov rdi, 2
    mov rsi, dimensions_a
    mov rdx, values_a
    mov rcx, 2
    mov r8, dimensions_b,
    mov r9, values_b
    push new_values
    
    call tensor_product

    mov r10, 0
    mov rcx, 16
    for:
        mov r11, [tensor_values+r10*8]
        cmp qword [new_values+r10*8], r11
        jne test_failed
        inc r10
        loop for

    jmp test_passed
    
    ret