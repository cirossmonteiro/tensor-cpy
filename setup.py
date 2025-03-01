from setuptools import setup, Extension

module = Extension(
    'tensor',
    sources=['tensor.c']
)

setup(
    name='Tensor',
    version='1.0',
    description='Tensor functions for Python',
    ext_modules=[module],
)