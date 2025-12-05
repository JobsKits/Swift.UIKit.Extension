//
//  UIButton+点按事件.swift
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

private enum JobsUIButtonAssociatedKeys {
    static var tapBlocks: UInt8 = 0
    static var tapSleeve: UInt8 = 0
    static var tapActionInstalled: UInt8 = 0
    static var longPressBlock: UInt8 = 0
}
// MARK: - 内部 Sleeve
private final class _JobsButtonTapSleeve: NSObject {
    weak var button: UIButton?

    init(button: UIButton?) {
        self.button = button
    }

    @objc func invoke(_ sender: UIButton) {
        // sender 优先，其次退回到弱引用的 button
        (sender as UIButton? ?? button)?.jobs_invokeTapBlocks()
    }
}

private final class _JobsButtonLongPressSleeve: NSObject {
    weak var button: UIButton?

    init(button: UIButton?) {
        self.button = button
    }

    @objc func invoke(_ g: UILongPressGestureRecognizer) {
        // ✅ 优先用 g.view 拿按钮，clone 的 button 也能拿到自己
        guard let btn = (g.view as? UIButton) ?? button else { return }
        btn.jobs_invokeLongPressBlocks(recognizer: g)
    }
}
// MARK: - 内部工具
private extension UIButton {
    // 点击：存一组 block，方便「覆盖」和「叠加」
    var jobsTapBlocks: [JobsButtonTapBlock] {
        get {
            objc_getAssociatedObject(self, &JobsUIButtonAssociatedKeys.tapBlocks) as? [JobsButtonTapBlock] ?? []
        }
        set {
            objc_setAssociatedObject(
                self,
                &JobsUIButtonAssociatedKeys.tapBlocks,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    // 长按：最终聚合成一个 block（内部自己合并 old/new）
    var jobsLongPressBlock: JobsButtonLongPressBlock? {
        get {
            objc_getAssociatedObject(self, &JobsUIButtonAssociatedKeys.longPressBlock) as? JobsButtonLongPressBlock
        }
        set {
            objc_setAssociatedObject(
                self,
                &JobsUIButtonAssociatedKeys.longPressBlock,
                newValue,
                .OBJC_ASSOCIATION_COPY_NONATOMIC
            )
        }
    }
    // 实际调用点击所有 block
    func jobs_invokeTapBlocks() {
        for block in jobsTapBlocks {
            block(self)
        }
    }
    // 实际调用长按聚合 block
    func jobs_invokeLongPressBlocks(recognizer: UILongPressGestureRecognizer) {
        jobsLongPressBlock?(self, recognizer)
    }
    // 确保已经挂上「统一点击入口」
    func jobs_ensureTapHandlerInstalled() {
        if #available(iOS 14.0, *) {
            let installed = (objc_getAssociatedObject(self, &JobsUIButtonAssociatedKeys.tapActionInstalled) as? Bool) ?? false
            if installed { return }

            let action = UIAction { [weak self] _ in
                self?.jobs_invokeTapBlocks()
            }
            (self as UIControl).addAction(action, for: .touchUpInside)
            objc_setAssociatedObject(
                self,
                &JobsUIButtonAssociatedKeys.tapActionInstalled,
                true,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        } else {
            if objc_getAssociatedObject(self, &JobsUIButtonAssociatedKeys.tapSleeve) != nil { return }

            let sleeve = _JobsButtonTapSleeve(button: self)
            addTarget(
                sleeve,
                action: #selector(_JobsButtonTapSleeve.invoke(_:)),
                for: .touchUpInside
            )
            objc_setAssociatedObject(
                self,
                &JobsUIButtonAssociatedKeys.tapSleeve,
                sleeve,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    // 确保「统一长按入口」的手势已经挂上
    func jobs_ensureLongPressRecognizer(minimumPressDuration: TimeInterval) {
        if let existing = (gestureRecognizers ?? [])
            .compactMap({ $0 as? UILongPressGestureRecognizer })
            .first(where: { objc_getAssociatedObject($0, &kJobsUIButtonLongPressSleeveKey) != nil }) {

            existing.minimumPressDuration = minimumPressDuration
            return
        }

        let gr = UILongPressGestureRecognizer(target: nil, action: nil)
        gr.minimumPressDuration = minimumPressDuration

        let sleeve = _JobsButtonLongPressSleeve(button: self)
        gr.addTarget(
            sleeve,
            action: #selector(_JobsButtonLongPressSleeve.invoke(_:))
        )

        // 用全局指针 key 标记这是我们挂的 GR，clone 时也能保留 sleeve
        objc_setAssociatedObject(
            gr,
            &kJobsUIButtonLongPressSleeveKey,
            sleeve,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        addGestureRecognizer(gr)
        isUserInteractionEnabled = true
    }
}
// MARK: - 闭包回调（低版本兜底）（保留）
private var actionKey: Void?
public extension UIButton {
    @discardableResult
    private func _bindTapClosure(_ action: @escaping (UIButton) -> Void,
                                 for events: UIControl.Event = .touchUpInside) -> Self {
        objc_setAssociatedObject(self, &actionKey, action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        removeTarget(self, action: #selector(_jobsHandleAction(_:)), for: events)
        addTarget(self, action: #selector(_jobsHandleAction(_:)), for: events)
        return self
    }
    @discardableResult
    func jobs_addTapClosure(_ action: @escaping (UIButton) -> Void,
                            for events: UIControl.Event = .touchUpInside) -> Self {
        _bindTapClosure(action, for: events)
    }
    @discardableResult
    func addAction(_ action: @escaping (UIButton) -> Void,
                   for events: UIControl.Event = .touchUpInside) -> Self {
        _bindTapClosure(action, for: events)
    }

    @objc private func _jobsHandleAction(_ sender: UIButton) {
        if let action = objc_getAssociatedObject(self, &actionKey) as? (UIButton) -> Void {
            action(sender)
        }
    }
}
// MARK: - 点按事件统一入口
var kJobsUIButtonLongPressSleeveKey: UInt8 = 0
public extension UIButton {
    @discardableResult
    /// 点击方法@普通
    func onTap(_ handler: @escaping (UIButton) -> Void) -> Self {
        if #available(iOS 14.0, *) {
            (self as UIControl).addAction(UIAction { [weak self] _ in
                guard let s = self else { return }
                handler(s)
            }, for: .touchUpInside)
        } else {
            _ = self.jobs_addTapClosure(handler)
        };return self
    }
    /// 点击方法@叠加
    @discardableResult
    func onTapAppend(_ handler: @escaping JobsButtonTapBlock) -> Self {
        var blocks = jobsTapBlocks
        blocks.append(handler)             // 叠加
        jobsTapBlocks = blocks
        jobs_ensureTapHandlerInstalled()
        return self
    }
    /// 长按方法@普通
    @discardableResult
     func onLongPress(minimumPressDuration: TimeInterval = 0.5,
                      _ handler: @escaping (UIButton, UILongPressGestureRecognizer) -> Void) -> Self {
         let gr = UILongPressGestureRecognizer(target: nil, action: nil)
         class _GRSleeve<T: UIGestureRecognizer> {
             let closure: (T) -> Void
             init(_ c: @escaping (T) -> Void) { closure = c }
             @objc func invoke(_ g: UIGestureRecognizer) {
                 if let gg = g as? T { closure(gg) }
             }
         }
         gr.minimumPressDuration = minimumPressDuration
         // ✅ 关键：优先用 g.view 作为按钮，这样 clone 的 button 也能拿到自己
         let sleeve = _GRSleeve<UILongPressGestureRecognizer> { [weak self] g in
             // g.view 是当前这个手势挂在哪个 view 上（模板按钮 or clone）
             guard let btn = (g.view as? UIButton) ?? self else { return }
             handler(btn, g)
         }
         gr.addTarget(
             sleeve,
             action: #selector(_GRSleeve<UILongPressGestureRecognizer>.invoke(_:))
         )
         // ✅ 不再用字符串当 key，用全局指针，clone 那边才能取得到
         objc_setAssociatedObject(
             gr,
             &kJobsUIButtonLongPressSleeveKey,
             sleeve,
             .OBJC_ASSOCIATION_RETAIN_NONATOMIC
         )
         addGestureRecognizer(gr)
         isUserInteractionEnabled = true
         return self
     }
    /// 长按方法@叠加
    @discardableResult
    func onLongPressAppend(
        minimumPressDuration: TimeInterval = 0.5,
        _ handler: @escaping JobsButtonLongPressBlock
    ) -> Self {
        if let old = jobsLongPressBlock {
            // 和 OC 一样：old 在前，new 在后
            jobsLongPressBlock = { btn, gr in
                old(btn, gr)
                handler(btn, gr)
            }
        } else {
            jobsLongPressBlock = handler
        }
        jobs_ensureLongPressRecognizer(minimumPressDuration: minimumPressDuration)
        return self
    }
}
