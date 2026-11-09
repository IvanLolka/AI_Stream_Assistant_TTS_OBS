@echo off
setlocal EnableExtensions
chcp 437 >nul
cd /d "%~dp0"
title Hanya Silero TTS Installer

echo ========================================================
echo Hanya - Silero TTS CPU installer
echo ========================================================
echo.
echo This installer installs CPU-only PyTorch 2.8.0 for compatibility
echo with the Hanya PyQt5 application on Windows.
echo.

set "PYTHON_EXE="
if defined HANYA_PYTHON set "PYTHON_EXE=%HANYA_PYTHON%"
if not defined PYTHON_EXE if exist "%~dp0.venv\Scripts\python.exe" set "PYTHON_EXE=%~dp0.venv\Scripts\python.exe"
if not defined PYTHON_EXE if exist "%~dp0venv\Scripts\python.exe" set "PYTHON_EXE=%~dp0venv\Scripts\python.exe"
if not defined PYTHON_EXE if defined VIRTUAL_ENV if exist "%VIRTUAL_ENV%\Scripts\python.exe" set "PYTHON_EXE=%VIRTUAL_ENV%\Scripts\python.exe"

if not defined PYTHON_EXE (
    for /f "delims=" %%I in ('py -3 -c "import sys; print(sys.executable)" 2^>nul') do set "PYTHON_EXE=%%I"
)
if not defined PYTHON_EXE (
    for /f "delims=" %%I in ('python -c "import sys; print(sys.executable)" 2^>nul') do set "PYTHON_EXE=%%I"
)
if not defined PYTHON_EXE goto :no_python

echo Selected Python:
echo "%PYTHON_EXE%"
"%PYTHON_EXE%" --version
if errorlevel 1 goto :failed

echo.
echo Step 1 of 3: upgrading pip...
"%PYTHON_EXE%" -m pip install --upgrade pip
if errorlevel 1 goto :failed

echo.
echo Step 2 of 3: installing CPU-only PyTorch 2.8.0...
"%PYTHON_EXE%" -m pip install --force-reinstall torch==2.8.0 --index-url https://download.pytorch.org/whl/cpu
if errorlevel 1 goto :failed

echo.
echo Step 3 of 3: installing Silero...
"%PYTHON_EXE%" -m pip install --upgrade silero
if errorlevel 1 goto :failed

echo.
echo Checking imports...
"%PYTHON_EXE%" -c "import torch; from silero import silero_tts; print('PyTorch:', torch.__version__); print('Silero import: OK')"
if errorlevel 1 goto :failed

echo.
echo SUCCESS: Silero dependencies are installed.
echo Restart Hanya and press Load Voice Model.
echo.
pause
exit /b 0

:no_python
echo ERROR: Python 3 was not found.
echo Put this installer beside Hanya or set HANYA_PYTHON to the full python.exe path.
echo.
pause
exit /b 1

:failed
echo.
echo ERROR: Installation or import test failed.
echo Check that the selected Python is the same one used to run Hanya.
echo Install Microsoft Visual C++ Redistributable x64 if DLL initialization fails.
echo.
pause
exit /b 1
