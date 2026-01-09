#!/bin/bash
set -xe

# MIPS Little Endian Cross-Compilation Script for subconverter
# This script cross-compiles subconverter and all its dependencies for MIPS LE architecture
#

# Set cross-compilation environment variables
export ARCH=mipsel
export CROSS_COMPILE=mipsel-linux-gnu-
export CC=mipsel-linux-gnu-gcc
export CXX=mipsel-linux-gnu-g++
export AR=mipsel-linux-gnu-ar
export RANLIB=mipsel-linux-gnu-ranlib
export STRIP=mipsel-linux-gnu-strip

# Set compilation flags to avoid buffer overflow false positives in static builds
export CFLAGS="-O3 -fno-stack-protector -D_FORTIFY_SOURCE=0"
export CXXFLAGS="-O3 -fno-stack-protector -D_FORTIFY_SOURCE=0"

# Set installation prefix
export PREFIX=/tmp/mipsel-toolchain
export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:${PREFIX}/lib64/pkgconfig

# Create build directory
BUILD_DIR=/tmp/mipsel-build
mkdir -p ${BUILD_DIR}
mkdir -p ${PREFIX}

cd ${BUILD_DIR}

echo "=========================================="
echo "Building zlib for MIPS LE"
echo "=========================================="
if [ ! -f ${PREFIX}/lib/libz.a ]; then
    git clone https://github.com/madler/zlib.git --depth=1 --branch v1.3.1
    cd zlib
    ./configure --prefix=${PREFIX} --static
    make clean
    make -j$(nproc)
    make install
    cd ..
fi

echo "=========================================="
echo "Building mbedTLS for MIPS LE"
echo "=========================================="
if [ ! -f ${PREFIX}/lib/libmbedtls.a ]; then
    git clone https://github.com/Mbed-TLS/mbedtls.git --depth=1 --branch v3.5.2
    cd mbedtls
    # Set CMAKE_AR properly as a path
    cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
          -DCMAKE_C_COMPILER=${CC} \
          -DCMAKE_CXX_COMPILER=${CXX} \
          -DCMAKE_AR=/usr/bin/mipsel-linux-gnu-ar \
          -DCMAKE_RANLIB=/usr/bin/mipsel-linux-gnu-ranlib \
          -DCMAKE_BUILD_TYPE=Release \
          -DENABLE_TESTING=OFF \
          -DENABLE_PROGRAMS=OFF \
          -DUSE_SHARED_MBEDTLS_LIBRARY=OFF \
          -DUSE_STATIC_MBEDTLS_LIBRARY=ON \
          .
    make clean
    make -j$(nproc)
    make install
    cd ..
fi

echo "=========================================="
echo "Building PCRE2 for MIPS LE"
echo "=========================================="
if [ ! -f ${PREFIX}/lib/libpcre2-8.a ]; then
    git clone https://github.com/PCRE2Project/pcre2.git --depth=1 --branch pcre2-10.44
    cd pcre2
    ./autogen.sh
    ./configure --host=mipsel-linux-gnu \
                --prefix=${PREFIX} \
                --enable-static \
                --disable-shared \
                --enable-jit
    make clean
    make -j$(nproc)
    make install
    cd ..
fi

echo "=========================================="
echo "Building curl for MIPS LE"
echo "=========================================="
if [ ! -f ${PREFIX}/lib/libcurl.a ]; then
    git clone https://github.com/curl/curl.git --depth=1 --branch curl-8_6_0
    cd curl
    cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
          -DCMAKE_C_COMPILER=${CC} \
          -DCMAKE_CXX_COMPILER=${CXX} \
          -DCMAKE_AR=/usr/bin/mipsel-linux-gnu-ar \
          -DCMAKE_RANLIB=/usr/bin/mipsel-linux-gnu-ranlib \
          -DCURL_USE_MBEDTLS=ON \
          -DHTTP_ONLY=ON \
          -DBUILD_TESTING=OFF \
          -DBUILD_SHARED_LIBS=OFF \
          -DCMAKE_USE_LIBSSH2=OFF \
          -DBUILD_CURL_EXE=OFF \
          -DCMAKE_BUILD_TYPE=Release \
          -DMBEDTLS_INCLUDE_DIRS=${PREFIX}/include \
          -DMBEDTLS_LIBRARY=${PREFIX}/lib/libmbedtls.a \
          -DMBEDX509_LIBRARY=${PREFIX}/lib/libmbedx509.a \
          -DMBEDCRYPTO_LIBRARY=${PREFIX}/lib/libmbedcrypto.a \
          -DZLIB_LIBRARY=${PREFIX}/lib/libz.a \
          -DZLIB_INCLUDE_DIR=${PREFIX}/include \
          .
    make clean
    make -j$(nproc)
    make install
    cd ..
