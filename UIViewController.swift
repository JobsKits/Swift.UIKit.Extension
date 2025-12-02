//
//  UIViewController.swift
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
import ObjectiveC
import QuartzCore
// ================================== UIViewController 链式扩展 ==================================
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
                   completion: (() -> Void)? = nil) -> Self {
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
        self.present(viewController, animated: animated, completion: completion)
        return self
    }
    */
    /// 统一语义化 dismiss
    @discardableResult
    func byDismiss(animated: Bool = true,
                   completion: (() -> Void)? = nil) -> Self {
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
                    layout: ((UIView) -> Void)? = nil) -> Self {
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
// ================================== GKNavigationBarSwift 包装 ==================================
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
// ================================== 数据传递 + 出现完成回调 ==================================
private enum JobsAssocKey {
    static var inputData: UInt8 = 0
    static var onResult: UInt8 = 1
    static var onAppearCompletions: UInt8 = 2
    static var appearCompletionFired: UInt8 = 3
}

extension UIViewController: JobsRouteComparable {
    @inline(__always)
    func jobs_isSameDestination(as other: UIViewController) -> Bool {
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

    fileprivate func jobs_fireAppearCompletionIfNeeded(reason: String) {
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
// ================================== 链式导航（去重） ==================================
public enum JobsPresentPolicy {
    case ignoreIfBusy
    case presentOnTopMost
}

private var _jobsPushLockKey: UInt8 = 0
private final class _JobsPushLockBox {
    var lockedUntil: TimeInterval = 0
}

private extension UINavigationController {
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
        }
        return self
    }
}

#if canImport(SnapKit)
import SnapKit
/// 利用SnapKit 给 UIViewController 加背景图（UIImageView）
public extension UIViewController {
    // MARK: - AO Key（UInt8 哨兵）
    private struct _JobsAssocKeys {
        static var imageView: UInt8 = 0
    }
    // MARK: - 懒载 imageView（挂在 VC 上）
    var jobsImageView: UIImageView {
        if let iv = objc_getAssociatedObject(self, &_JobsAssocKeys.imageView) as? UIImageView {
            return iv
        }
        let iv = UIImageView().byUserInteractionEnabled(false).byClipsToBounds(true).byContentMode(.scaleAspectFill)
        objc_setAssociatedObject(self, &_JobsAssocKeys.imageView, iv, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return iv
    }
    // MARK: - 安装并约束（默认铺满 Safe Area）
    @discardableResult
    func bgImageView(
        to container: UIView? = nil,
        contentMode: UIView.ContentMode = .scaleAspectFill,
        backgroundColor: UIColor? = nil,
        remakeConstraints: Bool = true,
        layout: ((ConstraintMaker) -> Void)? = nil
    ) -> UIImageView {
        let holder = container ?? view
        let iv = jobsImageView
        if iv.superview !== holder {
            iv.removeFromSuperview()
            holder?.addSubview(iv)
        }

        iv.contentMode = contentMode
        if let bg = backgroundColor { iv.backgroundColor = bg }

        if let layout = layout {
            if remakeConstraints { iv.snp.remakeConstraints(layout) }
            else { iv.snp.makeConstraints(layout) }
        } else {
            if remakeConstraints {
                iv.snp.remakeConstraints { make in
                    if let holder = holder {
                        make.edges.equalTo(holder.safeAreaLayoutGuide)
                    } else {
                        make.edges.equalToSuperview()
                    }
                }
            } else {
                iv.snp.makeConstraints { make in
                    if let holder = holder {
                        make.edges.equalTo(holder.safeAreaLayoutGuide)
                    } else {
                        make.edges.equalToSuperview()
                    }
                }
            }
        }
        view.sendSubviewToBack(iv)
        return iv
    }
    // MARK: - 卸载
    func removeJobsImageView() {
        jobsImageView.removeFromSuperview()
    }
}
#endif

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
// ================================== Push 方向枚举 ==================================
public enum JobsPushDirection: Int {
    case system = 0
    case fromLeft
    case fromRight
    case fromTop
    case fromBottom
}
private var _jobsPushDirKey: UInt8 = 0
// ========= 新增：记录“进入方向/时长/节奏”，用于自动匹配 pop 反向动画 =========
private var _jobsEntryDirKey: UInt8 = 0
private var _jobsEntryDurKey: UInt8 = 0
private var _jobsEntryTimingKey: UInt8 = 0
private extension UIViewController {
    var _jobs_entryDirection: JobsPushDirection? {
        get {
            guard let n = objc_getAssociatedObject(self, &_jobsEntryDirKey) as? NSNumber else { return nil }
            return JobsPushDirection(rawValue: n.intValue)
        }
        set {
            if let d = newValue {
                objc_setAssociatedObject(self, &_jobsEntryDirKey, NSNumber(value: d.rawValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &_jobsEntryDirKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    var _jobs_entryDuration: CFTimeInterval? {
        get { objc_getAssociatedObject(self, &_jobsEntryDurKey) as? CFTimeInterval }
        set { objc_setAssociatedObject(self, &_jobsEntryDurKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    var _jobs_entryTiming: CAMediaTimingFunctionName? {
        get { objc_getAssociatedObject(self, &_jobsEntryTimingKey) as? CAMediaTimingFunctionName }
        set { objc_setAssociatedObject(self, &_jobsEntryTimingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
@MainActor
public extension UIViewController {
    // ============================== 链式配置：进入方向 ===============================
    /// 设定下一次 push/present 的进入方向（不设即 .system → 系统默认右进左出）
    @discardableResult
    func byDirection(_ dir: JobsPushDirection) -> Self {
        objc_setAssociatedObject(self, &_jobsPushDirKey, NSNumber(value: dir.rawValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 清空已设置的方向（恢复默认）
    @discardableResult
    func byDirectionReset() -> Self {
        objc_setAssociatedObject(self, &_jobsPushDirKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 读取后即清空；确保“只对下一次 push 生效”
    private func _consumeDirection() -> JobsPushDirection {
        defer { byDirectionReset() }
        if let n = objc_getAssociatedObject(self, &_jobsPushDirKey) as? NSNumber,
           let d = JobsPushDirection(rawValue: n.intValue) {
            return d
        };return .system
    }
    // ============================== 使用存储方向的 byPush ==============================
    /// 现用入口：`.byDirection(...).byPush(self)`；不设方向 → 系统默认
    /// - Note: 自定义方向使用 CATransition + 无动画 push；默认方向走系统动画。
    @discardableResult
    func byPush(_ from: UIResponder?,
                duration: CFTimeInterval = 0.32,
                timing: CAMediaTimingFunctionName = .easeInEaseOut) -> Self{
        let dir = _consumeDirection()   // ← 只影响这一次
        guard let host = from?.jobsNearestVC() else {
            assertionFailure("❌ byPush: 未找到宿主 VC")
            return self
        }
        let useCustom = (dir != .system)
        // 1) 优先使用宿主导航栈
        if let nav = (host as? UINavigationController) ?? host.navigationController {
            // 轻量防连点
            if nav._jobs_isPushingLocked { return self }
            nav._jobs_lockPushing(for: 0.2)

            if useCustom {
                // 用 CATransition 模拟进入方向；push 本身必须设为非动画
                let tr = CATransition()
                tr.type = .push
                tr.subtype = dir._caSubtype
                tr.duration = duration
                tr.timingFunction = CAMediaTimingFunction(name: timing)
                nav.view.layer.add(tr, forKey: "jobs.push.\(dir._debugKey)")
                // 记录“进入动画参数”，供 pop 反向使用
                self._jobs_entryDirection = dir
                self._jobs_entryDuration = duration
                self._jobs_entryTiming = timing
                // 安装 pop swizzle（一次性）
                UINavigationController._jobs_installPopSwizzlesIfNeeded()
                nav.pushViewController(self, animated: false)
                // appear-completion 兜底
                DispatchQueue.main.async { [weak self] in
                    self?.jobs_fireAppearCompletionIfNeeded(reason: "pushCATransition")
                };return self
            } else {
                // 系统默认动画 → 不记录方向（保持系统默认 pop 行为）
                self._jobs_entryDirection = nil
                nav.pushViewController(self, animated: true)
                if let tc = nav.transitionCoordinator {
                    tc.animate(alongsideTransition: nil) { [weak self] _ in
                        self?.jobs_fireAppearCompletionIfNeeded(reason: "pushTransitionCoordinator")
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.jobs_fireAppearCompletionIfNeeded(reason: "pushAsyncFallback")
                    }
                };return self
            }
        }
        // 2) 没有导航栈：包一层 Nav 再 present（保持你原有语义）
        let wrapped = self.jobsNavContainer
            .byNavigationBarHidden(true)
            .byModalPresentationStyle(.fullScreen)
        if useCustom {
            let layer = host.view.window?.layer ?? host.view.layer
            let tr = CATransition()
            tr.type = .push
            tr.subtype = dir._caSubtype
            tr.duration = duration
            tr.timingFunction = CAMediaTimingFunction(name: timing)
            layer.add(tr, forKey: "jobs.present.push.\(dir._debugKey)")

            // 记录进入参数（仅供需要时外部自定义 dismiss 使用；系统 dismiss 默认方向不改）
            self._jobs_entryDirection = dir
            self._jobs_entryDuration = duration
            self._jobs_entryTiming = timing

            host.present(wrapped, animated: false) { [weak self] in
                self?.jobs_fireAppearCompletionIfNeeded(reason: "presentWrappedForPushCATransition")
            }
        } else {
            self._jobs_entryDirection = nil
            host.present(wrapped, animated: true) { [weak self] in
                self?.jobs_fireAppearCompletionIfNeeded(reason: "presentWrappedForPush")
            }
        };return self
    }
    // ======================= 兼容旧签名（可留可删，不影响你现在用法） =======================
    /// 旧签名：允许显式传方向；内部转为“临时设置方向再调用 byPush”
    @discardableResult
    func byPush(_ from: UIResponder?,
                direction: JobsPushDirection,
                duration: CFTimeInterval = 0.32,
                CAMediaTimingFunctionName timing: CAMediaTimingFunctionName = .easeInEaseOut) -> Self {
        return self.byDirection(direction).byPush(from, duration: duration, timing: timing)
    }
}
// MARK: - 内部：CATransition 的方向映射（含上下互换修正）
private extension JobsPushDirection {
    var _caSubtype: CATransitionSubtype {
        switch self {
        case .system, .fromRight:
            return .fromRight            // 系统默认右进
        case .fromLeft:
            return .fromLeft
        case .fromTop:
            return .fromBottom           // ✅ 修正：互换上下（视觉为“自上而下”进入）
        case .fromBottom:
            return .fromTop              // ✅ 修正：互换上下（视觉为“自下而上”进入）
        }
    }
    // 反向用于 pop：与上面的 subtype 取互逆
    var _reverseCASubtype: CATransitionSubtype {
        switch self {
        case .system, .fromRight: return .fromLeft
        case .fromLeft:           return .fromRight
        case .fromTop:            return .fromTop     // push 用了 .fromBottom，pop 用 .fromTop
        case .fromBottom:         return .fromBottom  // push 用了 .fromTop，pop 用 .fromBottom
        }
    }
    var _debugKey: String {
        switch self {
        case .system:     return "system"
        case .fromLeft:   return "fromLeft"
        case .fromRight:  return "fromRight"
        case .fromTop:    return "fromTop"
        case .fromBottom: return "fromBottom"
        }
    }
}
// ====================== 新增：UINavigationController 的 pop swizzle ======================
private enum _JobsNavPopSwizzleOnceToken { static var done = false }
private extension UINavigationController {
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
// MARK: - 给“实现了 JobsDataReceivable 的 VC”提供强类型重载：编译期直达 receive(_:)
extension JobsDataReceivable where Self: UIViewController {
    @discardableResult
    func byData(_ data: InputData) -> Self {
        receive(data)
        return self
    }
}
