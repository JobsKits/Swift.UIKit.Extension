//
//  UITextField+Rx.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/2/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

import ObjectiveC

import RxSwift
import RxCocoa
import NSObject_Rx
// MARK: 键盘按键行为监听
public extension Reactive where Base: UITextField {
    /// 每次按下删除键都会触发（空文本时也会触发）
    var didPressDelete: ControlEvent<Void> {
        ControlEvent(events: NotificationCenter.default.rx
            .notification(UITextField.didPressTextFieldDeleteNotification, object: base)
            .map { _ in () })
    }
    /// Return（editingDidEndOnExit）
    var didPressReturn: ControlEvent<Void> {
        controlEvent(.editingDidEndOnExit)
    }
    /// 开始/结束编辑
    var didBeginEditing: ControlEvent<Void> { controlEvent(.editingDidBegin) }
    var didEndEditing:   ControlEvent<Void> { controlEvent(.editingDidEnd)   }
}
/**
    | 输入序列                                    | distinct = true 是否回调                          |
    | ----------------------------------- | --------------------------------------------- |
    | "" → "A"                                    | ✅ 触发                                                   |
    | "A" → "AB"                               | ✅ 触发                                                   |
    | "AB" → "ABC"                          | ✅ 触发                                                    |
    | "A" → "A"（程序重复设同值） | ❌ 不触发                                                |
    | "A " →（trim 后是 "A"）           | trimmed/isValid 可能 ❌（修剪后没变） |
*/
// MARK: 🧠 规则模型：RxTextInput
// MARK: - 一体化模型（Reactive）
public extension Reactive where Base: UITextField {
    /// 与 `byLimitLength(_:)` 互斥：本方法会标记当前 TextField 已启用 textInput
    func textInput(
        maxLength: Int? = nil,                                 // 最大长度
        formatter: ((String) -> String)? = nil,                // 文本格式化（如 uppercased、trim 等）
        validator: @escaping (String) -> Bool = { _ in true }, // 校验规则（返回 true/false）
        distinct: Bool = true                                  // 输出去重
    ) -> RxTextInput {
        // ✅ 标记：该 TextField 已启用 textInput（供 byLimitLength 等功能做互斥判断）
        objc_setAssociatedObject(base,
                                 &JobsTFKeys.textInputActive,
                                 true,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        /// 基础源
        let rawText     = base.rx.text.asObservable()               // String?
        let textOrEmpty = base.rx.text.orEmpty.asObservable()       // String
        let trimmed     = textOrEmpty.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        /// 编辑态
        let began    = base.rx.didBeginEditing.map { true }.asObservable()
        let ended    = base.rx.didEndEditing  .map { false }.asObservable()
        let isEditing = Observable.merge(began, ended)
            .startWith(base.isFirstResponder)
        /// 删除 / 回车
        let deleteEvt = base.rx.didPressDelete.asObservable()
        let returnEvt = base.rx.didPressReturn.asObservable()
        /// 组合处理器：先 formatter 再 maxLength（按 Character 截断，避免拆 emoji/合成字符）
        let process: (String) -> String = { [weak base] input in
            // 1) 正在组字（中文/日文等 IME），直接放行
            if let tf = base, tf.markedTextRange != nil { return input }

            var s = input
            if let f = formatter { s = f(s) }
            if let m = maxLength, s.count > m {
                s = String(s.prefix(m))
            };return s
        }
        /// 仅在需要改写时回写，避免光标跳跃
        _ = textOrEmpty
            .map(process)
            .withLatestFrom(textOrEmpty) { processed, original in (processed, original) }
            .filter { $0.0 != $0.1 }
            .map { $0.0 }
            .observe(on: MainScheduler.instance)
            .take(until: base.rx.deallocated)                 // 绑定到 textField 生命周期
            .bind(to: base.rx.text)
        /// 有效性
        let validity = trimmed
            .map(validator)
            .distinctUntilChanged()
        /// 外部“强制回写”的 Binder
        let formattedBinder = Binder<String>(base) { tf, value in
            if tf.markedTextRange != nil { return }          // IME 保护
            let v = process(value)
            if tf.text != v { tf.text = v }
        }
        /// 输出去重策略
        let textOut: Observable<String?>       = distinct ? rawText.distinctUntilChanged { ($0 ?? "") == ($1 ?? "") } : rawText
        let textOrEmptyOut: Observable<String> = distinct ? textOrEmpty.distinctUntilChanged() : textOrEmpty
        let trimmedOut: Observable<String>     = distinct ? trimmed.distinctUntilChanged() : trimmed

        return RxTextInput(
            text: textOut,
            textOrEmpty: textOrEmptyOut,
            trimmed: trimmedOut,
            isEditing: isEditing.distinctUntilChanged(),
            didPressDelete: deleteEvt,
            didPressReturn: returnEvt,
            isValid: validity,
            formattedBinder: formattedBinder
        )
    }
}
// MARK: 🔁 双向绑定辅助
public extension Reactive where Base: UITextField {
    /// 把一个 BehaviorRelay<String> 与 UITextField 双向绑定
    /// - 注意：会自动去重，避免循环回写
    func bindTwoWay(_ relay: BehaviorRelay<String>) -> Disposable {
        return Disposables.create(
            self.text.orEmpty
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(onNext: { relay.accept($0) }),
            relay
                .distinctUntilChanged()
                .observe(on: MainScheduler.instance)
                .bind(to: self.text)
        )
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
        rx.textInput(maxLength: maxLength,
                            formatter: formatter,
                            validator: validator ?? { _ in true },
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
