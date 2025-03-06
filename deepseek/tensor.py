import tensor

dA = [2, 2]
A = [1.0, 2.0, 3.0, 4.0]
dB = [2, 2]
B = [5.0, 6.0, 7.0, 8.0]
result = [0.0] * (len(A) * len(B))

tensor.tensor_product(2, dA, A, 2, dB, B, result)
print(result)