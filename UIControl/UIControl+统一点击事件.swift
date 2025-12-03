//
//  UIControl+统一点击事件.swift
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
import ObjectiveC
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

