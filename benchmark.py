import math

import numpy

def numpy_contraction(t, i, j):
    return numpy.tensordot(t, numpy.eye(t.shape[i]), axes=([i, j], [0, 1]))


d1 = d2 = [100, 100]
v1 = numpy.arange(math.prod(d1)).reshape(d1)
v2 = numpy.arange(math.prod(d2)).reshape(d2)
v3 = numpy.tensordot(v1, v2, axes=0)
numpy_contraction(v3, 1, 2)
