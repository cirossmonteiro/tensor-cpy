[BITS 64]

section .data
    errors dq 0

section .text
    global _start
    ; extern test_product
    extern test__compute_tensor_index

_start:
    ; call test_product
    call test__compute_tensor_index
    add [errors], rax
    mov r14, [errors]
    ret
    
    mov eax, 1      ; syscall: exit
    xor ebx, ebx     ; status 0
    int 0x80