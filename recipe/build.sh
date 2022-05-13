#!/bin/bash -euo

set -x
set -o xtrace -o nounset -o pipefail -o errexit

SOEXT=so
if [ "$(uname)" == "Darwin" ]; then
    SOEXT=dylib
fi

cp include/sourmash.h ${PREFIX}/include/

cargo build --release

cp -a target/${CARGO_BUILD_TARGET}/release/libsourmash.${SOEXT} ${PREFIX}/lib/
cp -a target/${CARGO_BUILD_TARGET}/release/libsourmash.a ${PREFIX}/lib/

## This will work on currently unreleased sourmash, wait for 4.3.0+
export NO_BUILD=1
export DYLD_LIBRARY_PATH=${PREFIX}/lib

$PYTHON -m pip install --no-deps --ignore-installed -vv .

mkdir -p ${PREFIX}/lib/pkgconfig
cat > ${PREFIX}/lib/pkgconfig/sourmash.pc <<"EOF"
prefix=/usr/local
exec_prefix=${prefix}
includedir=${prefix}/include
libdir=${exec_prefix}/lib

Name: sourmash
Description: Compute MinHash signatures for nucleotide (DNA/RNA) and protein sequences.
Version: 0.10.0
Cflags: -I${includedir}
Libs: -L${libdir} -lsourmash
EOF
