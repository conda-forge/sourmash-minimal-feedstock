:: install python package
%PYTHON% -m build --wheel --no-isolation -x || goto :error
%PYTHON% -m build --sdist --no-isolation -x || goto :error
%PYTHON% -m pip install --no-deps --no-index --only-binary sourmash --find-links=dist sourmash || goto :error

:: TODO: copy headers to includedir

:: TODO: cargo build for shared and static libraries
:: TODO: copy libs to prefix/lib

:: maybe TODO? pkgconfig

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
