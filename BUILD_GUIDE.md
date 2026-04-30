# Notepad-- 编译与构建指南

本文档记录了 Notepad-- 项目的完整编译和构建流程，适用于 Windows x64 + Qt6 + MSVC 环境。

## 环境要求

| 组件 | 版本 | 路径示例 |
|------|------|----------|
| Qt | 6.x (推荐 6.5+) | `D:\Qt\6.11.0\msvc2022_64` |
| Visual Studio | 2022 | 默认安装路径 |
| CMake | 3.16+ | Qt 自带或单独安装 |
| NSIS | 3.x | `C:\Program Files (x86)\NSIS` |

## 一、编译步骤

### 1. 设置环境变量

```powershell
# 设置 Qt 路径（根据实际安装路径调整）
$env:Qt6_DIR = "D:\Qt\6.11.0\msvc2022_64"
$env:PATH = "$env:Qt6_DIR\bin;$env:PATH"
```

### 2. 初始化 VS 编译环境

```powershell
# 加载 VS2022 x64 编译环境
& "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
```

或使用 PowerShell 方式：

```powershell
Import-Module "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
Enter-VsDevShell -VsInstallPath "C:\Program Files\Microsoft Visual Studio\2022\Enterprise" -DevCmdArguments "-arch=x64"
```

### 3. CMake 配置

```powershell
cd e:\GitHub\notepad--
mkdir build -Force
cd build

cmake .. -G "Visual Studio 17 2022" -A x64 `
    -DCMAKE_PREFIX_PATH="D:\Qt\6.11.0\msvc2022_64" `
    -DCMAKE_BUILD_TYPE=Release
```

### 4. 编译

```powershell
cmake --build . --config Release --parallel
```

### 5. 验证编译结果

编译成功后，以下文件应存在：

| 文件 | 路径 |
|------|------|
| 主程序 | `build\Release\NotePad--.exe` |
| 插件 | `build\src\plugin\helloworld\Release\helloworld.dll` |
| Scintilla 库 | `build\src\qscint\Release\qmyedit_qt6.lib` |

## 二、构建安装包

### 1. 部署 Qt 运行时

```powershell
# 使用 windeployqt 部署 DLL
D:\Qt\6.11.0\msvc2022_64\bin\windeployqt.exe `
    "e:\GitHub\notepad--\build\Release\NotePad--.exe" `
    --release --no-translations
```

### 2. 创建打包目录

```powershell
# 创建 package 目录
New-Item -ItemType Directory -Path "e:\GitHub\notepad--\build\package" -Force

# 复制主程序和 Qt DLL
Copy-Item -Path "e:\GitHub\notepad--\build\Release\*" `
          -Destination "e:\GitHub\notepad--\build\package" -Recurse -Force

# 创建插件目录并复制插件
New-Item -ItemType Directory -Path "e:\GitHub\notepad--\build\package\plugin" -Force
Copy-Item -Path "e:\GitHub\notepad--\build\src\plugin\helloworld\Release\helloworld.dll" `
          -Destination "e:\GitHub\notepad--\build\package\plugin\" -Force

# 复制额外的 Qt DLL（如需要）
Copy-Item -Path "D:\Qt\6.11.0\msvc2022_64\bin\Qt6PrintSupport.dll" `
          -Destination "e:\GitHub\notepad--\build\package\" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "D:\Qt\6.11.0\msvc2022_64\bin\Qt6Concurrent.dll" `
          -Destination "e:\GitHub\notepad--\build\package\" -Force -ErrorAction SilentlyContinue
```

### 3. 生成安装包（NSIS）

NSIS 脚本位于 `build\installer_qt6.nsi`，执行：

```powershell
& "C:\Program Files (x86)\NSIS\makensis.exe" "e:\GitHub\notepad--\build\installer_qt6.nsi"
```

输出：`build\Notepad--v2.0.0-Qt6-x64-Installer.exe`

### 4. 生成便携包（ZIP）

```powershell
Compress-Archive -Path "e:\GitHub\notepad--\build\package\*" `
                 -DestinationPath "e:\GitHub\notepad--\build\Notepad--v2.0.0-Qt6-x64-Portable.zip" `
                 -Force
