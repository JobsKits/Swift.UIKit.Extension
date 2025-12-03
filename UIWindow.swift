//
//  UIWindow.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/4/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

public extension UIWindow {
    /// 返回一个“保证非空”的 UIWindow
    /// - 优先 jobsKeyWindow（真实窗口）
    /// - 取不到时兜底创建一个离屏窗口，避免 unwrap 报错
    static var wd: UIWindow {
        if let real = UIApplication.jobsKeyWindow() {
            return real
        } else {
            // ✅ 构造一个兜底 window（不会显示，只用于防止 nil）
            return UIWindow(frame: UIScreen.main.bounds).byWindowLevel(.alert + 1)
        }
    }
    /// 实例访问也保持一致
    var wd: UIWindow { Self.wd }
}
// ================================== UIWindow 语法糖 ==================================
public extension UIWindow {
    // MARK: - 构造 / 附着
    /// 绑定到指定 WindowScene（不会 makeKeyAndVisible）
    @discardableResult
    func byAttach(to scene: UIWindowScene?) -> Self {
        // iOS 13+，且外界可传 nil（nil 时不动）
        if #available(iOS 13.0, *), let scene {
            // 注意：不要强行覆盖另一个 scene 的 window
            if self.windowScene !== scene {
                self.windowScene = scene
            }
        };return self
    }
    // MARK: - 根控制器 / 可见性
    @discardableResult
    func byRootViewController(_ vc: UIViewController?) -> Self {
        self.rootViewController = vc
        return self
    }
    /// 仅 makeKey
    @discardableResult
    func byMakeKey() -> Self {
        self.makeKey()
        return self
    }
    /// makeKeyAndVisible（最常用）
    @discardableResult
    func byMakeKeyAndVisible() -> Self {
        self.makeKeyAndVisible()
        return self
    }
    /// 退位（让位于别的 window）
    @discardableResult
    func byResignKey() -> Self {
        self.resignKey()
        return self
    }
    // MARK: - 外观 / 显示层级
    @discardableResult
    func byWindowLevel(_ level: UIWindow.Level) -> Self {
        self.windowLevel = level
        return self
    }

    @available(*, deprecated, message: "Use windowScene assignment instead on iOS 13+")
    @discardableResult
    func byScreen(_ screen: UIScreen) -> Self {
        if #available(iOS 13.0, *) {
            if let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.screen == screen }) {
                self.windowScene = scene
            }
        } else {
            self.screen = screen
        };return self
    }
    // MARK: - 工具方法（少量“好用但容易踩坑”的动作）
    /// 快照整窗（不跨进程，不含系统状态栏）
    func snapshotImage(afterScreenUpdates: Bool = true) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
    /// 在最顶层控制器 present 一个 VC（避免直接对 window 做 VC 管理）
    @discardableResult
    func presentOnTop(_ vc: UIViewController,
                      animated: Bool = true,
                      completion: (() -> Void)? = nil) -> Self {
        guard let host = UIWindow.jobsTopMost(from: self.rootViewController) else { return self }
        // 宿主正在转场就别叠
        if host.transitionCoordinator != nil { return self }
        // 目标不能已经挂载
        if vc.parent != nil || vc.presentingViewController != nil { return self }
        host.present(vc, animated: animated, completion: completion)
        return self
    }
    // MARK: - 坐标转换（链式味道）
    @discardableResult
    func byConvert(_ point: CGPoint, to other: UIWindow?, sink: (CGPoint) -> Void) -> Self {
        sink(convert(point, to: other))
        return self
    }

    @discardableResult
    func byConvert(_ rect: CGRect, to other: UIWindow?, sink: (CGRect) -> Void) -> Self {
        sink(convert(rect, to: other))
        return self
    }
}
// ================================== 全局辅助（Scene 安全） ==================================
public extension UIWindow {
    /// 当前前台激活 scene 中的 keyWindow（尽量精确）
    static func jobsKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
            // 前台激活优先
            let ordered = scenes.sorted { lhs, rhs in
                func rank(_ s: UIScene.ActivationState) -> Int {
                    switch s {
                    case .foregroundActive:   return 0
                    case .foregroundInactive: return 1
                    case .background:         return 2
                    default:                  return 3
                    }
                };return rank(lhs.activationState) < rank(rhs.activationState)
            }
            for s in ordered {
                if let w = s.windows.first(where: \.isKeyWindow) { return w }
                if let w = s.windows.first { return w } // 次优
            };return nil
        } else {
            // 仅给老系统兜底（新项目通常不走这里）
            return legacyKeyWindowPreiOS13()
        }
    }
    /// 新建并附着到“最合适”的前台 scene（iOS 26+ 不要再用 init(frame:)）
    @discardableResult
    static func jobsMake(scene: UIWindowScene? = nil,
                         root: UIViewController? = nil,
                         level: UIWindow.Level = .normal,
                         makeKeyVisible: Bool = true) -> UIWindow {
        let targetScene: UIWindowScene? = {
            if #available(iOS 13.0, *) {
                if let scene { return scene }
                return UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first { $0.activationState == .foregroundActive }
                    ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
            } else {
                return nil
            }
        }()

        let win: UIWindow
        if #available(iOS 13.0, *), let s = targetScene {
            win = UIWindow(windowScene: s)
        } else {
            // 仅老系统路径；iOS 26 起这条是 deprecated，不在新系统上使用
            win = UIWindow(frame: UIScreen.main.bounds)
        }
        return win
            .byRootViewController(root)
            .byWindowLevel(level)
            ._makeIfNeeded(makeKeyVisible)
    }
    // 顶层 VC（跨 UINavigationController / UITabBarController / presented 链）
    static func jobsTopMost(from base: UIViewController?) -> UIViewController? {
        guard let base else { return nil }
        if let nav = base as? UINavigationController {
            return jobsTopMost(from: nav.visibleViewController ?? nav.topViewController)
        }
        if let tab = base as? UITabBarController {
            return jobsTopMost(from: tab.selectedViewController)
        }
        if let presented = base.presentedViewController {
            return jobsTopMost(from: presented)
        };return base
    }
    // 私有小工具：是否 makeKeyAndVisible
    @discardableResult
    private func _makeIfNeeded(_ flag: Bool) -> Self {
        if flag { self.makeKeyAndVisible() }
        return self
    }
}
