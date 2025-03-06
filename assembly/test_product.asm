[BITS 64]

section .data
    ; Mensagens de teste
    pass_msg db "Test product passed!", 0xA
    pass_len equ $ - pass_msg
    fail_msg db "Test product failed!", 0xA
    fail_len equ $ - fail_msg

    order_a equ 4
    dimensions_a dq 3,4,5,6

section .text
    global test_product
    extern product

; Finaliza o programa
; end:
;     mov eax, 1       ; syscall: exit
;     xor ebx, ebx     ; status 0
;     int 0x80

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
test_product:
    mov rdi, order_a
    mov rsi, dimensions_a
    call product
    mov r14, rax
    cmp rax, 360
    jne test_failed
    call test_passed
    
    ; mov eax, 60      ; syscall: exit (Linux)
    ; xor edi, edi     ; status 0
    ; syscall

; Finaliza o programa
end:
    ; ret
    ; mov eax, 1       ; syscall: exit
    ; xor ebx, ebx     ; status 0
    ; int 0x80