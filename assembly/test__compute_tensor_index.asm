[BITS 64]

; void _compute_tensor_index(
;     unsigned int order,
;     unsigned int *dimensions,
;     unsigned long index,
;     unsigned int *final
; )

section .data
    ; Mensagens de teste
    pass_msg db "Test _compute_tensor_index passed!", 0xA
    pass_len equ $ - pass_msg
    fail_msg db "Teste _compute_tensor_index failed!", 0xA
    fail_len equ $ - fail_msg

    order equ 3
    dimensions dq 3, 4, 5
    index equ 3
    index2 equ 26

section .bss
    final resd 3

section .text
    ; global _start
    global test__compute_tensor_index
    extern _compute_tensor_index

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

    call end

test_failed:
    ; Exibe mensagem de falha
    mov eax, 4       ; syscall: write
    mov ebx, 1       ; file descriptor: stdout
    mov ecx, fail_msg ; mensagem de falha
    mov edx, fail_len ; tamanho da mensagem
    int 0x80         ; chama o kernel

    call end

; _start:
test__compute_tensor_index:
    mov rdi, order
    mov rsi, dimensions
    mov rdx, index
    mov rcx, final
    
    call _compute_tensor_index
    cmp dword [final+0*8], 0
    jne test_failed
    cmp dword [final+1*8], 0
    jne test_failed
    cmp dword [final+2*8], 3
    jne test_failed
    call test_passed

    ; mov rdi, order
    ; mov rsi, dimensions
    ; mov rdx, index2
    ; mov rcx, final
    
    ; call _compute_tensor_index
    ; cmp dword [final+0*8], 1
    ; jne test_failed
    ; cmp dword [final+1*8], 1
    ; jne test_failed
    ; cmp dword [final+2*8], 1
    ; jne test_failed
    ; call test_passed

    ; mov eax, 60      ; syscall: exit (Linux)
    ; xor edi, edi     ; status 0
    ; syscall