//
//  UITextField.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

import ObjectiveC
import ObjectiveC.runtime

import RxSwift
import RxCocoa
import NSObject_Rx

#if canImport(JobsSwiftBaseTools)
import JobsSwiftBaseTools
#endif

public enum JobsTFKeys {
    static var limitBag = UInt8(0)                // 专用 DisposeBag
    static var textInputActive = UInt8(0)
    static var limitLastText: UInt8 = 0           // 最近一次合法文本
    static var limitCallback: UInt8 = 0           // 超长回调
    static var limitIsLimited: UInt8 = 0          // 当前是否处于“被限长”状态
    // ↓↓↓ 新增 3 个 AO Key
    static var onChangeBlock = UInt8(0)
    static var onChangeIncludeMarked = UInt8(0)
    static var previousText = UInt8(0)
}
// MARK: 🧱组件模型：RxTextInput：一个输入框的“响应式视图模型”，把常用流打包给
public struct RxTextInput {
    /// 原始文本（可选）与非可选文本（orEmpty）
    public let text: Observable<String?>
    public let textOrEmpty: Observable<String>
    /// 去首尾空格
    public let trimmed: Observable<String>
    /// 是否正在编辑
    public let isEditing: Observable<Bool>
    /// 删除键事件 / 回车事件
    public let didPressDelete: Observable<Void>
    public let didPressReturn: Observable<Void>
    /// 实时有效性（基于 validator）。每当输入框内容变化，就会根据传入的 validator 校验规则动态发出 true 或 false。
    public let isValid: Observable<Bool>
    /// 将“格式化后的文本”回写到 textField（避免光标跳动做了节制）
    public let formattedBinder: Binder<String>
}
/**
     passwordTextField.isSecureTextEntry = true

     @IBAction func toggleEyeButtonTapped(_ sender: UIButton) {
         passwordTextField.isSecureTextEntry.toggle()
         passwordTextField.togglePasswordVisibility()
     }
 */
// MARK: 用于在切换 isSecureTextEntry（明文/密文）后，修复 iOS 的文字丢失、光标闪烁和位置偏移问题，确保切换显示稳定、内容不丢失、光标正常。
public extension UITextField {
    func togglePasswordVisibility() {
        /// 临时去掉光标颜色（防止闪烁）
        let existingTintColor = tintColor
        tintColor = .clear
        /// 修复 iOS 的文字丢失 bug
        /// Bug 背景：当把 isSecureTextEntry 从 false 改回 true 时，如果用户光标不在最后、继续输入新字，系统会直接清空原有文字（奇怪的行为）。
        /// 修复思路：先删掉当前内容；再用 replace() 写回去；这样系统会重新渲染文字，但不会清空输入
        if let existingText = text, isSecureTextEntry {
            deleteBackward()
            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                replace(textRange, withText: existingText)
            }
        }
        /// 因为切换 secure 模式时，字体宽度变了（圆点 ● 的宽度不同于明文字体），所以光标位置可能偏移。
        /// 做法是：暂时清空 selectedTextRange，再设置回去（强制让系统重新计算光标位置）
        if let existingSelectedTextRange = selectedTextRange {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }
        ///恢复光标颜色
        self.tintColor = existingTintColor
    }
}

public extension UITextField {
    /// 通知名：当任意 UITextField 发生 deleteBackward 时派发（object = 当前 textField）
    static let didPressTextFieldDeleteNotification = Notification.Name("UITextField.didPressDelete")
}
