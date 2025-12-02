//
//  UINavigationController.swift
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

public extension UINavigationController {
    // ================================== Push / Pop ==================================
    // MARK: - ✅ push（带动画）
    @discardableResult
    func pushViewControllerByAnimated(_ viewController: UIViewController) -> Self {
        self.pushViewController(viewController, animated: true)
        return self
    }
    // MARK: - ✅ push（无动画）
    @discardableResult
    func pushViewController(_ viewController: UIViewController) -> Self {
        self.pushViewController(viewController, animated: false)
        return self
    }
    // MARK: - ✅ pop（带动画）
    @discardableResult
    func popViewControllerByAnimated() -> Self {
        self.popViewController(animated: true)
        return self
    }
    // MARK: - ✅ pop（无动画）
    @discardableResult
    func popViewController() -> Self {
        self.popViewController(animated: false)
        return self
    }
    // MARK: - ✅ popTo 指定控制器（带动画）
    @discardableResult
    func popToViewControllerByAnimated(_ viewController: UIViewController) -> Self {
        self.popToViewController(viewController, animated: true)
        return self
    }
    // MARK: - ✅ popTo 指定控制器（无动画）
    @discardableResult
    func popToViewController(_ viewController: UIViewController) -> Self {
        self.popToViewController(viewController, animated: false)
        return self
    }
    // MARK: - ✅ popTo 根控制器（带动画）
    @discardableResult
    func popToRootViewControllerByAnimated() -> Self {
        self.popToRootViewController(animated: true)
        return self
    }
    // MARK: - ✅ popTo 根控制器（无动画）
    @discardableResult
    func popToRootViewController() -> Self {
        self.popToRootViewController(animated: false)
        return self
    }
    // ================================== Set Stack ==================================
    // MARK: - ✅ 替换控制器栈（带动画）
    @discardableResult
    func byViewControllersByAnimated(_ controllers: [UIViewController]) -> Self {
        self.setViewControllers(controllers, animated: true)
        return self
    }
    // MARK: - ✅ 替换控制器栈（无动画）
    @discardableResult
    func byViewControllers(_ controllers: [UIViewController]) -> Self {
        self.setViewControllers(controllers, animated: false)
        return self
    }
    // ================================== 导航栏显示/隐藏 ==================================
    // MARK: - ✅ 链式写法：设置导航栏隐藏状态
    @discardableResult
    func byNavigationBarHidden(_ hidden: Bool) -> Self {
        /// 只是修改标志位，UIKit 会在下一次布局刷新时才更新 UI（可能延迟、或被打断）。
        self.isNavigationBarHidden = hidden
        return self
    }
    // MARK: - ✅ 导航栏显示/隐藏（带动画）
    @discardableResult
    func byNaBarHiddenByAnimated(_ hidden: Bool) -> Self {
        self.setNavigationBarHidden(hidden, animated: true)
        return self
    }
    // MARK: - ✅ 导航栏显示/隐藏（无动画）
    @discardableResult
    func byNavBarHidden(_ hidden: Bool) -> Self {
        /// 不仅改变属性，还会触发布局和动画。
        self.setNavigationBarHidden(hidden, animated: false)
        return self
    }
    // ================================== 工具栏显示/隐藏 ==================================
    // MARK: - ✅ 工具栏显示/隐藏（带动画）
    @discardableResult
    func byToolbarHiddenByAnimated(_ hidden: Bool) -> Self {
        self.setToolbarHidden(hidden, animated: true)
        return self
    }
    // MARK: - ✅ 工具栏显示/隐藏（无动画）
    @discardableResult
    func byToolbarHidden(_ hidden: Bool) -> Self {
        self.setToolbarHidden(hidden, animated: false)
        return self
    }
    // ================================== show / 工具方法 ==================================
    // MARK: - ✅ show 一个控制器（带默认 sender）
    @discardableResult
    func byShowVC(_ vc: UIViewController, sender: Any? = nil) -> Self {
        self.show(vc, sender: sender)
        return self
    }
    // MARK: - ✅ 隐藏所有 bars
    @discardableResult
    func byHideAllBars(_ hidden: Bool, animated: Bool = true) -> Self {
        self.setNavigationBarHidden(hidden, animated: animated)
        self.setToolbarHidden(hidden, animated: animated)
        return self
    }
}
// MARK: - UINavigationController 辅助（前缀化）
public extension UINavigationController {
    /// 若栈内已有“同目的地”，则 popTo；否则 push（无时间节流）
    func jobs_pushOrPopTo(_ vc: UIViewController, animated: Bool) {
        // 1) 动画进行中不叠加
        if transitionCoordinator != nil { return }
        // 2) 目标 VC 不能已挂载（避免“把已有父控制器的 VC 再 push”）
        if vc.parent != nil { return }
        // 3) 栈顶就是同目的地 → 忽略
        if let top = viewControllers.last, vc.jobs_isSameDestination(as: top) { return }
        // 4) 栈内存在同目的地 → popTo
        if let existed = viewControllers.first(where: { vc.jobs_isSameDestination(as: $0) }) {
            popToViewController(existed, animated: animated)
            return
        }
        // 5) 否则 push
        pushViewController(vc, animated: animated)
    }
}
