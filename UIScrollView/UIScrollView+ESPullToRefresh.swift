//
//  UIScrollView+ESPullToRefresh.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/6/25.
//
#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

#if canImport(ESPullToRefresh) && canImport(SnapKit)
import ESPullToRefresh
import SnapKit
// MARK: - Jobs Refresh Extension
public extension UIScrollView {
    // MARK: - 下拉刷新（Pull Down）
    /// 安装下拉刷新（默认 ESRefreshHeaderAnimator）
    @discardableResult
    func pullDown(_ action: @escaping () -> Void,
                  config: ((ESRefreshHeaderAnimator) -> Void)? = nil) -> Self {
        if self.header == nil {
            let animator = ESRefreshHeaderAnimator()
            config?(animator)
            let header = ESRefreshHeaderView(frame: .zero, handler: action, animator: animator)
            let headerH = animator.executeIncremental
            header.frame = CGRect(x: 0, y: -headerH, width: self.bounds.width, height: headerH)
            self.addSubview(header)
            self.header = header
        }
        return self
    }
    /// 安装下拉刷新（JobsHeaderAnimator 自定义样式）
    @discardableResult
    func pullDownWithJobsAnimator(_ action: @escaping () -> Void,
                                  config: ((JobsHeaderAnimator) -> Void)? = nil) -> Self {
        if self.header == nil {
            let animator = JobsHeaderAnimator()
            config?(animator)
            let header = ESRefreshHeaderView(frame: .zero, handler: action, animator: animator)
            let headerH = animator.executeIncremental
            header.frame = CGRect(x: 0, y: -headerH, width: self.bounds.width, height: headerH)
            self.addSubview(header)
            self.header = header
        }
        return self
    }
    /// 过期自动刷新
    @discardableResult
    func pullDownAutoIfExpired() -> Self {
        if let key = self.header?.refreshIdentifier, JobsRefreshCache.isExpired(forKey: key) {
            DispatchQueue.main.async { [weak self] in
                self?.header?.startRefreshing(isAuto: true)
            }
        }
        return self
    }
    /// 停止下拉刷新
    @discardableResult
    func pullDownStop(ignoreDate: Bool = false, ignoreFooter: Bool = false) -> Self {
        self.header?.stopRefreshing()
        if ignoreDate == false, let key = self.header?.refreshIdentifier {
            JobsRefreshCache.setDate(Date(), forKey: key) // ✅ 自家缓存
        }
        self.footer?.isHidden = ignoreFooter
        return self
    }
    /// 手动触发下拉刷新
    @discardableResult
    func pullDownStart(auto: Bool = false) -> Self {
        DispatchQueue.main.async { [weak self] in
            if auto { self?.header?.startRefreshing(isAuto: true) }
            else { self?.header?.startRefreshing(isAuto: false) }
        }
        return self
    }
    // MARK: - 上拉加载（Pull Up）
    /// 安装上拉加载（默认 ESRefreshFooterAnimator）
    @discardableResult
    func pullUp(_ action: @escaping () -> Void,
                config: ((ESRefreshFooterAnimator) -> Void)? = nil) -> Self {
        if self.footer == nil {
            let animator = ESRefreshFooterAnimator()
            config?(animator)
            let footer = ESRefreshFooterView(frame: .zero, handler: action, animator: animator)
            let footerH = animator.executeIncremental
            footer.frame = CGRect(
                x: 0,
                y: self.contentSize.height + self.contentInset.bottom,
                width: self.bounds.width,
                height: footerH
            )
            self.addSubview(footer)
            self.footer = footer
        }
        return self
    }
    /// 安装上拉加载（JobsFooterAnimator 自定义样式）
    @discardableResult
    func pullUpWithJobsAnimator(_ action: @escaping () -> Void,
                                config: ((JobsFooterAnimator) -> Void)? = nil) -> Self {
        if self.footer == nil {
            let animator = JobsFooterAnimator()
            config?(animator)
            let footer = ESRefreshFooterView(frame: .zero, handler: action, animator: animator)
            let footerH = animator.executeIncremental
            footer.frame = CGRect(
                x: 0,
                y: self.contentSize.height + self.contentInset.bottom,
                width: self.bounds.width,
                height: footerH
            )
            self.addSubview(footer)
            self.footer = footer
        }
        return self
    }
    /// 停止上拉加载
    @discardableResult
    func pullUpStop() -> Self {
        self.footer?.stopRefreshing()
        return self
    }
    /// 通知“没有更多数据”
    @discardableResult
    func pullUpNoMore() -> Self {
        self.footer?.stopRefreshing()
        self.footer?.noMoreData = true
        return self
    }
    /// 重置“没有更多数据”
    @discardableResult
    func pullUpReset() -> Self {
        self.footer?.noMoreData = false
        return self
    }
    // MARK: - 移除所有刷新控件
    @discardableResult
    func removeRefreshers() -> Self {
        self.header?.stopRefreshing()
        self.header?.removeFromSuperview()
        self.header = nil

        self.footer?.stopRefreshing()
        self.footer?.removeFromSuperview()
        self.footer = nil
        return self
    }
}
// MARK: - 下拉刷新（Header）
public final class JobsHeaderAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol {
    public var state: ESRefreshViewState = .pullToRefresh

