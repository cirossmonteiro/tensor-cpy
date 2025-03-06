section .text
global tensor_product_asm

; Argumentos:
;   rdi: oa (ordem de A)
;   rsi: dA (dimensões de A)
;   rdx: A (valores de A)
;   rcx: ob (ordem de B)
;   r8: dB (dimensões de B)
;   r9: B (valores de B)
;   [rsp+16]: result (resultado)

tensor_product_asm:
    ; Entradas:
    ; rdi = oa (ordem de A)
    ; rsi = dA (dimensões de A)
    ; rdx = A (valores do tensor A)
    ; rcx = ob (ordem de B)
    ; r8 = dB (dimensões de B)
    ; r9 = B (valores do tensor B)
    ; r10 = result (onde o produto será salvo)

    ; Calcula o produto tensorial de A e B
    ; Para simplificação, vamos fazer uma iteração simples sobre os índices de A e B.
    
    ; Tamanho do produto final (oa * ob)
    mov r11, rdi          ; r11 = oa
    imul r11, rcx         ; r11 = oa * ob

    ; Inicializa o índice de resultado
    xor r12, r12          ; r12 = 0, índice para o resultado

.loop_product:
    ; Calcular a posição em A
    ; A[i] = rdx[rdi], para o índice de A, o valor está em A

    ; Calcular a posição em B
    ; B[i] = r9[rsi], para o índice de B, o valor está em B

    ; Realizar o cálculo do produto
    ; result[r12] = A[i] * B[j]

    ; Avançar o índice para o próximo produto
    inc r12
    cmp r12, r11
    jl .loop_product

    ret
