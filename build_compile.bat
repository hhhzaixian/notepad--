@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

REM ============================================================
REM  Notepad-- 一键编译脚本
REM  功能：CMake 配置 + 编译
REM ============================================================

echo.
echo ============================================================
echo   Notepad-- 一键编译脚本
echo ============================================================
echo.

REM --- 配置项 ---
set "QT_PATH=D:\Qt\6.11.0\msvc2022_64"
set "PROJECT_ROOT=%~dp0"
set "BUILD_DIR=%PROJECT_ROOT%build"

REM --- 检查 Qt 路径 ---
if not exist "%QT_PATH%\bin\qmake.exe" (
    echo [错误] Qt 路径不存在: %QT_PATH%
    echo 请修改脚本中的 QT_PATH 变量
    pause
    exit /b 1
)

REM --- 设置环境变量 ---
echo [1/4] 设置环境变量...
set "Qt6_DIR=%QT_PATH%"
set "PATH=%QT_PATH%\bin;%PATH%"

REM --- 初始化 VS2022 编译环境 ---
echo [2/4] 初始化 VS2022 x64 编译环境...
if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
) else (
    echo [错误] 未找到 VS2022，请安装 Visual Studio 2022
    pause
    exit /b 1
)

REM --- CMake 配置 ---
echo [3/4] CMake 配置...
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="%QT_PATH%" -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 (
    echo [错误] CMake 配置失败
    pause
    exit /b 1
)

REM --- 编译 ---
echo [4/4] 编译中（Release 模式）...
cmake --build . --config Release --parallel
if errorlevel 1 (
    echo [错误] 编译失败
    pause
    exit /b 1
)

echo.
echo ============================================================
echo   编译完成！
echo ============================================================
echo.
echo   主程序: %BUILD_DIR%\Release\NotePad--.exe
echo   插件:   %BUILD_DIR%\src\plugin\helloworld\Release\helloworld.dll
echo.

pause
