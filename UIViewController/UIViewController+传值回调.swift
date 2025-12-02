//
//  UIViewController+传值回调.swift
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

// ================================== 数据传递 + 出现完成回调 ==================================
private enum JobsAssocKey {
    static var inputData: UInt8 = 0
    static var onResult: UInt8 = 1
    static var onAppearCompletions: UInt8 = 2
    static var appearCompletionFired: UInt8 = 3
}

extension UIViewController: JobsRouteComparable {
    @inline(__always)
    public func jobs_isSameDestination(as other: UIViewController) -> Bool {
        type(of: self) == type(of: other)
    }
}

public extension UIViewController {
    @discardableResult
    func byData(_ data: Any?) -> Self {
        objc_setAssociatedObject(self, &JobsAssocKey.inputData, data, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }

    func inputData<T>() -> T? {
        objc_getAssociatedObject(self, &JobsAssocKey.inputData) as? T
    }

    @discardableResult
    func onResult(_ callback: @escaping (Any) -> Void) -> Self {
        objc_setAssociatedObject(self, &JobsAssocKey.onResult, callback, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    func sendResult(_ result: Any) {
        if let cb = objc_getAssociatedObject(self, &JobsAssocKey.onResult) as? (Any) -> Void { cb(result) }
    }

    @discardableResult
    func goBack(_ result: Any?, animated: Bool = true) -> Self {
        if let r = result { sendResult(r) }
        if let nav = navigationController { nav.popViewController(animated: animated) }
        else { dismiss(animated: animated) }
        return self
    }
    // ✅ 出现完成（push/present 结束）的一次性回调
    @discardableResult
    func byCompletion(_ block: @escaping () -> Void) -> Self {
        UIViewController._JobsAppearSwizzler.installIfNeeded()
        var arr = (objc_getAssociatedObject(self, &JobsAssocKey.onAppearCompletions) as? [() -> Void]) ?? []
        arr.append(block)
        objc_setAssociatedObject(self, &JobsAssocKey.onAppearCompletions, arr, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        // 若已在窗口（先跳转后注册），下一轮主线程立即触发
        if self.viewIfLoaded?.window != nil {
            DispatchQueue.main.async { [weak self] in self?.jobs_fireAppearCompletionIfNeeded(reason: "alreadyVisible") }
        };return self
    }

    func jobs_fireAppearCompletionIfNeeded(reason: String) {
        let fired = (objc_getAssociatedObject(self, &JobsAssocKey.appearCompletionFired) as? Bool) ?? false
        guard !fired else { return }
        guard let blocks = objc_getAssociatedObject(self, &JobsAssocKey.onAppearCompletions) as? [() -> Void],
              !blocks.isEmpty else { return }
        objc_setAssociatedObject(self, &JobsAssocKey.appearCompletionFired, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &JobsAssocKey.onAppearCompletions, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        blocks.forEach { $0() }
        // print("✅ [JobsAppearCompletion] fired by \(reason) for \(self)")
    }
}
// `viewDidAppear` swizzle：出现完成时机
private enum _JobsAppearSwizzleOnceToken { static var done = false }
private extension UIViewController {
    final class _JobsAppearSwizzler {
        static func installIfNeeded() {
            guard !_JobsAppearSwizzleOnceToken.done else { return }
            _JobsAppearSwizzleOnceToken.done = true
            let cls: AnyClass = UIViewController.self
            guard
                let m1 = class_getInstanceMethod(cls, #selector(UIViewController.viewDidAppear(_:))),
                let m2 = class_getInstanceMethod(cls, #selector(UIViewController.jobs_viewDidAppear_swizzled(_:)))
            else { return }
            method_exchangeImplementations(m1, m2)
        }
    }

    @objc func jobs_viewDidAppear_swizzled(_ animated: Bool) {
        self.jobs_viewDidAppear_swizzled(animated) // 原实现
        self.jobs_fireAppearCompletionIfNeeded(reason: "viewDidAppear")
    }
}
// MARK: - 给“实现了 JobsDataReceivable 的 VC”提供强类型重载：编译期直达 receive(_:)
extension JobsDataReceivable where Self: UIViewController {
    @discardableResult
    func byData(_ data: InputData) -> Self {
        receive(data)
        return self
    }
}
