#!/bin/bash -euo

set -ex
set -o xtrace -o nounset -o pipefail -o errexit

# https://github.com/rust-lang/cargo/issues/10583#issuecomment-1129997984
export CARGO_NET_GIT_FETCH_WITH_CLI=true

###################
# Prepare licenses
###################

pushd src/core
# Bundle all downstream library licenses
cargo-bundle-licenses \
    --format yaml \
    --output ${SRC_DIR}/THIRDPARTY.yml
popd

# CTB: delete unnecessary file for sourmash v4.8.13
rm -f src/sourmash/_lowlevel/*

####################
# Build shared lib
####################
SOEXT=so
if [ "$(uname)" == "Darwin" ]; then
    SOEXT=dylib
fi

cp include/sourmash.h ${PREFIX}/include/

cargo build --release --features branchwater

cp -a target/${CARGO_BUILD_TARGET}/release/libsourmash.${SOEXT} ${PREFIX}/lib/
cp -a target/${CARGO_BUILD_TARGET}/release/libsourmash.a ${PREFIX}/lib/

mkdir -p ${PREFIX}/lib/pkgconfig
cat > ${PREFIX}/lib/pkgconfig/sourmash.pc <<"EOF"
prefix=/usr/local
exec_prefix=${prefix}
includedir=${prefix}/include
libdir=${exec_prefix}/lib

Name: sourmash
Description: Compute MinHash signatures for nucleotide (DNA/RNA) and protein sequences.
Version: 0.11.0
Cflags: -I${includedir}
Libs: -L${libdir} -lsourmash
EOF

#########################
# Install python package
#########################

# Run the maturin build via pip which works for direct and
# cross-compiled builds.
$PYTHON -m pip install . -vv
