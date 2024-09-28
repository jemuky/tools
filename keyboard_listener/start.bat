@echo off

set BUILD_DIR=build

if not exist %BUILD_DIR% (
    mkdir %BUILD_DIR%
) 

cd %BUILD_DIR%
cmake ..
if %ERRORLEVEL% neq 0 (
    @echo cmake failed
    cd ..
    exit /b
)

cmake --build . -- /p:Configuration=Release
if %ERRORLEVEL% neq 0 (
    @echo build failed
    cd ..
    exit /b
)
cd ..

@echo build ok! 

echo.

%BUILD_DIR%\Release\keyboard_listener.exe
echo.