    public var idleDescription: String = "下拉刷新"
    public var releaseToRefreshDescription: String = "松开立即刷新"
    public var loadingDescription: String = "刷新中…"
    public var noMoreDataDescription: String = "已经是最新数据"

    public var view: UIView { self }
    public var insets: UIEdgeInsets = .zero
    public var trigger: CGFloat = 60
    public var executeIncremental: CGFloat = 60
    // === 内部画布：等屏宽，居中于父视图 ===
    private lazy var canvas: UIView = {
        UIView()
            .byBgColor(.clear)
            /// 画布：等屏宽、中心对齐到父视图
            .byAddTo(self) { [unowned self] make in
                make.centerX.equalToSuperview()                  // ✅ 中心对齐（不从 0,0 起）
                make.centerY.equalToSuperview()
                self.canvasWidthConstraint = make.width.equalTo(UIScreen.main.bounds.width).constraint
                make.height.greaterThanOrEqualTo(executeIncremental)
            }
    }()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .byFont(.systemFont(ofSize: 14))
            .byTextColor(.secondaryLabel)
            .byTextAlignment(.center)
            .byHugging(.required, axis: .horizontal)
            .byCompressionResistance(.required, axis: .horizontal)
            /// 文本：永远居中在“画布”的几何中心
            .byAddTo(canvas) { [unowned self] make in
                make.centerX.equalTo(canvas.snp.centerX)         // ✅ 真正中线
                make.centerY.equalTo(canvas.snp.centerY)
                make.leading.greaterThanOrEqualTo(canvas.snp.leading).offset(16)
                make.trailing.lessThanOrEqualTo(canvas.snp.trailing).inset(16)
            }
    }()

    private lazy var indicator: UIActivityIndicatorView = {
        UIActivityIndicatorView(style: .medium)
            .byHidesWhenStopped(true)
            .byAddTo(canvas) { [unowned self] make in
                make.centerY.equalTo(titleLabel)
                make.trailing.equalTo(titleLabel.snp.leading).offset(-6)
            }
    }()

    private var canvasWidthConstraint: Constraint?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        byBgColor(.clear).byUserInteractionEnabled(false)
        canvas.byAlpha(1)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    // 跟随窗口宽度（适配横竖屏 / iPad 分屏）
    public override func layoutSubviews() {
        super.layoutSubviews()
        let w = (self.window?.bounds.width).map { CGFloat($0) } ?? UIScreen.main.bounds.width
        canvasWidthConstraint?.update(offset: 0)
        canvas.snp.updateConstraints { make in
            make.width.equalTo(w)
        }
    }
    // MARK: - ESRefreshProtocol
    public func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {}

    public func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        self.state = state
        switch state {
        case .pullToRefresh:
            titleLabel.text = idleDescription
            indicator.stopAnimating()
        case .releaseToRefresh:
            titleLabel.text = releaseToRefreshDescription
            indicator.stopAnimating()
        case .refreshing, .autoRefreshing:
            titleLabel.text = loadingDescription
            indicator.startAnimating()
        case .noMoreData:
            titleLabel.text = noMoreDataDescription
            indicator.stopAnimating()
        }
    }

    public func refreshAnimationBegin(view: ESRefreshComponent) { indicator.startAnimating() }
    public func refreshAnimationEnd(view: ESRefreshComponent) { indicator.stopAnimating() }
}
// MARK: - 上拉加载（Footer）
public final class JobsFooterAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol {
    public var state: ESRefreshViewState = .pullToRefresh

    public var idleDescription: String = "上拉加载更多"
    public var releaseToRefreshDescription: String = "松开立即加载"
    public var loadingMoreDescription: String = "加载中…"
    public var noMoreDataDescription: String = "没有更多数据"

    public var view: UIView { self }
    public var insets: UIEdgeInsets = .zero
    public var trigger: CGFloat = 52
    public var executeIncremental: CGFloat = 52

    private let canvas = UIView()
    private let titleLabel = UILabel()
    private let indicator  = UIActivityIndicatorView(style: .medium)

    private var canvasWidthConstraint: Constraint?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .clear
        isUserInteractionEnabled = false

        canvas.backgroundColor = .clear
        addSubview(canvas)

        titleLabel
            .byFont(.systemFont(ofSize: 14))
            .byTextColor(.secondaryLabel)
            .byTextAlignment(.center)
            .byHugging(.required, axis: .horizontal)
            .byCompressionResistance(.required, axis: .horizontal)

        indicator.hidesWhenStopped = true

