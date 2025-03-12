[BITS 64]

section .data
    errors dq 0

section .text
    global _start
    ; extern test_product
    ; extern test__compute_tensor_index
    ; extern test__compute_linear_index
    extern test_tensor_product

_start:
    ; call test_product
    ; call test__compute_tensor_index
    ; call test__compute_linear_index
    call test_tensor_product
    
    mov eax, 1      ; syscall: exit
    xor ebx, ebx     ; status 0
    int 0x80