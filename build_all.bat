@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

REM ============================================================
REM  Notepad-- 一键完整构建脚本
REM  功能：编译 + 部署 + 打包（安装包 + 便携包）
REM ============================================================

echo.
echo ============================================================
echo   Notepad-- 一键完整构建脚本
echo   编译 + 部署 + 打包
echo ============================================================
echo.

REM --- 配置项 ---
set "QT_PATH=D:\Qt\6.11.0\msvc2022_64"
set "PROJECT_ROOT=%~dp0"
set "BUILD_DIR=%PROJECT_ROOT%build"
set "PACKAGE_DIR=%BUILD_DIR%\package"
set "VERSION=2.0.0"
set "NSIS_PATH=C:\Program Files (x86)\NSIS\makensis.exe"

REM --- 记录开始时间 ---
set "START_TIME=%TIME%"

REM ============================================================
REM  第一阶段：环境检查
REM ============================================================
echo [阶段 1/6] 环境检查...

if not exist "%QT_PATH%\bin\qmake.exe" (
    echo [错误] Qt 路径不存在: %QT_PATH%
    echo 请修改脚本中的 QT_PATH 变量
    pause
    exit /b 1
)
echo   - Qt6: OK

REM 检查 VS2022
set "VS_BAT="
if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_BAT=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_BAT=C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_BAT=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
)

if "%VS_BAT%"=="" (
    echo [错误] 未找到 VS2022
    pause
    exit /b 1
)
echo   - VS2022: OK

REM ============================================================
REM  第二阶段：初始化编译环境
REM ============================================================
echo [阶段 2/6] 初始化编译环境...
set "Qt6_DIR=%QT_PATH%"
set "PATH=%QT_PATH%\bin;%PATH%"
call "%VS_BAT%" >nul 2>&1
echo   - 环境变量: OK
echo   - VS x64 工具链: OK

REM ============================================================
REM  第三阶段：CMake 配置
REM ============================================================
echo [阶段 3/6] CMake 配置...
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="%QT_PATH%" -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 (
    echo [错误] CMake 配置失败
    pause
    exit /b 1
)
echo   - CMake 配置: OK

REM ============================================================
REM  第四阶段：编译
REM ============================================================
echo [阶段 4/6] 编译（Release 模式，并行编译）...
cmake --build . --config Release --parallel
if errorlevel 1 (
    echo [错误] 编译失败
    pause
    exit /b 1
)
echo   - 编译: OK

REM ============================================================
REM  第五阶段：部署 Qt 运行时
REM ============================================================
echo [阶段 5/6] 部署 Qt 运行时...
"%QT_PATH%\bin\windeployqt.exe" "%BUILD_DIR%\Release\NotePad--.exe" --release --no-translations >nul 2>&1

REM 创建打包目录
if exist "%PACKAGE_DIR%" rmdir /s /q "%PACKAGE_DIR%"
mkdir "%PACKAGE_DIR%"
xcopy "%BUILD_DIR%\Release\*" "%PACKAGE_DIR%\" /E /I /Y >nul

REM 复制插件
mkdir "%PACKAGE_DIR%\plugin" 2>nul
copy "%BUILD_DIR%\src\plugin\helloworld\Release\helloworld.dll" "%PACKAGE_DIR%\plugin\" >nul 2>&1

REM 复制额外 DLL（确保这些 DLL 存在于 package 目录）
if exist "%QT_PATH%\bin\Qt6PrintSupport.dll" copy "%QT_PATH%\bin\Qt6PrintSupport.dll" "%PACKAGE_DIR%\" >nul
if exist "%QT_PATH%\bin\Qt6Concurrent.dll" copy "%QT_PATH%\bin\Qt6Concurrent.dll" "%PACKAGE_DIR%\" >nul
echo   - Qt DLL 部署: OK
echo   - 插件复制: OK

REM ============================================================
REM  第六阶段：生成安装包和便携包
REM ============================================================
echo [阶段 6/6] 生成安装包和便携包...

REM 生成安装包
set "INSTALLER_NAME=Notepad--v%VERSION%-Qt6-x64-Installer.exe"
if exist "%NSIS_PATH%" (
    if exist "%BUILD_DIR%\installer_qt6.nsi" (
        "%NSIS_PATH%" "%BUILD_DIR%\installer_qt6.nsi" >nul 2>&1
        if exist "%BUILD_DIR%\%INSTALLER_NAME%" (
            echo   - 安装包: OK
        ) else (
            echo   - 安装包: 失败
        )
    ) else (
        echo   - 安装包: 跳过（未找到 nsi 脚本）
    )
) else (
    echo   - 安装包: 跳过（未安装 NSIS）
)

REM 生成便携包
set "ZIP_NAME=Notepad--v%VERSION%-Qt6-x64-Portable.zip"
if exist "%BUILD_DIR%\%ZIP_NAME%" del "%BUILD_DIR%\%ZIP_NAME%"
powershell -Command "Compress-Archive -Path '%PACKAGE_DIR%\*' -DestinationPath '%BUILD_DIR%\%ZIP_NAME%' -Force" >nul 2>&1
if exist "%BUILD_DIR%\%ZIP_NAME%" (
    echo   - 便携包: OK
) else (
    echo   - 便携包: 失败
)

REM ============================================================
REM  完成
REM ============================================================
echo.
echo ============================================================
echo   构建完成！
echo ============================================================
echo.
echo   开始时间: %START_TIME%
echo   结束时间: %TIME%
echo.
echo   输出文件:
echo   ---------------------------------------------------------

if exist "%BUILD_DIR%\%INSTALLER_NAME%" (
    for %%A in ("%BUILD_DIR%\%INSTALLER_NAME%") do echo   安装包: %%~nxA ^(%%~zA bytes^)
)

if exist "%BUILD_DIR%\%ZIP_NAME%" (
    for %%A in ("%BUILD_DIR%\%ZIP_NAME%") do echo   便携包: %%~nxA ^(%%~zA bytes^)
)

echo.
echo   文件位置: %BUILD_DIR%
echo.

pause