        canvas.addSubview(titleLabel)
        canvas.addSubview(indicator)
    }

    private func setupConstraints() {
        canvas.snp.makeConstraints { make in
            make.centerX.equalToSuperview()                 // ✅ 居中对齐父视图
            make.centerY.equalToSuperview()
            self.canvasWidthConstraint = make.width.equalTo(UIScreen.main.bounds.width).constraint
            make.height.greaterThanOrEqualTo(executeIncremental)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(canvas.snp.centerX)        // ✅ 文本居中于画布
            make.centerY.equalTo(canvas.snp.centerY)
            make.leading.greaterThanOrEqualTo(canvas.snp.leading).offset(16)
            make.trailing.lessThanOrEqualTo(canvas.snp.trailing).inset(16)
        }

        indicator.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel.snp.leading).offset(-6)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let w = (self.window?.bounds.width).map { CGFloat($0) } ?? UIScreen.main.bounds.width
        canvasWidthConstraint?.update(offset: 0)
        canvas.snp.updateConstraints { make in
            make.width.equalTo(w)
        }
    }
    // MARK: - ESRefreshProtocol
    public func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {}
    public func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        self.state = state
        switch state {
        case .pullToRefresh:
            titleLabel.text = idleDescription
            indicator.stopAnimating()
        case .releaseToRefresh:
            titleLabel.text = releaseToRefreshDescription
            indicator.stopAnimating()
        case .refreshing, .autoRefreshing:
            titleLabel.text = loadingMoreDescription
            indicator.startAnimating()
        case .noMoreData:
            titleLabel.text = noMoreDataDescription
            indicator.stopAnimating()
        }
    }

    public func refreshAnimationBegin(view: ESRefreshComponent) { indicator.startAnimating() }
    public func refreshAnimationEnd(view: ESRefreshComponent) { indicator.stopAnimating() }
}
// MARK: - 上拉下拉链式语法
public extension JobsHeaderAnimator {
    // MARK: - 单项链式配置
    @discardableResult
    func byIdleDescription(_ text: String) -> Self {
        self.idleDescription = text
        return self
    }

    @discardableResult
    func byReleaseToRefreshDescription(_ text: String) -> Self {
        self.releaseToRefreshDescription = text
        return self
    }

    @discardableResult
    func byLoadingDescription(_ text: String) -> Self {
        self.loadingDescription = text
        return self
    }

    @discardableResult
    func byNoMoreDataDescription(_ text: String) -> Self {
        self.noMoreDataDescription = text
        return self
    }
    // MARK: - 组合链式配置（少写几行）
    @discardableResult
    func byDescriptions(
        idle: String? = nil,
        releaseToRefresh: String? = nil,
        loading: String? = nil,
        noMoreData: String? = nil
    ) -> Self {
        if let v = idle { self.idleDescription = v }
        if let v = releaseToRefresh { self.releaseToRefreshDescription = v }
        if let v = loading { self.loadingDescription = v }
        if let v = noMoreData { self.noMoreDataDescription = v }
        return self
    }
}
public extension JobsFooterAnimator {
    // MARK: - 单项链式配置
    @discardableResult
    func byIdleDescription(_ text: String) -> Self {
        self.idleDescription = text
        return self
    }

    @discardableResult
    func byReleaseToRefreshDescription(_ text: String) -> Self {
        self.releaseToRefreshDescription = text
        return self
    }

    @discardableResult
    func byLoadingMoreDescription(_ text: String) -> Self {
        self.loadingMoreDescription = text
        return self
    }

    @discardableResult
    func byNoMoreDataDescription(_ text: String) -> Self {
        self.noMoreDataDescription = text
        return self
    }
    // MARK: - 组合链式配置（可选，少写几行）
    @discardableResult
    func byDescriptions(
        idle: String? = nil,
        releaseToRefresh: String? = nil,
        loadingMore: String? = nil,
        noMoreData: String? = nil
    ) -> Self {
        if let v = idle { self.idleDescription = v }
        if let v = releaseToRefresh { self.releaseToRefreshDescription = v }
        if let v = loadingMore { self.loadingMoreDescription = v }
        if let v = noMoreData { self.noMoreDataDescription = v }
        return self
    }
}
 MARK: - 轻量的“最近刷新时间”缓存，替代 ESRefreshDataManager（避免跨模块 internal 访问问题）
public enum JobsRefreshCache {
    private static let prefix = "jobs.refresh."
    private static let ud = UserDefaults.standard

    @inline(__always)
    private static func key(_ k: String) -> String { prefix + k }

    public static func setDate(_ date: Date, forKey key: String) {
        ud.set(date.timeIntervalSince1970, forKey: self.key(key))
    }

    public static func date(forKey key: String) -> Date? {
        let ts = ud.double(forKey: self.key(key))
        return ts > 0 ? Date(timeIntervalSince1970: ts) : nil
    }
    /// 可选：设置过期时长（秒）
    public static func setExpiredInterval(_ interval: TimeInterval?, forKey key: String) {
        let k = self.key(key) + ".expired"
        if let interval { ud.set(interval, forKey: k) } else { ud.removeObject(forKey: k) }
    }

    public static func expiredInterval(forKey key: String) -> TimeInterval? {
        let k = self.key(key) + ".expired"
        let v = ud.double(forKey: k)
        return v > 0 ? v : nil
    }
    /// 可选：是否已过期（模仿 ES 行为）
    public static func isExpired(forKey key: String) -> Bool {
        guard let last = date(forKey: key),
              let interval = expiredInterval(forKey: key) else { return false }
        return Date().timeIntervalSince(last) >= interval
    }
}
#endif
