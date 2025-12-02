//
//  UITextView+校验.swift
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

import RxSwift
import RxCocoa
import RxRelay

public enum TwoWayInitial {
    case fromRelay   // 默认：用 relay 覆盖 view
    case fromView    // 用 view 的当前值覆盖 relay
}
// MARK: 🧱 组件模型（UITextView 版）
public struct RxTextViewInput {
    public let text: Observable<String?>
    public let textOrEmpty: Observable<String>
    public let trimmed: Observable<String>

    public let isEditing: Observable<Bool>
    public let didPressDelete: Observable<Void>
    public let didChange: ControlEvent<Void> // 文本变化事件

    public let isValid: Observable<Bool>
    public let formattedBinder: Binder<String>
}
// MARK: - Rx 快捷桥接（去掉 .rx,给 UITextView 直接用）
public extension UITextView {
    // MARK: 通用输入绑定：带格式化 / 校验 / 最大长度 / 去重
    func textInput(
        maxLength: Int? = nil,
        formatter: ((String) -> String)? = nil,
        validator: @escaping (String) -> Bool = { _ in true },
        distinct: Bool = true
    ) -> Observable<String> {
        // 1) 基础流：去首尾空白、格式化、截断并回写 UI
        var stream = rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { [weak self] raw -> String in
                guard let self else { return raw }
                // IME 组合输入期间（中文/日文拼写）不要强行改 text，避免光标跳动
                if markedTextRange != nil { return raw }

                var formatted = formatter?(raw) ?? raw

                if let max = maxLength, formatted.count > max {
                    formatted = String(formatted.prefix(max))
                }

                if text != formatted {
                    // 保留光标位置的写法（尽量减少跳动）
                    let selected = selectedRange
                    text = formatted
                    selectedRange = selected
                };return formatted
            }
        // 2) 按需去重
        if distinct {
            stream = stream.distinctUntilChanged()
        };return stream.filter { validator($0) }// 3) 过滤非法值
    }
    // MARK: 双向绑定：TextView <-> BehaviorRelay<String>
    /// - Parameter relay: 行为Relay
    /// - Returns: Disposable（用于释放绑定）
    @discardableResult
    func bindTwoWay(_ relay: BehaviorRelay<String>, initial: TwoWayInitial = .fromRelay) -> Disposable {
        // 初始同步
        switch initial {
        case .fromRelay:
            if text != relay.value { text = relay.value }
        case .fromView:
            relay.accept(text ?? "")
        };return Disposables.create(
            // View → Relay
            rx.text.orEmpty
            .distinctUntilChanged()
            .bind(onNext: { relay.accept($0) }),
            // Relay → View
            relay.asDriver()
                .distinctUntilChanged()
                .drive(rx.text)
        )
    }

    var didPressDelete: Observable<Void> {
        rx.didPressDelete.asObservable()
    }
}

public extension UITextView {
    /// 通用输入绑定：带格式化 / 校验 / 最大长度 / 去重
    /// 返回 TextInputStream，支持 .isValid()
    func textInput(
        maxLength: Int? = nil,
        formatter: ((String) -> String)? = nil,
        validator: @escaping (String) -> Bool = { _ in true },
        distinct: Bool = true,
        equals: ((String, String) -> Bool)? = nil   // 自定义去重比较（可选）
    ) -> TextInputStream {

        var stream = rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { [weak self] raw -> String in
                guard let self else { return raw }
                // 组合输入阶段（中文/日文等 IME）不要强行改 text，避免光标跳动
                if markedTextRange != nil { return raw }

                var formatted = formatter?(raw) ?? raw

                if let max = maxLength, formatted.count > max {
                    formatted = String(formatted.prefix(max))
                }

                if text != formatted {
                    let sel = selectedRange
                    text = formatted
                    selectedRange = sel
                };return formatted
            }

        if distinct {
            if let eq = equals {
                stream = stream.distinctUntilChanged(eq)
            } else {
                stream = stream.distinctUntilChanged()
            }
        };return TextInputStream(source: stream, validator: validator)
    }
}
