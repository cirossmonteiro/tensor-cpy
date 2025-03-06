[BITS 64]

section .data
    order_a equ 5
    dimensions_a dd 1,2,3,4,5
    product_a dd 0

    order_b equ 4
    dimensions_b dd 3,4,5,6
    product_b dd 0

section .text
    global _start

_start:

; compute product_a
    mov eax, 1
    mov ecx, order_a
    mov rsi, dimensions_a

fproduct_a:
    mov ebx, [rsi]
    imul eax, ebx
    add rsi, 4
    loop fproduct_a

    mov [product_a], eax
    mov ebx, [product_a]

; compute product_b
    mov eax, 1
    mov ecx, order_b
    mov rsi, dimensions_b

fproduct_b:
    mov ebx, [rsi]
    imul eax, ebx
    add rsi, 4
    loop fproduct_b

    mov [product_b], eax
    mov ebx, [product_b]