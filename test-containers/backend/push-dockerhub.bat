@echo off
REM ==============================================================
REM Build and push kelix-backend-test image to Docker Hub
REM Usage:
REM    push-dockerhub.bat  [%TAG%]
REM If no tag argument is supplied, "latest" is used.
REM ==============================================================

REM ---------- 1. Variables -------------------------------------
set IMAGE_NAME=kelix-backend-test
set DOCKERHUB_USER=hamzazf
set TAG=%1
if "%TAG%"=="" set TAG=latest

REM ---------- 2. Build -----------------------------------------
echo.
echo Building %IMAGE_NAME%:%TAG% ...
docker build -t %IMAGE_NAME%:%TAG% .
if errorlevel 1 (
    echo Build failed & exit /b 1
)

REM ---------- 3. Tag for Docker Hub ----------------------------
set FULL_TAG=%DOCKERHUB_USER%/%IMAGE_NAME%:%TAG%
echo.
echo Tagging image as %FULL_TAG% ...
docker tag %IMAGE_NAME%:%TAG% %FULL_TAG%
if errorlevel 1 (
    echo Tag failed & exit /b 1
)

@REM REM ---------- 4. Login to Docker Hub ---------------------------
@REM echo.
@REM echo Logging in to Docker Hub...
@REM docker login -u %DOCKERHUB_USER%
@REM if errorlevel 1 (
@REM     echo Login failed & exit /b 1
@REM )

REM ---------- 5. Push ------------------------------------------
echo.
echo Pushing %FULL_TAG% ...
docker push %FULL_TAG%
if errorlevel 1 (
    echo Push failed & exit /b 1
)

echo.
echo Image pushed successfully: %FULL_TAG%
