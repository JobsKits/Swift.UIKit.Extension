//
//  NSObject.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/15.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import ObjectiveC.runtime
import RxSwift

#if canImport(JobsSwiftBaseDefines)
import JobsSwiftBaseDefines
#endif

extension NSObject: JobsAsyncable {}
extension NSObject: Then {}
/// ✅ 用 UInt8 就不会有警告
/// Swift 的 &nameKey 现在是 UnsafeRawPointer 类型的地址，但 nameKey 是个简单的整数（UInt8），不会暴露复杂类型（如 String、NSObject）的内部内存结构，因此不会触发 Swift 的类型安全警告。
/// 这是 Apple 官方推荐的方式之一。
// MARK: -
private var nameKey: UInt8 = 0
extension NSObject {
    var nickname: String {
        get {
            return objc_getAssociatedObject(self, &nameKey) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &nameKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    func greet() {
        print("👋 Hello, my name is \(nickname)")
    }
}

extension NSObject {
    /// 类名 -> 字符串
    public var className: String {
        return type(of: self).className
    }
    /// 枚举 -> 类名
    public static var className: String {
        return String(describing: self)
    }

    func py_description() -> String {
        var output = ""
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            output = String(data: data, encoding: .utf8) ?? ""
            output = output.replacingOccurrences(of: "\\/", with: "/") // 处理\/转义字符
        } catch {

        };return output
    }
}
