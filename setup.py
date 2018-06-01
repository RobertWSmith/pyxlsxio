import sys
import os

import glob
import subprocess

from Cython.Build import cythonize
from setuptools import Extension, setup

# if 'PYXLSXIO_FULL_CLEAN' in os.environ:
#     subprocess.call(['bash', 'scripts/full-clean.sh'])

retcode = subprocess.call(['bash', 'scripts/build-xlsxio.sh'])

if retcode != 0:
    sys.exit(retcode)

PYXLSXIO_INCLUDE_DIR = "include"
PYXLSXIO_LIB_DIR = "lib"

def make_extension(name, path):
    print(path, ": ", name)
    return Extension(
        name,
        [
            path,
        ],
        extra_compile_args=['-O2', '-Wall'],
        extra_link_args=['-g', ],
        include_dirs=[PYXLSXIO_INCLUDE_DIR, "."],
        libraries=["xlsxio_read", "xlsxio_write", "expat", "zip"],
        library_dirs=[PYXLSXIO_LIB_DIR, '.'],
    )

def scandir(dir="pyxlsxio"):
    output = []
    for file in glob.glob(os.path.join(dir, "**.pyx")):
        name = file.replace(os.path.sep, ".")[:-4]
        output.append(make_extension(name, file))
    return output


setup(
    name="pyxlsxio",
    version="2.0.0",
    packages=[
        'pyxlsxio',
        'pyxlsxio',
    ],  # 'pyxlsxio.writer'
    ext_modules=cythonize(scandir("pyxlsxio")),
    # cmdclass = {'build_ext', build_ext}
)
