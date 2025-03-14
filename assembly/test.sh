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

# tests
nasm -f elf64 -o test_product.o test_product.asm
nasm -f elf64 -o test__compute_tensor_index.o test__compute_tensor_index.asm
nasm -f elf64 -o test__compute_linear_index.o test__compute_linear_index.asm
nasm -f elf64 -o test_tensor_product.o test_tensor_product.asm
nasm -f elf64 -o tests.o tests.asm

echo all compiled

# link
ld -m elf_x86_64 \
malloc.o \
product.o \
_compute_tensor_index.o \
_compute_linear_index.o \
tensor_product.o \
contraction.o \
test_product.o \
test__compute_tensor_index.o \
test__compute_linear_index.o \
test_tensor_product.o \
tests.o \
-o main_test

echo all linked

chmod +x main_test
echo test started
./main_test
echo test ended
# rm main_test # comment to debug
rm *.o