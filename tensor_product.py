import tensor_product

A = [1.0, 2.0, 3.0]
B = [4.0, 5.0]
dA = [3]
dB = [2]
result = tensor_product.tensor_product(1, dA, A, 1, dB, B)

print(result)