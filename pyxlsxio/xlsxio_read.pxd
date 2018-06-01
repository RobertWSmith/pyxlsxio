
from libc.stddef cimport size_t
from libc.stdint cimport int64_t, uint64_t
from libc.time cimport time_t


cdef extern from "xlsxio_read.h":
  # /*! \brief get xlsxio_write version
  #  * \param  pmajor        pointer to integer that will receive major version number
  #  * \param  pminor        pointer to integer that will receive minor version number
  #  * \param  pmicro        pointer to integer that will receive micro version number
  #  * \sa     xlsxiowrite_get_version_string()
  #  */
  void xlsxioread_get_version (int* pmajor, int* pminor, int* pmicro) nogil

  # /*! \brief get xlsxio_write version string
  #  * \return version string
  #  * \sa     xlsxiowrite_get_version()
  #  */
  const char* xlsxioread_get_version_string () nogil

  # /*! \brief read handle for .xlsx object */
  struct xlsxio_read_struct:
    pass

  ctypedef xlsxio_read_struct* xlsxioreader

  # /*! \brief open .xlsx file
  #  * \param  filename      path of .xlsx file to open
  #  * \return read handle for .xlsx object or NULL on error
  #  * \sa     xlsxioread_close()
  #  */
  xlsxioreader xlsxioread_open (const char* filename) nogil

  # /*! \brief open .xlsx file
  #  * \param  filehandle    file handle of .xlsx file opened with read access in binary mode
  #  * \return read handle for .xlsx object or NULL on error
  #  * \sa     xlsxioread_close()
  #  */
  xlsxioreader xlsxioread_open_filehandle (int filehandle) nogil

  # /*! \brief open .xlsx from memory buffer
  #  * \param  data          memory buffer containing .xlsx file (data must remain valid as long as any xlsxioread_ functions are called)
  #  * \param  datalen       size of memory buffer containing .xlsx file
  #  * \param  freedata      if non-zero data will be freed by xlsxioread_close()
  #  * \return read handle for .xlsx object or NULL on error
  #  * \sa     xlsxioread_close()
  #  */
  xlsxioreader xlsxioread_open_memory (void* data,
                                       uint64_t datalen,
                                       int freedata) nogil

  # /*! \brief close .xlsx file
  #  * \param  handle        read handle for .xlsx object
  #  * \sa     xlsxioread_open()
  #  */
  void xlsxioread_close (xlsxioreader handle) nogil

  # /*! \brief type of pointer to callback function for listing worksheets
  #  * \param  name          name of worksheet
  #  * \param  callbackdata  callback data passed to xlsxioread_list_sheets
  #  * \return zero to continue, non-zero to abort
  #  * \sa     xlsxioread_list_sheets()
  #  */
  ctypedef int (*xlsxioread_list_sheets_callback_fn)(const char* name,
                                                     void* callbackdata) nogil

  # /*! \brief list worksheets in .xlsx file
  #  * \param  handle        read handle for .xlsx object
  #  * \param  callback      callback function called for each worksheet
  #  * \param  callbackdata  custom data as passed to quickmail_add_body_custom/quickmail_add_attachment_custom
  #  * \sa     xlsxioread_list_sheets_callback_fn
  #  */
  void xlsxioread_list_sheets (xlsxioreader handle,
                               xlsxioread_list_sheets_callback_fn callback,
                               void* callbackdata) nogil

  # /*! \brief possible values for the flags parameter of xlsxioread_process()
  #  * \sa     xlsxioread_process()
  #  * \name   XLSXIOREAD_SKIP_*
  #  * \{
  #  */
  # /*! \brief don't skip any rows or cells \hideinitializer */
  #define XLSXIOREAD_SKIP_NONE            0
  unsigned XLSXIOREAD_SKIP_NONE
  # /*! \brief skip empty rows (note: cells may appear empty while they actually contain data) \hideinitializer */
  #define XLSXIOREAD_SKIP_EMPTY_ROWS      0x01
  unsigned XLSXIOREAD_SKIP_EMPTY_ROWS
  # /*! \brief skip empty cells \hideinitializer */
  #define XLSXIOREAD_SKIP_EMPTY_CELLS     0x02
  unsigned XLSXIOREAD_SKIP_EMPTY_CELLS
  # /*! \brief skip empty rows and cells \hideinitializer */
  #define XLSXIOREAD_SKIP_ALL_EMPTY       (XLSXIOREAD_SKIP_EMPTY_ROWS | XLSXIOREAD_SKIP_EMPTY_CELLS)
  unsigned XLSXIOREAD_SKIP_ALL_EMPTY
  # /*! \brief skip extra cells to the right of the rightmost header cell \hideinitializer */
  #define XLSXIOREAD_SKIP_EXTRA_CELLS     0x04
  unsigned XLSXIOREAD_SKIP_EXTRA_CELLS
  # /*! @} */


  # /*! \brief type of pointer to callback function for processing a worksheet cell value
  #  * \param  row           row number (first row is 1)
  #  * \param  col           column number (first column is 1)
  #  * \param  value         value of cell (note: formulas are not calculated)
  #  * \param  callbackdata  callback data passed to xlsxioread_process
  #  * \return zero to continue, non-zero to abort
  #  * \sa     xlsxioread_process()
  #  * \sa     xlsxioread_process_row_callback_fn
  #  */
  ctypedef int (*xlsxioread_process_cell_callback_fn)(size_t row,
                                                      size_t col,
                                                      const char* value,
                                                      void* callbackdata) nogil

  # /*! \brief type of pointer to callback function for processing the end of a worksheet row
  #  * \param  row           row number (first row is 1)
  #  * \param  maxcol        maximum column number on this row (first column is 1)
  #  * \param  callbackdata  callback data passed to xlsxioread_process
  #  * \return zero to continue, non-zero to abort
  #  * \sa     xlsxioread_process()
  #  * \sa     xlsxioread_process_cell_callback_fn
  #  */
  ctypedef int (*xlsxioread_process_row_callback_fn)(size_t row,
                                                     size_t maxcol,
                                                     void* callbackdata) nogil

  # /*! \brief process all rows and columns of a worksheet in an .xlsx file
  #  * \param  handle        read handle for .xlsx object
  #  * \param  sheetname     worksheet name (NULL for first sheet)
  #  * \param  flags         XLSXIOREAD_SKIP_ flag(s) to determine how data is processed
  #  * \param  cell_callback callback function called for each cell
  #  * \param  row_callback  callback function called after each row
  #  * \param  callbackdata  callback data passed to xlsxioread_process
  #  * \return zero on success, non-zero on error
  #  * \sa     xlsxioread_process_row_callback_fn
  #  * \sa     xlsxioread_process_cell_callback_fn
  #  */
  int xlsxioread_process (xlsxioreader handle,
                          const char* sheetname,
                          unsigned int flags,
                          xlsxioread_process_cell_callback_fn cell_callback,
                          xlsxioread_process_row_callback_fn row_callback,
                          void* callbackdata) nogil

  # /*! \brief read handle for list of worksheet names */
  struct xlsxio_read_sheetlist_struct:
    pass

  ctypedef xlsxio_read_sheetlist_struct* xlsxioreadersheetlist

  # /*! \brief open list of worksheet names
  #  * \param  handle           read handle for .xlsx object
  #  * \sa     xlsxioread_sheetlist_close()
  #  * \sa     xlsxioread_open()
  #  */
  xlsxioreadersheetlist xlsxioread_sheetlist_open (xlsxioreader handle) nogil

  # /*! \brief close worksheet
  #  * \param  sheetlisthandle  read handle for worksheet object
  #  * \sa     xlsxioread_sheetlist_open()
  #  */
  void xlsxioread_sheetlist_close (xlsxioreadersheetlist sheetlisthandle) nogil

  # /*! \brief get next worksheet name
  #  * \param  sheetlisthandle  read handle for worksheet object
  #  * \return name of worksheet or NULL if no more worksheets are available
  #  * \sa     xlsxioread_sheetlist_open()
  #  */
  const char* xlsxioread_sheetlist_next (xlsxioreadersheetlist sheetlisthandle) nogil

  # /*! \brief read handle for worksheet object */
  struct xlsxio_read_sheet_struct:
    pass

  ctypedef xlsxio_read_sheet_struct* xlsxioreadersheet

  # /*! \brief open worksheet
  #  * \param  handle        read handle for .xlsx object
  #  * \param  sheetname     worksheet name (NULL for first sheet)
  #  * \param  flags         XLSXIOREAD_SKIP_ flag(s) to determine how data is processed
  #  * \return read handle for worksheet object or NULL in case of error
  #  * \sa     xlsxioread_sheet_close()
  #  * \sa     xlsxioread_open()
  #  */
  xlsxioreadersheet xlsxioread_sheet_open (xlsxioreader handle,
                                           const char* sheetname,
                                           unsigned int flags) nogil

  # /*! \brief close worksheet
  #  * \param  sheethandle   read handle for worksheet object
  #  * \sa     xlsxioread_sheet_open()
  #  */
  void xlsxioread_sheet_close (xlsxioreadersheet sheethandle) nogil

  # /*! \brief get next row from worksheet (to be called before each row)
  #  * \param  sheethandle   read handle for worksheet object
  #  * \return non-zero if a new row is available
  #  * \sa     xlsxioread_sheet_open()
  #  */
  int xlsxioread_sheet_next_row (xlsxioreadersheet sheethandle) nogil

  # /*! \brief get next cell from worksheet
  #  * \param  sheethandle   read handle for worksheet object
  #  * \return value (caller must free the result) or NULL if no more cells are available in the current row
  #  * \sa     xlsxioread_sheet_open()
  #  */
  char* xlsxioread_sheet_next_cell (xlsxioreadersheet sheethandle) nogil

  # /*! \brief get next cell from worksheet as a string
  #  * \param  sheethandle   read handle for worksheet object
  #  * \param  pvalue        pointer where string will be stored if data is available (caller must free the result)
  #  * \return non-zero if a new cell was available in the current row
  #  * \sa     xlsxioread_sheet_open()
  #  * \sa     xlsxioread_sheet_next_cell()
  #  */
  int xlsxioread_sheet_next_cell_string (xlsxioreadersheet sheethandle,
                                         char** pvalue) nogil

  # /*! \brief get next cell from worksheet as an integer
  #  * \param  sheethandle   read handle for worksheet object
  #  * \param  pvalue        pointer where integer will be stored if data is available
  #  * \return non-zero if a new cell was available in the current row
  #  * \sa     xlsxioread_sheet_open()
  #  * \sa     xlsxioread_sheet_next_cell()
  #  */
  int xlsxioread_sheet_next_cell_int (xlsxioreadersheet sheethandle,
                                      int64_t* pvalue) nogil

  # /*! \brief get next cell from worksheet as a floating point value
  #  * \param  sheethandle   read handle for worksheet object
  #  * \param  pvalue        pointer where floating point value will be stored if data is available
  #  * \return non-zero if a new cell was available in the current row
  #  * \sa     xlsxioread_sheet_open()
  #  * \sa     xlsxioread_sheet_next_cell()
  #  */
  int xlsxioread_sheet_next_cell_float (xlsxioreadersheet sheethandle,
                                        double* pvalue) nogil

  # /*! \brief get next cell from worksheet as date and time data
  #  * \param  sheethandle   read handle for worksheet object
  #  * \param  pvalue        pointer where date and time data will be stored if data is available
  #  * \return non-zero if a new cell was available in the current row
  #  * \sa     xlsxioread_sheet_open()
  #  * \sa     xlsxioread_sheet_next_cell()
  #  */
  int xlsxioread_sheet_next_cell_datetime (xlsxioreadersheet sheethandle,
                                           time_t* pvalue) nogil
