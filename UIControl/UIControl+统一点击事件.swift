//
//  UIControl+统一点击事件.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

import ObjectiveC
// MARK: - UIControl 统一事件 DSL
public extension UIControl {
    // 用一个 key 挂一整张表：[eventRawValue : wrapper]
    private struct JobsAssociatedKeys {
        static var handlersKey: UInt8 = 0
    }

    private var jobsHandlers: [UInt: _JobsClosureWrapper] {
        get {
            (objc_getAssociatedObject(self, &JobsAssociatedKeys.handlersKey) as? [UInt: _JobsClosureWrapper]) ?? [:]
        }
        set {
            objc_setAssociatedObject(self,
                                     &JobsAssociatedKeys.handlersKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    // MARK: - 通用 Tap 事件（.touchUpInside）
    @discardableResult
    func onJobsTap<T: UIControl>(_ handler: @escaping jobsByNonNullTypeBlock<T>) -> Self {
        addJobsAction(for: .touchUpInside, handler)
        return self
    }
    // MARK: - 通用 ValueChanged（UISwitch / UISlider / UIDatePicker 等）
    @discardableResult
    func onJobsChange<T: UIControl>(_ handler: @escaping jobsByNonNullTypeBlock<T>) -> Self {
        addJobsAction(for: .valueChanged, handler)
        return self
    }
    // MARK: - 通用事件绑定（任意 Event）
    @discardableResult
    func onJobsEvent<T: UIControl>(_ event: UIControl.Event,
                                   _ handler: @escaping jobsByNonNullTypeBlock<T>) -> Self {
        addJobsAction(for: event, handler)
        return self
    }
    // MARK: - 内部统一注册函数
    private func addJobsAction<T: UIControl>(for event: UIControl.Event,
                                             _ handler: @escaping jobsByNonNullTypeBlock<T>) {
        let box = _JobsClosureWrapper { [weak self] in
            guard let self = self else { return }
            if let specific = self as? T {
                handler(specific)
            }
        }
        // 按事件存起来，避免不同事件互相覆盖
        var dict = jobsHandlers
        dict[event.rawValue] = box
        jobsHandlers = dict

        addTarget(box, action: #selector(_JobsClosureWrapper.invoke), for: event)
    }
}
