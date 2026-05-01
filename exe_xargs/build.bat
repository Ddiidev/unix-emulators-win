@echo off
setlocal
pushd "%~dp0"
v -prod -o "..\..\xargs.exe" .
set "exit_code=%errorlevel%"
popd
exit /b %exit_code%
