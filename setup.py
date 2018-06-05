import sys
import os

import glob
import subprocess

from Cython.Build import cythonize
from setuptools import Extension, setup

retcode = subprocess.call(['bash', 'scripts/build-xlsxio.sh'])
if retcode != 0:
    sys.exit(retcode)

PYXLSXIO_INCLUDE_DIR = "include"
PYXLSXIO_LIB_DIR = "lib"

ext_files = glob.glob("pyxlsxio/*.pyx")
ext_files.remove("pyxlsxio/writer.pyx")

extensions = [
    Extension(
        "pyxlsxio.pyxlsxio",
        ["pyxlsxio/pyxlsxio.pyx", ],
        extra_compile_args=['-g', '-O2', '-Wall'],
        extra_link_args=['-g', ],
    ),
    Extension(
        "pyxlsxio.reader",
        ["pyxlsxio/reader.pyx", ],
        extra_compile_args=['-g', '-O2', '-Wall'],
        extra_link_args=['-g', ],
        include_dirs=[PYXLSXIO_INCLUDE_DIR, "."],
        libraries=["xlsxio_read", "expat", "zip"],
        library_dirs=[PYXLSXIO_LIB_DIR, '.'],
    ),
    ]

setup(
    name="pyxlsxio",
    version="2.0.0",
    packages=["pyxlsxio", ],
    ext_modules=extensions
)
