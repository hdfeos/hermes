#!/bin/bash

set -x
set -e
set -o pipefail

mkdir -p build
pushd build

: ${RUN_TESTS:-1}
: ${INSTALL_HERMES:-0}

INSTALL_PREFIX="${HOME}/${LOCAL}"

if [[ ! -z "${DEBUG}" ]]; then
    BUILD_TYPE=-DCMAKE_BUILD_TYPE=Debug
    DBG_FLAGS="-ggdb3 -O0 -Wall -Wextra"
else
    BUILD_TYPE=-DCMAKE_BUILD_TYPE=Release
    DBG_FLAGS="-g -Wall -Wextra -Werror"
fi

CXXFLAGS="-std=c++17 ${DBG_FLAGS}"                         \
cmake                                                      \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}               \
    -DCMAKE_PREFIX_PATH=${INSTALL_PREFIX}                  \
    -DCMAKE_BUILD_RPATH=${INSTALL_PREFIX}/lib              \
    -DCMAKE_INSTALL_RPATH=${INSTALL_PREFIX}/lib            \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE}                       \
    -DCMAKE_CXX_COMPILER=`which mpicxx`                    \
    -DCMAKE_C_COMPILER=`which mpicc`                       \
    -DBUILD_SHARED_LIBS=ON                                 \
    -DHERMES_ENABLE_COVERAGE=ON                            \
    -DHERMES_INTERCEPT_IO=OFF                              \
    -DHERMES_BUILD_BENCHMARKS=ON                           \
    -DHERMES_COMMUNICATION_MPI=ON                          \
    -DHERMES_BUILD_BUFFER_POOL_VISUALIZER=ON               \
    -DORTOOLS_DIR=${INSTALL_PREFIX}                        \
    -DHERMES_USE_ADDRESS_SANITIZER=ON                      \
    -DHERMES_USE_THREAD_SANITIZER=OFF                      \
    -DHERMES_RPC_THALLIUM=ON                               \
    -DHERMES_DEBUG_HEAP=OFF                                \
    -DHERMES_ENABLE_VFD=ON                                 \
    -DBUILD_TESTING=ON                                     \
    ..

cmake --build . -- -j4

if [[ "${RUN_TESTS}" -eq "1" ]]; then
    ctest -VV
fi

if [[ "${INSTALL_HERMES}" -eq "1" ]]; then
    make install
fi

popd
