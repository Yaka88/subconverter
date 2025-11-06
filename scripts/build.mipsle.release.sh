#!/bin/bash
set -xe

# MIPSEL cross-compilation build script
# This script builds subconverter for mipsle architecture with static dependencies
# and stack protection disabled

ARCH=mipsel
CROSS_PREFIX=mipsel-linux-gnu
BUILD_DIR=/tmp/mipsel-build
INSTALL_PREFIX=${BUILD_DIR}/install

# Create build directory
mkdir -p ${BUILD_DIR}
mkdir -p ${INSTALL_PREFIX}

# Set toolchain
export CC=${CROSS_PREFIX}-gcc
export CXX=${CROSS_PREFIX}-g++
export AR=${CROSS_PREFIX}-ar
export RANLIB=${CROSS_PREFIX}-ranlib
export LD=${CROSS_PREFIX}-ld
export STRIP=${CROSS_PREFIX}-strip

# Compiler flags: disable stack protection and optimize for size
export CFLAGS="-fno-stack-protector -Os"
export CXXFLAGS="-fno-stack-protector -Os"
export LDFLAGS="-static"

# PKG_CONFIG setup for cross-compilation
export PKG_CONFIG_PATH=${INSTALL_PREFIX}/lib/pkgconfig:${INSTALL_PREFIX}/lib64/pkgconfig
export PKG_CONFIG_LIBDIR=${PKG_CONFIG_PATH}

cd ${BUILD_DIR}

echo "=========================================="
echo "Building zlib for ${ARCH}"
echo "=========================================="
if [ ! -f "${INSTALL_PREFIX}/lib/libz.a" ]; then
    git clone https://github.com/madler/zlib --depth=1 --branch v1.3.1 || true
    cd zlib
    # Temporarily remove strict flags for zlib configure
    ORIG_CFLAGS="${CFLAGS}"
    export CFLAGS="-fno-stack-protector -Os"
    CC=${CC} ./configure --prefix=${INSTALL_PREFIX} --static
    export CFLAGS="${ORIG_CFLAGS}"
    make clean || true
    make -j$(nproc)
    make install
    cd ..
fi

echo "=========================================="
echo "Building mbedtls for ${ARCH}"
echo "=========================================="
if [ ! -f "${INSTALL_PREFIX}/lib/libmbedtls.a" ]; then
    git clone https://github.com/Mbed-TLS/mbedtls --depth=1 --branch mbedtls-3.6.0 || true
    cd mbedtls
    git submodule update --init || true
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
          -DCMAKE_C_COMPILER=${CC} \
          -DCMAKE_CXX_COMPILER=${CXX} \
          -DCMAKE_C_FLAGS="${CFLAGS}" \
          -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
          -DENABLE_TESTING=OFF \
          -DENABLE_PROGRAMS=OFF \
          -DUSE_SHARED_MBEDTLS_LIBRARY=OFF \
          -DUSE_STATIC_MBEDTLS_LIBRARY=ON \
          .
    make clean || true
    make -j$(nproc)
    make install
    cd ..
fi

echo "=========================================="
echo "Building curl for ${ARCH}"
echo "=========================================="
if [ ! -f "${INSTALL_PREFIX}/lib/libcurl.a" ]; then
    git clone https://github.com/curl/curl --depth=1 --branch curl-8_6_0 || true
    cd curl
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
          -DCMAKE_C_COMPILER=${CC} \
          -DCMAKE_CXX_COMPILER=${CXX} \
          -DCMAKE_C_FLAGS="${CFLAGS}" \
          -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
          -DCURL_USE_MBEDTLS=ON \
          -DHTTP_ONLY=ON \
          -DBUILD_TESTING=OFF \
          -DBUILD_SHARED_LIBS=OFF \
          -DCMAKE_USE_LIBSSH2=OFF \
          -DBUILD_CURL_EXE=OFF \
          -DCURL_STATICLIB=ON \
          .
    make clean || true
    make -j$(nproc)
    make install
    cd ..
fi

echo "=========================================="
echo "Building pcre2 for ${ARCH}"
echo "=========================================="
if [ ! -f "${INSTALL_PREFIX}/lib/libpcre2-8.a" ]; then
    git clone https://github.com/PCRE2Project/pcre2 --depth=1 --branch pcre2-10.43 || true
    cd pcre2
    ./autogen.sh
    ./configure --host=${CROSS_PREFIX} \
                --prefix=${INSTALL_PREFIX} \
                --enable-static \
                --disable-shared \
                --disable-cpp \
                CFLAGS="${CFLAGS}" \
                CXXFLAGS="${CXXFLAGS}"
    make clean || true
    make -j$(nproc)
    make install
    cd ..
fi

echo "=========================================="
echo "Building yaml-cpp for ${ARCH}"
echo "=========================================="
if [ ! -f "${INSTALL_PREFIX}/lib/libyaml-cpp.a" ]; then
    git clone https://github.com/jbeder/yaml-cpp --depth=1 --branch 0.8.0 || true
    cd yaml-cpp
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
          -DCMAKE_C_COMPILER=${CC} \
          -DCMAKE_CXX_COMPILER=${CXX} \
          -DCMAKE_C_FLAGS="${CFLAGS}" \
          -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
          -DYAML_CPP_BUILD_TESTS=OFF \
          -DYAML_CPP_BUILD_TOOLS=OFF \
          -DYAML_BUILD_SHARED_LIBS=OFF \
          .
    make clean || true
    make -j$(nproc)
    make install
    cd ..
fi

