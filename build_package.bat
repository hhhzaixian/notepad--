@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

REM ============================================================
REM  Notepad-- 一键构建安装包脚本
REM  功能：部署 Qt DLL + 生成安装包 + 生成便携包
REM  前提：已完成编译（运行过 build_compile.bat）
REM ============================================================

echo.
echo ============================================================
echo   Notepad-- 一键构建安装包脚本
echo ============================================================
echo.

REM --- 配置项 ---
set "QT_PATH=D:\Qt\6.11.0\msvc2022_64"
set "PROJECT_ROOT=%~dp0"
set "BUILD_DIR=%PROJECT_ROOT%build"
set "PACKAGE_DIR=%BUILD_DIR%\package"
set "VERSION=2.0.0"
set "NSIS_PATH=C:\Program Files (x86)\NSIS\makensis.exe"

REM --- 检查编译产物 ---
if not exist "%BUILD_DIR%\Release\NotePad--.exe" (
    echo [错误] 未找到编译产物，请先运行 build_compile.bat
    pause
    exit /b 1
)

REM --- 部署 Qt 运行时 ---
echo [1/5] 部署 Qt 运行时 DLL...
"%QT_PATH%\bin\windeployqt.exe" "%BUILD_DIR%\Release\NotePad--.exe" --release --no-translations
if errorlevel 1 (
    echo [警告] windeployqt 可能有警告，继续执行...
)

REM --- 创建打包目录 ---
echo [2/5] 创建打包目录...
if exist "%PACKAGE_DIR%" rmdir /s /q "%PACKAGE_DIR%"
mkdir "%PACKAGE_DIR%"
xcopy "%BUILD_DIR%\Release\*" "%PACKAGE_DIR%\" /E /I /Y >nul

REM --- 复制插件 ---
echo [3/5] 复制插件...
mkdir "%PACKAGE_DIR%\plugin" 2>nul
copy "%BUILD_DIR%\src\plugin\helloworld\Release\helloworld.dll" "%PACKAGE_DIR%\plugin\" >nul 2>&1

REM --- 复制额外 DLL（确保这些 DLL 存在于 package 目录）---
echo [3.5/5] 复制额外 DLL...
if exist "%QT_PATH%\bin\Qt6PrintSupport.dll" copy "%QT_PATH%\bin\Qt6PrintSupport.dll" "%PACKAGE_DIR%\" >nul
if exist "%QT_PATH%\bin\Qt6Concurrent.dll" copy "%QT_PATH%\bin\Qt6Concurrent.dll" "%PACKAGE_DIR%\" >nul

REM --- 生成安装包 ---
echo [4/5] 生成安装包...
if exist "%NSIS_PATH%" (
    if exist "%BUILD_DIR%\installer_qt6.nsi" (
        "%NSIS_PATH%" "%BUILD_DIR%\installer_qt6.nsi"
        if errorlevel 1 (
            echo [警告] NSIS 打包可能有警告
        )
    ) else (
        echo [警告] 未找到 installer_qt6.nsi，跳过安装包生成
    )
) else (
    echo [警告] 未安装 NSIS，跳过安装包生成
)

REM --- 生成便携包 ---
echo [5/5] 生成便携包...
set "ZIP_NAME=Notepad--v%VERSION%-Qt6-x64-Portable.zip"
if exist "%BUILD_DIR%\%ZIP_NAME%" del "%BUILD_DIR%\%ZIP_NAME%"

REM 使用 PowerShell 压缩
powershell -Command "Compress-Archive -Path '%PACKAGE_DIR%\*' -DestinationPath '%BUILD_DIR%\%ZIP_NAME%' -Force"
if errorlevel 1 (
    echo [错误] 生成便携包失败
    pause
    exit /b 1
)

echo.
echo ============================================================
echo   构建完成！
echo ============================================================
echo.
echo   安装包: %BUILD_DIR%\Notepad--v%VERSION%-Qt6-x64-Installer.exe
echo   便携包: %BUILD_DIR%\%ZIP_NAME%
echo.

pause
