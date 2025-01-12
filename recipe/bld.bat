:: install python package
set "RUSTFLAGS=-C codegen-units=4"
maturin build -v --jobs 1 --release --strip --manylinux off --interpreter=%PYTHON%
if errorlevel 1 exit 1

FOR /F "delims=" %%i IN ('dir /s /b target\wheels\*.whl') DO set sourmash_wheel=%%i
%PYTHON% -m pip install --ignore-installed --no-deps %sourmash_wheel% -vv
if errorlevel 1 exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

:: TODO: copy headers to includedir

:: CTB: delete incorrectly packaged file for sourmash v4.8.13.
del src\sourmash\_lowlevel\*

:: TODO: cargo build for shared and static libraries
:: TODO: copy libs to prefix/lib

:: maybe TODO? pkgconfig

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
