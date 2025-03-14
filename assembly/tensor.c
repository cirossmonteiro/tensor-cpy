#include <Python.h>

extern void contraction (
    unsigned int order,
    unsigned int *dimensions,
    unsigned int I,
    unsigned int J,
    double *values,
    double *new_values
);

static PyObject* contraction_asm(PyObject* self, PyObject* args) {
    unsigned long order = PyLong_AsUnsignedLong(PyTuple_GetItem(args, 0));
    unsigned long I = PyLong_AsUnsignedLong(PyTuple_GetItem(args, 1));
    unsigned long J = PyLong_AsUnsignedLong(PyTuple_GetItem(args, 2));
    unsigned int *dimensions;
    unsigned long i;
    unsigned long p = 1;
    unsigned long new_p = 1;
    double *values;
    double *new_values;
    PyObject *result;
    
    dimensions = malloc(order*sizeof(unsigned int));
    
    for(i = 0; i < order; i++) {
        dimensions[i] = PyLong_AsUnsignedLong(PyTuple_GetItem(args, i+3));
    }

    for(i = 0; i < order; i++) {
        p *= dimensions[i];
        if (i == I || i == J) {
            continue;
        } else {
            new_p *= dimensions[i];
        }
    }

    values = malloc(p*sizeof(double));
    new_values = malloc(new_p*sizeof(double));
    
    for(i = 0; i < p; i++) {
        values[i] = PyFloat_AsDouble(PyTuple_GetItem(args, i+order+3));
    }

    // core
    contraction(order, dimensions, I, J, values, new_values);

    result = PyList_New(new_p);
    for(i = 0; i < new_p; i++) {
        PyList_SetItem(result, i, PyFloat_FromDouble(new_values[i]));
    }

    free(dimensions);
    free(values);
    free(new_values);

    return result;
}

static PyMethodDef TensorMethods[] = {
    {"contraction_asm", contraction_asm, METH_VARARGS, "Compute contraction using Nasm."},
    {NULL, NULL, 0, NULL} /* Sentinel */
};

static struct PyModuleDef tensor_module = {
    PyModuleDef_HEAD_INIT,
    "tensor", /* name of module */
    NULL,           /* module documentation, may be NULL */
    -1,             /* size of per-interpreter state of the module, or -1 if the module keeps state in global variables. */
    TensorMethods
};

PyMODINIT_FUNC PyInit_tensor(void) {
    return PyModule_Create(&tensor_module);
}