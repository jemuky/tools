@echo off

dotnet build 
if %ERRORLEVEL% neq 0 (
    @echo build failed
    exit /b
)

bin\Debug\net8.0\wechat_tools.exe
