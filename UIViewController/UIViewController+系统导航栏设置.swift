//
//  UIViewController+系统导航栏显隐.swift
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

private var _nbHiddenKey: UInt8 = 0
private var _nbAnimatedKey: UInt8 = 0
private var _nbSwizzledKey: UInt8 = 0
public extension UIViewController {
    /// 写在 viewDidLoad：进入本页隐藏，离开自动还原
    @discardableResult
    func byNavBarHiddenLifecycle(_ hiddenOnAppear: Bool, animated: Bool = true) -> Self {
        objc_setAssociatedObject(self, &_nbHiddenKey, hiddenOnAppear as NSNumber, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &_nbAnimatedKey, animated as NSNumber, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        Self._nb_swizzleOnce(for: type(of: self))
        return self
    }
    /// 立即切换（链式）
    @discardableResult
    func byNavBarHidden(_ hidden: Bool, animated: Bool = false) -> Self {
        navigationController?.setNavigationBarHidden(hidden, animated: animated)
        return self
    }
    // MARK: - swizzle
    private static func _nb_swizzleOnce(for cls: UIViewController.Type) {
        let key = ObjectIdentifier(cls)
        var done = (objc_getAssociatedObject(cls, &_nbSwizzledKey) as? Set<ObjectIdentifier>) ?? []
        guard !done.contains(key) else { return }
        done.insert(key); objc_setAssociatedObject(cls, &_nbSwizzledKey, done, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        func exch(_ c: AnyClass, _ o: Selector, _ n: Selector) {
            guard let m1 = class_getInstanceMethod(c, o),
                  let m2 = class_getInstanceMethod(c, n) else { return }
            method_exchangeImplementations(m1, m2)
        }
        exch(cls, #selector(UIViewController.viewWillAppear(_:)),
                  #selector(UIViewController._nb_viewWillAppear(_:)))
        exch(cls, #selector(UIViewController.viewWillDisappear(_:)),
                  #selector(UIViewController._nb_viewWillDisappear(_:)))
    }

    @objc private func _nb_viewWillAppear(_ animated: Bool) {
        _nb_viewWillAppear(animated) // 调原实现
        if let on = (objc_getAssociatedObject(self, &_nbHiddenKey) as? NSNumber)?.boolValue,
           let anim = (objc_getAssociatedObject(self, &_nbAnimatedKey) as? NSNumber)?.boolValue {
            navigationController?.setNavigationBarHidden(on, animated: anim)
        }
    }

    @objc private func _nb_viewWillDisappear(_ animated: Bool) {
        _nb_viewWillDisappear(animated) // 调原实现
        if let _ = objc_getAssociatedObject(self, &_nbHiddenKey) {
            // 只在你启用了 lifecycle 时还原
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}

private enum _JobsNavPopSwizzleOnceToken { static var done = false }
public extension UINavigationController {
    static func _jobs_installPopSwizzlesIfNeeded() {
        guard !_JobsNavPopSwizzleOnceToken.done else { return }
        _JobsNavPopSwizzleOnceToken.done = true
        let cls: AnyClass = UINavigationController.self

        func exch(_ o: Selector, _ n: Selector) {
            guard let m1 = class_getInstanceMethod(cls, o),
                  let m2 = class_getInstanceMethod(cls, n) else { return }
            method_exchangeImplementations(m1, m2)
        }

        exch(#selector(UINavigationController.popViewController(animated:)),
             #selector(UINavigationController._jobs_popViewController_swizzled(animated:)))

        exch(#selector(UINavigationController.popToViewController(_:animated:)),
             #selector(UINavigationController._jobs_popToViewController_swizzled(_:animated:)))

        exch(#selector(UINavigationController.popToRootViewController(animated:)),
             #selector(UINavigationController._jobs_popToRootViewController_swizzled(animated:)))
    }

    @objc func _jobs_popViewController_swizzled(animated: Bool) -> UIViewController? {
        // 手势交互进行中 → 走系统（避免破坏交互式返回）
        if let g = self.interactivePopGestureRecognizer,
           g.state == .began || g.state == .changed {
            return _jobs_popViewController_swizzled(animated: animated)
        }
        if animated, let top = self.topViewController,
           let dir = top._jobs_entryDirection, dir != .system {
            let tr = CATransition()
            tr.type = .push
            tr.subtype = dir._reverseCASubtype
            tr.duration = top._jobs_entryDuration ?? 0.32
            tr.timingFunction = CAMediaTimingFunction(name: top._jobs_entryTiming ?? .easeInEaseOut)
            self.view.layer.add(tr, forKey: "jobs.pop.\(dir._debugKey)")
            return _jobs_popViewController_swizzled(animated: false)
        };return _jobs_popViewController_swizzled(animated: animated)
    }

    @objc func _jobs_popToViewController_swizzled(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if let g = self.interactivePopGestureRecognizer,
           g.state == .began || g.state == .changed {
            return _jobs_popToViewController_swizzled(viewController, animated: animated)
        }
        if animated, let top = self.topViewController,
           let dir = top._jobs_entryDirection, dir != .system {
            let tr = CATransition()
            tr.type = .push
            tr.subtype = dir._reverseCASubtype
            tr.duration = top._jobs_entryDuration ?? 0.32
            tr.timingFunction = CAMediaTimingFunction(name: top._jobs_entryTiming ?? .easeInEaseOut)
            self.view.layer.add(tr, forKey: "jobs.popTo.\(dir._debugKey)")
            return _jobs_popToViewController_swizzled(viewController, animated: false)
        };return _jobs_popToViewController_swizzled(viewController, animated: animated)
    }

    @objc func _jobs_popToRootViewController_swizzled(animated: Bool) -> [UIViewController]? {
        if let g = self.interactivePopGestureRecognizer,
           g.state == .began || g.state == .changed {
            return _jobs_popToRootViewController_swizzled(animated: animated)
        }
        if animated, let top = self.topViewController,
           let dir = top._jobs_entryDirection, dir != .system {
            let tr = CATransition()
            tr.type = .push
            tr.subtype = dir._reverseCASubtype
            tr.duration = top._jobs_entryDuration ?? 0.32
            tr.timingFunction = CAMediaTimingFunction(name: top._jobs_entryTiming ?? .easeInEaseOut)
            self.view.layer.add(tr, forKey: "jobs.popRoot.\(dir._debugKey)")
            return _jobs_popToRootViewController_swizzled(animated: false)
        };return _jobs_popToRootViewController_swizzled(animated: animated)
    }
}

@MainActor
public extension UIViewController {
    private struct _JobsNavKey {
        // 用地址作为唯一 key
        static var wrapper: UInt8 = 0
    }

    var jobsNavContainer: UINavigationController {
        if let nav = self as? UINavigationController { return nav }
        if let nav = self.navigationController { return nav }
        if let cached = objc_getAssociatedObject(self, &_JobsNavKey.wrapper) as? UINavigationController {
            return cached
        }
        let nav = UINavigationController(rootViewController: self)
        objc_setAssociatedObject(self, &_JobsNavKey.wrapper, nav, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return nav
    }

    var jobsNav: Self {
        _ = jobsNavContainer
        return self
    }

    @discardableResult
    func jobsNav(_ onWrap: (UINavigationController) -> Void) -> Self {
        let alreadyHad = (self is UINavigationController)
            || (self.navigationController != nil)
            || (objc_getAssociatedObject(self, &_JobsNavKey.wrapper) != nil)

        let nav = jobsNavContainer
        if !alreadyHad { onWrap(nav) }
        return self
    }
}
// ================================== 链式导航（去重） ==================================
public enum JobsPresentPolicy {
    case ignoreIfBusy
    case presentOnTopMost
}

private var _jobsPushLockKey: UInt8 = 0
public final class _JobsPushLockBox {
    var lockedUntil: TimeInterval = 0
}

public extension UINavigationController {
    var _jobs_lockBox: _JobsPushLockBox {
        if let b = objc_getAssociatedObject(self, &_jobsPushLockKey) as? _JobsPushLockBox { return b }
        let b = _JobsPushLockBox()
        objc_setAssociatedObject(self, &_jobsPushLockKey, b, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return b
    }
    var _jobs_isPushingLocked: Bool {
        CFAbsoluteTimeGetCurrent() < _jobs_lockBox.lockedUntil
    }
    func _jobs_lockPushing(for seconds: TimeInterval) {
        _jobs_lockBox.lockedUntil = CFAbsoluteTimeGetCurrent() + max(0.05, seconds)
    }
}

public extension UIViewController {
    /// 旧签名：保留系统默认行为（不参与方向）；用于兼容工程内旧调用点
    @discardableResult
    func byPush(_ from: UIResponder?, animated: Bool = true) -> Self {
        // 忽略旧的 animated 参数，统一交给新实现处理（含自定义方向 & 系统默认路径）
        return self.byPush(from, duration: 0.32, timing: .easeInEaseOut)
    }

    @discardableResult
    func byPresent(_ from: UIResponder?,
                   animated: Bool = true,
                   policy: JobsPresentPolicy = .ignoreIfBusy,
                   completion: (() -> Void)? = nil) -> Self {
        assert(Thread.isMainThread, "byPresent must be called on main thread")
        // 目标不能已挂载 / 正在展示
        guard self.parent == nil, self.presentingViewController == nil else {
            assertionFailure("❌ Trying to present a VC already mounted/presented: \(self)")
            return self
        }
        // 宿主选择
        guard var host = from?.jobsNearestVC() ?? UIWindow.wd.rootViewController else {
            assertionFailure("❌ byPresent: no host VC"); return self
        }
        if let top = UIApplication.jobsTopMostVC(from: host, ignoreAlert: true) { host = top }
        guard host.viewIfLoaded?.window != nil, host.isBeingDismissed == false else { return self }
        // 策略
        switch policy {
        case .ignoreIfBusy:
            if let presented = host.presentedViewController, presented.isBeingDismissed == false {
                if jobs_isSameDestination(as: presented) { return self }
                return self
            }
        case .presentOnTopMost:
            while let top = UIApplication.jobsTopMostVC(from: host, ignoreAlert: true),
                  top.isBeingDismissed == false, top !== host { host = top }
        }
        // 防自己 present 自己
        guard host !== self else {
            assertionFailure("❌ Don't present self on self"); return self
        }
        // 系统 present；完成时触发一次（与 viewDidAppear 幂等）
        host.present(self, animated: animated) { [weak self] in
            completion?()
            self?.jobs_fireAppearCompletionIfNeeded(reason: "presentCompletion")
        };return self
    }
}
