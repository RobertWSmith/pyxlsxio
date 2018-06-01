#!/bin/bash

START_DIR=`pwd`

if [[ "$OSTYPE" == "linux-gnu" ]]; then
        CMAKE_BUILD_GENERATOR="Unix Makefiles"
elif [[ "$OSTYPE" == "cygwin" ]]; then
        CMAKE_BUILD_GENERATOR="MinGW Makefiles"
elif [[ "$OSTYPE" == "msys" ]]; then
        CMAKE_BUILD_GENERATOR="MSYS Makefiles"
fi

# input directory for cmake
XLSXIO_SOURCE_DIR=${START_DIR%%/}/external/xlsxio
# cmake build directory
XLSXIO_BUILD_DIR=${START_DIR%%/}/external/xlsxio-build

# directory for cython includes
XLSXIO_INSTALL_INCLUDE_DIR=${START_DIR%%/}/include
# directory for cython libraries
XLSXIO_INSTALL_LIB_DIR=${START_DIR%%/}/lib

# ensure the submodule is prepared
git submodule sync
git submodule update --init

mkdir -p ${XLSXIO_BUILD_DIR} ${XLSXIO_INSTALL_INCLUDE_DIR} ${XLSXIO_INSTALL_LIB_DIR}

cd $XLSXIO_BUILD_DIR
cmake -G "$CMAKE_BUILD_GENERATOR" -Wno-dev -Wno-deprecated \
    -DBUILD_STATIC:BOOL=ON \
    -DBUILD_SHARED:BOOL=OFF \
    -DBUILD_TOOLS:BOOL=OFF \
    -DBUILD_EXAMPLES:BOOL=OFF \
    -DWITH_LIBZIP:BOOL=ON \
    -DWITH_WIDE:BOOL=OFF \
    -DBUILD_DOCUMENTATION:BOOL=OFF \
    -DCMAKE_INSTALL_PREFIX=$XLSXIO_BUILD_DIR \
    $XLSXIO_SOURCE_DIR
retcode_check

cmake --build . --clean-first --config Release

cp $XLSXIO_SOURCE_DIR/include/*.h $XLSXIO_INSTALL_INCLUDE_DIR
retcode_check

# BUILD_STATIC=ON indicates the library will have the 'a' extensions
cp $XLSXIO_BUILD_DIR/libxlsxio_*.a $XLSXIO_INSTALL_LIB_DIR
retcode_check

cd $START_DIR
