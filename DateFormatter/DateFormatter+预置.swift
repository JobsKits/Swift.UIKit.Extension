//
//  DateFormatter+预置.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
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
