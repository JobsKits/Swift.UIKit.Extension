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
// ======================================================
// MARK: - 闭包回调（低版本兜底）（保留）
// ======================================================
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
}
