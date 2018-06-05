import sys
import os

import subprocess

from Cython.Build import cythonize
from setuptools import Extension, setup

retcode = subprocess.call(['bash', 'scripts/build-xlsxio.sh'])
if retcode != 0:
    sys.exit(retcode)

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
        include_dirs=["include", "."],
        libraries=["xlsxio_read", "expat", "zip"],
        library_dirs=["lib", '.'],
    ),
    ]

setup(
    name="pyxlsxio",
    version="2.0.0",
    packages=["pyxlsxio", ],
    ext_modules=cythonzie(extensions)
)
