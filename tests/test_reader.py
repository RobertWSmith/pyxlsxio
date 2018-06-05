
from pyxlsxio.reader import Reader


def test_row_count():
    expected_row_count = 151
    cnt = 0
    workbook = Reader("data/iris.xlsx")
    sheet = workbook.get_worksheet("Sheet1")
    for row in sheet:
        cnt += 1
    assert cnt > 0
    assert cnt == expected_row_count

def test_colum_count():
    expected_column_count = 5
    workbook = Reader("data/iris.xlsx")
    sheet = workbook.get_worksheet("Sheet1")
    for row in sheet:
        column_cnt = len([cell for cell in row])
        assert column_cnt == expected_column_count

def test_header_values():
    expected_header = ['sepal length in cm', 'sepal width in cm', 'petal length in cm', 'petal with in cm', 'class']
    workbook = Reader("data/iris.xlsx")
    sheet = workbook.get_worksheet("Sheet1")
    header = list(next(iter(sheet)))

    assert len(header) == len(expected_header)

    for i in range(len(expected_header)):
        assert header[i] == expected_header[i]
