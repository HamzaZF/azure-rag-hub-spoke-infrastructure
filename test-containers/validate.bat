@echo off
REM Kelix Test Containers Validation Script for Windows
REM This script validates the test container setup

setlocal EnableDelayedExpansion

REM Colors for output (Windows doesn't support colors in batch easily, so we'll use text)
set "INFO_PREFIX=[INFO]"
set "SUCCESS_PREFIX=[SUCCESS]"
set "WARNING_PREFIX=[WARNING]"
set "ERROR_PREFIX=[ERROR]"

set "VALIDATION_FAILED=false"

echo %INFO_PREFIX% Validating Kelix test containers setup...

REM Check Docker
call :check_docker
if errorlevel 1 set "VALIDATION_FAILED=true"

REM Check backend files
echo %INFO_PREFIX% Checking backend files...
call :check_file "backend\package.json" "Backend package.json"
if errorlevel 1 set "VALIDATION_FAILED=true"

call :check_file "backend\server.js" "Backend server"
if errorlevel 1 set "VALIDATION_FAILED=true"

call :check_file "backend\Dockerfile" "Backend Dockerfile"
if errorlevel 1 set "VALIDATION_FAILED=true"

REM Check frontend files
echo %INFO_PREFIX% Checking frontend files...
call :check_file "frontend\index.html" "Frontend HTML"
if errorlevel 1 set "VALIDATION_FAILED=true"

call :check_file "frontend\nginx.conf" "Frontend Nginx config"
if errorlevel 1 set "VALIDATION_FAILED=true"

call :check_file "frontend\Dockerfile" "Frontend Dockerfile"
if errorlevel 1 set "VALIDATION_FAILED=true"

REM Check configuration files
echo %INFO_PREFIX% Checking configuration files...
call :check_file "docker-compose.yml" "Docker Compose config"
if errorlevel 1 set "VALIDATION_FAILED=true"

call :check_file "build.bat" "Build script"
if errorlevel 1 set "VALIDATION_FAILED=true"

call :check_file "deploy.bat" "Deploy script"
if errorlevel 1 set "VALIDATION_FAILED=true"

REM Final result
echo.
if "%VALIDATION_FAILED%"=="true" (
    echo %ERROR_PREFIX% Validation failed! Some files are missing.
    exit /b 1
) else (
    echo %SUCCESS_PREFIX% All validation checks passed!
    echo.
    echo %INFO_PREFIX% Next steps:
    echo   1. Copy config.env.example to config.env and set your Docker Hub username
    echo   2. Test locally: docker-compose up --build
    echo   3. Build for Docker Hub: build.bat --username your-dockerhub-username --push
    echo   4. Deploy to Azure: deploy.bat --username your-dockerhub-username --resource-group your-rg --backend-app backend-app --frontend-app frontend-app
)

goto :eof

REM Check file function
:check_file
set "file=%~1"
set "description=%~2"

if exist "%file%" (
    echo %SUCCESS_PREFIX% %description% exists: %file%
    exit /b 0
) else (
    echo %ERROR_PREFIX% %description% missing: %file%
    exit /b 1
)

REM Check Docker function
:check_docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR_PREFIX% Docker is not installed
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    echo %ERROR_PREFIX% Docker is installed but not running
    exit /b 1
)

echo %SUCCESS_PREFIX% Docker is available and running
exit /b 0
