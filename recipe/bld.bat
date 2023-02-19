REM https://github.com/rust-lang/cargo/issues/10583#issuecomment-1129997984
set CARGO_NET_GIT_FETCH_WITH_CLI=true
REM Create temp folder
mkdir tmpbuild_%PY_VER%
set TEMP=%CD%\tmpbuild_%PY_VER%
REM Bundle all downstream library licenses
pushd src/core
cargo-bundle-licenses ^
    --format yaml ^
    --output %SRC_DIR%\THIRDPARTY.yml ^
    || goto :error
popd
REM Run the maturin build via pip
set PYTHONUTF8=1
set PYTHONIOENCODING="UTF-8"
set TMPDIR=tmpbuild_%PY_VER%
%PYTHON% -m pip install . -vv

:: TODO: copy headers to includedir

:: TODO: cargo build for shared and static libraries
:: TODO: copy libs to prefix/lib

:: maybe TODO? pkgconfig

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
