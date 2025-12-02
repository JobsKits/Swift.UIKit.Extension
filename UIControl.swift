//
//  UIControl.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/1/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

import ObjectiveC

private final class _JobsClosureWrapper: NSObject {
    private let closure: () -> Void
    init(_ closure: @escaping () -> Void) { self.closure = closure }
    @objc func invoke() { closure() }
}

public extension UIControl {
    // MARK: - 通用 Tap 事件
    @discardableResult
    func onJobsTap<T: UIControl>(_ handler: @escaping (T) -> Void) -> Self {
        addJobsAction(for: .touchUpInside, handler)
        return self
    }
    // MARK: - 通用 ValueChanged（比如 Switch / Slider / DatePicker）
    @discardableResult
    func onJobsChange<T: UIControl>(_ handler: @escaping (T) -> Void) -> Self {
        addJobsAction(for: .valueChanged, handler)
        return self
    }
    // MARK: - 通用事件绑定（任意 Event）
    @discardableResult
    func onJobsEvent<T: UIControl>(_ event: UIControl.Event,
                                   _ handler: @escaping (T) -> Void) -> Self {
        addJobsAction(for: event, handler)
        return self
    }
    // MARK: - 内部统一注册函数
    private func addJobsAction<T: UIControl>(for event: UIControl.Event,
                                             _ handler: @escaping (T) -> Void) {
        let box = _JobsClosureWrapper { [weak self] in
            guard let self = self else { return }
            if let specific = self as? T {
                handler(specific)
            }
        }
        let key = "[[jobs_event_\(event.rawValue)]]"
        objc_setAssociatedObject(self, key, box, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(box, action: #selector(_JobsClosureWrapper.invoke), for: event)
    }
}

public extension UIControl {
    // MARK: - 基础状态
    @discardableResult func byEnabled(_ on: Bool) -> Self { self.isEnabled = on; return self }
    @discardableResult func bySelected(_ on: Bool) -> Self { self.isSelected = on; return self }
    @discardableResult func byHighlighted(_ on: Bool) -> Self { self.isHighlighted = on; return self }
    // MARK: - 内容对齐
    @discardableResult
    func byContentAlignment(horizontal: UIControl.ContentHorizontalAlignment? = nil,
                            vertical: UIControl.ContentVerticalAlignment? = nil) -> Self {
        if let h = horizontal { self.contentHorizontalAlignment = h }
        if let v = vertical   { self.contentVerticalAlignment = v }
        return self
    }
    // MARK: - Target-Action（传统）
    @discardableResult
    func byAddTarget(_ target: Any?, action: Selector, for events: UIControl.Event) -> Self {
        addTarget(target, action: action, for: events); return self
    }
    @discardableResult
    func byRemoveTarget(_ target: Any?, action: Selector? = nil, for events: UIControl.Event) -> Self {
        removeTarget(target, action: action, for: events); return self
    }
    /// 触发指定事件（比如 .touchUpInside）
    @discardableResult
    func bySendActions(for events: UIControl.Event) -> Self {
        sendActions(for: events); return self
    }
    // MARK: - UIAction（iOS 14+）
    /// 直接加一个 UIAction；identifier 相同会被替换
    @available(iOS 14.0, *)
    @discardableResult
    func byAddAction(_ action: UIAction, for events: UIControl.Event) -> Self {
        addAction(action, for: events); return self
    }
    /// 移除指定实例的 UIAction
    @available(iOS 14.0, *)
    @discardableResult
    func byRemoveAction(_ action: UIAction, for events: UIControl.Event) -> Self {
        removeAction(action, for: events); return self
    }
    /// 根据 identifier 移除 UIAction
    @available(iOS 14.0, *)
    @discardableResult
    func byRemoveAction(identifiedBy id: UIAction.Identifier, for events: UIControl.Event) -> Self {
        removeAction(identifiedBy: id, for: events); return self
    }
    /// 便捷：创建并添加一个闭包形式 UIAction，返回 action 以便后续移除
    @available(iOS 14.0, *)
    @discardableResult
    func byOn(_ events: UIControl.Event,
              id: UIAction.Identifier? = nil,
              _ handler: @escaping (UIAction) -> Void) -> Self {
        let action = UIAction(identifier: id, handler: handler)
        addAction(action, for: events)
        return self
    }
    // MARK: - Primary Action（iOS 17.4+）
    @available(iOS 17.4, *)
    @discardableResult
    func byPerformPrimaryAction() -> Self {
        performPrimaryAction(); return self
    }
    // MARK: - Context Menu（iOS 14+）
    /// 开启/关闭把菜单作为主操作（touch-down 展开）
    @available(iOS 14.0, *)
    @discardableResult
    func byShowsMenuAsPrimaryAction(_ on: Bool) -> Self {
        self.showsMenuAsPrimaryAction = on; return self
    }
    /// 启用/禁用上下文菜单交互
    @available(iOS 14.0, *)
    @discardableResult
    func byContextMenuEnabled(_ on: Bool) -> Self {
        self.isContextMenuInteractionEnabled = on; return self
    }
    // MARK: - ToolTip（iOS 15+）
    @available(iOS 15.0, *)
    @discardableResult
    func byToolTip(_ text: String?) -> Self {
        self.toolTip = text; return self
    }
    // MARK: - SF Symbol 动画（iOS 17+）
    @available(iOS 17.0, *)
    @discardableResult
    func bySymbolAnimationEnabled(_ on: Bool) -> Self {
        self.isSymbolAnimationEnabled = on; return self
    }
}
