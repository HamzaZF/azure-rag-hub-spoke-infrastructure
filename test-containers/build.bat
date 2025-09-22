@echo off
REM Kelix Test Containers Build Script for Windows
REM This script builds and optionally pushes Docker images to Docker Hub

setlocal EnableDelayedExpansion

REM Configuration
set "DOCKER_USERNAME="
set "IMAGE_TAG=latest"
set "BACKEND_IMAGE_NAME=kelix-backend-test"
set "FRONTEND_IMAGE_NAME=kelix-frontend-test"
set "PUSH=false"
set "BACKEND_ONLY=false"
set "FRONTEND_ONLY=false"
set "CLEAN=false"

REM Colors for output (Windows doesn't support colors in batch easily, so we'll use text)
set "INFO_PREFIX=[INFO]"
set "SUCCESS_PREFIX=[SUCCESS]"
set "WARNING_PREFIX=[WARNING]"
set "ERROR_PREFIX=[ERROR]"

REM Help function
if "%1"=="--help" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="/?" goto :show_help

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :validate_args

if "%~1"=="-u" (
    set "DOCKER_USERNAME=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--username" (
    set "DOCKER_USERNAME=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="-t" (
    set "IMAGE_TAG=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--tag" (
    set "IMAGE_TAG=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="-p" (
    set "PUSH=true"
    shift
    goto :parse_args
)
if "%~1"=="--push" (
    set "PUSH=true"
    shift
    goto :parse_args
)
if "%~1"=="-b" (
    set "BACKEND_ONLY=true"
    shift
    goto :parse_args
)
if "%~1"=="--backend-only" (
    set "BACKEND_ONLY=true"
    shift
    goto :parse_args
)
if "%~1"=="-f" (
    set "FRONTEND_ONLY=true"
    shift
    goto :parse_args
)
if "%~1"=="--frontend-only" (
    set "FRONTEND_ONLY=true"
    shift
    goto :parse_args
)
if "%~1"=="-c" (
    set "CLEAN=true"
    shift
    goto :parse_args
)
if "%~1"=="--clean" (
    set "CLEAN=true"
    shift
    goto :parse_args
)

echo %ERROR_PREFIX% Unknown option: %~1
goto :show_help

:validate_args
REM Check if Docker username is provided for push
if "%PUSH%"=="true" if "%DOCKER_USERNAME%"=="" (
    echo %ERROR_PREFIX% Docker username is required when pushing images
    echo Use: %0 --username your-dockerhub-username --push
    exit /b 1
)

REM Check conflicting options
if "%BACKEND_ONLY%"=="true" if "%FRONTEND_ONLY%"=="true" (
    echo %ERROR_PREFIX% Cannot specify both --backend-only and --frontend-only
    exit /b 1
)

REM Check Docker availability
docker --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR_PREFIX% Docker is not installed or not in PATH
    exit /b 1
)

REM Check if Docker daemon is running
docker info >nul 2>&1
if errorlevel 1 (
    echo %ERROR_PREFIX% Docker daemon is not running
    exit /b 1
)

REM Main execution
echo %INFO_PREFIX% Starting Kelix test containers build process...
echo %INFO_PREFIX% Image tag: %IMAGE_TAG%
if not "%DOCKER_USERNAME%"=="" (
    echo %INFO_PREFIX% Docker Hub: %DOCKER_USERNAME%
)

REM Build backend
if not "%FRONTEND_ONLY%"=="true" (
    call :build_image "backend" "%BACKEND_IMAGE_NAME%"
    if errorlevel 1 (
        echo %ERROR_PREFIX% Backend build failed
        exit /b 1
    )
    set "BACKEND_BUILT=true"
)

REM Build frontend
if not "%BACKEND_ONLY%"=="true" (
    call :build_image "frontend" "%FRONTEND_IMAGE_NAME%"
    if errorlevel 1 (
        echo %ERROR_PREFIX% Frontend build failed
        exit /b 1
    )
    set "FRONTEND_BUILT=true"
)

REM Push images if requested
if "%PUSH%"=="true" (
    echo %INFO_PREFIX% Logging into Docker Hub...
    docker login
    if errorlevel 1 (
        echo %ERROR_PREFIX% Failed to login to Docker Hub
        exit /b 1
    )
    
    if not "%FRONTEND_ONLY%"=="true" if "%BACKEND_BUILT%"=="true" (
        call :push_image "%BACKEND_IMAGE_NAME%"
        if errorlevel 1 exit /b 1
    )
    
    if not "%BACKEND_ONLY%"=="true" if "%FRONTEND_BUILT%"=="true" (
        call :push_image "%FRONTEND_IMAGE_NAME%"
        if errorlevel 1 exit /b 1
    )
)

REM Clean up if requested
if "%CLEAN%"=="true" (
    if not "%FRONTEND_ONLY%"=="true" if "%BACKEND_BUILT%"=="true" (
        call :clean_image "%BACKEND_IMAGE_NAME%"
    )
    
    if not "%BACKEND_ONLY%"=="true" if "%FRONTEND_BUILT%"=="true" (
        call :clean_image "%FRONTEND_IMAGE_NAME%"
    )
)

echo %SUCCESS_PREFIX% Build process completed successfully!
echo.
echo %INFO_PREFIX% Next steps:
if not "%PUSH%"=="true" (
    echo   - To test locally: docker-compose up
    if not "%DOCKER_USERNAME%"=="" (
        echo   - To push to Docker Hub: %0 --username %DOCKER_USERNAME% --push
    )
) else (
    echo   - Images are now available on Docker Hub
    echo   - Update your Azure App Service to use these images
)

goto :eof

REM Build function
:build_image
set "context_dir=%~1"
set "image_name=%~2"
set "local_tag=%image_name%:%IMAGE_TAG%"
set "hub_tag="

if not "%DOCKER_USERNAME%"=="" (
    set "hub_tag=%DOCKER_USERNAME%/%image_name%:%IMAGE_TAG%"
)

echo %INFO_PREFIX% Building %image_name%...

REM Build with local tag
docker build -t "%local_tag%" "%context_dir%"
if errorlevel 1 (
    echo %ERROR_PREFIX% Failed to build %image_name%
    exit /b 1
)

echo %SUCCESS_PREFIX% Built %local_tag%

REM Tag for Docker Hub if specified
if not "%hub_tag%"=="" (
    docker tag "%local_tag%" "%hub_tag%"
    if errorlevel 1 (
        echo %ERROR_PREFIX% Failed to tag image for Docker Hub
        exit /b 1
    )
    echo %SUCCESS_PREFIX% Tagged as %hub_tag%
)

exit /b 0

REM Push function
:push_image
set "image_name=%~1"
set "hub_tag=%DOCKER_USERNAME%/%image_name%:%IMAGE_TAG%"

echo %INFO_PREFIX% Pushing %hub_tag%...

docker push "%hub_tag%"
if errorlevel 1 (
    echo %ERROR_PREFIX% Failed to push %hub_tag%
    exit /b 1
)

echo %SUCCESS_PREFIX% Pushed %hub_tag%
exit /b 0

REM Clean function
:clean_image
set "image_name=%~1"
set "local_tag=%image_name%:%IMAGE_TAG%"
set "hub_tag="

if not "%DOCKER_USERNAME%"=="" (
    set "hub_tag=%DOCKER_USERNAME%/%image_name%:%IMAGE_TAG%"
)

echo %INFO_PREFIX% Cleaning up local images for %image_name%...

REM Remove local tag
docker rmi "%local_tag%" >nul 2>&1
if not errorlevel 1 (
    echo %SUCCESS_PREFIX% Removed %local_tag%
)

REM Remove Docker Hub tag
if not "%hub_tag%"=="" (
    docker rmi "%hub_tag%" >nul 2>&1
    if not errorlevel 1 (
        echo %SUCCESS_PREFIX% Removed %hub_tag%
    )
)

exit /b 0

:show_help
echo Kelix Test Containers Build Script for Windows
echo.
echo Usage: %0 [OPTIONS]
echo.
echo Options:
echo     -u, --username NAME    Docker Hub username (required for push)
echo     -t, --tag TAG         Image tag (default: latest)
echo     -p, --push            Push images to Docker Hub after building
echo     -b, --backend-only    Build only backend image
echo     -f, --frontend-only   Build only frontend image
echo     -c, --clean           Clean up local images after push
echo     -h, --help            Show this help message
echo.
echo Environment Variables:
echo     DOCKER_USERNAME       Docker Hub username
echo     IMAGE_TAG            Image tag to use
echo.
echo Examples:
echo     REM Build both images locally
echo     %0
echo.
echo     REM Build and push to Docker Hub
echo     %0 --username myusername --push
echo.
echo     REM Build only backend with custom tag
echo     %0 --backend-only --tag v1.2.3
echo.
echo     REM Build and push with cleanup
echo     %0 --username myusername --push --clean

exit /b 0
