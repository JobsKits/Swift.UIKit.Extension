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
/// 限长状态变化时的回调
/// isLimited = true  : 进入“被限长”状态（尝试超出时被拦截）
/// isLimited = false : 从“被限长”状态恢复（删到 maxLength 以下）
public typealias JobsTFOnLimitChanged = (_ isLimited: Bool, _ textField: UITextField) -> Void
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
// MARK: ✏️ UITextField 链式配置
public extension UITextField {
    // MARK: 🌸 基础文本属性
    @discardableResult
    func byPlaceholder(_ placeholder: String?) -> Self {
        self.placeholder = placeholder
        return self
    }

    @discardableResult
    func byText(_ text: String?) -> Self {
        self.text = text
        return self
    }

    @discardableResult
    func byTextColor(_ color: UIColor?) -> Self {
        self.textColor = color
        return self
    }

    @discardableResult
    func byFont(_ font: UIFont?) -> Self {
        self.font = font
        return self
    }

    @discardableResult
    func byTextAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }

    @discardableResult
    func byBorderStyle(_ style: UITextField.BorderStyle) -> Self {
        self.borderStyle = style
        return self
    }
    // MARK: 🧱 占位/背景样式
    @available(iOS 6.0, *)
    @discardableResult
    func byAttributedText(_ attributedText: NSAttributedString?) -> Self {
        self.attributedText = attributedText
        return self
    }

    @available(iOS 6.0, *)
    @discardableResult
    func byAttributedPlaceholder(_ attributedPlaceholder: NSAttributedString?) -> Self {
        self.attributedPlaceholder = attributedPlaceholder
        return self
    }

    @discardableResult
    func byBackground(_ image: UIImage?) -> Self {
        self.background = image
        return self
    }

    @discardableResult
    func byDisabledBackground(_ image: UIImage?) -> Self {
        self.disabledBackground = image
        return self
    }
    // MARK: 🧠 输入控制行为
    @discardableResult
    func byClearsOnBeginEditing(_ clears: Bool) -> Self {
        self.clearsOnBeginEditing = clears
        return self
    }

    @discardableResult
    func byClearsOnInsertion(_ clears: Bool) -> Self {
        self.clearsOnInsertion = clears
        return self
    }

    @discardableResult
    func byAdjustsFontSizeToFitWidth(_ adjusts: Bool) -> Self {
        self.adjustsFontSizeToFitWidth = adjusts
        return self
    }

    @discardableResult
    func byMinimumFontSize(_ size: CGFloat) -> Self {
        self.minimumFontSize = size
        return self
    }

    @discardableResult
    func bySecureTextEntry(_ secure: Bool) -> Self {
        self.isSecureTextEntry = secure
        return self
    }
    // MARK: ⌨️ 键盘行为
    @discardableResult
    func byKeyboardType(_ type: UIKeyboardType) -> Self {
        self.keyboardType = type
        return self
    }

    @discardableResult
    func byKeyboardAppearance(_ appearance: UIKeyboardAppearance) -> Self {
        self.keyboardAppearance = appearance
        return self
    }

    @discardableResult
    func byReturnKeyType(_ type: UIReturnKeyType) -> Self {
        self.returnKeyType = type
        return self
    }

    @discardableResult
    func byEnablesReturnKeyAutomatically(_ enabled: Bool) -> Self {
        self.enablesReturnKeyAutomatically = enabled
        return self
    }
    // MARK: 🧠 智能输入特性
    @discardableResult
    func byAutocapitalizationType(_ type: UITextAutocapitalizationType) -> Self {
        self.autocapitalizationType = type
        return self
    }

    @discardableResult
    func byAutocorrectionType(_ type: UITextAutocorrectionType) -> Self {
        self.autocorrectionType = type
        return self
    }

    @discardableResult
    func bySpellCheckingType(_ type: UITextSpellCheckingType) -> Self {
        self.spellCheckingType = type
        return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func bySmartQuotesType(_ type: UITextSmartQuotesType) -> Self {
        self.smartQuotesType = type
        return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func bySmartDashesType(_ type: UITextSmartDashesType) -> Self {
        self.smartDashesType = type
        return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func bySmartInsertDeleteType(_ type: UITextSmartInsertDeleteType) -> Self {
        self.smartInsertDeleteType = type
        return self
    }

    @available(iOS 17.0, *)
    @discardableResult
    func byInlinePredictionType(_ type: UITextInlinePredictionType) -> Self {
        self.inlinePredictionType = type
        return self
    }
    // MARK: 🧠 iOS 18+ 新特性
    @available(iOS 18.0, *)
    @discardableResult
    func byMathExpressionCompletionType(_ type: UITextMathExpressionCompletionType) -> Self {
        self.mathExpressionCompletionType = type
        return self
    }

    @available(iOS 18.0, *)
    @discardableResult
    func byWritingToolsBehavior(_ behavior: UIWritingToolsBehavior) -> Self {
        self.writingToolsBehavior = behavior
        return self
    }

    @available(iOS 18.0, *)
    @discardableResult
    func byAllowedWritingToolsResultOptions(_ options: UIWritingToolsResultOptions) -> Self {
        self.allowedWritingToolsResultOptions = options
        return self
    }
    // MARK: 🔠 内容类型 / 密码规则
    @discardableResult
    func byTextContentType(_ type: UITextContentType?) -> Self {
        self.textContentType = type
        return self
    }

    @available(iOS 12.0, *)
    @discardableResult
    func byPasswordRules(_ rules: UITextInputPasswordRules?) -> Self {
        self.passwordRules = rules
        return self
    }
    // MARK: 🎨 左右视图 / 清除按钮
    @discardableResult
    func byClearButtonMode(_ mode: UITextField.ViewMode) -> Self {
        self.clearButtonMode = mode
        return self
    }

    @discardableResult
    func byLeftView(_ view: UIView?, mode: UITextField.ViewMode = .always) -> Self {
        self.leftView = view
        self.leftViewMode = mode
        return self
    }

    @discardableResult
    func byRightView(_ view: UIView?, mode: UITextField.ViewMode = .always) -> Self {
        self.rightView = view
        self.rightViewMode = mode
        return self
    }

    @available(iOS 7.0, *)
    @discardableResult
    func byDefaultTextAttributes(_ attrs: [NSAttributedString.Key : Any]) -> Self {
        self.defaultTextAttributes = attrs
        return self
    }

    @available(iOS 6.0, *)
    @discardableResult
    func byAllowsEditingTextAttributes(_ allows: Bool) -> Self {
        self.allowsEditingTextAttributes = allows
        return self
    }

    @available(iOS 6.0, *)
    @discardableResult
    func byTypingAttributes(_ attrs: [NSAttributedString.Key : Any]?) -> Self {
        self.typingAttributes = attrs
        return self
    }

    @discardableResult
    func byInputView(_ view: UIView?) -> Self {
        self.inputView = view
        return self
    }

    @discardableResult
    func byInputAccessoryView(_ view: UIView?) -> Self {
        self.inputAccessoryView = view
        return self
    }
    // ⚠️ delegate 弱引用属性：仅便捷设置，别强持有
    @discardableResult
    func byDelegate(_ delegate: UITextFieldDelegate?) -> Self {
        self.delegate = delegate
        return self
    }

    @available(iOS 10.0, *)
    @discardableResult
    func byDynamicTextStyle(_ style: UIFont.TextStyle) -> Self {
        self.font = .preferredFont(forTextStyle: style)
        self.adjustsFontForContentSizeCategory = true
        return self
    }
    /// 链式监听“发送/回车”键
    @discardableResult
    func onReturn(_ handler: @escaping (UITextField) -> Void) -> Self {
        let wrapper = UIAction { [weak self] _ in
            guard let self = self else { return }; handler(self)
        }
        addAction(wrapper, for: .editingDidEndOnExit)
        return self
    }
}
// MARK: - 左侧图标 & 纯留白
public extension UITextField {
    /// 设置左侧图标，并精确控制：leading（到边距）和 spacing（到文字）
    @discardableResult
    func byLeftIcon(
        _ image: UIImage?,
        tint: UIColor? = nil,
        size: CGSize = .init(width: 18, height: 18),
        leading: CGFloat = 12,      // 图标距 TextField 左边缘
        spacing: CGFloat = 8        // 图标与文字之间
    ) -> Self {
        guard let image else {
            leftView = nil
            leftViewMode = .never
            return self
        }

        let containerW = leading + size.width + spacing
        let containerH = max(24, size.height)    // 高度随便给，系统会垂直居中
        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerW, height: containerH))

        self.byLeftView(container.byAddSubviewRetSuper(UIImageView().byImage(tint == nil ? image : image.withRenderingMode(.alwaysTemplate))
            .byTintColor(tint)
            .byContentMode(.scaleAspectFit)
            .byFrame(CGRect(origin: .zero, size: size))
             // 把图标放到带 leading 的位置
            .byCenter(CGPoint(x: leading + size.width / 2, y: container.bounds.midY))
            .byAutoresizingMask([.flexibleTopMargin, .flexibleBottomMargin])),mode:.always)

        return self
    }
    /// 仅设置左侧留白（没有图标），常用于单纯增加文本左内边距
    @discardableResult
    func byLeftPadding(_ padding: CGFloat) -> Self {
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 1))
        spacer.isUserInteractionEnabled = false
        leftView = spacer
        leftViewMode = .always
        return self
    }
}
// MARK: ⚙️ 一次性开启 deleteBackward 广播
public extension UITextField {
    /// 通知名：当任意 UITextField 发生 deleteBackward 时派发（object = 当前 textField）
    static let didPressDeleteNotification = Notification.Name("UITextField.didPressDelete")
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
            name: UITextField.didPressDeleteNotification,
            object: self,
            userInfo: nil
        )
    }
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
// MARK: 限制输入框最大长度（最大长度和最大长度回退的时候回调）
public extension UITextField {
    /// 仅做“纯限长”；与 textInput 互斥。
    ///
    /// - Parameters:
    ///   - maxLength: 最大允许长度（按 Character 计，避免拆 emoji）
    ///   - onLimitChanged:
    ///       - isLimited: 是否处于“被限长”状态
    ///       - textField: 当前输入框
    ///
    /// 触发时机：
    ///   1. false -> true：第一次尝试超过 maxLength 被拦截
    ///   2. true  -> false：从满格状态删到 maxLength 以下
    @discardableResult
    func byLimitLength(_ maxLength: Int,
                       onLimitChanged: JobsTFOnLimitChanged? = nil) -> Self {
        guard maxLength > 0 else { return self }
        // 若已启用 textInput，则跳过（避免双向回写冲突）
        if (objc_getAssociatedObject(self, &JobsTFKeys.textInputActive) as? Bool) == true {
            #if DEBUG
            print("⚠️ byLimitLength 与 textInput 互斥：已启用 textInput，忽略限长。")
            #endif
            return self
        }
        // 记录回调
        if let onLimitChanged {
            objc_setAssociatedObject(self,
                                     &JobsTFKeys.limitCallback,
                                     onLimitChanged,
                                     .OBJC_ASSOCIATION_COPY_NONATOMIC)
        } else {
            objc_setAssociatedObject(self,
                                     &JobsTFKeys.limitCallback,
                                     nil,
                                     .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        // 为当前 textField 挂一个专用 DisposeBag（重复调用会覆盖旧订阅）
        let bag = DisposeBag()
        objc_setAssociatedObject(self,
                                 &JobsTFKeys.limitBag,
                                 bag,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        // 初始化“最近一次合法文本”：保证不 > maxLength
        var initialText = self.text ?? ""
        if initialText.count > maxLength {
            initialText = String(initialText.prefix(maxLength))
            self.text = initialText
        }
        objc_setAssociatedObject(self,
                                 &JobsTFKeys.limitLastText,
                                 initialText,
                                 .OBJC_ASSOCIATION_COPY_NONATOMIC)
        // 初始时默认认为“未被限长”
        objc_setAssociatedObject(self,
                                 &JobsTFKeys.limitIsLimited,
                                 false,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        // 监听文本变化
        rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] newText in
                guard let self = self else { return }

                // 有高亮（中文/日文 IME 组字中）时不做限制
                if let range = self.markedTextRange,
                   self.position(from: range.start, offset: 0) != nil {
                    return
                }

                let maxLen = maxLength
                let callback = objc_getAssociatedObject(self,
                                                        &JobsTFKeys.limitCallback) as? JobsTFOnLimitChanged
                let wasLimited =
                    (objc_getAssociatedObject(self, &JobsTFKeys.limitIsLimited) as? Bool) ?? false

                var processed = newText

                if newText.count > maxLen {
                    // ❌ 尝试超出：裁剪到 maxLength，进入“被限长”状态
                    processed = String(newText.prefix(maxLen))

                    if processed != self.text {
                        self.text = processed
                    }

                    objc_setAssociatedObject(self,
                                             &JobsTFKeys.limitLastText,
                                             processed,
                                             .OBJC_ASSOCIATION_COPY_NONATOMIC)

                    if wasLimited == false {
                        // false -> true：第一次触发限长
                        objc_setAssociatedObject(self,
                                                 &JobsTFKeys.limitIsLimited,
                                                 true,
                                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                        callback?(true, self)
                    }
                    // 已经是 true 再次乱按键，不重复回调
                } else {
                    // ✅ 在 maxLength 以内，更新合法文本
                    objc_setAssociatedObject(self,
                                             &JobsTFKeys.limitLastText,
                                             processed,
                                             .OBJC_ASSOCIATION_COPY_NONATOMIC)

                    let isNowLimited: Bool
                    if processed.count < maxLen {
                        // 长度 < maxLength 必然不在“被限长”
                        isNowLimited = false
                    } else {
                        // processed.count == maxLen
                        // 是否把“刚好等于 maxLength”也当作 limited，看需求；
                        // 这里按“只有出现过超长拦截才算 limited”来处理：
                        isNowLimited = wasLimited
                    }

                    if wasLimited == true && isNowLimited == false {
                        // true -> false：从“被限长”状态删回来了
                        objc_setAssociatedObject(self,
                                                 &JobsTFKeys.limitIsLimited,
                                                 false,
                                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                        callback?(false, self)
                    } else {
                        objc_setAssociatedObject(self,
                                                 &JobsTFKeys.limitIsLimited,
                                                 isNowLimited,
                                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    }
                }
            })
            .disposed(by: bag)
        return self
    }
    /// 兼容你原来只有 maxLength 的老签名（不关心回调就用这个）
    @discardableResult
    func byLimitLength(_ maxLength: Int) -> Self {
        byLimitLength(maxLength, onLimitChanged: nil)
    }
}

// MARK: - Rx 快捷桥接（去掉 .rx,给 UITextField 直接用）
public extension UITextField {
    /// 删除键事件（等价 rx.didPressDelete）
    var didPressDelete: ControlEvent<Void> { rx.didPressDelete }
    /// Return 键事件
    var didPressReturn: ControlEvent<Void> { rx.didPressReturn }
    /// 开始/结束编辑
    var didBeginEditingEvent: ControlEvent<Void> { rx.didBeginEditing }
    var didEndEditingEvent:   ControlEvent<Void> { rx.didEndEditing }
    /// 一体化输入模型（等价 rx.textInput(...)）
    @discardableResult
    func textInput(
        maxLength: Int? = nil,
        formatter: ((String) -> String)? = nil,
        validator: ((String) -> Bool)? = nil,
        distinct: Bool = true
    ) -> RxTextInput {
        let v = validator ?? { _ in true }
        return rx.textInput(maxLength: maxLength,
                            formatter: formatter,
                            validator: v,
                            distinct: distinct)
    }
    /// 文本流（等价于 rx.text.orEmpty.asObservable()）
    var textStream: Observable<String> {
        rx.text.orEmpty.asObservable()
    }
    /// 便捷监听（自动 distinct）
    @discardableResult
    func onText(_ handler: @escaping (String) -> Void) -> Disposable {
        rx.text.orEmpty
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: handler)
    }
}
// MARK: - 设置富文本（UITextField）
public extension UITextField {
    func richTextBy(_ runs: [JobsRichRun], paragraphStyle: NSMutableParagraphStyle? = nil) {
        self.attributedText = JobsRichText.make(runs, paragraphStyle: paragraphStyle)
    }
}
// MARK: - 🔔 Block 监听（挂在 UITextField）
public typealias UITextFieldOnChange = (_ tf: UITextField,
                                        _ input: String,
                                        _ oldText: String,
                                        _ isDeleting: Bool) -> Void

private extension UITextField {
    var _jobs_onChangeBlock: UITextFieldOnChange? {
        get { objc_getAssociatedObject(self, &JobsTFKeys.onChangeBlock) as? UITextFieldOnChange }
        set { objc_setAssociatedObject(self, &JobsTFKeys.onChangeBlock, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    var _jobs_includeMarked: Bool {
        get { (objc_getAssociatedObject(self, &JobsTFKeys.onChangeIncludeMarked) as? NSNumber)?.boolValue ?? false }
        set { objc_setAssociatedObject(self, &JobsTFKeys.onChangeIncludeMarked, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    var _jobs_previousText: String {
        get { (objc_getAssociatedObject(self, &JobsTFKeys.previousText) as? String) ?? (self.text ?? "") }
        set { objc_setAssociatedObject(self, &JobsTFKeys.previousText, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    @objc func _jobs_handleEditingChanged() {
        // 中文/日文等 IME 组字阶段默认忽略（可通过 includeMarked 开启）
        if !_jobs_includeMarked, self.markedTextRange != nil { return }

        let old = _jobs_previousText
        let cur = self.text ?? ""
        let isDeleting = cur.count < old.count

        let input: String
        if isDeleting {
            input = ""
        } else if cur.hasPrefix(old) {
            input = String(cur.dropFirst(old.count))
        } else {
            // 粘贴/替换整段等情况，直接视为整段输入
            input = cur
        }

        _jobs_onChangeBlock?(self, input, old, isDeleting)
        _jobs_previousText = cur
    }
}

public extension UITextField {
    /// 链式注册：与 Alert 版回调语义保持一致 (input/old/isDeleting)
    /// - includeMarked: 是否包含 IME 组字过程（默认 false 更稳）
    @discardableResult
    func onChange(includeMarked: Bool = false,
                  _ handler: @escaping UITextFieldOnChange) -> Self {
        _jobs_onChangeBlock = handler
        _jobs_includeMarked = includeMarked
        _jobs_previousText = self.text ?? ""
        // 重复调用会复用同一个 selector；iOS 会去重，不会叠加多次触发
        addTarget(self, action: #selector(_jobs_handleEditingChanged), for: .editingChanged)
        return self
    }
    /// 取消监听（可选）
    @discardableResult
    func removeOnChange() -> Self {
        removeTarget(self, action: #selector(_jobs_handleEditingChanged), for: .editingChanged)
        _jobs_onChangeBlock = nil
        return self
    }
}
