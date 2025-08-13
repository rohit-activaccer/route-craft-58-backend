@echo off
REM Route Craft 58 Backend - Startup Script for Windows
REM Simple batch script to run the FastAPI application

setlocal enabledelayedexpansion

REM Set title
title Route Craft 58 Backend

echo.
echo ==================================================
echo 🚀 Route Craft 58 Backend Startup
echo ==================================================
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.8+ and add it to your PATH
    pause
    exit /b 1
)

REM Check Python version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [INFO] Python version: %PYTHON_VERSION%

REM Check if virtual environment exists
if not exist "venv" (
    echo [WARN] Virtual environment not found. Creating one...
    python -m venv venv
    echo [INFO] Virtual environment created
)

REM Activate virtual environment
echo [INFO] Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo [ERROR] Failed to activate virtual environment
    pause
    exit /b 1
)
echo [INFO] Virtual environment activated

REM Install dependencies
echo [INFO] Checking dependencies...
python -c "import fastapi" >nul 2>&1
if errorlevel 1 (
    echo [WARN] Dependencies not installed. Installing...
    pip install -r requirements.txt
    if errorlevel 1 (
        echo [ERROR] Failed to install dependencies
        pause
        exit /b 1
    )
    echo [INFO] Dependencies installed
) else (
    echo [INFO] Dependencies already installed
)

REM Check environment file
if not exist ".env" (
    if exist "env.example" (
        echo [WARN] .env file not found. Creating from env.example...
        copy env.example .env >nul
        echo [WARN] Please edit .env file with your configuration before running the application
        echo [WARN] Required variables: SUPABASE_URL, SUPABASE_KEY, SECRET_KEY
        pause
        exit /b 1
    ) else (
        echo [ERROR] No .env file or env.example found
        pause
        exit /b 1
    )
)

echo.
echo [INFO] Starting the application...
echo ==================================================
echo.

REM Run the application
python run.py %*

REM Keep window open if there was an error
if errorlevel 1 (
    echo.
    echo [ERROR] Application exited with error code %errorlevel%
    pause
) 