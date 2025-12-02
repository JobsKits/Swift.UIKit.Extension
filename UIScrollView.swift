//
//  UIScrollView.swift
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
import ObjectiveC.runtime
import SnapKit

extension UIScrollView {
    // MARK:  Basics
    @discardableResult
    func byContentSize(_ size: CGSize) -> Self {
        self.contentSize = size
        return self
    }

    @discardableResult
    func byContentOffsetBy(_ offset: CGPoint) -> Self {
        self.setContentOffset(offset, animated: false)
        return self
    }

    @discardableResult
    func byContentOffsetByAnimated(_ offset: CGPoint) -> Self {
        self.setContentOffset(offset, animated: true)
        return self
    }

    @discardableResult
    func byShowsVerticalScrollIndicator(_ show: Bool) -> Self {
        self.showsVerticalScrollIndicator = show
        return self
    }

    @discardableResult
    func byShowsHorizontalScrollIndicator(_ show: Bool) -> Self {
        self.showsHorizontalScrollIndicator = show
        return self
    }

    @discardableResult
    func byBounces(_ bounces: Bool) -> Self {
        self.bounces = bounces
        return self
    }

    @discardableResult
    func byAlwaysBounceVertical(_ enable: Bool) -> Self {
        self.alwaysBounceVertical = enable
        return self
    }

    @discardableResult
    func byAlwaysBounceHorizontal(_ enable: Bool) -> Self {
        self.alwaysBounceHorizontal = enable
        return self
    }

    @discardableResult
    func byPagingEnabled(_ enabled: Bool) -> Self {
        self.isPagingEnabled = enabled
        return self
    }

    @discardableResult
    func byScrollEnabled(_ enabled: Bool) -> Self {
        self.isScrollEnabled = enabled
        return self
    }

    @discardableResult
    func byDirectionalLockEnabled(_ enabled: Bool) -> Self {
        self.isDirectionalLockEnabled = enabled
        return self
    }

    @discardableResult
    func byScrollIndicatorInsets(_ insets: UIEdgeInsets) -> Self {
        self.scrollIndicatorInsets = insets
        return self
    }

    @discardableResult
    func byContentInset(_ insets: UIEdgeInsets) -> Self {
        self.contentInset = insets
        return self
    }

    @discardableResult
    func byIndicatorStyle(_ style: UIScrollView.IndicatorStyle) -> Self {
        self.indicatorStyle = style
        return self
    }
    /// 改为可选，便于置空
    @discardableResult
    func byDelegate(_ delegate: UIScrollViewDelegate?) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult
    func byKeyboardDismissMode(_ mode: UIScrollView.KeyboardDismissMode) -> Self {
        self.keyboardDismissMode = mode
        return self
    }

    @discardableResult
    func byRefreshControl(_ control: UIRefreshControl?) -> Self {
        self.refreshControl = control
        return self
    }

    @discardableResult
    func byDecelerationRate(_ rate: UIScrollView.DecelerationRate) -> Self {
        self.decelerationRate = rate
        return self
    }

