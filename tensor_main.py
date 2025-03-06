import math
import typing
import time
import unittest

import numpy
import pycuda.driver as cuda

import tensor

MODE_C = True

def numpy_contraction(t, i, j):
    return numpy.tensordot(t, numpy.eye(t.shape[i]), axes=([i, j], [0, 1]))


class Tensor:
    index = []

    def __init__(self, dimensions: list[int]):
        self.dimensions = dimensions
        p = math.prod(dimensions)
        self.values: list = [None for n in range(p)]

    @property
    def order(self):
        return len(self.dimensions)

    def assign(self, index, value):
        self.values[index] = value

    # O(k)
    def compute_tensor_index(self, index: int) -> list[int]:
        if MODE_C:
            return tensor.compute_tensor_index(index, *self.dimensions)
        final = [0 for _ in self.dimensions]
        p = math.prod(self.dimensions) # this is computed too many times for the same array 'dimensions'
        r = 0
        for i, dimension in enumerate(self.dimensions):
            p //= dimension
            final[i] = (index - r) // p
            r += final[i]*p
        return final

    # O(k)
    ############# UNDER WORK
    def compute_linear_index(self, index: list[int]) -> int:
        if MODE_C:
            return tensor.compute_linear_index(*self.dimensions, *index)
        
        if len(index) != self.order:
            raise Exception("Index's length and dimensions's length MUST be equal.")
        p, final = 1, 0
        for i, dimension in enumerate(self.dimensions[::-1]):
            final += index[-i-1]*p
            p *= dimension
        return final

    def __getitem__(self, index):
        if isinstance(index, list):
            if len(index) == len(self.dimensions):
                pos = self.compute_linear_index(index)
                return self.values[pos]
            else:
                raise IndexError("""
                    Index and dimensions MUST have the same length.
                """)
        elif len(self.index) == len(self.dimensions)-1:
            index = [*self.index, index]
            pos = self.compute_linear_index(index)
            return self.values[pos]
        else:
            newt = Tensor(self.dimensions[:])
            newt.values = self.values[:]
            newt.index = [*self.index, index]
            newt.assign = self.assign
            return newt

    def __setitem__(self, index, value):
        index = [*self.index, index]
        if len(index) == len(self.dimensions):
            pos = self.compute_linear_index(index)
            self.assign(pos, value)
        elif isinstance(value, Tensor):
            if len(self.dimensions) == len(index) + len(value.dimensions):
                index_extended = [
                    *index,
                    *[0 for _ in range(len(value.dimensions))]]
                pos = self.compute_linear_index(index_extended)
                for i, x in enumerate(value.values):
                    self.assign(pos + i, x)
            else:
                raise IndexError("""
                    Tensor provided is not compatible with current index.
                """)
        else:
            raise IndexError("Not enough indexes provided.")

    def __mul__(self, other: typing.Self):
        newt = Tensor([*self.dimensions, *other.dimensions])
        p2 = math.prod(other.dimensions)
        for pos1, v1 in enumerate(self.values):
            for pos2, v2 in enumerate(other.values):
                # first approach - bad!
                index1 = self.compute_tensor_index(pos1)  # O(k1)
                index2 = other.compute_tensor_index(pos2)  # O(k2)
                newpos = newt.compute_linear_index([*index1, *index2])

                # second approach - good!
                newpos2 = pos1 * p2 + pos2
                assert newpos == newpos2
                newt.assign(newpos, v1 * v2)

        return newt

    def contraction(self, i, j):
        if self.dimensions[i] == self.dimensions[j]:
            dimensions = [
                d
                for k, d in enumerate(self.dimensions)
                if k not in [i, j]
            ]
            newt = Tensor(dimensions)
            if MODE_C:
                start = time.time()
                newt.values = tensor.contraction(len(self.dimensions), i, j, *self.dimensions, *self.values)
                end = time.time()
                print("mode c", end-start)
            else:
                start = time.time()
                newt.values = [0 for _ in range(math.prod(dimensions))]
                for pos, v in enumerate(self.values):
                    index = self.compute_tensor_index(pos)
                    if index[i] == index[j]:
                        new_index = [d for k, d in enumerate(index) if k not in [i,j]]
                        new_pos = newt.compute_linear_index(new_index)
                        newt.values[new_pos] += v
                end = time.time()
                print("mode python", end-start)
            return newt
        else:
            raise IndexError("Bad indices, they MUST have the same dimension.")

