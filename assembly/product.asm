[BITS 64]

section .text
    global product

; rdi: order
; rsi: array of dimensions
; rax: return
product:
    push rbx
    push rcx
    push rdx
    
    mov rax, 1
    mov rcx, rdi

    main_product:
        mov rbx, [rsi+(rcx-1)*8] ; DEBUG here
        mul rbx
        loop main_product
    pop rdx
    pop rcx
    pop rbx

    ret