    @discardableResult
    func byScrollsToTop(_ enabled: Bool) -> Self {
        self.scrollsToTop = enabled
        return self
    }
    // MARK:  Insets & Adjustment
    /// iOS 11.0+ 内容 inset 自动调整行为
    @available(iOS 11.0, *)
    @discardableResult
    func byContentInsetAdjustmentBehavior(_ behavior: UIScrollView.ContentInsetAdjustmentBehavior) -> Self {
        self.contentInsetAdjustmentBehavior = behavior
        return self
    }
    /// iOS 13.0+ 自动调整滚动条 inset
    @available(iOS 13.0, *)
    @discardableResult
    func byAutomaticallyAdjustsScrollIndicatorInsets(_ enable: Bool) -> Self {
        self.automaticallyAdjustsScrollIndicatorInsets = enable
        return self
    }
    /// iOS 11.1+ 垂直滚动条 inset
    @available(iOS 11.1, *)
    @discardableResult
    func byVerticalScrollIndicatorInsets(_ insets: UIEdgeInsets) -> Self {
        self.verticalScrollIndicatorInsets = insets
        return self
    }
    /// iOS 11.1+ 水平滚动条 inset
    @available(iOS 11.1, *)
    @discardableResult
    func byHorizontalScrollIndicatorInsets(_ insets: UIEdgeInsets) -> Self {
        self.horizontalScrollIndicatorInsets = insets
        return self
    }
    // MARK: Keyboard Scrolling
    /// iOS 17.0+ 允许键盘方向键滚动
    @available(iOS 17.0, *)
    @discardableResult
    func byAllowsKeyboardScrolling(_ enable: Bool) -> Self {
        self.allowsKeyboardScrolling = enable
        return self
    }
    // MARK: iOS 17.4+ 属性组
    /// iOS 17.4+ 内容对齐点
    @available(iOS 17.4, *)
    @discardableResult
    func byContentAlignmentPoint(_ point: CGPoint) -> Self {
        self.contentAlignmentPoint = point
        return self
    }
    /// iOS 17.4+ 水平回弹
    @available(iOS 17.4, *)
    @discardableResult
    func byBouncesHorizontally(_ enable: Bool) -> Self {
        self.bouncesHorizontally = enable
        return self
    }
    /// iOS 17.4+ 垂直回弹
    @available(iOS 17.4, *)
    @discardableResult
    func byBouncesVertically(_ enable: Bool) -> Self {
        self.bouncesVertically = enable
        return self
    }
    /// iOS 17.4+ 是否将水平滚动交给父级
    @available(iOS 17.4, *)
    @discardableResult
    func byTransfersHorizontalScrollingToParent(_ enable: Bool) -> Self {
        self.transfersHorizontalScrollingToParent = enable
        return self
    }
    /// iOS 17.4+ 是否将垂直滚动交给父级
    @available(iOS 17.4, *)
    @discardableResult
    func byTransfersVerticalScrollingToParent(_ enable: Bool) -> Self {
        self.transfersVerticalScrollingToParent = enable
        return self
    }
    /// iOS 17.4+ 滚动 offset 变化时强制显示滚动条
    @available(iOS 17.4, *)
    @discardableResult
    func byWithScrollIndicatorsShownForContentOffsetChanges(_ changes: () -> Void) -> Self {
        self.withScrollIndicatorsShown(forContentOffsetChanges: changes)
        return self
    }
    /// iOS 17.4+ 立即停止滚动与缩放动画
    @available(iOS 17.4, *)
    @discardableResult
    func byStopScrollingAndZooming() -> Self {
        self.stopScrollingAndZooming()
        return self
    }

    // MARK: Touch Behavior
    @discardableResult
    func byDelaysContentTouches(_ enable: Bool) -> Self {
        self.delaysContentTouches = enable
        return self
    }

    @discardableResult
    func byCanCancelContentTouches(_ enable: Bool) -> Self {
        self.canCancelContentTouches = enable
        return self
    }
    // MARK: Zoom
    @discardableResult
    func byMinimumZoomScale(_ scale: CGFloat) -> Self {
        self.minimumZoomScale = scale
        return self
    }

    @discardableResult
    func byMaximumZoomScale(_ scale: CGFloat) -> Self {
        self.maximumZoomScale = scale
        return self
    }

    @discardableResult
    func byZoomScale(_ scale: CGFloat, animated: Bool = false) -> Self {
        if animated {
            self.setZoomScale(scale, animated: true)
        } else {
            self.zoomScale = scale
        }
        return self
    }

    @discardableResult
    func byBouncesZoom(_ enable: Bool) -> Self {
        self.bouncesZoom = enable
        return self
    }

    @discardableResult
    func byZoom(to rect: CGRect, animated: Bool) -> Self {
        self.zoom(to: rect, animated: animated)
        return self
    }
    // MARK: Indicators
    @discardableResult
    func byShowsIndicators(vertical: Bool? = nil, horizontal: Bool? = nil) -> Self {
        if let v = vertical { self.showsVerticalScrollIndicator = v }
        if let h = horizontal { self.showsHorizontalScrollIndicator = h }
        return self
    }

