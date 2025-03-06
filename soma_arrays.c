#define PY_SSIZE_T_CLEAN
#include <Python.h>

// Declaração da função em Assembly
extern void soma_arrays(double *A, double *B, double *C, long n);

// Função que será chamada no Python
static PyObject* py_soma_arrays(PyObject *self, PyObject *args) {
    PyObject *listA, *listB;
    Py_ssize_t n;
    
    if (!PyArg_ParseTuple(args, "OO", &listA, &listB)) {
        return NULL;
    }

    n = PyList_Size(listA);
    if (n != PyList_Size(listB)) {
        PyErr_SetString(PyExc_ValueError, "Os arrays devem ter o mesmo tamanho");
        return NULL;
    }

    double *A = (double*) malloc(n * sizeof(double));
    double *B = (double*) malloc(n * sizeof(double));
    double *C = (double*) malloc(n * sizeof(double));

    if (!A || !B || !C) {
        PyErr_SetString(PyExc_MemoryError, "Erro ao alocar memória");
        return NULL;
    }

    for (Py_ssize_t i = 0; i < n; i++) {
        A[i] = PyFloat_AsDouble(PyList_GetItem(listA, i));
        B[i] = PyFloat_AsDouble(PyList_GetItem(listB, i));
    }

    soma_arrays(A, B, C, n);  // Chama a função Assembly

    PyObject *result = PyList_New(n);
    for (Py_ssize_t i = 0; i < n; i++) {
        PyList_SetItem(result, i, PyFloat_FromDouble(C[i]));
    }

    free(A);
    free(B);
    free(C);

    return result;
}

// Métodos do módulo Python
static PyMethodDef Methods[] = {
    {"soma_arrays", py_soma_arrays, METH_VARARGS, "Soma dois arrays de double"},
    {NULL, NULL, 0, NULL}
};

// Definição do módulo Python
static struct PyModuleDef ModuleDef = {
    PyModuleDef_HEAD_INIT,
    "soma_arrays_module",
    NULL,
    -1,
    Methods
};

// Inicialização do módulo
PyMODINIT_FUNC PyInit_soma_arrays_module(void) {
    return PyModule_Create(&ModuleDef);
}
