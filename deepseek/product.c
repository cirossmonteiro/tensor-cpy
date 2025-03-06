#include <Python.h>
#include <stdio.h>
#include <stdlib.h>

// Declaração da função Assembly
extern void tensor_product_asm(int oa, int *dA, double *A, int ob, int *dB, double *B, double *result);

// Função C que será chamada pelo Python
static PyObject* tensor_product(PyObject* self, PyObject* args) {
    int oa, ob;
    PyObject *dA_obj, *A_obj, *dB_obj, *B_obj, *result_obj;
    int *dA, *dB;
    double *A, *B, *result;

    // Parse dos argumentos Python para C
    if (!PyArg_ParseTuple(args, "iO!O!iO!O!O!", &oa, &PyList_Type, &dA_obj, &PyList_Type, &A_obj, &ob, &PyList_Type, &dB_obj, &PyList_Type, &B_obj, &PyList_Type, &result_obj)) {
        return NULL;
    }

    // Convertendo listas Python para arrays C
    dA = (int *)malloc(oa * sizeof(int));
    for (int i = 0; i < oa; i++) {
        dA[i] = PyLong_AsLong(PyList_GetItem(dA_obj, i));
    }

    A = (double *)malloc(PyList_Size(A_obj) * sizeof(double));
    for (int i = 0; i < PyList_Size(A_obj); i++) {
        A[i] = PyFloat_AsDouble(PyList_GetItem(A_obj, i));
    }

    dB = (int *)malloc(ob * sizeof(int));
    for (int i = 0; i < ob; i++) {
        dB[i] = PyLong_AsLong(PyList_GetItem(dB_obj, i));
    }

    B = (double *)malloc(PyList_Size(B_obj) * sizeof(double));
    for (int i = 0; i < PyList_Size(B_obj); i++) {
        B[i] = PyFloat_AsDouble(PyList_GetItem(B_obj, i));
    }

    // Calcular o tamanho do resultado
    size_t size_A = 1;
    for (int i = 0; i < oa; i++) {
        size_A *= dA[i];
    }

    size_t size_B = 1;
    for (int i = 0; i < ob; i++) {
        size_B *= dB[i];
    }

    size_t size_result = size_A * size_B;

    // Verificar se result_obj tem o tamanho correto
    if (PyList_Size(result_obj) != size_result) {
        PyErr_SetString(PyExc_ValueError, "result list has incorrect size");
        return NULL;
    }

    // Alocar memória para result
    result = (double *)malloc(size_result * sizeof(double));
    if (!result) {
        PyErr_SetString(PyExc_MemoryError, "Failed to allocate memory for result");
        return NULL;
    }

    // Chamando a função Assembly
    tensor_product_asm(oa, dA, A, ob, dB, B, result);

    // Convertendo o resultado de volta para Python
    for (int i = 0; i < size_result; i++) {
        PyList_SetItem(result_obj, i, PyFloat_FromDouble(result[i]));
    }

    // Liberando memória
    free(dA);
    free(A);
    free(dB);
    free(B);
    free(result);

    Py_RETURN_NONE;
}

// Métodos do módulo
static PyMethodDef TensorMethods[] = {
    {"tensor_product", tensor_product, METH_VARARGS, "Calculate the tensor product of two tensors."},
    {NULL, NULL, 0, NULL}
};

// Definição do módulo
static struct PyModuleDef tensor_module = {
    PyModuleDef_HEAD_INIT,
    "tensor",
    NULL,
    -1,
    TensorMethods
};

// Inicialização do módulo
PyMODINIT_FUNC PyInit_tensor(void) {
    return PyModule_Create(&tensor_module);
}