import ctypes
# import tensor_asm

# Carrega a biblioteca compartilhada
mylib = ctypes.CDLL("./tensor_asm.so")

# # Define os tipos de argumento e retorno para sum_numbers
# mylib.sum_numbers.argtypes = [ctypes.c_long, ctypes.c_long]
# mylib.sum_numbers.restype = ctypes.c_long

# # Define os tipos de argumento e retorno para sub_numbers
# mylib.sub_numbers.argtypes = [ctypes.c_long, ctypes.c_long]
# mylib.sub_numbers.restype = ctypes.c_long

# # Teste das funções
# a, b = 15, 5
# print(f"Soma: {mylib.sum_numbers(a, b)}")        # Esperado: 20
# print(f"Subtração: {mylib.sub_numbers(a, b)}")   # Esperado: 10