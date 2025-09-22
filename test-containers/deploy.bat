@echo off
REM Kelix Test Containers Deployment Script for Windows
REM This script deploys the test containers to Azure App Services from Docker Hub

setlocal EnableDelayedExpansion

REM Configuration
set "DOCKER_USERNAME="
set "RESOURCE_GROUP="
set "BACKEND_APP_NAME="
set "FRONTEND_APP_NAME="
set "IMAGE_TAG=latest"
set "BACKEND_IMAGE_NAME=kelix-backend-test"
set "FRONTEND_IMAGE_NAME=kelix-frontend-test"
set "BUILD=false"
set "BACKEND_ONLY=false"
set "FRONTEND_ONLY=false"
set "API_URL="

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
if "%~1"=="-g" (
    set "RESOURCE_GROUP=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--resource-group" (
    set "RESOURCE_GROUP=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="-b" (
    set "BACKEND_APP_NAME=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--backend-app" (
    set "BACKEND_APP_NAME=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="-f" (
    set "FRONTEND_APP_NAME=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--frontend-app" (
    set "FRONTEND_APP_NAME=%~2"
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
if "%~1"=="--build" (
    set "BUILD=true"
    shift
    goto :parse_args
)
if "%~1"=="--backend-only" (
    set "BACKEND_ONLY=true"
    shift
    goto :parse_args
)
if "%~1"=="--frontend-only" (
    set "FRONTEND_ONLY=true"
    shift
    goto :parse_args
)
if "%~1"=="--api-url" (
    set "API_URL=%~2"
    shift
    shift
    goto :parse_args
)

echo %ERROR_PREFIX% Unknown option: %~1
goto :show_help

:validate_args
REM Check required parameters
if "%DOCKER_USERNAME%"=="" (
    echo %ERROR_PREFIX% Docker Hub username is required
    exit /b 1
)

if "%RESOURCE_GROUP%"=="" (
    echo %ERROR_PREFIX% Resource group is required
    exit /b 1
)

if "%BACKEND_ONLY%" neq "true" if "%FRONTEND_APP_NAME%"=="" (
    echo %ERROR_PREFIX% Frontend app name is required when not using --backend-only
    exit /b 1
)

if "%FRONTEND_ONLY%" neq "true" if "%BACKEND_APP_NAME%"=="" (
    echo %ERROR_PREFIX% Backend app name is required when not using --frontend-only
    exit /b 1
)

if "%BACKEND_ONLY%"=="true" if "%FRONTEND_ONLY%"=="true" (
    echo %ERROR_PREFIX% Cannot specify both --backend-only and --frontend-only
    exit /b 1
)

REM Check Azure CLI availability
az --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR_PREFIX% Azure CLI is not installed or not in PATH
    exit /b 1
)

REM Check if logged into Azure
az account show >nul 2>&1
if errorlevel 1 (
    echo %ERROR_PREFIX% Not logged into Azure. Run 'az login' first
    exit /b 1
)

REM Build and push if requested
if "%BUILD%"=="true" (
    echo %INFO_PREFIX% Building and pushing images...
    
    set "build_args=--username %DOCKER_USERNAME% --tag %IMAGE_TAG% --push"
    
    if "%BACKEND_ONLY%"=="true" (
        set "build_args=!build_args! --backend-only"
    ) else if "%FRONTEND_ONLY%"=="true" (
        set "build_args=!build_args! --frontend-only"
    )
    
    call build.bat !build_args!
    if errorlevel 1 (
        echo %ERROR_PREFIX% Build and push failed
        exit /b 1
    )
)

REM Main execution
echo %INFO_PREFIX% Starting deployment to Azure App Services...
echo %INFO_PREFIX% Docker Hub: %DOCKER_USERNAME%
echo %INFO_PREFIX% Resource Group: %RESOURCE_GROUP%
echo %INFO_PREFIX% Image tag: %IMAGE_TAG%
if not "%API_URL%"=="" echo %INFO_PREFIX% API URL: %API_URL%

REM Deploy backend
if "%FRONTEND_ONLY%" neq "true" (
    call :deploy_backend
    if errorlevel 1 (
        echo %ERROR_PREFIX% Backend deployment failed
        exit /b 1
    )
)

REM Deploy frontend
if "%BACKEND_ONLY%" neq "true" (
    call :deploy_frontend
    if errorlevel 1 (
        echo %ERROR_PREFIX% Frontend deployment failed
        exit /b 1
    )
)

echo %SUCCESS_PREFIX% Deployment completed successfully!
echo.
echo %INFO_PREFIX% Deployment Summary:
if "%FRONTEND_ONLY%" neq "true" if not "%BACKEND_URL%"=="" (
    echo   Backend:  !BACKEND_URL!
    echo   Health:   !BACKEND_URL!/health
    echo   API:      !BACKEND_URL!/api/random
)

if "%BACKEND_ONLY%" neq "true" if not "%FRONTEND_URL%"=="" (
    echo   Frontend: !FRONTEND_URL!
)

echo.
echo %INFO_PREFIX% Next steps:
echo   - Test the applications using the URLs above
echo   - Monitor logs: az webapp log tail --name ^<app-name^> --resource-group %RESOURCE_GROUP%
echo   - Check app status: az webapp show --name ^<app-name^> --resource-group %RESOURCE_GROUP%

goto :eof

REM Deploy backend function
:deploy_backend
set "backend_image=%DOCKER_USERNAME%/%BACKEND_IMAGE_NAME%:%IMAGE_TAG%"

echo %INFO_PREFIX% Deploying backend: %BACKEND_APP_NAME%
echo %INFO_PREFIX% Using image: %backend_image%

REM Configure the web app to use the container
az webapp config container set --name "%BACKEND_APP_NAME%" --resource-group "%RESOURCE_GROUP%" --docker-custom-image-name "%backend_image%" --docker-registry-server-url "https://index.docker.io"
if errorlevel 1 (
    echo %ERROR_PREFIX% Failed to configure backend container
    exit /b 1
)

echo %SUCCESS_PREFIX% Backend container configuration updated

REM Set app settings for backend
echo %INFO_PREFIX% Configuring backend app settings...
az webapp config appsettings set --name "%BACKEND_APP_NAME%" --resource-group "%RESOURCE_GROUP%" --settings NODE_ENV=production PORT=3000 WEBSITES_ENABLE_APP_SERVICE_STORAGE=false WEBSITES_PORT=3000
if errorlevel 1 (
    echo %ERROR_PREFIX% Failed to configure backend app settings
    exit /b 1
)

echo %SUCCESS_PREFIX% Backend app settings configured

REM Restart the app to apply changes
echo %INFO_PREFIX% Restarting backend app...
az webapp restart --name "%BACKEND_APP_NAME%" --resource-group "%RESOURCE_GROUP%"
if errorlevel 1 (
    echo %WARNING_PREFIX% Failed to restart backend app
) else (
    echo %SUCCESS_PREFIX% Backend app restarted
)

REM Get the backend URL for frontend configuration
for /f "tokens=*" %%i in ('az webapp show --name "%BACKEND_APP_NAME%" --resource-group "%RESOURCE_GROUP%" --query "defaultHostName" -o tsv') do set "BACKEND_HOSTNAME=%%i"
if not "%BACKEND_HOSTNAME%"=="" (
    set "BACKEND_URL=https://!BACKEND_HOSTNAME!"
    echo %INFO_PREFIX% Backend URL: !BACKEND_URL!
)

exit /b 0

REM Deploy frontend function
:deploy_frontend
set "frontend_image=%DOCKER_USERNAME%/%FRONTEND_IMAGE_NAME%:%IMAGE_TAG%"

echo %INFO_PREFIX% Deploying frontend: %FRONTEND_APP_NAME%
echo %INFO_PREFIX% Using image: %frontend_image%

REM Configure the web app to use the container
az webapp config container set --name "%FRONTEND_APP_NAME%" --resource-group "%RESOURCE_GROUP%" --docker-custom-image-name "%frontend_image%" --docker-registry-server-url "https://index.docker.io"
if errorlevel 1 (
    echo %ERROR_PREFIX% Failed to configure frontend container
    exit /b 1
)

echo %SUCCESS_PREFIX% Frontend container configuration updated

REM Set app settings for frontend
echo %INFO_PREFIX% Configuring frontend app settings...
set "app_settings=WEBSITES_ENABLE_APP_SERVICE_STORAGE=false WEBSITES_PORT=80"

REM Prefer explicit API URL if provided, else use discovered backend URL
if not "%API_URL%"=="" (
    set "app_settings=!app_settings! BACKEND_API_URL=!API_URL!"
) else if not "%BACKEND_URL%"=="" (
    set "app_settings=!app_settings! BACKEND_API_URL=!BACKEND_URL!"
)

az webapp config appsettings set --name "%FRONTEND_APP_NAME%" --resource-group "%RESOURCE_GROUP%" --settings !app_settings!
if errorlevel 1 (
    echo %ERROR_PREFIX% Failed to configure frontend app settings
    exit /b 1
)

echo %SUCCESS_PREFIX% Frontend app settings configured

REM Restart the app to apply changes
echo %INFO_PREFIX% Restarting frontend app...
az webapp restart --name "%FRONTEND_APP_NAME%" --resource-group "%RESOURCE_GROUP%"
if errorlevel 1 (
    echo %WARNING_PREFIX% Failed to restart frontend app
) else (
    echo %SUCCESS_PREFIX% Frontend app restarted
)

REM Get the frontend URL
for /f "tokens=*" %%i in ('az webapp show --name "%FRONTEND_APP_NAME%" --resource-group "%RESOURCE_GROUP%" --query "defaultHostName" -o tsv') do set "FRONTEND_HOSTNAME=%%i"
if not "%FRONTEND_HOSTNAME%"=="" (
    set "FRONTEND_URL=https://!FRONTEND_HOSTNAME!"
    echo %INFO_PREFIX% Frontend URL: !FRONTEND_URL!
)

exit /b 0

:show_help
echo Kelix Test Containers Deployment Script for Windows
echo.
echo Usage: %0 [OPTIONS]
echo.
echo Options:
echo     -u, --username NAME        Docker Hub username (required)
echo     -g, --resource-group NAME  Azure Resource Group name (required)
echo     -b, --backend-app NAME     Backend App Service name (required)
echo     -f, --frontend-app NAME    Frontend App Service name (required)
echo     -t, --tag TAG             Image tag (default: latest)
echo     --build                   Build and push images before deployment
echo     --backend-only            Deploy only backend
echo     --frontend-only           Deploy only frontend
echo     -h, --help                Show this help message
echo.
echo Environment Variables:
echo     DOCKER_USERNAME       Docker Hub username
echo     RESOURCE_GROUP        Azure Resource Group name
echo     BACKEND_APP_NAME      Backend App Service name
echo     FRONTEND_APP_NAME     Frontend App Service name
echo     IMAGE_TAG             Image tag to use
echo.
echo Examples:
echo     REM Deploy both apps
echo     %0 -u myusername -g my-rg -b backend-app -f frontend-app
echo.
echo     REM Build and deploy
echo     %0 -u myusername -g my-rg -b backend-app -f frontend-app --build
echo.
echo     REM Deploy only backend
echo     %0 -u myusername -g my-rg -b backend-app --backend-only

exit /b 0
