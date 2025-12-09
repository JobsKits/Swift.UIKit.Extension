//
//  UIViewController+DSL.swift
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

@MainActor
public extension UIViewController {
    // ================================== 标题 / 背景 ==================================
    @discardableResult
    func byTitle(_ title: String?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    func byBgColor(_ color: UIColor) -> Self {
        if viewIfLoaded == nil { loadViewIfNeeded() }
        self.view.backgroundColor = color
        return self
    }
    // ================================== Segue ==================================
    @discardableResult
    func byPerformSegue(_ identifier: String, sender: Any? = nil) -> Self {
        self.performSegue(withIdentifier: identifier, sender: sender)
        return self
    }

    // ================================== Modal 展示 / 解散 ==================================
    // ⚠️ 已删除：byPresent(_ viewController: UIViewController, ...) 这个容易误用的重载
    // 如果确实想保留，请放开下面注释，并保留所有护栏（强烈建议不要改）：
    /*
    @discardableResult
    func byPresent(_ viewController: UIViewController,
                   animated: Bool = false,
                   jobsByVoidBlock: (jobsByVoidBlock)? = nil) -> Self {
        // 强力护栏：禁止 present 已挂载 / 正在展示 / 自己
        guard viewController !== self else {
            assertionFailure("❌ Don't present self on self")
            return self
        }
        guard viewController.parent == nil, viewController.presentingViewController == nil else {
            assertionFailure("❌ Trying to present a VC that already has a parent/presentingVC: \(viewController)")
            return self
        }
        // 宿主自己必须在 window 上，且不在 dismiss
        guard self.viewIfLoaded?.window != nil, self.isBeingDismissed == false else {
            assertionFailure("❌ Host not in window or being dismissed: \(self)")
            return self
        }
        self.present(viewController, animated: animated, jobsByVoidBlock: jobsByVoidBlock)
        return self
    }
    */
    /// 统一语义化 dismiss
    @discardableResult
    func byDismiss(animated: Bool = true,
                   completion: (jobsByVoidBlock)? = nil) -> Self {
        self.dismiss(animated: animated, completion: completion)
        return self
    }
    // ================================== Modal 属性 ==================================
    @discardableResult
    func byModalPresentationStyle(_ style: UIModalPresentationStyle) -> Self {
        self.modalPresentationStyle = style
        return self
    }

    @discardableResult
    func byModalTransitionStyle(_ style: UIModalTransitionStyle) -> Self {
        self.modalTransitionStyle = style
        return self
    }

    @available(iOS 18.0, *)
    @discardableResult
    func byPreferredTransition(_ transition: UIViewController.Transition?) -> Self {
        self.preferredTransition = transition
        return self
    }

    @available(iOS 7.0, *)
    @discardableResult
    func byTransitioningDelegate(_ delegate: UIViewControllerTransitioningDelegate?) -> Self {
        self.transitioningDelegate = delegate
        return self
    }
    // ================================== Content Size / Layout ==================================
    @discardableResult
    func byPreferredContentSize(_ size: CGSize) -> Self {
        self.preferredContentSize = size
        return self
    }

    var jobs_preferredContentSize: CGSize {
        self.preferredContentSize
    }

    @discardableResult
    func byEdgesForExtendedLayout(_ edges: UIRectEdge) -> Self {
        self.edgesForExtendedLayout = edges
        return self
    }

    @discardableResult
    func byExtendedLayoutIncludesOpaqueBars(_ flag: Bool) -> Self {
        self.extendedLayoutIncludesOpaqueBars = flag
        return self
    }

    @discardableResult
    func byAutomaticallyAdjustsScrollInsets(_ flag: Bool) -> Self {
        if #available(iOS 11.0, *) {
            assertionFailure("iOS 11+ 请使用 UIScrollView.contentInsetAdjustmentBehavior")
        } else {
            self.automaticallyAdjustsScrollViewInsets = flag
        }
        return self
    }
    // ================================== show / showDetail（安全命名） ==================================
    @discardableResult
    func byShow(_ vc: UIViewController, sender: Any? = nil) -> Self {
        self.show(vc, sender: sender)
        return self
    }

    @discardableResult
    func byShowDetail(_ vc: UIViewController, sender: Any? = nil) -> Self {
        self.showDetailViewController(vc, sender: sender)
        return self
    }
    // ================================== 状态栏 / 外观 ==================================
    @discardableResult
    func byOverrideUserInterfaceStyle(_ style: UIUserInterfaceStyle) -> Self {
        self.overrideUserInterfaceStyle = style
        return self
    }

    @discardableResult
    func byNeedsStatusBarUpdate() -> Self {
        self.setNeedsStatusBarAppearanceUpdate()
        return self
    }

    @discardableResult
    func byPreferredStatusBarStyle(_ style: UIStatusBarStyle) -> Self {
        assertionFailure("请在子类中 override preferredStatusBarStyle 实现此功能")
        return self
    }
    // ================================== 子控制器管理 ==================================
    @discardableResult
    func addChildVC(_ child: UIViewController,
                    into container: UIView? = nil,
                    layout: (jobsByViewBlock)? = nil) -> Self {
        self.addChild(child)
        if viewIfLoaded == nil { loadViewIfNeeded() }
        let host = container ?? self.view!
        host.addSubview(child.view)
        layout?(child.view)
        child.didMove(toParent: self)
        return self
    }

    @discardableResult
    func addChildVC(_ child: UIViewController) -> Self {
        self.addChild(child)
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
        return self
    }

    @discardableResult
    func removeFromParentVC() -> Self {
        guard parent != nil else { return self }
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
        return self
    }

    var jobs_hasParent: Bool { self.parent != nil }
    // ================================== 滚动联动（iOS15+） ==================================
    @available(iOS 15.0, *)
    @discardableResult
    func byContentScrollView(_ scrollView: UIScrollView?, for edge: NSDirectionalRectEdge) -> Self {
        self.setContentScrollView(scrollView, for: edge)
        return self
    }

    @available(iOS 15.0, *)
    var jobs_contentScrollViewTop: UIScrollView? {
        self.contentScrollView(for: .top)
    }
    // ================================== 焦点 / 交互追踪（TV / iOS 15+） ==================================
    @available(iOS 15.0, *)
    @discardableResult
    func byFocusGroupIdentifier(_ id: String?) -> Self {
        self.focusGroupIdentifier = id
        return self
    }

    @available(iOS 16.0, *)
    @discardableResult
    func byInteractionActivityBaseName(_ name: String?) -> Self {
        self.interactionActivityTrackingBaseName = name
        return self
    }
    // ================================== iOS 26+ 属性更新批 ==================================
    @available(iOS 26.0, *)
    @discardableResult
    func bySetNeedsUpdateProperties() -> Self {
        self.setNeedsUpdateProperties()
        return self
    }

    @available(iOS 26.0, *)
    @discardableResult
    func byUpdatePropertiesIfNeeded() -> Self {
        self.updatePropertiesIfNeeded()
        return self
    }
}
