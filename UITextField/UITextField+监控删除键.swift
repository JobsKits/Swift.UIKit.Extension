//
//  UITextField+监控删除键.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
// MARK: ⚙️ 一次性开启 deleteBackward 广播
public extension UITextField {
    /// 只在首次加载时执行一次
    private static let _swizzleDeleteBackwardImplementation: Void = {
        let cls: AnyClass = UITextField.self

        let originalSelector = #selector(UITextField.deleteBackward)
        let swizzledSelector = #selector(UITextField._rx_swizzled_deleteBackward)

        guard
            let originalMethod = class_getInstanceMethod(cls, originalSelector),
            let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
        else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()
    /// 触发静态属性以完成 swizzle（App 生命周期里找个合适地方触发一次即可）
    /// 必须调用一次，否则 swizzle 不生效
    /// 一旦调用，全局所有 UITextField 都支持删除监听
    static func enableDeleteBackwardBroadcast() {
        _ = self._swizzleDeleteBackwardImplementation
    }
    /// 被交换后的实现：先调用原始实现，再发通知
    @objc private func _rx_swizzled_deleteBackward() {
        // 调用原始 deleteBackward（交换后原始实现映射到此方法名）
        self._rx_swizzled_deleteBackward()
        // 广播删除事件（object 带上当前 textField）
        NotificationCenter.default.post(
            name: UITextField.didPressTextFieldDeleteNotification,
            object: self,
            userInfo: nil
        )
    }
}
