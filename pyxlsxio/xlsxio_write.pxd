
from libc.stddef cimport size_t
from libc.stdint cimport int64_t, uint64_t
from libc.time cimport time_t


cdef extern from "xlsxio_write.h":
    #/*! \brief get xlsxio_write version
    # * \param  pmajor        pointer to integer that will receive major version number
    # * \param  pminor        pointer to integer that will receive minor version number
    # * \param  pmicro        pointer to integer that will receive micro version number
    # * \sa     xlsxiowrite_get_version_string()
    # */
    void xlsxiowrite_get_version (int* pmajor, int* pminor, int* pmicro) nogil

    #/*! \brief get xlsxio_write version string
    # * \return version string
    # * \sa     xlsxiowrite_get_version()
    # */
    const char* xlsxiowrite_get_version_string () nogil

    #/*! \brief write handle for .xlsx object */
    struct xlsxio_write_struct:
        pass

    ctypedef xlsxio_write_struct* xlsxiowriter

    #/*! \brief create and open .xlsx file
    # * \param  filename      path of .xlsx file to open
    # * \param  sheetname     name of worksheet
    # * \return write handle for .xlsx object or NULL on error
    # * \sa     xlsxiowrite_close()
    # */
    xlsxiowriter xlsxiowrite_open (const char* filename, const char* sheetname) nogil

    #/*! \brief close .xlsx file
    # * \param  handle        write handle for .xlsx object
    # * \return zero on success, non-zero on error
    # * \sa     xlsxiowrite_open()
    # */
    int xlsxiowrite_close (xlsxiowriter handle) nogil

    #/*! \brief specify how many initial rows will be buffered in memory to determine column widths
    # * \param  handle        write handle for .xlsx object
    # * \param  rows          number of rows to buffer in memory, zero for none
    # * Must be called before the first call to xlsxiowrite_next_row()
    # * \sa     xlsxiowrite_add_column()
    # * \sa     xlsxiowrite_next_row()
    # */
    void xlsxiowrite_set_detection_rows (xlsxiowriter handle, size_t rows) nogil

    #/*! \brief specify the row height to use for the current and next rows
    # * \param  handle        write handle for .xlsx object
    # * \param  height        row height (in text lines), zero for unspecified
    # * Must be called before the first call to any xlsxiowrite_add_ function of the current row
    # * \sa     xlsxiowrite_next_row()
    # */
    void xlsxiowrite_set_row_height (xlsxiowriter handle, size_t height) nogil

    #/*! \brief add a column cell
    # * \param  handle        write handle for .xlsx object
    # * \param  name          column name
    # * \param  width         column width (in characters)
    # * Only one row of column names is supported or none.
    # * Call for each column, and finish column row by calling xlsxiowrite_next_row().
    # * Must be called before any xlsxiowrite_next_row() or the xlsxiowrite_add_cell_ functions.
    # * \sa     xlsxiowrite_next_row()
    # * \sa     xlsxiowrite_set_detection_rows()
    # */
    void xlsxiowrite_add_column (xlsxiowriter handle, const char* name, int width) nogil

    #/*! \brief add a cell with string data
    # * \param  handle        write handle for .xlsx object
    # * \param  value         string value
    # * \sa     xlsxiowrite_next_row()
    # */
    void xlsxiowrite_add_cell_string (xlsxiowriter handle, const char* value) nogil

    #/*! \brief add a cell with integer data
    # * \param  handle        write handle for .xlsx object
    # * \param  value         integer value
    # * \sa     xlsxiowrite_next_row()
    # */
    void xlsxiowrite_add_cell_int (xlsxiowriter handle, int64_t value) nogil

    #/*! \brief add a cell with floating point data
    # * \param  handle        write handle for .xlsx object
    # * \param  value         floating point value
    # * \sa     xlsxiowrite_next_row()
    # */
    void xlsxiowrite_add_cell_float (xlsxiowriter handle, double value) nogil

    #/*! \brief add a cell with date and time data
    # * \param  handle        write handle for .xlsx object
    # * \param  value         date and time value
    # * \sa     xlsxiowrite_next_row()
    # */
    void xlsxiowrite_add_cell_datetime (xlsxiowriter handle, time_t value) nogil

    #/*! \brief mark the end of a row (next cell will start on a new row)
    # * \param  handle        write handle for .xlsx object
    # * \sa     xlsxiowrite_add_cell_string()
    # */
    void xlsxiowrite_next_row (xlsxiowriter handle) nogil
