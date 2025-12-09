//
//  UIWindow.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/4/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
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
