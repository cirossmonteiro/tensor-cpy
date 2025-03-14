#!/bin/sh

echo script started

# utils
nasm -f elf64 -o malloc.o malloc.asm

# library
nasm -f elf64 -o product.o product.asm
nasm -f elf64 -o _compute_tensor_index.o _compute_tensor_index.asm
nasm -f elf64 -o _compute_linear_index.o _compute_linear_index.asm
nasm -f elf64 -o tensor_product.o tensor_product.asm
nasm -f elf64 -o contraction.o contraction.asm

# main
nasm -f elf64 -o benchmark.o benchmark.asm

# link
ld -m elf_x86_64 \
malloc.o \
product.o \
_compute_tensor_index.o \
_compute_linear_index.o \
tensor_product.o \
contraction.o \
benchmark.o \
-o benchmark

echo benchmark compiled