#ifndef QT6COMPAT_H
#define QT6COMPAT_H

#include <QtGlobal>
#include <QSettings>
#include <QString>

// =============================================================================
// Qt6 兼容性头文件
// 处理 Qt5 → Qt6 的 API 变更
// =============================================================================

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    // =========================================================================
    // Qt6: 使用 Core5Compat 模块或新 API
    // =========================================================================
    
    // QSettings::setIniCodec() 在 Qt6 中移除，默认 UTF-8
    #define SET_INI_CODEC_UTF8(settings) // Qt6 中不需要设置，默认 UTF-8
    inline void setIniCodecUtf8(QSettings* /*settings*/) {}
    inline void setIniCodecUtf8(QSettings& /*settings*/) {}
    
    // QRegExp → QRegularExpression (或使用 Core5Compat 中的 QRegExp)
    // 这里使用 Core5Compat 以最小化代码改动
    #include <QRegularExpression>
    #include <QRegExp>  // 来自 Qt6::Core5Compat
    
    // QTextCodec 在 Qt6 中移到 Core5Compat
    #include <QTextCodec>  // 来自 Qt6::Core5Compat
    
    // QStringConverter 是 Qt6 新增的轻量级替代
    #include <QStringConverter>
    
#else
    // =========================================================================
    // Qt5: 使用原生 API
    // =========================================================================
    
    #define SET_INI_CODEC_UTF8(settings) (settings).setIniCodec("UTF-8")
    inline void setIniCodecUtf8(QSettings* settings) { if(settings) settings->setIniCodec("UTF-8"); }
    inline void setIniCodecUtf8(QSettings& settings) { settings.setIniCodec("UTF-8"); }
    
    #include <QRegExp>
    #include <QTextCodec>
    
#endif

// =============================================================================
// 兼容性辅助函数
// =============================================================================

// 使用 QRegularExpression 替代 QRegExp 的辅助函数 (适用于 Qt6 完全迁移的情况)
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
namespace Qt6Compat {
    // 计算字符串中匹配正则表达式的次数
    inline int countMatches(const QString& str, const QString& pattern) {
        QRegularExpression re(pattern);
        int count = 0;
        QRegularExpressionMatchIterator it = re.globalMatch(str);
        while (it.hasNext()) {
            it.next();
            ++count;
        }
        return count;
    }
    
    // 使用正则表达式替换 (全部替换)
    inline QString replaceAll(const QString& str, const QString& pattern, const QString& replacement) {
        QRegularExpression re(pattern);
        return QString(str).replace(re, replacement);
    }
}
#endif

#endif // QT6COMPAT_H
