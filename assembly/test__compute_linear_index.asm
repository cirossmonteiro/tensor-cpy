[BITS 64]

; unsigned long _compute_linear_index(
;     unsigned int order,
;     unsigned int *dimensions,
;     unsigned int *index
; )

section .data
    ; Mensagens de teste
    pass_msg db "Test _compute_linear_index passed!", 0xA
    pass_len equ $ - pass_msg
    fail_msg db "Teste _compute_linear_index failed!", 0xA
    fail_len equ $ - fail_msg

    order equ 3
    dimensions dq 3, 4, 5
    index dq 1, 1, 1

section .bss
    final resq 3

section .text
    global test__compute_linear_index
    extern _compute_linear_index

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
test__compute_linear_index:
    ; first test case
    mov rdi, order
    mov rsi, dimensions
    mov rdx, index
    
    call _compute_linear_index

    cmp qword rax, 26
    jne test_failed
    jmp test_passed

    ; todo: ; second test case
    
    ret