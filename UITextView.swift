//
//  UITextView.swift
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
import RxSwift
import RxCocoa
import RxRelay
// MARK:  让返回值可继续接 Rx 操作符
public struct TextInputStream: ObservableConvertibleType {
    public typealias Element = String
    fileprivate let source: Observable<String>
    fileprivate let validator: (String) -> Bool
    public func asObservable() -> Observable<String> { source }
    public var isValid: Observable<Bool> { source.map(validator) }
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
// MARK:
public enum TwoWayInitial {
    case fromRelay   // 默认：用 relay 覆盖 view
    case fromView    // 用 view 的当前值覆盖 relay
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

public extension UITextView {
    // MARK:  文本基础属性
    @discardableResult
    func byText(_ string: String?) -> Self {
        text = string
        return self
    }

    @discardableResult
    func byTextColor(_ color: UIColor) -> Self {
        textColor = color
        return self
    }

    @discardableResult
    func byFont(_ f: UIFont) -> Self {
        font = f
        return self
    }

    @discardableResult
    func byTextAlignment(_ alignment: NSTextAlignment) -> Self {
        textAlignment = alignment
        return self
    }

    @discardableResult
    func byAttributedText(_ attrText: NSAttributedString) -> Self {
        attributedText = attrText
        return self
    }

    @discardableResult
    func byTypingAttributes(_ attrs: [NSAttributedString.Key: Any]) -> Self {
        typingAttributes = attrs
        return self
    }
    // MARK: 可编辑与交互
    @discardableResult
    func byEditable(_ editable: Bool) -> Self {
        isEditable = editable
        return self
    }

    @discardableResult
    func bySelectable(_ selectable: Bool) -> Self {
        isSelectable = selectable
        return self
    }

    @discardableResult
    func byDataDetectorTypes(_ types: UIDataDetectorTypes) -> Self {
        dataDetectorTypes = types
        return self
    }

    @discardableResult
    func byAllowsEditingTextAttributes(_ allow: Bool) -> Self {
        allowsEditingTextAttributes = allow
        return self
    }
    // MARK: 输入相关
    @discardableResult
    func byKeyboardType(_ type: UIKeyboardType) -> Self {
        keyboardType = type
        return self
    }

    @discardableResult
    func byInputView(_ view: UIView?) -> Self {
        inputView = view
        return self
    }

    @discardableResult
    func byInputAccessoryView(_ view: UIView?) -> Self {
        inputAccessoryView = view
        return self
    }

    @discardableResult
    func byClearsOnInsertion(_ clear: Bool) -> Self {
        clearsOnInsertion = clear
        return self
    }
    // MARK: 富文本与链接样式
    @discardableResult
    func byLinkTextAttributes(_ attrs: [NSAttributedString.Key: Any]) -> Self {
        linkTextAttributes = attrs
        return self
    }

    @discardableResult
    @available(iOS 13.0, *)
    func byUsesStandardTextScaling(_ enable: Bool) -> Self {
        usesStandardTextScaling = enable
        return self
    }
    // MARK: 布局与内边距
    @discardableResult
    func byTextContainerInset(_ inset: UIEdgeInsets) -> Self {
        textContainerInset = inset
        return self
    }
    // MARK: 滚动与范围
    @discardableResult
    func byScrollToVisible(range: NSRange) -> Self {
        scrollRangeToVisible(range)
        return self
    }
    // MARK: 查找功能 (iOS 16+)
    @available(iOS 16.0, *)
    @discardableResult
    func byFindInteractionEnabled(_ enable: Bool) -> Self {
        isFindInteractionEnabled = enable
        return self
    }
    // MARK: 边框样式 (iOS 17+)
    @available(iOS 17.0, *)
    @discardableResult
    func byBorderStyle(_ style: UITextView.BorderStyle) -> Self {
        borderStyle = style
        return self
    }
    // MARK: 高亮显示 (iOS 18+)
    @available(iOS 18.0, *)
    @discardableResult
    func byTextHighlightAttributes(_ attrs: [NSAttributedString.Key: Any]) -> Self {
        textHighlightAttributes = attrs
        return self
    }
    // MARK:  Writing Tools (iOS 18+)
    @available(iOS 18.0, *)
    @discardableResult
    func byWritingToolsBehavior(_ behavior: UIWritingToolsBehavior) -> Self {
        writingToolsBehavior = behavior
        return self
    }

