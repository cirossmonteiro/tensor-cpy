#!/bin/sh

echo script started

# library
nasm -f elf64 -o product.o product.asm
nasm -f elf64 -o _compute_tensor_index.o _compute_tensor_index.asm
nasm -f elf64 -o _compute_linear_index.o _compute_linear_index.asm

# tests
nasm -f elf64 -o test_product.o test_product.asm
nasm -f elf64 -o test__compute_tensor_index.o test__compute_tensor_index.asm
nasm -f elf64 -o test__compute_linear_index.o test__compute_linear_index.asm
nasm -f elf64 -o tests.o tests.asm

echo all compiled

# link
ld -m elf_x86_64 \
product.o \
_compute_tensor_index.o \
_compute_linear_index.o \
test_product.o \
test__compute_tensor_index.o \
test__compute_linear_index.o \
tests.o \
-o main_test

echo all linked

chmod +x main_test
echo test started
./main_test
echo test ended
rm main_test # comment to debug
rm *.o