section .text
    global soma_arrays

    ; Função para somar dois arrays de double
    ; void tensor_product(int oa, int *dA, double *A, int ob, int *dB, double *B)
    ; A -> rdi (ponteiro para o primeiro array)
    ; B -> rsi (ponteiro para o segundo array)
    ; C -> rdx (ponteiro para o array de saída)
    ; n -> rcx (quantidade de elementos)
soma_arrays:
    test rcx, rcx       ; Verifica se n é 0
    jz fim              ; Se for zero, sai da função
    xor r11, r11 ; index walk through A's dimensions

.product_a:
    mov xmm0, [rdi+r11*8]
    mul xmm1, xmm0 ; p *= A[i]
    inc r11 ; increment index

    loop .loop          ; Decrementa RCX e continua o loop se não for zero

fim:
    ret