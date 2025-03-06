#include <Python.h>

extern void tensor_product_asm(int oa, int *dA, double *A, int ob, int *dB, double *B, double *result);

static PyObject* py_tensor_product(PyObject* self, PyObject* args) {
    int oa, ob;
    PyObject *dA_obj, *dB_obj;
    PyObject *A_obj, *B_obj;
    double *A, *B, *result;
    int *dA, *dB;
    
    if (!PyArg_ParseTuple(args, "iOOiOO", &oa, &dA_obj, &A_obj, &ob, &dB_obj, &B_obj))
        return NULL;

    // Convert Python lists to C arrays
    dA = (int*)malloc(oa * sizeof(int));
    dB = (int*)malloc(ob * sizeof(int));
    A = (double*)malloc(oa * sizeof(double));  // Aqui, precisaria de um tamanho adequado
    B = (double*)malloc(ob * sizeof(double));  // Aqui, precisaria de um tamanho adequado
    result = (double*)malloc(oa * ob * sizeof(double));  // Para o resultado final

    for (int i = 0; i < oa; i++) {
        dA[i] = (int)PyLong_AsLong(PyList_GetItem(dA_obj, i));
        A[i] = PyFloat_AsDouble(PyList_GetItem(A_obj, i));
    }

    for (int i = 0; i < ob; i++) {
        dB[i] = (int)PyLong_AsLong(PyList_GetItem(dB_obj, i));
        B[i] = PyFloat_AsDouble(PyList_GetItem(B_obj, i));
    }

    // Chama a função em Assembly
    tensor_product_asm(oa, dA, A, ob, dB, B, result);

    // Retorna o resultado como uma lista de floats
    PyObject *result_list = PyList_New(oa * ob);
    for (int i = 0; i < oa * ob; i++) {
        PyList_SetItem(result_list, i, PyFloat_FromDouble(result[i]));
    }

    // Libera as alocações de memória
    free(dA);
    free(dB);
    free(A);
    free(B);
    free(result);

    return result_list;
}

// Definição do método para Python
static PyMethodDef TensorMethods[] = {
    {"tensor_product", py_tensor_product, METH_VARARGS, "Calcula o produto tensorial de A e B."},
    {NULL, NULL, 0, NULL}  // Sentinel
};

// Definição do módulo
static struct PyModuleDef tensormodule = {
    PyModuleDef_HEAD_INIT,
    "tensor_product",   // nome do módulo
    NULL,               // documentação
    -1,                 // tamanho da estrutura do estado
    TensorMethods       // lista de métodos
};

// Inicialização do módulo
PyMODINIT_FUNC PyInit_tensor_product(void) {
    return PyModule_Create(&tensormodule);
}
