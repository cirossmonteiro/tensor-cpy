[BITS 64]  ; Força o modo 64 bits

section .data
    ; global dimensions
    dimensions dd 1,2,3,4,5,6,7,8
    order equ 5

section .text
    global _start

_start:
    mov eax, 1
    mov ecx, order
    mov rdi, 0
    mov rsi, dimensions

product:
    mov ebx, [rsi]
    imul eax, ebx
    add rsi, 4
    loop product

    ; mov rdx, rax
    
    ; ret

    ; mov eax, 60   ; Número da syscall 'exit' no Linux
    ; xor edi, edi  ; Código de saída 0 (sem erro)
    ; syscall       ; Chama o kernel para encerrar o programa
