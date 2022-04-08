#!/bin/bash -euo

set -x
set -o xtrace -o nounset -o pipefail -o errexit

case "$target_platform" in
    linux-64) CARGO_BUILD_TARGET=x86_64-unknown-linux-gnu ;;
    linux-aarch64) CARGO_BUILD_TARGET=aarch64-unknown-linux-gnu ;;
    linux-ppc64le) CARGO_BUILD_TARGET=powerpc64le-unknown-linux-gnu ;;
    win-64) CARGO_BUILD_TARGET=x86_64-pc-windows-msvc ;;
    osx-64) CARGO_BUILD_TARGET=x86_64-apple-darwin;;
    osx-arm64) CARGO_BUILD_TARGET=aarch64-apple-darwin;;
    *) echo "unknown target_platform $target_platform" ; exit 1 ;;
esac
export CARGO_BUILD_TARGET

SOEXT=so
if [ "$(uname)" == "Darwin" ]; then
    SOEXT=dylib
fi

cp include/sourmash.h ${PREFIX}/include/

cargo build --release

## A bit of an workaround, but make other parts of the script more consistent
cp -a target/${CARGO_BUILD_TARGET}/release/libsourmash.${SOEXT} target/release/libsourmash.${SOEXT}
cp -a target/${CARGO_BUILD_TARGET}/release/libsourmash.a target/release/libsourmash.a

cp target/release/libsourmash.a ${PREFIX}/lib/
cp target/release/libsourmash.${SOEXT} ${PREFIX}/lib/

## This will work on currently unreleased sourmash, wait for 4.3.0+
#export NO_BUILD=1
#export DYLD_LIBRARY_PATH=${PREFIX}/lib

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
