[BITS 64]

section .data
    order_a dq 2
    order_b dq 2
    dimensions_a dq 100, 100
    dimensions_b dq 100, 100
    tensor_dimensions dq 100, 100, 100, 100

section .bss
    values_a resq 10000 ; 100*100
    values_b resq 10000 ; 100*100
    tensor_values resq 100000000 ; 10000*10000
    matrix_values resq 10000

section .text
    global _start
    
    extern contraction
    extern malloc
    extern tensor_product

_start:
    ; allocate memory
    mov rdi, 10000*8
    call malloc
    mov [values_a], rax
    call malloc
    mov [values_b], rax
    
    ; init memory
    mov rcx, 10000
    fill:
        mov qword [values_a+rcx*8], 1
        mov qword [values_b+rcx*8], 1
        loop fill

    ; setting arguments for tensor product
    mov rdi, [order_a]
    mov rsi, dimensions_a
    mov rdx, values_a
    mov rcx, [order_b]
    mov r8, dimensions_b,
    mov r9, values_b
    push tensor_values

    call tensor_product

    mov rdi, 4
    mov rsi, tensor_dimensions
    mov rdx, 1
    mov rcx, 2
    mov r8, tensor_values
    mov r9, matrix_values

    call contraction

; Finaliza o programa
end:
    mov eax, 1       ; syscall: exit
    xor ebx, ebx     ; status 0
    int 0x80
