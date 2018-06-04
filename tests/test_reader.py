
from pyxlsxio import Reader


def test_rowcount():
    cnt = 0
    workbook = Reader("data/iris.xlsx")
    for row in workbook:
        cnt += 1
    assert cnt > 0