fi

echo "=========================================="
echo "Building RapidJSON for MIPS LE"
echo "=========================================="
if [ ! -d ${PREFIX}/include/rapidjson ]; then
    git clone https://github.com/Tencent/rapidjson.git --depth=1
    cd rapidjson
    cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
          -DRAPIDJSON_BUILD_DOC=OFF \
          -DRAPIDJSON_BUILD_EXAMPLES=OFF \
          -DRAPIDJSON_BUILD_TESTS=OFF \
          .
    make install
    cd ..
fi

echo "=========================================="
echo "Building yaml-cpp for MIPS LE"
echo "=========================================="
if [ ! -f ${PREFIX}/lib/libyaml-cpp.a ]; then
    git clone https://github.com/jbeder/yaml-cpp.git --depth=1 --branch 0.8.0
    cd yaml-cpp
    cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
          -DCMAKE_C_COMPILER=${CC} \
          -DCMAKE_CXX_COMPILER=${CXX} \
          -DCMAKE_AR=/usr/bin/mipsel-linux-gnu-ar \
          -DCMAKE_RANLIB=/usr/bin/mipsel-linux-gnu-ranlib \
          -DCMAKE_BUILD_TYPE=Release \
          -DYAML_CPP_BUILD_TESTS=OFF \
          -DYAML_CPP_BUILD_TOOLS=OFF \
          -DYAML_BUILD_SHARED_LIBS=OFF \
          .
    make clean
    make -j$(nproc)
    make install
    cd ..
fi

echo "=========================================="
echo "Building QuickJS for MIPS LE"
echo "=========================================="
if [ ! -f ${PREFIX}/lib/quickjs/libquickjs.a ]; then
    git clone https://github.com/ftk/quickjspp.git --depth=1
    cd quickjspp
    # Apply patches if needed
    #cd quickjs
    # Use cross-compilation for QuickJS
    cmake -DCMAKE_INSTALL_PREFIX=${BUILD_DIR} -DCMAKE_C_COMPILER=mipsel-linux-gnu-gcc \
    -DCMAKE_CXX_COMPILER=mipsel-linux-gnu-g++ -DCMAKE_AR=/usr/bin/mipsel-linux-gnu-ar \
    -DCMAKE_RANLIB=/usr/bin/mipsel-linux-gnu-ranlib -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="${CFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" . 
    make quickjs -j$(nproc) 
    #cd ..
    
    install -d ${PREFIX}/lib/quickjs/
    install -m644 quickjs/libquickjs.a ${PREFIX}/lib/quickjs/
    install -d ${PREFIX}/include/quickjs/
    install -m644 quickjs/quickjs.h quickjs/quickjs-libc.h ${PREFIX}/include/quickjs/
    install -m644 quickjspp.hpp ${PREFIX}/include/
    cd ..
fi

echo "=========================================="
echo "Building toml11 for MIPS LE"
echo "=========================================="
if [ ! -f ${PREFIX}/include/toml.hpp ]; then
    git clone https://github.com/ToruNiina/toml11.git --branch=v4.3.0 --depth=1
    cd toml11
    cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
          -DCMAKE_CXX_STANDARD=11 \
          -Dtoml11_BUILD_TESTS=OFF \
          .
    make install
    cd ..
fi

