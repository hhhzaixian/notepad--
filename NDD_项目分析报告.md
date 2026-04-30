# Notepad-- (NDD) 项目分析报告

> 文档生成时间：2026-04-30
> 项目版本：v1.22.0

---

## 目录

1. [项目简介](#1-项目简介)
2. [工程结构与构建方式](#2-工程结构与构建方式)
3. [插件开发指南](#3-插件开发指南)
4. [作者与贡献者](#4-作者与贡献者)
5. [NDD特色功能](#5-ndd特色功能)
6. [NDD vs Notepad++ 对比](#6-ndd-vs-notepad-对比)

---

## 1. 项目简介

**Notepad--** (简称 NDD) 是一个使用 C++ 和 Qt 框架开发的轻量级跨平台文本编辑器，支持 Windows、Linux 和 macOS 操作系统。

### 项目目标
- 进行文本编辑类软件的国产可替代
- 重点在国产信创 UOS 系统、Mac 系统、各类 Linux 系统上发展
- 致力于国产软件的可替代，专心做软件

### 开源协议
- **GPLv3** (GNU General Public License v3)

### 项目地址
- GitHub: https://github.com/cxasm/notepad--
- Gitee: https://gitee.com/cxasm/notepad--
- 最新版本下载: https://gitee.com/cxasm/notepad--/releases/tag/v3.5

---

## 2. 工程结构与构建方式

### 2.1 项目目录结构

```
notepad--/
├── CMakeLists.txt           # CMake 主构建文件
├── LICENSE                  # GPLv3 许可证
├── README.md                # 中文说明文档
├── README_EN.md             # 英文说明文档
├── THIRDPARTY.md            # 第三方依赖说明
├── changelog.txt            # 更新日志
├── cmake/                   # CMake 配置模块
│   ├── deb_package_config.cmake    # Debian 打包配置
│   └── nsis_package_config.cmake   # Windows NSIS 安装包配置
└── src/                     # 源代码目录
    ├── cceditor/            # 核心编辑器模块
    ├── include/             # 公共头文件
    ├── installer/           # 安装程序相关
    ├── plugin/              # 插件目录
    │   ├── helloworld/      # 示例插件
    │   └── test/            # 测试插件
    ├── qscint/              # QScintilla 编辑器组件 (核心依赖)
    ├── qss/                 # Qt 样式表
    ├── themes/              # 主题配置 (17种主题)
    ├── Resources/           # 资源文件 (图标等)
    └── *.cpp/*.h/*.ui       # 各功能模块源码
```

### 2.2 技术栈

| 组件 | 技术 |
|------|------|
| 开发语言 | C++ |
| UI 框架 | Qt 5 |
| 编辑器组件 | QScintilla |
| 正则表达式 | Boost Regex |
| 构建系统 | CMake / qmake |
| 打包工具 | NSIS (Windows) / CPack (Linux) |

### 2.3 依赖库

```
Qt 5 组件:
- Qt5::Core
- Qt5::Gui
- Qt5::Widgets
- Qt5::Concurrent
- Qt5::Network
- Qt5::PrintSupport
- Qt5::XmlPatterns

核心依赖:
- QScintilla (qscint)
- Boost Regex
```

### 2.4 编译构建方法

#### 方法一：CMake 工具链编译

**Ubuntu/Debian:**
```bash
# 1. 安装编译环境
sudo apt-get install g++ make cmake

# 2. 安装 Qt 工具和库
sudo apt-get install qtbase5-dev qt5-qmake qtbase5-dev-tools \
                     libqt5printsupport5 libqt5xmlpatterns5-dev

# 3. 配置项目
cmake -B build -DCMAKE_BUILD_TYPE=Release

# 4. 编译
cd build && make -j

# 5. 打包
cpack
```

**ArchLinux:**
```bash
# 1. 安装编译环境
sudo pacman -S gcc cmake make ninja

# 2. 安装 Qt 工具和库
sudo pacman -S qt5-tools qt5-base qt5-xmlpatterns

# 3. 配置
cmake -S . -Bbuild -GNinja -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr -W no-dev

# 4. 编译安装
ninja -C build && ninja -C build install

# 5. 或使用 AUR 安装
yay -S notepad---git
```

**Windows:**
```batch
# 1. 确保安装 Qt 5.15+ 和 CMake
# 2. 配置
cmake -B build -DCMAKE_BUILD_TYPE=Release

# 3. 编译
cmake --build build --config Release

# 4. 打包
cd build && cpack
```

#### 方法二：Qt 项目编译

1. **编译依赖库**: 使用 Qt Creator 或 Visual Studio 打开 `src/qscint/src/qscintilla.pro`，编译 QScintilla 依赖库

2. **编译主程序**: 打开 `src/RealCompare.pro` 并编译

#### CMake 编译选项

```cmake
# 禁用插件功能
cmake -B build -DPLUGIN_EN=on

# Debug 模式
cmake -B build -DCMAKE_BUILD_TYPE=Debug
```

### 2.5 打包发布

**Windows (NSIS 安装包):**
- 输出位置: `build/` 目录
- 格式: `.exe` 安装程序
- 支持右键菜单集成

**Linux (DEB 包):**
- 输出位置: `build/` 目录
- 格式: `.deb` 包
- 架构: amd64

---

## 3. 插件开发指南

NDD 支持动态加载插件，开发者可以使用 C++/Qt 编写插件扩展功能。

### 3.1 插件架构

```
插件目录结构:
plugin/
├── helloworld/              # 示例插件
│   ├── CMakeLists.txt       # CMake 构建文件
│   ├── helloworld.pro       # qmake 构建文件
│   ├── helloworldexport.cpp # 插件导出接口
│   ├── qttestclass.cpp      # 插件功能实现
│   ├── qttestclass.h
│   └── qttestclass.ui       # 插件 UI 文件
```

### 3.2 插件接口定义

插件必须实现两个导出函数：

```cpp
// 头文件: pluginGl.h
struct NDD_PROC_DATA {
    QString m_strPlugName;  // 插件名称 (必填)
    QString m_strFilePath;  // 插件完整路径 (主程序填充)
    QString m_strComment;   // 插件说明
    QString m_version;      // 版本号
    QString m_auther;       // 作者名称
    int m_menuType;         // 菜单类型: 0=不创建二级菜单, 1=创建二级菜单
    QMenu* m_rootMenu;      // 二级菜单根节点 (m_menuType=1 时有效)
};
```

### 3.3 必须实现的导出函数

```cpp
#include <pluginGl.h>
#include <qsciscintilla.h>
#include <functional>

// 1. 插件标识函数 - 返回插件基本信息
extern "C" NDD_EXPORT bool NDD_PROC_IDENTIFY(NDD_PROC_DATA* pProcData) {
    if (pProcData == NULL) return false;
    
    pProcData->m_strPlugName = "我的插件名称";
    pProcData->m_strComment = "插件功能说明";
    pProcData->m_version = "v1.0";
    pProcData->m_auther = "作者名";
    pProcData->m_menuType = 0;  // 0=不创建二级菜单
    
    return true;
}

// 2. 插件主入口函数 - 点击菜单时调用
extern "C" NDD_EXPORT int NDD_PROC_MAIN(
    QWidget* pNotepad,           // NDD 主窗口指针
    const QString& strFileName,  // 插件 DLL 完整路径
    std::function<QsciScintilla*()> getCurEdit,    // 获取当前编辑器
    std::function<bool(int, void*)> pluginCallBack, // 回调主程序功能
    NDD_PROC_DATA* pProcData     // 插件数据
) {
    // 获取当前编辑器
    QsciScintilla* pEdit = getCurEdit();
    if (pEdit == nullptr) return -1;
    
    // 实现你的功能
    // ...
    
    return 0;
}
```

### 3.4 完整插件示例

**helloworld 插件功能**: 文本大小写转换

```cpp
// qttestclass.h
#pragma once
#include <QWidget>
#include "ui_qttestclass.h"

class QsciScintilla;
class QtTestClass : public QWidget {
    Q_OBJECT
public:
    QtTestClass(QWidget* parent, QsciScintilla* pEdit);
    ~QtTestClass();

private slots:
    void on_upper();  // 转大写
    void on_lower();  // 转小写

private:
    Ui::QtTestClassClass ui;
    QsciScintilla* m_pEdit;
};

// qttestclass.cpp
#include "qttestclass.h"
#include <qsciscintilla.h>

QtTestClass::QtTestClass(QWidget* parent, QsciScintilla* pEdit)
    : QWidget(parent), m_pEdit(pEdit) {
    ui.setupUi(this);
}

void QtTestClass::on_upper() {
    QString text = m_pEdit->text();
    m_pEdit->setText(text.toUpper());
}

void QtTestClass::on_lower() {
    QString text = m_pEdit->text();
    m_pEdit->setText(text.toLower());
}
```

### 3.5 插件 CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.16)
project(myplugin)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 REQUIRED COMPONENTS Core Gui Widgets)

add_definitions(-D_UNICODE -DUNICODE)

file(GLOB UI_SRC ${PROJECT_SOURCE_DIR}/*.ui)
file(GLOB SRC ${PROJECT_SOURCE_DIR}/*.cpp)
file(GLOB MOC_HEADER ${PROJECT_SOURCE_DIR}/*.h)

# 编译为动态库
add_library(${PROJECT_NAME} SHARED ${SRC} ${UI_SRC} ${MOC_HEADER})

target_include_directories(${PROJECT_NAME} PRIVATE
    ${PROJECT_SOURCE_DIR}
    ${PROJECT_SOURCE_DIR}/../../include
    ${PROJECT_SOURCE_DIR}/../../qscint/src
    ${PROJECT_SOURCE_DIR}/../../qscint/src/Qsci
)

target_link_libraries(${PROJECT_NAME} 
    qscint 
    Qt5::Core Qt5::Gui Qt5::Widgets
)
```

### 3.6 插件部署

1. 编译生成 `.dll` (Windows) 或 `lib*.so` (Linux)
2. 将插件文件复制到 NDD 安装目录下的 `plugin/` 文件夹
3. 重启 NDD，插件会自动加载到"插件"菜单

### 3.7 二级菜单插件

如果需要创建自己的二级菜单:

```cpp
bool NDD_PROC_IDENTIFY(NDD_PROC_DATA* pProcData) {
    pProcData->m_strPlugName = "高级工具";
    pProcData->m_menuType = 1;  // 启用二级菜单
    return true;
}

int NDD_PROC_MAIN(..., NDD_PROC_DATA* pProcData) {
    if (pProcData && pProcData->m_menuType == 1) {
        QMenu* rootMenu = pProcData->m_rootMenu;
        // 在 rootMenu 下添加自己的菜单项
        QAction* action1 = rootMenu->addAction("功能1");
        QAction* action2 = rootMenu->addAction("功能2");
        // 连接信号槽...
    }
    return 0;
}
```

---

## 4. 作者与贡献者

### 4.1 主要作者

| 贡献者 | 提交次数 | 角色 |
|--------|----------|------|
| **zuowei.yin** | 52 | 项目创建者/主要开发者 |
| **Notepad-- (Subtwo)** | 25 | 核心开发者 |
| **爬山虎** | 8 | 贡献者 |
| **tangramor** | 1 | 贡献者 |
| **littzhch** | 1 | 贡献者 |

### 4.2 项目维护

- **项目发起者**: zuowei.yin (cxasm)
- **联系方式**: QQ群 959439826
- **Gitee 主页**: https://gitee.com/cxasm

---

## 5. NDD特色功能

### 5.1 核心功能

| 功能分类 | 具体功能 |
|----------|----------|
| **跨平台** | Windows / Linux (Ubuntu, Debian, Arch, UOS) / macOS |
| **语法高亮** | 支持 40+ 编程语言 |
| **主题支持** | 17 种内置主题 (Monokai, Obsidian, Twilight 等) |
| **编码支持** | UTF-8, GBK, GB2312, Unicode 等多种编码 |
| **大文件** | 支持大文本/超大文本分块显示 |
| **文件对比** | 文本对比 / 二进制对比 / 目录对比 |
| **插件系统** | 支持 C++/Qt 插件扩展 |

### 5.2 编辑功能

- ✅ 多标签页编辑
- ✅ 语法高亮 (C/C++, Python, Java, JavaScript, HTML, CSS, SQL, Shell, ASM 等)
- ✅ 代码折叠
- ✅ 自动缩进
- ✅ 块选择/列编辑
- ✅ 书签功能 (F2 切换)
- ✅ 查找替换 (支持正则表达式)
- ✅ 批量查找替换
- ✅ 目录内文件搜索
- ✅ 大小写转换
- ✅ 行排序/去重
- ✅ 移除空行
- ✅ MD5/SHA 计算

### 5.3 界面功能

- ✅ 深色/浅色主题切换
- ✅ 文件列表面板
- ✅ 查找结果面板
- ✅ 行号显示
- ✅ 缩放率显示
- ✅ 状态栏 (编码/换行符/位置)
- ✅ 自定义语言样式
- ✅ 快捷键自定义
- ✅ 自动保存/恢复标签页
- ✅ 高清屏幕适配

### 5.4 文件功能

- ✅ 拖放打开文件
- ✅ 最近文件列表
- ✅ 右键菜单集成 (Windows)
- ✅ 文件关联设置
- ✅ 打开文件所在目录
- ✅ 命令行打开 (Windows)
- ✅ 文件变更监测
- ✅ Tail 模式 (实时刷新)

### 5.5 内置 17 种主题

| 主题名称 | 风格 |
|----------|------|
| Bespin | 深色 |
| Black board | 深色 |
| Blue light | 浅色 |
| Choco | 深色 |
| DansLeRuSH-Dark | 深色 |
| Deep Black | 深色 |
| HotFudgeSundae | 深色 |
| lavender | 浅色 |
| misty rose | 浅色 |
| Mono Industrial | 深色 |
| **Monokai** | 深色经典 |
| Obsidian | 深色 |
| Plastic Code Wrap | 深色 |
| Ruby Blue | 深色 |
| Twilight | 深色 |
| Vibrant Ink | 深色 |
| yellow rice | 浅色 |

---

## 6. NDD vs Notepad++ 对比

### 6.1 概览对比

| 特性 | Notepad-- (NDD) | Notepad++ |
|------|-----------------|-----------|
| **开发语言** | C++ / Qt | C++ / Win32 API |
| **跨平台** | ✅ Windows/Linux/macOS | ❌ 仅 Windows |
| **开源协议** | GPLv3 | GPLv2 |
| **首次发布** | 2021 年 | 2003 年 |
| **UI 框架** | Qt 5 | Scintilla + Win32 |
| **插件系统** | ✅ C++/Qt 插件 | ✅ C++ 插件 |
| **中文支持** | ✅ 原生支持 | ✅ 多语言包 |

### 6.2 功能对比

| 功能 | NDD | Notepad++ |
|------|-----|-----------|
| 语法高亮 | ✅ 40+ 语言 | ✅ 80+ 语言 |
| 代码折叠 | ✅ | ✅ |
| 自动完成 | ⚠️ 基础 | ✅ 完善 |
| 宏录制 | ❌ | ✅ |
| 正则查找 | ✅ Boost Regex | ✅ PCRE |
| 列编辑 | ✅ | ✅ |
| 文件对比 | ✅ 内置 | ⚠️ 需插件 |
| 目录对比 | ✅ 内置 | ⚠️ 需插件 |
| 二进制编辑 | ✅ Hex 视图 | ⚠️ 需插件 |
| 大文件支持 | ✅ 分块加载 | ⚠️ 有限制 |
| 主题数量 | 17 种 | 20+ 种 |
| 插件生态 | 🔨 发展中 | ✅ 丰富成熟 |

### 6.3 平台支持对比

| 平台 | NDD | Notepad++ |
|------|-----|-----------|
| Windows 10/11 | ✅ | ✅ |
| Windows 7/8 | ✅ | ✅ |
| Ubuntu/Debian | ✅ | ❌ (需 Wine) |
| Arch Linux | ✅ AUR | ❌ |
| **国产 UOS** | ✅ 商店上架 | ❌ |
| macOS | ✅ | ❌ |
| 龙芯 (LoongArch) | ✅ | ❌ |

### 6.4 NDD 的核心优势

1. **真正的跨平台**
   - 原生支持 Windows、Linux、macOS
   - 特别优化国产 UOS 系统
   - 支持龙芯等国产处理器架构

2. **国产软件可替代**
   - 满足信创环境要求
   - 已上架 UOS 应用商店
   - 中国开发者维护，响应及时

3. **内置对比功能**
   - 文本对比无需额外插件
   - 二进制对比内置支持
   - 目录对比支持递归

4. **大文件处理**
   - 超大文本分块显示
   - 4GB+ 文件支持
   - 内存占用优化

5. **现代化 UI**
   - 基于 Qt 的现代界面
   - 高清屏幕自适应
   - 统一的跨平台体验

### 6.5 Notepad++ 的优势

1. **成熟稳定** - 20+ 年历史，经过充分测试
2. **插件丰富** - 大量成熟插件可用
3. **功能完善** - 宏录制、自动完成等
4. **用户基数大** - 文档和教程丰富
5. **Windows 深度集成** - 右键菜单、文件关联

### 6.6 选择建议

| 场景 | 推荐 |
|------|------|
| Windows 用户，需要丰富插件 | Notepad++ |
| Linux/macOS 用户 | **NDD** ✅ |
| 国产 UOS/信创环境 | **NDD** ✅ |
| 需要内置文件对比 | **NDD** ✅ |
| 需要处理超大文件 | **NDD** ✅ |
| 需要宏录制功能 | Notepad++ |
| 学习 Qt 插件开发 | **NDD** ✅ |

---

## 附录

### A. 快捷键列表

| 快捷键 | 功能 |
|--------|------|
| Ctrl + N | 新建文件 |
| Ctrl + O | 打开文件 |
| Ctrl + S | 保存文件 |
| Ctrl + Shift + S | 另存为 |
| Ctrl + W | 关闭当前标签 |
| Ctrl + F | 查找 |
| Ctrl + H | 替换 |
| Ctrl + G | 跳转到行 |
| F2 | 切换书签 |
| Ctrl + +/- | 缩放 |

### B. 相关链接

- 官方 Gitee: https://gitee.com/cxasm/notepad--
- 官方 GitHub: https://github.com/cxasm/notepad--
- QQ 交流群: 959439826
- AUR 包: https://aur.archlinux.org/packages/notepad---git

---

## 7. Qt6 编译适配记录（2026-04-30）

### 7.1 编译环境

| 项目 | 版本/路径 |
|------|-----------|
| 操作系统 | Windows 10/11 |
| Qt 版本 | Qt 6.11.0 (MSVC 2022 64-bit) |
| Qt 安装路径 | D:\Qt\6.11.0\msvc2022_64 |
| CMake 版本 | 4.3.1 |
| 编译器 | MSVC 19.44 (VS 2022 BuildTools) |

### 7.2 Qt6 适配修改

由于原项目基于 Qt5 开发，适配 Qt6 需要进行以下修改：

#### 7.2.1 CMakeLists.txt 修改

**主 CMakeLists.txt (`CMakeLists.txt`)**
```cmake
# 支持 Qt6 和 Qt5
find_package(Qt6 COMPONENTS Core Gui Widgets Concurrent Network PrintSupport Core5Compat QUIET)
if(NOT Qt6_FOUND)
    find_package(Qt5 REQUIRED COMPONENTS Core Gui Widgets Concurrent Network PrintSupport XmlPatterns)
    set(QT_VERSION_MAJOR 5)
else()
    set(QT_VERSION_MAJOR 6)
endif()

# 链接时根据 Qt 版本选择正确的库
if(QT_VERSION_MAJOR EQUAL 6)
    target_link_libraries(${PROJECT_NAME} qscint Qt6::Core Qt6::Gui Qt6::Widgets ...)
else()
    target_link_libraries(${PROJECT_NAME} qscint Qt5::Core Qt5::Gui Qt5::Widgets ...)
endif()
```

#### 7.2.2 Qt5 → Qt6 API 变更

| 废弃 API | Qt6 替代方案 | 涉及文件 |
|----------|--------------|----------|
| `QSettings::setIniCodec()` | Qt6 默认 UTF-8，无需设置 | 9 个文件 |
| `QRegExp` | `QRegularExpression` 或 Core5Compat | 3 个文件 |
| `QTextCodec` | `QStringConverter` 或 Core5Compat | Encode.cpp 等 |
| `QXmlQuery` / `QXmlPatterns` | Qt6 已移除，需重写或删除 | ccnotepad.cpp |
| `nativeEvent(long*)` | `nativeEvent(qintptr*)` | ccnotepad.h/cpp |

#### 7.2.3 新增兼容性头文件

创建 `src/qt6compat.h`：
```cpp
#ifndef QT6COMPAT_H
#define QT6COMPAT_H

#include <QtGlobal>
#include <QSettings>

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    #define SET_INI_CODEC_UTF8(settings) // Qt6 默认 UTF-8
    #include <QRegularExpression>
#else
    #define SET_INI_CODEC_UTF8(settings) (settings).setIniCodec("UTF-8")
    #include <QRegExp>
#endif


#endif // QT6COMPAT_H
```

### 7.3 当前编译状态

| 模块 | 状态 | 说明 |
|------|------|------|
| qscint 库 | ✅ 成功 | 生成 qmyedit_qt6.lib (28.26 MB) |
| helloworld 插件 | ✅ 成功 | 生成 helloworld.dll (2.07 MB) |
| NotePad-- 主程序 | ✅ 成功 | 生成 NotePad--.exe (3.45 MB) |

### 7.4 Qt6 适配详细修改清单

#### 7.4.1 QRegExp → QRegularExpression 适配

| 文件 | 修改内容 |
|------|----------|
| `batchfindreplace.cpp` | 添加条件编译，Qt6 使用 `QRegularExpression` |
| `CmpareMode.cpp` | 两处 lambda 函数中的 `QRegExp` 替换 |
| `scintillaeditview.cpp` | 统计字数功能中的正则表达式替换 |

#### 7.4.2 QTextCodec 适配（使用 Core5Compat）

| 文件 | 修改内容 |
|------|----------|
| `Encode.cpp` | 通过 `qt6compat.h` 使用 Core5Compat 的 QTextCodec |
| `encodeconvert.cpp` | 同上 |
| `main.cpp` | 同上 |
| `ccnotepad.cpp` | 同上，并修复多处 `setIniCodec` 调用 |

#### 7.4.3 setIniCodec → SET_INI_CODEC_UTF8 宏替换

共修改 **12** 处，涉及文件：
- `ccnotepad.cpp` (4处)
- `langstyledefine.cpp` (3处)
- `nddsetting.cpp` (1处)
- `langextset.cpp` (1处)
- `shortcutkeymgr.cpp` (1处)
- `userlexdef.cpp` (1处)
- `qscilexer.cpp` (1处 - 自带兼容定义)

#### 7.4.4 其他 Qt6 API 变更修复

| 问题 | 文件 | 解决方案 |
|------|------|----------|
| `QLayout::setMargin()` 移除 | `ccnotepad.cpp` | 改用 `setContentsMargins(0,0,0,0)` |
| `QVariant` 比较运算符移除 | `ccnotepad.cpp` | 改用 `.toInt() >= 0` |
| `QChar` 构造函数变更 | `scintillaeditview.cpp` | 使用 `QChar('\0')` 替代 `QChar(0)` |
| `QChar` 赋值运算符限制 | `findwin.cpp` | 使用 int 临时变量 |
| `QVariant` 不接受 `char*` | `userlexdef.cpp` | 使用 `QString::fromUtf8()` 包装 |
| `QFile` 未定义 | `draglineedit.cpp`, `langextset.cpp` | 添加 `#include <QFile>` |

#### 7.4.5 链接库适配

| 文件 | 修改内容 |
|------|----------|
| `main.cpp` | 根据 Qt 版本选择链接 `qmyedit_qt5.lib` 或 `qmyedit_qt6.lib` |
| `qscint/CMakeLists.txt` | 修复多配置生成器下的输出名称 |

### 7.5 编译环境

| 组件 | 版本 |
|------|------|
| Qt | 6.11.0 (MSVC 2022 64-bit) |
| CMake | 4.3.1 |
| 编译器 | MSVC 19.44 (Visual Studio 2022) |
| Windows SDK | 10.0.26100.0 |

### 7.6 编译命令参考

```powershell
# 配置 CMake（使用 Qt6）
cmake -B build -G "Visual Studio 17 2022" -A x64 `
      -DCMAKE_PREFIX_PATH="D:/Qt/6.11.0/msvc2022_64"

# 编译 Release 版本
cmake --build build --config Release

# 编译 Debug 版本
cmake --build build --config Debug
```

### 7.7 运行时依赖

运行 NotePad--.exe 需要以下 Qt6 DLL（从 `D:\Qt\6.11.0\msvc2022_64\bin` 复制）：
- `Qt6Core.dll`
- `Qt6Gui.dll`
- `Qt6Widgets.dll`
- `Qt6Network.dll`
- `Qt6PrintSupport.dll`
- `Qt6Concurrent.dll`
- `Qt6Core5Compat.dll`

或者使用 `windeployqt` 工具自动部署：
```powershell
D:\Qt\6.11.0\msvc2022_64\bin\windeployqt.exe build\Release\NotePad--.exe
```

---

*本文档由 CodeBuddy 自动生成*
