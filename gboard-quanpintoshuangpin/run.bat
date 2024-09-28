@echo off

dotnet build 
if %ERRORLEVEL% neq 0 (
    @echo build failed
    exit /b
)

bin\Debug\net8.0\gboard-quanpintoshuangpin.exe -i "D:\space\other\phoenix_test\tmp\file\tmp_7195809748477115282.tmp" -o "d:\my.txt"