    @available(iOS 18.0, *)
    @discardableResult
    func byAllowedWritingToolsResultOptions(_ options: UIWritingToolsResultOptions) -> Self {
        var safe = options
        // ⚠️ iOS 18.0 / 18.1 暂不支持 table（部分机型连 list 也不行）
        safe.remove(.table)
        // safe.remove(.list) // 如果遇到崩溃，再打开这一行
        allowedWritingToolsResultOptions = safe
        return self
    }
    // MARK: 富文本格式配置 (iOS 18+)
    @available(iOS 18.0, *)
    @discardableResult
    func byTextFormattingConfiguration(_ config: UITextFormattingViewController.Configuration) -> Self {
        textFormattingConfiguration = config
        return self
    }
    // MARK: 代理设置
    @discardableResult
    func byDelegate(_ textViewDelegate: UITextViewDelegate?) -> Self {
        delegate = textViewDelegate
        return self
    }
    @available(iOS 10.0, *)
    @discardableResult
    func byDynamicTextStyle(_ style: UIFont.TextStyle) -> Self {
        self.font = .preferredFont(forTextStyle: style)
        self.adjustsFontForContentSizeCategory = true
        return self
    }
}

public extension UITextView {
    // MARK: 统一的圆角边框样式（跨 iOS 版本）
    @discardableResult
    func byRoundedBorder(
        color: UIColor = .systemGray4,
        width: CGFloat = 1,
        radius: CGFloat = 8,
        background: UIColor? = nil
    ) -> Self {
        layer.byBorderColor(color)
            .byBorderWidth(width)
            .byCornerRadius(radius)
            .byMasksToBounds(true)
        if let bg = background { backgroundColor = bg }
        return self
    }
    // MARK: 类似“bezel”的外观（简易版）
    @discardableResult
    func byBezelLike(
        radius: CGFloat = 8
    ) -> Self {
        layer.byBorderColor(.separator)
            .byBorderWidth(1)
            .byCornerRadius(radius)
            .byMasksToBounds(true)
        byBgColor(.secondarySystemBackground)
        return self
    }
}
// MARK: ⚙️ deleteBackward 广播（UITextView）
public extension UITextView {
    static let didPressDeleteNotification = Notification.Name("UITextView.didPressDelete")
    private static let _swizzleOnce: Void = {
        let cls: AnyClass = UITextView.self
        let originalSel = #selector(UITextView.deleteBackward)
        let swizzledSel = #selector(UITextView._jobs_swizzled_deleteBackward)
        guard
            let ori = class_getInstanceMethod(cls, originalSel),
            let swz = class_getInstanceMethod(cls, swizzledSel)
        else { return }
        method_exchangeImplementations(ori, swz)
    }()
    /// 在 App 启动时调用一次（与 UITextField 的启用相互独立）
    static func enableDeleteBackwardBroadcast() {
        _ = _swizzleOnce
    }

