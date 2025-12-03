//
//  UITextView+监控删除键.swift
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
// MARK: ⚙️ deleteBackward 广播（UITextView）
public extension UITextView {
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
        NotificationCenter.default.post(name: UITextView.didPressTextViewDeleteNotification, object: self)
    }
}

public extension UITextView {
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
