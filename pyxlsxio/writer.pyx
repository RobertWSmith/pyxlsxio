# cython: c_string_type=unicode
# cython: c_string_encoding=utf8

from libc cimport stddef, stdlib, string
from libc.stddef cimport size_t
from libc.stdint cimport int64_t
from libc.time cimport time_t, tm, strptime, mktime

cimport xlsxio_write
from pyxlsxio cimport _cptr
from cpython.version cimport PY_MAJOR_VERSION

import datetime
import time


class Writer(object):

  def __init__(self, filename, sheetname):
    self.handle = CWriter(filename, sheetname)
    self._detection_rows = None
    self._row_height = 15


  def __del__(self):
    del self.handle

  @property
  def detection_rows(self):
    return self._detection_rows

  @detection_rows.setter
  def detection_rows(self, value):
    assert (value is not None) and isinstance(value, int) and (value >= 0)
    self._detection_rows = int(value)
    self.handle.set_detection_rows(self._detection_rows)

  @property
  def row_height(self):
    return self._row_height

  @row_height.setter
  def row_height(self, value):
    assert (value is not None) and isinstance(value, double) and (value >= 0.0)
    self._row_height = int(value)
    self.handle.set_row_height(self._row_height)

  def add_column(self, name, width=9):
    self.handle.add_column(name, width)
    return self

  def add_cell(self, value):
    if isinstance(value, basestring):
      self.handle.add_string_cell(value)

    elif isinstance(value, int):
      self.handle.add_cell_int(value)

    elif isinstance(value, float):
      self.handle.xlsxiowrite_add_cell_float(value)

    elif isinstance(value, (datetime.date, datetime.datetime)):
      if isinstance(value, datetime.date):
        value = datetime.datetime.fromordinal(value.toordinal())
      value = time.mktime(value.timetuple())
      self.handle.add_datetime_cell(value)

    elif value is None:
      # write an empty string
      self.add_cell(str())

    else:
      # recurse after explicitly trying to cast to string
      self.add_cell(str(value))


cdef class CWriter:
    cdef xlsxio_write.xlsxiowriter handle
    cdef readonly bint next_row_has_been_called

    def __cinit__(self, filename, sheetname):
      cdef const char* fn, sh

      fn = _cptr(filename)
      sn = _cptr(sheetname)

      self.next_row_has_been_called = False
      self.handle = xlsxio_write.xlsxiowrite_open(fn, sn)

      stdlib.free(<void*>(fn))
      stdlib.free(<void*>(sn))

    def __dealloc__(self):
      if self.handle != NULL:
        xlsxio_write.xlsxiowrite_close(self.handle)

    cdef void set_detection_rows(self, size_t rows=1012):
      # not set before a call here
      # number of rows is used to determine cell
      if not self.next_row_has_been_called:
        xlsxio_write.xlsxiowrite_set_detection_rows(self.handle, rows)
      else:
        print("an exception should probably be raised here.")

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
      self.next_row_has_been_called = True
      xlsxio_write.xlsxiowrite_next_row(self.handle)
