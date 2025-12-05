//
//  UITextField+监控输入.swift
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

import RxSwift
import RxCocoa
import NSObject_Rx
// MARK: - 🔔 Block 监听（挂在 UITextField）


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
