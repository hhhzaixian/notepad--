cmake_minimum_required(VERSION 3.16)
project(qscint CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# 支持 Qt6 和 Qt5
find_package(Qt6 COMPONENTS Core Gui Widgets PrintSupport Concurrent Network QUIET)
if(NOT Qt6_FOUND)
    find_package(Qt5 REQUIRED COMPONENTS Core Gui Widgets PrintSupport)
    set(QT_VERSION_MAJOR 5)
else()
    set(QT_VERSION_MAJOR 6)
endif()

aux_source_directory(${PROJECT_SOURCE_DIR}/src SRC)
aux_source_directory(${PROJECT_SOURCE_DIR}/scintilla/lexers SRC)
aux_source_directory(${PROJECT_SOURCE_DIR}/scintilla/lexlib SRC)
aux_source_directory(${PROJECT_SOURCE_DIR}/scintilla/src SRC)
aux_source_directory(${PROJECT_SOURCE_DIR}/scintilla/boostregex SRC)

file(GLOB MOC_HEADER ${PROJECT_SOURCE_DIR}/src/Qsci/*.h)

#message(${MOC_HEADER})

add_library(${PROJECT_NAME} STATIC ${SRC} ${MOC_HEADER})

# add_definitions(-DQSCINTILLA_MAKE_DLL)
# add_library(${PROJECT_NAME} SHARED ${SRC} ${MOC_HEADER})

target_compile_definitions(${PROJECT_NAME} PRIVATE SCINTILLA_QT SCI_LEXER INCLUDE_DEPRECATED_FEATURES)

target_include_directories(${PROJECT_NAME} PRIVATE
${PROJECT_SOURCE_DIR}/scintilla/lexlib
${PROJECT_SOURCE_DIR}/scintilla/boostregex
)

target_include_directories(${PROJECT_NAME} PUBLIC
${PROJECT_SOURCE_DIR}/src
${PROJECT_SOURCE_DIR}/src/Qsci
${PROJECT_SOURCE_DIR}/scintilla/src
${PROJECT_SOURCE_DIR}/scintilla/include)

if(QT_VERSION_MAJOR EQUAL 6)
    target_link_libraries(${PROJECT_NAME} Qt6::Core Qt6::Gui Qt6::Widgets Qt6::Concurrent Qt6::Network Qt6::PrintSupport)
else()
    target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Gui Qt5::Widgets Qt5::Concurrent Qt5::Network Qt5::PrintSupport)
endif()

# 设置输出名称 - 支持多配置生成器（如 Visual Studio）
set_target_properties(${PROJECT_NAME} PROPERTIES 
    OUTPUT_NAME_DEBUG "qmyedit_qt${QT_VERSION_MAJOR}d"
    OUTPUT_NAME_RELEASE "qmyedit_qt${QT_VERSION_MAJOR}"
    OUTPUT_NAME_RELWITHDEBINFO "qmyedit_qt${QT_VERSION_MAJOR}"
    OUTPUT_NAME_MINSIZEREL "qmyedit_qt${QT_VERSION_MAJOR}"
)



# if(NOT DEFINED ${notepad--_BINARY_DIR})
# set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${notepad--_BINARY_DIR}/bin/plugin)
# set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${notepad--_BINARY_DIR}/bin/plugin)
# set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${notepad--_BINARY_DIR}/bin/plugin)
# set(LIBRARY_OUTPUT_PATH ${notepad--_BINARY_DIR}/bin/plugin)
# set_target_properties(${PROJECT_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${notepad--_BINARY_DIR}/bin/plugin)
# endif()
