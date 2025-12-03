//
//  Optional.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/1/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
import CoreGraphics
#if canImport(JobsSwiftBaseDefines)
import JobsSwiftBaseDefines
#endif
// MARK: - 标准库：纯值与集合
extension String: SafeUnwrappedInitializable {}
extension Bool: SafeUnwrappedInitializable {}

extension Int: SafeUnwrappedInitializable {}
extension Int8: SafeUnwrappedInitializable {}
extension Int16: SafeUnwrappedInitializable {}
extension Int32: SafeUnwrappedInitializable {}
extension Int64: SafeUnwrappedInitializable {}

extension UInt: SafeUnwrappedInitializable {}
extension UInt8: SafeUnwrappedInitializable {}
extension UInt16: SafeUnwrappedInitializable {}
extension UInt32: SafeUnwrappedInitializable {}
extension UInt64: SafeUnwrappedInitializable {}

extension Double: SafeUnwrappedInitializable {}
extension Float: SafeUnwrappedInitializable {}

extension Array: SafeUnwrappedInitializable {}
extension Dictionary: SafeUnwrappedInitializable {}
extension Set: SafeUnwrappedInitializable {}
// MARK: - CoreGraphics 结构体
extension CGPoint: SafeUnwrappedInitializable {}
extension CGSize: SafeUnwrappedInitializable {}
extension CGRect: SafeUnwrappedInitializable {}
extension CGVector: SafeUnwrappedInitializable {}
extension CGAffineTransform: SafeUnwrappedInitializable {}
// MARK: - UIKit/SwiftUI 常用结构体（非 UI 类）
extension UIEdgeInsets: SafeUnwrappedInitializable {}
extension UIOffset: SafeUnwrappedInitializable {}
@available(iOS 11.0, *)
extension NSDirectionalEdgeInsets: SafeUnwrappedInitializable {}
// MARK: - Foundation 常用值类型
extension Data: SafeUnwrappedInitializable {}
extension Date: SafeUnwrappedInitializable {}
extension Decimal: SafeUnwrappedInitializable {}
extension DateComponents: SafeUnwrappedInitializable {
    public init() {
        self.init(calendar: nil,
                  timeZone: nil,
                  era: nil,
                  year: nil,
                  month: nil,
                  day: nil,
                  hour: nil,
                  minute: nil,
                  second: nil,
                  nanosecond: nil,
                  weekday: nil,
                  weekdayOrdinal: nil,
                  quarter: nil,
                  weekOfMonth: nil,
                  weekOfYear: nil,
                  yearForWeekOfYear: nil)
    }
}
extension IndexSet: SafeUnwrappedInitializable {}
extension CharacterSet: SafeUnwrappedInitializable {}
// 如需：NSAttributedString/AttributedString 也可打开（它们有空 init）
extension NSAttributedString: SafeUnwrappedInitializable {}
@available(iOS 15.0, *)
extension AttributedString: SafeUnwrappedInitializable {}
// MARK: - 通用 safelyUnwrapped：给“允许兜底构造”的类型使用
extension Optional where Wrapped: SafeUnwrappedInitializable {
    func safelyUnwrapped(_ defaultValue: Wrapped? = nil) -> Wrapped {
        self ?? (defaultValue ?? Wrapped())
    }
}
// MARK: - UI 类禁用（编译期直接报错；与上面通用版互不影响）
extension UIViewController: _UISafeUnwrappedBan {}
extension UIView: _UISafeUnwrappedBan {}
extension UIImage: _UISafeUnwrappedBan {}
extension UIColor: _UISafeUnwrappedBan {}

extension Optional where Wrapped: _UISafeUnwrappedBan {
    @available(*, unavailable, message: "🚫 UI 类型禁止使用 safelyUnwrapped()，请显式处理 nil 或提供业务兜底。")
    func safelyUnwrapped(_ defaultValue: Wrapped? = nil) -> Wrapped { fatalError() }
}
