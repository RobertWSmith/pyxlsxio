# cython: c_string_type=unicode
# cython: c_string_encoding=utf8

import os

from libc cimport stdlib, string
from libc.stdint cimport int64_t
from libc.time cimport time_t

cimport xlsxio_read
from pyxlsxio.pyxlsxio cimport _cptr

from cpython.version cimport PY_MAJOR_VERSION


cdef enum:
    XLSXIOREAD_SKIP_NONE = 0
    XLSXIOREAD_SKIP_EMPTY_ROWS = 1
    XLSXIOREAD_SKIP_EMPTY_CELLS = 2
    XLSXIOREAD_SKIP_ALL_EMPTY = (XLSXIOREAD_SKIP_EMPTY_ROWS | XLSXIOREAD_SKIP_EMPTY_CELLS)
    XLSXIOREAD_SKIP_EXTRA_CELLS = 4


cdef str get_version():
    return xlsxio_read.xlsxioread_get_version_string()


class Reader(object):

  def __init__(self, filepath):
    self.filepath = filepath
    self._reader = CReader()

  def __del__(self):
    del self._reader
    del self.filepath

  def open(self, filepath=None):
    cdef const char* fp
    if filepath is not None:
      self.filepath = filepath

    if not os.path.isfile(self.filepath):
      raise IOError("File not found `{0}`".format(self.filepath))

    fp = _cptr(self.filepath)
    output = self._reader.open(fp)
    stdlib.free(<void*>(fp))

    if output:
      raise IOError("Workbook could not be opened @ `{0}`".format(self.filepath))

  def close(self):
    self._reader.close()

  def get_sheetlist(self):
    return WorksheetList(self._reader)

  def get_worksheet(self, sheetname, flags=None):
    if flags is None:
      flags = XLSXIOREAD_SKIP_EXTRA_CELLS | XLSXIOREAD_SKIP_EMPTY_ROWS
    r = WorksheetReader(self._reader, sheetname, flags)
    return r


cdef class CReader:
    cdef xlsxio_read.xlsxioreader handle

    def __cinit__(self):
        self.handle = NULL

    def __dealloc__(self):
        if self.handle != NULL:
          xlsxio_read.xlsxioread_close(self.handle)

    cdef bint open(self, const char* filepath):
        self.c_close()
        self.handle = xlsxio_read.xlsxioread_open(filepath)
        return self.handle != NULL

    cdef void close(self):
      if self.handle != NULL:
        xlsxio_read.xlsxioread_close(self.handle)
      self.handle = NULL


cdef class WorksheetList:
    cdef xlsxio_read.xlsxioreadersheetlist handle

    def __cinit__(self, CReader reader):
        assert reader is not None
        self.handle = xlsxio_read.xlsxioread_sheetlist_open(reader.handle)

    def __dealloc__(self):
      if self.handle != NULL:
          xlsxio_read.xlsxioread_sheetlist_close(self.handle)

    def __iter__(self):
        return self

    def __next__(self):
        cdef const char* data

        if self.handle == NULL:
          raise StopIteration()

        data = self.get_next()
        if data == NULL:
            raise StopIteration()
        return str(data)

    def __contains__(self, value):
        cdef str sheet, v
        v = str(value)
        return any([(sheet == v) for sheet in self])

    cdef const char* get_next(self) except *:
        if self.handle == NULL:
            return NULL
        return xlsxio_read.xlsxioread_sheetlist_next(self.handle)


cdef class WorksheetReader:
    cdef xlsxio_read.xlsxioreadersheet handle
    cdef list typelist

    def __cinit__(self, CReader reader not None, str sheet_name not None,
                  unsigned flags):
        cdef const char* sn

        if flags is None:
            flags = <unsigned>(XLSXIOREAD_SKIP_EXTRA_CELLS |
                               XLSXIOREAD_SKIP_EMPTY_ROWS)
        sn = _cptr(sheet_name)
        self.handle = xlsxio_read.xlsxioread_sheet_open(reader.handle, sn, flags)
        self.typelist = list()
        stdlib.free(<void*>(sn))

    def __dealloc__(self):
        if self.handle != NULL:
            xlsxio_read.xlsxioread_sheet_close(self.handle)

    def __iter__(self):
        return WorksheetReaderRowIterator(self)

    # def set_column_type(self, dtype, append_or_index=True):
    #   if append_or_index == True:
    #     self.typelist.append(dtype)
    #   else:
    #     self.typelist.insert(append_or_index, dtype)


cdef class WorksheetReaderRowIterator:
    cdef WorksheetReader sheet

    def __cinit__(self, WorksheetReader worksheet_reader):
        self.sheet = worksheet_reader

    def __iter__(self):
        return self

    def __next__(self):
        if self.has_next_row():
            return WorksheetReaderCellIterator(self.sheet)
        else:
            raise StopIteration()

    cdef bint has_next_row(self):
      # source docs: non-zero if a new row is available
      return xlsxio_read.xlsxioread_sheet_next_row(self.sheet.handle) != 0


cdef class WorksheetReaderCellIterator:
    cdef WorksheetReader sheet

    def __cinit__(self, WorksheetReader worksheet_reader):
        self.sheet = worksheet_reader

    def __iter__(self):
        return self

    def __next__(self):
        cdef char* next_value
        cdef str output

        next_value = self.get_next()
        if next_value == NULL:
          raise StopIteration()

        output = <str>(next_value)
        stdlib.free(<void*>(next_value))
        return output

    cdef char* get_next(self):
      # source docs: non-zero if a new row is available
      return xlsxio_read.xlsxioread_sheet_next_cell(self.sheet.handle)

    cdef bint get_next_string(self, char** value):
      cdef int results
      results = xlsxio_read.xlsxioread_sheet_next_cell_string(
          self.sheet.handle, value)

      if (results == 0):
        value[0] = NULL
        return False
      return True

    cdef bint get_next_int(self, int64_t* value):
      cdef int results
      results = xlsxio_read.xlsxioread_sheet_next_cell_int(
          self.sheet.handle, value)

      if (results == 0):
        value[0] = 0
        return False
      return True

    cdef bint get_next_float(self, double* value):
      cdef int results
      results = xlsxio_read.xlsxioread_sheet_next_cell_float(
          self.sheet.handle, value)

      if (results == 0):
        value[0] = 0
        return False
      return True

    cdef bint get_next_datetime(self, time_t* value):
      cdef int results
      results = xlsxio_read.xlsxioread_sheet_next_cell_datetime(
          self.sheet.handle, value)

      if (results == 0):
        value[0] = 0
        return False
      return True
