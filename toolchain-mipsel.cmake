SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_PROCESSOR mipsel)

SET(CMAKE_C_COMPILER mipsel-linux-gnu-gcc)
SET(CMAKE_CXX_COMPILER mipsel-linux-gnu-g++)
SET(CMAKE_AR mipsel-linux-gnu-ar)
SET(CMAKE_RANLIB mipsel-linux-gnu-ranlib)

SET(CMAKE_FIND_ROOT_PATH /tmp/mipsel-build/install)
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

SET(CMAKE_C_FLAGS "-fno-stack-protector -Os -fno-stack-protector")
SET(CMAKE_CXX_FLAGS "-fno-stack-protector -Os -fno-stack-protector")
SET(CMAKE_EXE_LINKER_FLAGS "-static")