    @discardableResult
    func byFlashScrollIndicators() -> Self {
        self.flashScrollIndicators()
        return self
    }
    // MARK: Visible Rect
    @discardableResult
    func byScrollRectToVisible(_ rect: CGRect, animated: Bool) -> Self {
        self.scrollRectToVisible(rect, animated: animated)
        return self
    }
    // MARK: Index Display
    @discardableResult
    func byIndexDisplayMode(_ mode: UIScrollView.IndexDisplayMode) -> Self {
        self.indexDisplayMode = mode
        return self
    }
    // MARK: Gesture Config
    @discardableResult
    func byPanGesture(_ config: (UIPanGestureRecognizer) -> Void) -> Self {
        config(self.panGestureRecognizer)
        return self
    }

    @available(iOS 5.0, *)
    @discardableResult
    func byPinchGesture(_ config: (UIPinchGestureRecognizer) -> Void) -> Self {
        if let pinch = self.pinchGestureRecognizer {
            config(pinch)
        }
        return self
    }

    @discardableResult
    func byDirectionalPressGesture(_ config: (UIGestureRecognizer) -> Void) -> Self {
        config(self.directionalPressGestureRecognizer)
        return self
    }
    // MARK:  iOS 26.0+ Scroll Edge Effects
    @available(iOS 26.0, *)
    @discardableResult
    func byTopEdgeEffect(_ config: (UIScrollEdgeEffect) -> Void) -> Self {
        config(self.topEdgeEffect)
        return self
    }

    @available(iOS 26.0, *)
    @discardableResult
    func byLeftEdgeEffect(_ config: (UIScrollEdgeEffect) -> Void) -> Self {
        config(self.leftEdgeEffect)
        return self
    }

    @available(iOS 26.0, *)
    @discardableResult
    func byBottomEdgeEffect(_ config: (UIScrollEdgeEffect) -> Void) -> Self {
        config(self.bottomEdgeEffect)
        return self
    }

    @available(iOS 26.0, *)
    @discardableResult
    func byRightEdgeEffect(_ config: (UIScrollEdgeEffect) -> Void) -> Self {
        config(self.rightEdgeEffect)
        return self
    }
}
// MARK: - UIScrollView层：统一的占位能力@按钮
#if canImport(SnapKit)
import SnapKit
public enum JobsEmptyAuto {
    public enum Config {
        /// 全局默认按钮提供器（你可在 App 任何位置重写）
        public static var defaultProvider: () -> UIButton = {
            UIButton(type: .system)
                .byTitle("暂无数据", for: .normal)
                .bySubTitle("下拉刷新或点我试试", for: .normal)
                .byTitleFont(.systemFont(ofSize: 18, weight: .semibold))
                .bySubTitleFont(.systemFont(ofSize: 13))
                .byTitleColor(.label, for: .normal)
                .bySubTitleColor(.secondaryLabel, for: .normal)
                .byImage("tray".sysImg, for: .normal)
                .byImagePlacement(.top)
        }
    }

