//
//  UIApplication.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/30/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
/**
     // 取 keyWindow
     let win = UIApplication.jobsKeyWindow()

     // 取最顶层可见 VC（做 push/present 的宿主）
     if let topVC = UIApplication.jobsTopMostVC() {
         // ... 用 topVC 做 present 或的 pushSafely 入口
     }
 */
// MARK: - Key Window（跨版本最大兼容）
// =======================================================
// UIApplication + UI 层级工具（零弃用警告 / 多 Scene 兼容）
// =======================================================
public extension UIApplication {
    // MARK: - 对外 API
    /// ① 获取“最合理”的 Key Window（多 Scene / 外接屏 / 可见性 / windowLevel 兼容）
    /// - Parameter scene: 指定 UIScene；nil 则自动从所有 connectedScenes 中择优
    /// - Parameter preferMainScreen: 是否优先主屏幕（避免拿到外接屏/CarPlay 的 window）
    static func jobsKeyWindow(in scene: UIScene? = nil,
                              preferMainScreen: Bool = true) -> UIWindow? {
        if #available(iOS 13.0, *) {
            // 选择最合适的 windowScene
            let ws = (scene as? UIWindowScene) ?? bestWindowScene()
            guard let ws else { return nil }
            return bestWindow(in: ws, preferMainScreen: preferMainScreen)
        } else {
            // < iOS13：没有 Scene 的年代，仅用 keyWindow 兜底（避免触碰 .windows）
            return UIApplication.shared.keyWindow
        }
    }
    /// ② 顶层“可见 VC”（支持 Nav/Tab/Split/Page/Presented；可选忽略 Alert）
    /// - Parameters:
    ///   - root: 指定起点 VC；默认自动取 rootVC
    ///   - scene: 指定场景；默认自动选择前台/最合理的
    ///   - ignoreAlert: 是否忽略 UIAlertController（比如做 present 宿主时可忽略）
    static func jobsTopMostVC(
        from root: UIViewController? = nil,
        in scene: UIScene? = nil,
        ignoreAlert: Bool = false
    ) -> UIViewController? {
        // 1) 确定起点 rootVC
        let rootVC: UIViewController? = {
            if let root { return root }
            if #available(iOS 13.0, *) {
                if let ws = (scene as? UIWindowScene) ?? bestWindowScene(),
                   let r = bestRootViewController(in: ws) { return r }
                return nil
            } else {
                return UIApplication.shared.keyWindow?.rootViewController
            }
        }()
        // 2) 递归下钻
        func visibleVC(from vc: UIViewController?) -> UIViewController? {
            guard let vc else { return nil }

            // UINavigationController
            if let nav = vc as? UINavigationController {
                return visibleVC(from: nav.visibleViewController ?? nav.topViewController ?? nav)
            }
            // UITabBarController
            if let tab = vc as? UITabBarController {
                return visibleVC(from: tab.selectedViewController ?? tab)
            }
            // UISplitViewController（一般取最后一个作为 detail）
            if let split = vc as? UISplitViewController {
                return visibleVC(from: split.viewControllers.last ?? split)
            }
            // UIPageViewController（当前页）
            if let page = vc as? UIPageViewController,
               let cur = page.viewControllers?.first {
                return visibleVC(from: cur)
            }
            // 被 present 出来的控制器（可选忽略 Alert）
            if let presented = vc.presentedViewController {
                if !(ignoreAlert && presented is UIAlertController) {
                    return visibleVC(from: presented)
                }
            };return vc
        };return visibleVC(from: rootVC)
    }
    /// ③ 全局安全区 Insets（不依赖当前 VC）
    static var jobsSafeAreaInsets: UIEdgeInsets {
        return jobsKeyWindow()?.safeAreaInsets ?? .zero
    }
    /// ④ 四个边的便捷访问
    static var jobsSafeTopInset: CGFloat { jobsSafeAreaInsets.top }
    static var jobsSafeBottomInset: CGFloat { jobsSafeAreaInsets.bottom }
    static var jobsSafeLeftInset: CGFloat { jobsSafeAreaInsets.left }
    static var jobsSafeRightInset: CGFloat { jobsSafeAreaInsets.right }
}
// MARK: - 内部实现（iOS 13+）
@available(iOS 13.0, *)
private extension UIApplication {
    /// 选择最“活跃/合理”的 windowScene（前台激活 > 前台非激活 > 其余）
    static func bestWindowScene() -> UIWindowScene? {
        func rank(_ s: UIScene.ActivationState) -> Int {
            switch s {
            case .foregroundActive:   return 0
            case .foregroundInactive: return 1
            case .background:         return 2
            default:                  return 3
            }
        };return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .sorted { rank($0.activationState) < rank($1.activationState) }
            .first
    }
    /// 在一个 windowScene 内选择“最佳窗口”
    static func bestWindow(in ws: UIWindowScene, preferMainScreen: Bool) -> UIWindow? {
        let windows = ws.windows
        guard !windows.isEmpty else { return nil }
        // 1) keyWindow 优先（iOS15 有 scene.keyWindow，但这里统一从 windows 里找）
        if let key = windows.first(where: \.isKeyWindow) {
            if !preferMainScreen || key.screen == UIScreen.main { return key }
        }
        // 2) 可见窗口优先：normal level > 非 normal
        func windowRank(_ w: UIWindow) -> (Int, Int, Int) {
            // 可见性：0(可见且normal) < 1(可见且非normal) < 2(不可见)
            let visibilityGroup: Int = {
                guard !w.isHidden, w.alpha > 0.01 else { return 2 }
                return (w.windowLevel == .normal) ? 0 : 1
            }()
            // 主屏优先
            let screenGroup = (preferMainScreen && w.screen != UIScreen.main) ? 1 : 0
            // 与 normal 的距离越小越好
            let levelDistance = Int(abs(w.windowLevel.rawValue - UIWindow.Level.normal.rawValue))
            return (visibilityGroup, screenGroup, levelDistance)
        };return windows.sorted { a, b in windowRank(a) < windowRank(b) }.first
    }
    /// 从 windowScene 取 rootVC（统一入口，供 jobsTopMostVC 使用）
    static func bestRootViewController(in ws: UIWindowScene) -> UIViewController? {
        bestWindow(in: ws, preferMainScreen: true)?.rootViewController
    }
}
