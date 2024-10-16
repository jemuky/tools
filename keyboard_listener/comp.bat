chcp 65001
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

@REM %BUILD_DIR%\Release\keyboard_listener.exe 0x78 0x11 0x77
@REM echo.