    @objc private func _jobs_swizzled_deleteBackward() {
        _jobs_swizzled_deleteBackward()
        NotificationCenter.default.post(name: UITextView.didPressDeleteNotification, object: self)
    }
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
// MARK: 设置富文本
public extension UITextView {
    func richTextBy(_ runs: [JobsRichRun], paragraphStyle: NSMutableParagraphStyle? = nil) {
        attributedText = JobsRichText.make(runs, paragraphStyle: paragraphStyle)
        isEditable = false
        isScrollEnabled = false
        dataDetectorTypes = [] // 仅走自定义 link
    }
}
// MARK: - 私有代理（手势 + 命中计算）
public final class _LinkTapProxy: NSObject, UIGestureRecognizerDelegate {
    let relay = PublishRelay<URL>()
    @objc func handleTap(_ gr: UITapGestureRecognizer) {
        guard let tv = gr.view as? UITextView else { return }
        // 1) 将点击点转换到 textContainer 坐标，并考虑 inset
        let lm  = tv.layoutManager
        let tc  = tv.textContainer
        var pt  = gr.location(in: tv)
        pt.x   -= tv.textContainerInset.left
        pt.y   -= tv.textContainerInset.top
        // 2) glyph → char index
        let glyphIndex = lm.glyphIndex(for: pt, in: tc)
        let charIndex  = lm.characterIndexForGlyph(at: glyphIndex)
        guard charIndex < tv.attributedText.length else { return }
        // 3) 命中检测：点击必须落在该 glyph 的有效 rect 内（避免空白区域误触）
        var usedRect = lm.lineFragmentUsedRect(forGlyphAt: glyphIndex, effectiveRange: nil, withoutAdditionalLayout: true)
        usedRect.origin.x += tv.textContainerInset.left
        usedRect.origin.y += tv.textContainerInset.top
        guard usedRect.contains(gr.location(in: tv)) else { return }
        // 4) 取属性（支持 URL 或 String）
        var eff = NSRange(location: 0, length: 0)
        let attrs = tv.attributedText.attributes(at: charIndex, effectiveRange: &eff)

        if let v = attrs[NSAttributedString.Key.link] {
            if let url = v as? URL {
                relay.accept(url)
            } else if let s = v as? String, let url = URL(string: s) {
                relay.accept(url)
            }
        }
    }
    // 与系统手势并发，避免被内建选择/链接手势抢走
    public func gestureRecognizer(_ g: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }
}
// MARK: - 语义扩展：tv.linkTap（省略 .rx）
public extension UITextView {
    var linkTap: Observable<URL> { rx.linkTap.asObservable() }
}
// ===========================================================
// 🎯 重点：UITextView.onChange（RAC 版本，挂在 UITextView 上）
// ===========================================================
public extension UITextView {
    typealias TVOnChange = (_ tv: UITextView, _ input: String, _ old: String, _ isDeleting: Bool) -> Void
    /// 监听文本变化（Rx 方案）
    /// - Parameters:
    ///   - emitDuringComposition: 是否在 IME 合成期（markedTextRange != nil）也回调，默认 false
    ///   - distinct: 文本相同是否去重
    ///   - handler: (tv, inputDiff, oldText, isDeleting)
    @discardableResult
    func onChange(
        emitDuringComposition: Bool = false,
        distinct: Bool = true,
        _ handler: @escaping TVOnChange
    ) -> Self {
        // 安装 deleteBackward 广播（一次）
        UITextView.enableDeleteBackwardBroadcast()
        // 重绑时先清理
        _tv_onChangeBag = DisposeBag()
        // 是否合成期过滤
        let baseStream = rx.text.orEmpty
            .filter { [weak self] _ in
                guard let self else { return true }
                return emitDuringComposition || self.markedTextRange == nil
            }

        let textChanged = (distinct ? baseStream.distinctUntilChanged() : baseStream)
            .share(replay: 1, scope: .whileConnected)
        // old/new 配对：old = 初始 + 之前的 new
        let oldText = Observable.just(text ?? "").concat(textChanged)
        let pair: Observable<(String, String)> = Observable.zip(oldText, textChanged) // (old, new)
        // 回调（不要在参数列表里做 (old, new) 解构，编译器在这里经常跪）
        pair
            .withUnretained(self)
            .subscribe(onNext: { tv, pair in
                let (old, new) = pair
                let isDeleting = new.count < old.count
                let input = new._jobs_insertedSubstring(comparedTo: old)
                handler(tv, input, old, isDeleting)
            })
            .disposed(by: _tv_onChangeBag)

        return self
    }
}
// ===========================================================
// 私有：AO & 工具
// ===========================================================
private enum JobsTVKeys {
    static var onChangeBag: UInt8 = 0
    static var linkTapProxy: UInt8 = 0
    static var backspaceBag: UInt8 = 0
}

private extension UITextView {
    var _tv_backspaceBag: DisposeBag {
        get { _tv_getOrSetAssociated(key: &JobsTVKeys.backspaceBag) { _ in DisposeBag() } }
        set { objc_setAssociatedObject(self, &JobsTVKeys.backspaceBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    var _tv_onChangeBag: DisposeBag {
        get { _tv_getOrSetAssociated(key: &JobsTVKeys.onChangeBag) { _ in DisposeBag() } }
        set { objc_setAssociatedObject(self, &JobsTVKeys.onChangeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    @inline(__always)
    func _tv_getOrSetAssociated<T>(key: UnsafeRawPointer, _ make: (UITextView) -> T) -> T {
        if let v = objc_getAssociatedObject(self, key) as? T { return v }
        let v = make(self)
        objc_setAssociatedObject(self, key, v, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return v
    }
}
// 计算 new 相比 old “插入的子串”，在中间插入/替换场景也能尽量正确
private extension String {
    func _jobs_insertedSubstring(comparedTo old: String) -> String {
        if self == old { return "" }
        let a = Array(self)
        let b = Array(old)
        // 前缀对齐
        var i = 0
        while i < min(a.count, b.count), a[i] == b[i] { i += 1 }
        // 后缀对齐
        var j = 0
        while j < min(a.count - i, b.count - i),
              a[a.count - 1 - j] == b[b.count - 1 - j] { j += 1 }
        if self.count >= old.count, i <= a.count - j {
            return String(a[i..<(a.count - j)])
        } else {
            return "" // 删除或替换导致整体变短时，这里返回空串
        }
    }
}
// ===========================================================
// 🎯 API：链式退格回调（返回 Self）
// ===========================================================
import RxRelay // 你文件里已用到 PublishRelay/BehaviorRelay，确保有这行

public extension UITextView {
    typealias TVOnBackspace = (_ tv: UITextView) -> Void

    /// 监听退格键：点语法 + 可选节流
    /// - Parameters:
    ///   - throttle: 可选节流间隔（例如 .milliseconds(120)），默认 nil 不节流
    ///   - scheduler: 调度器，默认 MainScheduler.instance
    ///   - handler: 回调 (tv)
    @discardableResult
    func onBackspace(
        throttle: RxTimeInterval? = nil,
        scheduler: SchedulerType = MainScheduler.instance,
        _ handler: @escaping TVOnBackspace
    ) -> Self {
        // 保证 deleteBackward 广播生效
        UITextView.enableDeleteBackwardBroadcast()
        // 重绑先清理旧订阅
        _tv_backspaceBag = DisposeBag()
        var src = self.didPressDelete
        if let interval = throttle {
            // 避免长按连续触发过于频繁
            src = src.throttle(interval, latest: true, scheduler: scheduler)
        }
        src.withUnretained(self)
            .subscribe(onNext: { tv, _ in
                handler(tv)
            })
            .disposed(by: _tv_backspaceBag)
        return self
    }

    /// 语义别名：onDelete == onBackspace
    @discardableResult
    func onDelete(
        throttle: RxTimeInterval? = nil,
        scheduler: SchedulerType = MainScheduler.instance,
        _ handler: @escaping TVOnBackspace
    ) -> Self {
        onBackspace(throttle: throttle, scheduler: scheduler, handler)
    }
}
