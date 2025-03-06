[BITS 64]  ; Força o modo 64 bits

section .text
    global _start

_start:
    ; Reservando espaço para o array na pilha
    sub rsp, 20  ; Reserva 20 bytes para o array de 5 inteiros

    ; Inicializando o array na pilha manualmente
    mov dword [rsp], 1      ; Atribui o valor 1 ao primeiro elemento (array[0])
    mov dword [rsp + 4], 2  ; Atribui o valor 2 ao segundo elemento (array[1])
    mov dword [rsp + 8], 3  ; Atribui o valor 3 ao terceiro elemento (array[2])
    mov dword [rsp + 12], 4 ; Atribui o valor 4 ao quarto elemento (array[3])
    mov dword [rsp + 16], 5 ; Atribui o valor 5 ao quinto elemento (array[4])

    ; Definindo o valor de oa (5)
    mov rdi, 5    ; rdi -> oa, número de elementos no array

    ; rsi -> endereço do array dA
    lea rsi, [rsp]  ; rsi agora aponta para o começo do array

    ; Inicializando as variáveis de controle
    mov r10, 1      ; r10 será usado para acumular o produto, inicializa com 1
    mov r11, 0      ; r11 será o índice para percorrer o array (0 <= r11 < oa)

    ; Chama a função para calcular o produto dos elementos do array
    call product_A

    ; Finaliza o programa
    mov rax, 60     ; Código de saída
    mov rdi, 0      ; Status de saída (sucesso)
    syscall

product_A:
    cmp r11, rdi    ; Verifica se o índice (r11) chegou a oa
    jge end         ; Se r11 >= rdi, termina o loop

    ; Carrega o valor de array[r11] em rax (registrador de 64 bits)
    mov eax, [rsi + r11 * 4]  ; Carrega o valor de array[r11] em eax (32 bits)

    ; Multiplica o valor de r10 pelo valor de rax (produto acumulado)
    imul r10, rax        ; Multiplica r10 pelo valor de rax (produto acumulado)

    inc r11            ; Incrementa o índice
    jmp product_A      ; Repete o loop

end:
    ; O produto final está em r10
    ; O código de finalização do programa está no final
    ret