    private static var once: Void = {
        // UITableView.reloadData
        _swizzle(UITableView.self,
                 #selector(UITableView.reloadData),
                 #selector(UITableView.jobs_swizzled_reloadData))
        // UICollectionView.reloadData
        _swizzle(UICollectionView.self,
                 #selector(UICollectionView.reloadData),
                 #selector(UICollectionView.jobs_swizzled_reloadData))
        // UICollectionView.performBatchUpdates(_:completion:)
        _swizzle(UICollectionView.self,
                 #selector(UICollectionView.performBatchUpdates(_:completion:)),
                 #selector(UICollectionView.jobs_swizzled_performBatchUpdates(_:completion:)))
    }()
    public static func enable() { _JobsEmptySwizzle.ensureOnce() }  // 幂等
    private static func _swizzle(_ cls: AnyClass, _ original: Selector, _ swizzled: Selector) {
        guard let m1 = class_getInstanceMethod(cls, original),
              let m2 = class_getInstanceMethod(cls, swizzled) else { return }
        method_exchangeImplementations(m1, m2)
    }
}

private enum _JobsEmptyAutoBootstrap {
    static var ensure: Void = { JobsEmptyAuto.enable() }()
}

private enum _JobsEmptySwizzle {
    // 只执行一次，幂等
    private static var did = false
    static func ensureOnce() {
        guard !did else { return }
        did = true

        func exch(_ cls: AnyClass, _ o: Selector, _ s: Selector) {
            guard
                let m1 = class_getInstanceMethod(cls, o),
                let m2 = class_getInstanceMethod(cls, s)
            else { return }
            method_exchangeImplementations(m1, m2)
        }

        // UICollectionView
        exch(UICollectionView.self,
             #selector(UICollectionView.reloadData),
             #selector(UICollectionView.jobs_swizzled_reloadData))

        if #available(iOS 13.0, *) {
            exch(UICollectionView.self,
                 #selector(UICollectionView.performBatchUpdates(_:completion:)),
                 #selector(UICollectionView.jobs_swizzled_performBatchUpdates(_:completion:)))
        }

        // （如你也 swizzle 了 UITableView，在这里同理放进去；不会重复）
        // exch(UITableView.self, #selector(UITableView.reloadData), #selector(UITableView.jobs_swizzled_reloadData))
        // if #available(iOS 13.0, *) {
        //     exch(UITableView.self,
        //          #selector(UITableView.performBatchUpdates(_:completion:)),
        //          #selector(UITableView.jobs_swizzled_performBatchUpdates(_:completion:)))
        // }
    }
}
private var _jobsEmptyBtnKey: UInt8       = 0
private var _jobsEmptyProviderKey: UInt8  = 0
private var _jobsEmptyDisabledKey: UInt8  = 0
public extension UIScrollView {
    // MARK: - 存取：全局/局部 Provider
    /// 链式：设置“本视图”的局部空态按钮提供器（会触发懒 swizzle）
    @discardableResult
    func jobs_emptyButtonProvider(_ provider: @escaping () -> UIButton) -> Self {
        _JobsEmptySwizzle.ensureOnce() // ← 保证只交换一次
        objc_setAssociatedObject(self, &_jobsEmptyProviderKey, provider, .OBJC_ASSOCIATION_COPY_NONATOMIC)

        // 可选：切换 provider 时，丢弃旧按钮，下一次自动重建
        if let btn = jobs_emptyButton {
            btn.removeFromSuperview()
            objc_setAssociatedObject(self, &_jobsEmptyBtnKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return self
    }
    /// 链式：清除“本视图”的局部 Provider（回退到全局默认）
    @discardableResult
    func jobs_clearEmptyButtonProvider() -> Self {
        let _ = _JobsEmptyAutoBootstrap.ensure
        objc_setAssociatedObject(self, &_jobsEmptyProviderKey, nil, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }
    /// 内部读取：局部 Provider
    fileprivate var _jobs_localProvider: (() -> UIButton)? {
        objc_getAssociatedObject(self, &_jobsEmptyProviderKey) as? (() -> UIButton)
    }
    // MARK: - 状态：当前按钮 & 开关
    /// 当前挂载的空态按钮（只读）
    var jobs_emptyButton: UIButton? {
        objc_getAssociatedObject(self, &_jobsEmptyBtnKey) as? UIButton
    }
    /// 关闭本视图的“自动空态”（默认 false）
    var jobs_emptyAutoDisabled: Bool {
        get { (objc_getAssociatedObject(self, &_jobsEmptyDisabledKey) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &_jobsEmptyDisabledKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    // MARK: - 显隐控制（保留原手动/自动 API）
    /// 手动显隐：业务自己判断 empty -> true/false
    @discardableResult
    func jobs_reloadEmptyViewManual(isEmpty: Bool) -> Self {
        let _ = _JobsEmptyAutoBootstrap.ensure
        jobs_emptyButton?.isHidden = !isEmpty
        return self
    }
    /// 自动判断（支持 UITableView / UICollectionView）
    // MARK: - 自动评估空态显隐
    @discardableResult
    func jobs_reloadEmptyViewAuto(animated: Bool = true) -> Self {
        _JobsEmptySwizzle.ensureOnce()                 // 幂等交换一次
        _jobs_ensureEmptyButtonIfNeeded()              // 懒创建并布置约束（若有 provider）

        // 仅表格/集合视图需要自动显隐
        let isEmpty: Bool
        if let t = self as? UITableView {
            isEmpty = _jobs_isEmpty(for: t)
        } else if let c = self as? UICollectionView {
            isEmpty = _jobs_isEmpty(for: c)
        } else {
            return self
        }

        guard let btn = jobs_emptyButton else { return self }

        // 切显隐（带轻动画）；显示时放到最上层
        if animated {
            if isEmpty {
                if btn.isHidden { btn.alpha = 0; btn.isHidden = false }
                bringSubviewToFront(btn)
                UIView.animate(withDuration: 0.15) { btn.alpha = 1 }
            } else {
                UIView.animate(withDuration: 0.15, animations: { btn.alpha = 0 }) { _ in
                    btn.isHidden = true
                }
            }
        } else {
            btn.alpha = isEmpty ? 1 : 0
            btn.isHidden = !isEmpty
        }
        btn.isUserInteractionEnabled = isEmpty
        return self
    }
    // MARK: - 懒创建空态按钮 & 约束
    private func _jobs_ensureEmptyButtonIfNeeded() {
        // 已有按钮或没有 provider -> 不创建
        guard jobs_emptyButton == nil,
              let provider = objc_getAssociatedObject(self, &_jobsEmptyProviderKey) as? () -> UIButton
        else { return }

        let btn = provider()
        btn.isHidden = true
        btn.alpha = 0
        addSubview(btn)
        objc_setAssociatedObject(self, &_jobsEmptyBtnKey, btn, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // 若外部提供了自定义布局闭包，优先使用；否则走默认约束
        if let anyLayout = objc_getAssociatedObject(self, &_jobsEmptyLayoutKey) {
            #if canImport(SnapKit)
            if let layout = anyLayout as? (UIButton, SnapKit.ConstraintMaker, UIScrollView) -> Void {
                btn.snp.remakeConstraints { make in layout(btn, make, self) }
            } else {
                _jobs_defaultEmptyButtonConstraints(btn)
            }
            #else
            _jobs_defaultEmptyButtonConstraints(btn)
            #endif
        } else {
            _jobs_defaultEmptyButtonConstraints(btn)
        }
    }

    private func _jobs_defaultEmptyButtonConstraints(_ btn: UIButton) {
        btn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
    }
    // MARK: - 创建/挂载/评估
    /// 若无按钮则按“局部 > 全局”提供器创建并挂载；随后评估显隐
    func _jobs_autoEnsureEmptyButtonThenEval() {
        guard !jobs_emptyAutoDisabled else { return }
        if jobs_emptyButton == nil {
            let button = (_jobs_localProvider ?? JobsEmptyAuto.Config.defaultProvider)()
            _jobs_attachEmptyButton(button)
        };jobs_reloadEmptyViewAuto()
    }
    /// 把按钮挂载到当前 ScrollView 上（会清旧的）
    fileprivate func _jobs_attachEmptyButton(_ btn: UIButton) {
        // 若按钮原本挂在别处，先摘
        if let sv = btn.superview, sv !== self { btn.removeFromSuperview() }
        // 清旧约束
        btn.snp.removeConstraints()
        // 移除旧按钮
        if let old = jobs_emptyButton { old.removeFromSuperview() }
        addSubview(btn)
        bringSubviewToFront(btn)
        // 自定义布局优先；否则使用默认居中 + 宽度<=90% + 左右不贴边
        btn.snp.makeConstraints { make in
            if let L = btn._jobsEmptyLayout {
                L(btn, make, self)
            } else {
                make.center.equalToSuperview()
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.9)
                make.leading.greaterThanOrEqualToSuperview().offset(16)
                make.trailing.lessThanOrEqualToSuperview().inset(16)
            }
        };objc_setAssociatedObject(self, &_jobsEmptyBtnKey, btn, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    /// 判空：UITableView
    fileprivate func _jobs_isEmpty(for table: UITableView) -> Bool {
        guard let ds = table.dataSource else { return true }
        let sections = ds.numberOfSections?(in: table) ?? 1
        if sections == 0 { return true }
        var rows = 0
        for s in 0..<sections {
            rows += ds.tableView(table, numberOfRowsInSection: s)
            if rows > 0 { return false }
        };return true
    }
    /// 判空：UICollectionView
    fileprivate func _jobs_isEmpty(for collection: UICollectionView) -> Bool {
        guard let ds = collection.dataSource else { return true }
        let sections = ds.numberOfSections?(in: collection) ?? 1
        if sections == 0 { return true }
        var items = 0
        for s in 0..<sections {
            items += ds.collectionView(collection, numberOfItemsInSection: s)
            if items > 0 { return false }
        };return true
    }
}
#endif