class TestTensorMethods(unittest.TestCase):
    def test_computes(self):
        linear_index = 2*4*5+3*5+4
        tensor_index = [2,3,4]
        dimensions = [3,4,5]
        tensor = Tensor(dimensions)
        self.assertEqual(
            tensor.compute_linear_index(tensor_index),
            linear_index
        )
        self.assertListEqual(
            tensor.compute_tensor_index(linear_index),
            tensor_index
        )

    def test_element_assign(self):
        dimensions = [3,4,5,6]
        t1 = Tensor(dimensions)
        t1.values = list(range(math.prod(dimensions)))
        self.assertEqual(t1.order, len(dimensions))
        for i in range(3):
            for j in range(4):
                for k in range(5):
                    for l in range(6):
                        v = i*4*5*6 + j*5*6 + k*6 + l
                        self.assertEqual(t1[i][j][k][l], v)
                        t1[i][j][k][l] = v+1
                        self.assertEqual(t1[i][j][k][l], v+1)

    def test_tensor_assign(self):
        d1, d2 = [3,4,5,6], [5,6]
        t1, t2 = Tensor(d1), Tensor(d2)
        t1.values = list(range(math.prod(d1)))
        for k in range(5):
            for l in range(6):
                t2[k][l] = k*6+l
        for i in range(3):
            for j in range(4):
                t1[i][j] = t2
                for k in range(5):
                    for l in range(6):
                        self.assertEqual(t1[i][j][k][l], k*6 + l)
    
    def test_tensor_mult(self):
        d1, d2 = [3,4], [5,6,7]
        t1, t2 = Tensor(d1), Tensor(d2)
        t1.values = list(range(math.prod(d1)))
        t2.values = list(range(math.prod(d2)))
        t3 = t1 * t2
        self.assertEqual(t1.order, len(d1))
        self.assertEqual(t2.order, len(d2))

        # numpy
        v1 = numpy.arange(12).reshape([3,4])
        v2 = numpy.arange(210).reshape([5,6,7])
        v3 = numpy.tensordot(v1,v2, axes=0)

        for i in range(3):
            for j in range(4):
                for k in range(5):
                    for l in range(6):
                        for m in range(7):
                            self.assertEqual(
                                t1[i][j] * t2[k][l][m],
                                t3[i][j][k][l][m]
                            )

                            # numpy
                            self.assertEqual(
                                v3[i][j][k][l][m],
                                t3[i][j][k][l][m]
                            )
    
    def test_matrix_mult(self):
        d1 = d2 = [2,2]
        t1 = Tensor(d1)
        t2 = Tensor(d2)
        t1.values = [1,2,3,4]
        t2.values = [5,6,7,8]
        newt = (t1*t2).contraction(1,2)
        self.assertListEqual(newt.values, [19,22,43,50])
    
    def test_time_elapsed(self):
        # return
        start = time.time()
        d1 = d2 = [10, 11, 12]
        t1 = Tensor(d1)
        t2 = Tensor(d2)
        t1.values = list(range(math.prod(d1)))
        t2.values = list(range(math.prod(d2)))
        (t1*t2).contraction(1,4)
        end = time.time()
        print("mode c", MODE_C, end-start)

        start = time.time()
        d1 = d2 = [10,11,12]
        v1 = numpy.arange(math.prod(d1)).reshape(d1)
        v2 = numpy.arange(math.prod(d2)).reshape(d2)
        v3 = numpy.tensordot(v1,v2, axes=0)
        numpy_contraction(v3, 1, 4)
        end = time.time()
        print("numpy", end-start)
        



if __name__ == '__main__':
    unittest.main()