echo "=========================================="
echo "Building libcron for MIPS LE"
echo "=========================================="
if [ ! -f ${PREFIX}/lib/liblibcron.a ]; then
    git clone https://github.com/PerMalmberg/libcron.git --depth=1
    cd libcron
    git submodule update --init
    cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
          -DCMAKE_C_COMPILER=${CC} \
          -DCMAKE_CXX_COMPILER=${CXX} \
          -DCMAKE_AR=/usr/bin/mipsel-linux-gnu-ar \
          -DCMAKE_RANLIB=/usr/bin/mipsel-linux-gnu-ranlib \
          -DCMAKE_BUILD_TYPE=Release \
          .
    make clean
    make libcron -j$(nproc)
    make install
    cd ..
fi

echo "=========================================="
echo "Building subconverter for MIPS LE"
echo "=========================================="
cd /home/runner/work/subconverter/subconverter

# Create build directory for subconverter
mkdir -p build-mipsle
cd build-mipsle

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_C_COMPILER=${CC} \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DCMAKE_AR=/usr/bin/mipsel-linux-gnu-ar \
      -DCMAKE_RANLIB=/usr/bin/mipsel-linux-gnu-ranlib \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
      -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
      -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
      -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
      -DCURL_INCLUDE_DIR=${PREFIX}/include \
      -DCURL_LIBRARY=${PREFIX}/lib/libcurl.a \
      -DRAPIDJSON_INCLUDE_DIRS=${PREFIX}/include \
      -DTOML11_INCLUDE_DIRS=${PREFIX}/include \
      -DYAML_CPP_INCLUDE_DIR=${PREFIX}/include \
      -DYAML_CPP_LIBRARIES=${PREFIX}/lib/libyaml-cpp.a \
      -DPCRE2_INCLUDE_DIRS=${PREFIX}/include \
      -DPCRE2_LIBRARY=${PREFIX}/lib/libpcre2-8.a \
      -DQUICKJS_INCLUDE_DIRS=${PREFIX}/include \
      -DQUICKJS_LIBRARIES=${PREFIX}/lib/quickjs/libquickjs.a \
      -DLIBCRON_INCLUDE_DIRS=${PREFIX}/include \
      -DLIBCRON_LIBRARIES=${PREFIX}/lib/liblibcron.a \
      ..

make clean
make -j$(nproc) VERBOSE=1

echo "=========================================="
echo "Linking static executable"
echo "=========================================="
# Create static executable with all dependencies
# Use -fno-stack-protector to avoid buffer overflow false positives in static builds
# Add -D_FORTIFY_SOURCE=0 to disable fortify checks that can cause issues in cross-compiled binaries
${CXX} -o subconverter-mipsle \
    $(find CMakeFiles/subconverter.dir/src/ -name "*.o") \
    -static -march=mips32r2 -mabi=32 -DNDEBUG \
    -fno-stack-protector \
    ${PREFIX}/lib/libyaml-cpp.a \
    ${PREFIX}/lib/libcurl.a \
    ${PREFIX}/lib/libmbedtls.a \
    ${PREFIX}/lib/libmbedx509.a \
    ${PREFIX}/lib/libmbedcrypto.a \
    ${PREFIX}/lib/libz.a \
    ${PREFIX}/lib/libpcre2-8.a \
    ${PREFIX}/lib/quickjs/libquickjs.a \
    ${PREFIX}/lib/liblibcron.a \
    -Wl,--whole-archive -lpthread -Wl,--no-whole-archive \
    -latomic -ldl -lm \
    -O3 -D_FORTIFY_SOURCE=0

# Strip the binary to reduce size
${STRIP} subconverter-mipsle

echo "=========================================="
echo "Verifying the executable"
echo "=========================================="
file subconverter-mipsle
ls -lh subconverter-mipsle

echo "=========================================="
echo "Copying executable to base directory"
echo "=========================================="
cp subconverter-mipsle ../base
chmod +x ../base/subconverter-mipsle

echo "=========================================="
echo "Build completed successfully!"
echo "Executable location: base/subconverter-mipsle"
echo "=========================================="
