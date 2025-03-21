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

# ar rcs libmylib.a malloc.o product.o _compute_tensor_index.o _compute_linear_index.o tensor_product.o contraction.o

# C wrapper + linking
gcc -fPIC -c tensor.c $(python3-config --cflags --ldflags)
gcc  -no-pie -nostartfiles -fpic -o tensor_asm.so \
tensor.o \
malloc.o \
product.o \
_compute_tensor_index.o \
_compute_linear_index.o \
tensor_product.o \
contraction.o \
 -shared

# ld -m elf_x86_64 \
# malloc.o \
# product.o \
# _compute_tensor_index.o \
# _compute_linear_index.o \
# tensor_product.o \
# contraction.o \
# -o tensor_asm2.so

echo all compiled
