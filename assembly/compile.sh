#!/bin/sh

# compile
nasm -f elf64 -o product.o product.asm
nasm -f elf64 -o _compute_tensor_index.o _compute_tensor_index.asm
nasm -f elf64 -o test_product.o test_product.asm
nasm -f elf64 -o test__compute_tensor_index.o test__compute_tensor_index.asm


# link
ld -m elf_x86_64 test_product.o product.o -o main