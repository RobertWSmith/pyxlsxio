
from libc cimport stdlib, string

cdef const char* _cptr(py_input):
    cdef unsigned size, i
    cdef char* output

    if type(py_input) is str or type(py_input) is unicode:
        py_input = py_input.encode('UTF-8')

    i = 0

    print("before calling len on raw input")
    size = len(py_input)

    print("before calling calloc")
    output = <char*>(stdlib.calloc(size+1, sizeof(char)))
    print("after calling calloc")

    string.strncpy(output, <const char*>py_input, size)

    print(output)
    return <const char*>(output)
