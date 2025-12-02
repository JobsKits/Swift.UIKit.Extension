//
//  DateFormatter.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/4/25.
//

import Foundation

public extension DateFormatter {
    // MARK: - 基础链式
    @discardableResult
    func byDateFormat(_ format: String) -> Self {
        self.dateFormat = format
        return self
    }
    // MARK: - iOS 会按本地化模板生成 format（适合“年/月/日/时区/星期”之类可本地化展示）
    @discardableResult
    func byLocalizedTemplate(_ template: String, locale: Locale? = nil) -> Self {
        if let locale { self.locale = locale }
        self.setLocalizedDateFormatFromTemplate(template)
        return self
    }

    @discardableResult
    func byStyles(date: DateFormatter.Style = .none,
                  time: DateFormatter.Style = .none) -> Self {
        self.dateStyle = date
        self.timeStyle = time
        // ⚠️ 只有启用样式时才清掉自定义 format
        if date != .none || time != .none {
            self.dateFormat = nil
        };return self
    }

    @discardableResult
    func byLocale(_ locale: Locale) -> Self {
        self.locale = locale
        return self
    }

    @discardableResult
    func byTimeZone(_ tz: TimeZone) -> Self {
        self.timeZone = tz
        return self
    }

    @discardableResult
    func byCalendar(_ calendar: Calendar) -> Self {
        self.calendar = calendar
        return self
    }
    // MARK: - 宽松解析：比如 "2025/1/2"、"2025-01-02" 都尽量解析
    @discardableResult
    func byLenient(_ on: Bool = true) -> Self {
        self.isLenient = on
        return self
    }
    // MARK: - 相对日期（Today/Yesterday 等）——中文/本地化由 locale 决定
    @discardableResult
    func byRelativeDateFormatting(_ on: Bool = true) -> Self {
        self.doesRelativeDateFormatting = on
        return self
    }
    // MARK: - 上下文（标题/独立文本），会影响大小写等本地化细节
    @available(iOS 8.0, *)
    @discardableResult
    func byFormattingContext(_ ctx: Formatter.Context) -> Self {
        self.formattingContext = ctx
        return self
    }
    // MARK: - 符号/字符串
    @discardableResult
    func byAMSymbol(_ am: String) -> Self { self.amSymbol = am; return self }

    @discardableResult
    func byPMSymbol(_ pm: String) -> Self { self.pmSymbol = pm; return self }
    // MARK: - 自定义月/周等符号（如需要完全自定义中文/印尼文）
    @discardableResult
    func byMonthSymbols(_ symbols: [String]) -> Self { self.monthSymbols = symbols; return self }

    @discardableResult
    func byShortMonthSymbols(_ symbols: [String]) -> Self { self.shortMonthSymbols = symbols; return self }

    @discardableResult
    func byWeekdaySymbols(_ symbols: [String]) -> Self { self.weekdaySymbols = symbols; return self }

    @discardableResult
    func byShortWeekdaySymbols(_ symbols: [String]) -> Self { self.shortWeekdaySymbols = symbols; return self }
    // MARK: - 便捷方法
    /// 格式化
    func format(_ date: Date) -> String { string(from: date) }
    /// 解析
    func parse(_ text: String) -> Date? { date(from: text) }
}
// MARK: - 工厂 & 预置
/**
     // 1) 最全日志
     let f = DateFormatter.jobs_fullPrinter()
     print(f.format(Date()))

     // 2) ISO8601 毫秒
     let iso = DateFormatter.jobs_iso8601Millis()
     let s = iso.format(Date())
     let d = iso.parse(s)

     // 3) UI 本地化
     let uiFmt = DateFormatter.jobs_localizedYMD()
     label.text = uiFmt.format(Date())
 */
public extension DateFormatter {
    /// “尽可能最全”的打印器：yyyy-MM-dd HH:mm:ss.SSS Z（完整时区）(区域名) 星期 纪元
    // MARK: - 用于日志，不建议把字符串入库
    static func jobs_fullPrinter(
        locale: Locale = Locale(identifier: "zh_CN"),
        timeZone: TimeZone = .current,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> DateFormatter {
        DateFormatter()
            .byCalendar(calendar)
            .byLocale(locale)
            .byTimeZone(timeZone)
            .byDateFormat("yyyy-MM-dd HH:mm:ss.SSS ZZZZZ (VV) EEEE G")
    }
    // MARK: - ISO8601（带毫秒，时区 Z/±hh:mm）
    static func jobs_iso8601Millis() -> DateFormatter {
        DateFormatter()
            .byLocale(Locale(identifier: "en_US_POSIX"))
            .byTimeZone(TimeZone(secondsFromGMT: 0)!)
            .byDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX")
    }
    // MARK: - RFC3339（常见后端日志/接口）
    static func jobs_rfc3339() -> DateFormatter {
        DateFormatter()
            .byLocale(Locale(identifier: "en_US_POSIX"))
            .byTimeZone(TimeZone(secondsFromGMT: 0)!)
            .byDateFormat("yyyy-MM-dd'T'HH:mm:ssXXXXX")
    }
    // MARK: - 本地化模板：按地区自动排布年月日（适合 UI 展示）
    static func jobs_localizedYMD(
        locale: Locale = .current
    ) -> DateFormatter {
        DateFormatter()
            .byLocale(locale)
            .byLocalizedTemplate("yMd") // 例如 en_US -> 1/2/2025, zh_CN -> 2025/1/2
    }
}