```

输出：`build\Notepad--v2.0.0-Qt6-x64-Portable.zip`

## 三、一键构建脚本

将以下内容保存为 `build_release.ps1`，可一键完成全部构建：

```powershell
# build_release.ps1 - Notepad-- Qt6 一键构建脚本

param(
    [string]$QtPath = "D:\Qt\6.11.0\msvc2022_64",
    [string]$Version = "2.0.0"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = "e:\GitHub\notepad--"
$BuildDir = "$ProjectRoot\build"

Write-Host "=== Notepad-- Qt6 Build Script ===" -ForegroundColor Cyan

# 1. 设置环境
Write-Host "`n[1/6] Setting up environment..." -ForegroundColor Yellow
$env:Qt6_DIR = $QtPath
$env:PATH = "$QtPath\bin;$env:PATH"

# 2. CMake 配置
Write-Host "`n[2/6] Configuring CMake..." -ForegroundColor Yellow
if (!(Test-Path $BuildDir)) { New-Item -ItemType Directory -Path $BuildDir | Out-Null }
Set-Location $BuildDir
cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="$QtPath" -DCMAKE_BUILD_TYPE=Release

# 3. 编译
Write-Host "`n[3/6] Building..." -ForegroundColor Yellow
cmake --build . --config Release --parallel

# 4. 部署 Qt
Write-Host "`n[4/6] Deploying Qt runtime..." -ForegroundColor Yellow
& "$QtPath\bin\windeployqt.exe" "$BuildDir\Release\NotePad--.exe" --release --no-translations

# 5. 创建打包目录
Write-Host "`n[5/6] Creating package directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "$BuildDir\package" -Force | Out-Null
Copy-Item -Path "$BuildDir\Release\*" -Destination "$BuildDir\package" -Recurse -Force
New-Item -ItemType Directory -Path "$BuildDir\package\plugin" -Force | Out-Null
Copy-Item -Path "$BuildDir\src\plugin\helloworld\Release\helloworld.dll" -Destination "$BuildDir\package\plugin\" -Force
Copy-Item -Path "$QtPath\bin\Qt6PrintSupport.dll" -Destination "$BuildDir\package\" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$QtPath\bin\Qt6Concurrent.dll" -Destination "$BuildDir\package\" -Force -ErrorAction SilentlyContinue

# 6. 生成安装包和便携包
Write-Host "`n[6/6] Creating installer and portable package..." -ForegroundColor Yellow
& "C:\Program Files (x86)\NSIS\makensis.exe" "$BuildDir\installer_qt6.nsi"
Compress-Archive -Path "$BuildDir\package\*" -DestinationPath "$BuildDir\Notepad--v$Version-Qt6-x64-Portable.zip" -Force

Write-Host "`n=== Build Complete ===" -ForegroundColor Green
Write-Host "Installer: $BuildDir\Notepad--v$Version-Qt6-x64-Installer.exe"
Write-Host "Portable:  $BuildDir\Notepad--v$Version-Qt6-x64-Portable.zip"
```

## 四、输出文件清单

| 类型 | 文件名 | 说明 |
|------|--------|------|
| 安装包 | `Notepad--v2.0.0-Qt6-x64-Installer.exe` | NSIS 安装程序，含快捷方式和右键菜单 |
| 便携包 | `Notepad--v2.0.0-Qt6-x64-Portable.zip` | 解压即用，无需安装 |

## 五、常见问题

### Q1: CMake 找不到 Qt6

确保设置了正确的 `CMAKE_PREFIX_PATH`：
```powershell
cmake .. -DCMAKE_PREFIX_PATH="D:\Qt\6.11.0\msvc2022_64"
```

### Q2: 运行时缺少 DLL

执行 `windeployqt` 或手动复制以下 DLL：
- Qt6Core.dll, Qt6Gui.dll, Qt6Widgets.dll
- Qt6Network.dll, Qt6Svg.dll, Qt6Core5Compat.dll
- platforms/qwindows.dll

### Q3: NSIS 编译中文乱码

确保 `.nsi` 脚本使用 UTF-8 with BOM 编码，或避免使用中文字符。

### Q4: 插件加载失败

确保 `helloworld.dll` 位于 `exe` 同级的 `plugin` 目录下。

---

*文档更新时间: 2026-04-30*
