# cython: c_string_type=unicode
# cython: c_string_encoding=utf8

from libc cimport stddef, stdlib, string
from libc.stddef cimport size_t
from libc.stdint cimport int64_t
from libc.time cimport time_t

cimport xlsxio_write
from pyxlsxio.pyxlsxio cimport _cptr
from cpython.version cimport PY_MAJOR_VERSION


cdef class CWriter:
    cdef xlsxio_write.xlsxiowriter handle

    def __cinit__(self, filename, sheetname):
      cdef const char* fn, sh

      fn = _cptr(filename)
      sn = _cptr(sheetname)

      self.handle = xlsxio_write.xlsxiowrite_open(fn, sn)

      stdlib.free(<void*>(fn))
      stdlib.free(<void*>(sn))

    def __dealloc__(self):
      if self.handle != NULL:
        xlsxio_write.xlsxiowrite_close(self.handle)

    cdef void set_detection_rows(self, size_t rows):
      xlsxio_write.xlsxiowrite_set_detection_rows(self.handle, rows)

    cdef void set_row_height(self, size_t height):
      xlsxio_write.xlsxiowrite_set_row_height(self.handle, height)

    cdef void add_column(self, str name, int width):
      ## can only be called for the first row
      cdef const char* nm
      nm = _cptr(name)
      xlsxio_write.xlsxiowrite_add_column(self.handle, nm, width)
      stdlib.free(<void*>(nm))

    cdef void add_string_cell(self, str value):
      cdef const char* v
      v = _cptr(value)
      xlsxio_write.xlsxiowrite_add_cell_string(self.handle, v)
      stdlib.free(<void*>(v))

    cdef void add_int_cell(self, int64_t value):
      xlsxio_write.xlsxiowrite_add_cell_int(self.handle, value)

    cdef void add_float_cell(self, double value):
      xlsxio_write.xlsxiowrite_add_cell_float(self.handle, value)

    cdef void add_datetime_cell(self, time_t value):
      xlsxio_write.xlsxiowrite_add_cell_datetime(self.handle, value)

    cdef void next_row(self):
      xlsxio_write.xlsxiowrite_next_row(self.handle)
