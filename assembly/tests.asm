section .text
    global _start
    ; extern test_product
    extern test__compute_tensor_index

_start:
    ; call test_product
    call test__compute_tensor_index
    
    mov eax, 1       ; syscall: exit
    xor ebx, ebx     ; status 0
    int 0x80