echo "=========================================="
echo "Building quickjs for ${ARCH}"
echo "=========================================="
if [ ! -d "${INSTALL_PREFIX}/include/quickjs" ]; then
    git clone https://github.com/ftk/quickjspp --depth=1 || true
    cd quickjspp
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
          -DCMAKE_C_COMPILER=${CC} \
          -DCMAKE_CXX_COMPILER=${CXX} \
          -DCMAKE_C_FLAGS="${CFLAGS}" \
          -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
          .
    make clean || true
    make quickjs -j$(nproc)
    install -d ${INSTALL_PREFIX}/lib/quickjs/
    install -m644 quickjs/libquickjs.a ${INSTALL_PREFIX}/lib/quickjs/
    install -d ${INSTALL_PREFIX}/include/quickjs/
    install -m644 quickjs/quickjs.h quickjs/quickjs-libc.h ${INSTALL_PREFIX}/include/quickjs/
    install -m644 quickjspp.hpp ${INSTALL_PREFIX}/include/
    cd ..
fi

echo "=========================================="
echo "Building libcron for ${ARCH}"
echo "=========================================="
if [ ! -f "${INSTALL_PREFIX}/lib/libcron.a" ]; then
    git clone https://github.com/PerMalmberg/libcron --depth=1 || true
    cd libcron
    git submodule update --init
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
          -DCMAKE_C_COMPILER=${CC} \
          -DCMAKE_CXX_COMPILER=${CXX} \
          -DCMAKE_C_FLAGS="${CFLAGS}" \
          -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
          .
    make clean || true
    make libcron -j$(nproc)
    make install
    cd ..
fi

echo "=========================================="
echo "Installing toml11 (header-only) for ${ARCH}"
echo "=========================================="
if [ ! -d "${INSTALL_PREFIX}/include/toml11" ]; then
    git clone https://github.com/ToruNiina/toml11 --branch=v4.3.0 --depth=1 || true
    cd toml11
    cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
          -DCMAKE_CXX_STANDARD=20 \
          .
    make install
    cd ..
fi

echo "=========================================="
echo "Installing rapidjson (header-only) for ${ARCH}"
echo "=========================================="
if [ ! -d "${INSTALL_PREFIX}/include/rapidjson" ]; then
    git clone https://github.com/Tencent/rapidjson --depth=1 || true
    cd rapidjson
    cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
          -DRAPIDJSON_BUILD_DOC=OFF \
          -DRAPIDJSON_BUILD_EXAMPLES=OFF \
          -DRAPIDJSON_BUILD_TESTS=OFF \
          .
    make install
    cd ..
fi

echo "=========================================="
echo "Building subconverter for ${ARCH}"
echo "=========================================="
cd /home/runner/work/subconverter/subconverter

# Create CMake toolchain file
cat > toolchain-mipsel.cmake <<EOF
SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_PROCESSOR mipsel)

SET(CMAKE_C_COMPILER ${CC})
SET(CMAKE_CXX_COMPILER ${CXX})
SET(CMAKE_AR ${AR})
SET(CMAKE_RANLIB ${RANLIB})

SET(CMAKE_FIND_ROOT_PATH ${INSTALL_PREFIX})
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

SET(CMAKE_C_FLAGS "${CFLAGS} -fno-stack-protector")
SET(CMAKE_CXX_FLAGS "${CXXFLAGS} -fno-stack-protector")
SET(CMAKE_EXE_LINKER_FLAGS "-static")
EOF

# Clean previous build
rm -rf build-mipsel
mkdir -p build-mipsel
cd build-mipsel

# Configure with CMake
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_TOOLCHAIN_FILE=../toolchain-mipsel.cmake \
      -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
      -DCMAKE_C_COMPILER=${CC} \
      -DCMAKE_CXX_COMPILER=${CXX} \
      -DCMAKE_C_FLAGS="${CFLAGS} -fno-stack-protector" \
      -DCMAKE_CXX_FLAGS="${CXXFLAGS} -fno-stack-protector" \
      -DCMAKE_EXE_LINKER_FLAGS="-static" \
      -DCURL_INCLUDE_DIR=${INSTALL_PREFIX}/include \
      -DCURL_LIBRARY=${INSTALL_PREFIX}/lib/libcurl.a \
      -DRAPIDJSON_INCLUDE_DIRS=${INSTALL_PREFIX}/include \
      -DTOML11_INCLUDE_DIRS=${INSTALL_PREFIX}/include \
      -DYAML_CPP_INCLUDE_DIRS=${INSTALL_PREFIX}/include \
      -DYAML_CPP_LIBRARIES=${INSTALL_PREFIX}/lib/libyaml-cpp.a \
      -DPCRE2_INCLUDE_DIRS=${INSTALL_PREFIX}/include \
      -DPCRE2_LIBRARY=${INSTALL_PREFIX}/lib/libpcre2-8.a \
      -DQUICKJS_INCLUDE_DIRS=${INSTALL_PREFIX}/include \
      -DQUICKJS_LIBRARIES=${INSTALL_PREFIX}/lib/quickjs/libquickjs.a \
      -DLIBCRON_INCLUDE_DIRS=${INSTALL_PREFIX}/include \
      -DLIBCRON_LIBRARIES=${INSTALL_PREFIX}/lib/libcron.a \
      ..

# Build
make VERBOSE=1 -j$(nproc)

echo "=========================================="
echo "Build completed successfully!"
echo "=========================================="
file subconverter
${STRIP} subconverter
ls -lh subconverter

# Copy to base directory
mkdir -p /home/runner/work/subconverter/subconverter/base-mipsel
cp subconverter /home/runner/work/subconverter/subconverter/base-mipsel/
cp -r /home/runner/work/subconverter/subconverter/base/* /home/runner/work/subconverter/subconverter/base-mipsel/

echo "=========================================="
echo "Executable is ready at:"
echo "/home/runner/work/subconverter/subconverter/base-mipsel/subconverter"
echo "=========================================="
