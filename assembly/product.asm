[BITS 64]

section .text
    global product

; rdi: order
; rsi: array of dimensions
; rax: return
product:
    mov rax, 1
    mov rcx, rdi
    mov rdi, 0
    main_product:
        mov rbx, [rsi+rdi*8] ; DEBUG here
        imul rax, rbx
        inc rdi
        loop main_product
    
    ret
    
    
;     mov [product_a], eax
;     mov ebx, [product_a]

; ; compute product_a
;     mov eax, 1
;     mov ecx, order_a
;     mov rsi, dimensions_a

; fproduct_a:
;     mov ebx, [rsi]
;     imul eax, ebx
;     add rsi, 4
;     loop fproduct_a

;     mov [product_a], eax
;     mov ebx, [product_a]

; ; compute product_b
;     mov eax, 1
;     mov ecx, order_b
;     mov rsi, dimensions_b

; fproduct_b:
;     mov ebx, [rsi]
;     imul eax, ebx
;     add rsi, 4
;     loop fproduct_b

;     mov [product_b], eax
;     mov ebx, [product_b]