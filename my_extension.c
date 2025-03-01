#include <Python.h>

static PyObject* my_extension_hello(PyObject* self, PyObject* args) {
    const char* name;

    if (!PyArg_ParseTuple(args, "s", &name)) {
        return NULL;
    }

    printf("Hello, %s!\n", name);

    Py_RETURN_NONE;
}

static PyMethodDef MyExtensionMethods[] = {
    {"hello", my_extension_hello, METH_VARARGS, "Print a hello message."},
    {NULL, NULL, 0, NULL} /* Sentinel */
};

static struct PyModuleDef my_extension_module = {
    PyModuleDef_HEAD_INIT,
    "my_extension", /* name of module */
    NULL,           /* module documentation, may be NULL */
    -1,             /* size of per-interpreter state of the module, or -1 if the module keeps state in global variables. */
    MyExtensionMethods
};

PyMODINIT_FUNC PyInit_my_extension(void) {
    return PyModule_Create(&my_extension_module);
}