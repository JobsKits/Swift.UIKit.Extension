//
//  UIViewController+GKNavigationBarSwift.swift
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

#if canImport(GKNavigationBarSwift)
import GKNavigationBarSwift
public extension UIViewController {
    /// 统一配置 GKNav
    /// - Parameters:
    ///   - title: JobsText（支持纯文本/富文本，这里取 rawString 写到 gk_navTitle）
    ///   - leftButton: 左侧按钮（UIButton）。nil → 使用默认“< 返回”
    ///   - rightButtons: 右侧按钮组（[UIButton]）。nil 或空 → 不创建
    func jobsSetupGKNav(
        title: JobsText,
        leftButton: UIButton? = nil,
        rightButtons: [UIButton]? = nil
    ) {
        // 标题（GK 只吃 String）
        gk_navTitle = title.asString

        // 左侧按钮：nil → 默认返回；否则用传入的 UIButton
        if let btn = leftButton {
            gk_navLeftBarButtonItem = UIBarButtonItem(customView: btn)
        } else {
            gk_navLeftBarButtonItem = UIBarButtonItem(
                customView: makeDefaultBackButton()
            )
        }
        // 右侧按钮：只有在非空时才创建
        if let items = rightButtons, !items.isEmpty {
            gk_navRightBarButtonItems = items.map { UIBarButtonItem(customView: $0) }
        } else {
            gk_navRightBarButtonItems = nil
        }
    }
    // MARK: - 内置：默认“< 返回”按钮（SF Symbol: chevron.left）
    private func makeDefaultBackButton() -> UIButton {
        UIButton(type: .system)
            .byFrame(CGRect(x: 0, y: 0, width: 32.w, height: 32.h))
            .byTintColor(.white)
            .byImage("chevron.left".sysImg, for: .normal)
            .byContentEdgeInsets(.zero)
            .byTitleEdgeInsets(.zero)
            .onTap { [weak self] _ in
                guard let self else { return }
                goBack("") // 系统通用返回
            }
    }
    /// 立即隐藏/显示 GK 的导航栏（并把系统栏同步隐藏，避免双栏）
    @discardableResult
    func byGKNavBarHidden(_ hidden: Bool) -> Self {
        _ = gk_navigationBar                 // 触发创建与挂载
        gk_navigationBar.isHidden = hidden   // 真实隐藏 GK 的 bar
        navigationController?.setNavigationBarHidden(hidden, animated: false) // 避免系统栏干扰
        return self
    }
    /// 透明导航/恢复（不移除视图，适合沉浸式）
    @discardableResult
    func byGKNavTransparent(_ enable: Bool) -> Self {
        _ = gk_navigationBar
        if enable {
            gk_navBarAlpha = 0
            gk_navLineHidden = true
        } else {
            gk_navBarAlpha = 1
            gk_navLineHidden = false
        };return self
    }
}
#endif
