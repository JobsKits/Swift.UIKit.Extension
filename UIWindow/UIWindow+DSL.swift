//
//  UIWindow+DSL.swift
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
