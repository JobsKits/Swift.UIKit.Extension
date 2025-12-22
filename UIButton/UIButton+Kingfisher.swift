//
//  UIButton+Kingfisher.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import ObjectiveC.runtime
// MARK: - Kingfisher
#if canImport(Kingfisher)
import Kingfisher

public struct KFButtonLoadConfig {
    public var url: URL?
    public var placeholder: UIImage?
    /// ✅ 目标 UI 尺寸（point）：默认会用它来做 Downsampling，保证不会被大图撑开按钮
    public var targetSize: CGSize? = nil
    /// ✅ 背景图目标 UI 尺寸（point）
    public var bgTargetSize: CGSize? = nil

    public var options: KingfisherOptionsInfo = []
    public var progress: ((_ receivedSize: Int64, _ totalSize: Int64) -> Void)?
    public var completed: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?

    public init() {}
}

private enum _KFButtonAOKey { static var config: UInt8 = 0 }
private var kfBgURLKey: UInt8 = 0
public extension UIButton {
    var _kf_config: KFButtonLoadConfig {
        get { (objc_getAssociatedObject(self, &_KFButtonAOKey.config) as? KFButtonLoadConfig) ?? KFButtonLoadConfig() }
        set { objc_setAssociatedObject(self, &_KFButtonAOKey.config, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

private extension UIButton {
    @discardableResult func _kf_setImageURL(_ url: URL?) -> Self { var c = _kf_config; c.url = url; _kf_config = c; return self }
    @discardableResult func _kf_setPlaceholder(_ img: UIImage?) -> Self { var c = _kf_config; c.placeholder = img; _kf_config = c; return self }
    @discardableResult func _kf_setTargetSize(_ size: CGSize?) -> Self { var c = _kf_config; c.targetSize = size; _kf_config = c; return self }
    @discardableResult func _kf_setBgTargetSize(_ size: CGSize?) -> Self { var c = _kf_config; c.bgTargetSize = size; _kf_config = c; return self }
    @discardableResult func _kf_setOptions(_ opts: KingfisherOptionsInfo) -> Self { var c = _kf_config; c.options = opts; _kf_config = c; return self }
    @discardableResult func _kf_setProgress(_ block: ((_ receivedSize: Int64, _ totalSize: Int64) -> Void)?) -> Self { var c = _kf_config; c.progress = block; _kf_config = c; return self }
    @discardableResult func _kf_setCompleted(_ block: KFCompleted?) -> Self { var c = _kf_config; c.completed = block; _kf_config = c; return self }
}

public extension UIButton {
    // MARK: - 基础配置
    @discardableResult func kf_imageURL(_ url: URL?) -> Self { _kf_setImageURL(url) }
    @discardableResult func kf_imageURL(_ urlString: String?) -> Self {
        guard let s = urlString, let u = URL(string: s) else { return _kf_setImageURL(nil) }
        return _kf_setImageURL(u)
    }
    @discardableResult func kf_placeholderImage(_ img: UIImage?) -> Self { _kf_setPlaceholder(img) }
    @discardableResult func kf_targetSize(_ size: CGSize?) -> Self { _kf_setTargetSize(size) }
    @discardableResult func kf_bgTargetSize(_ size: CGSize?) -> Self { _kf_setBgTargetSize(size) }
    @discardableResult func kf_options(_ opts: KingfisherOptionsInfo) -> Self { _kf_setOptions(opts) }
    @discardableResult func kf_progress(_ block: ((_ receivedSize: Int64, _ totalSize: Int64) -> Void)?) -> Self { _kf_setProgress(block) }
    @discardableResult func kf_completed(_ block: KFCompleted?) -> Self { _kf_setCompleted(block) }
    // MARK: - 前景图加载
    @discardableResult func kf_normalLoad() -> Self {
        _kf_loadImage(for: .normal)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() } // ✅刷新配置
        return self
    }
    @discardableResult func kf_highlightedLoad() -> Self {
        _kf_loadImage(for: .highlighted)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
        return self
    }
    @discardableResult func kf_disabledLoad() -> Self {
        _kf_loadImage(for: .disabled)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
        return self
    }
    @discardableResult func kf_selectedLoad() -> Self {
        _kf_loadImage(for: .selected)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
        return self
    }
    @available(iOS 9.0, *)
    @discardableResult func kf_focusedLoad() -> Self {
        _kf_loadImage(for: .focused)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
        return self
    }
    @discardableResult func kf_applicationLoad() -> Self {
        _kf_loadImage(for: .application)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
        return self
    }
    @discardableResult func kf_reservedLoad() -> Self {
        _kf_loadImage(for: .reserved)
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
        return self
    }
    // MARK: - 背景图加载
    @discardableResult func kf_bgNormalLoad() -> Self { _kf_loadBackgroundImage(for: .normal); return self }
    @discardableResult func kf_bgHighlightedLoad() -> Self { _kf_loadBackgroundImage(for: .highlighted); return self }
    @discardableResult func kf_bgDisabledLoad() -> Self { _kf_loadBackgroundImage(for: .disabled); return self }
    @discardableResult func kf_bgSelectedLoad() -> Self { _kf_loadBackgroundImage(for: .selected); return self }
    @available(iOS 9.0, *)
    @discardableResult func kf_bgFocusedLoad() -> Self { _kf_loadBackgroundImage(for: .focused); return self }
    @discardableResult func kf_bgApplicationLoad() -> Self { _kf_loadBackgroundImage(for: .application); return self }
    @discardableResult func kf_bgReservedLoad() -> Self { _kf_loadBackgroundImage(for: .reserved); return self }
}
// MARK: - internal helpers
private extension UIButton {
    /// ✅ 统一主线程执行：避免占位/回调乱序覆盖
    func _jobs_runOnMain(_ work: @escaping (UIButton) -> Void) {
        if Thread.isMainThread {
            work(self)
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                work(self)
            }
        }
    }

    // MARK: - Foreground load token（解决：旧请求回调/取消回调把新请求的 shimmer 停掉）
    private enum _JobsKFButtonTokenAOKey { static var fgTokenMap: UInt8 = 0 }

    func _jobs_kfNextForegroundToken(for state: UIControl.State) -> Int {
        var map = (objc_getAssociatedObject(self, &_JobsKFButtonTokenAOKey.fgTokenMap) as? [UInt: Int]) ?? [:]
        let next = (map[state.rawValue] ?? 0) + 1
        map[state.rawValue] = next
        objc_setAssociatedObject(self, &_JobsKFButtonTokenAOKey.fgTokenMap, map, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return next
    }

    func _jobs_kfIsCurrentForegroundToken(_ token: Int, for state: UIControl.State) -> Bool {
        let map = (objc_getAssociatedObject(self, &_JobsKFButtonTokenAOKey.fgTokenMap) as? [UInt: Int]) ?? [:]
        return map[state.rawValue] == token
    }

    // MARK: - Shimmer helpers（loading 占位）
    func _jobs_startForegroundShimmer(targetSize: CGSize) {
        self._jobs_startForegroundShimmerOverlay(targetSize: targetSize)
    }

    func _jobs_stopForegroundShimmer() {
        self._jobs_stopForegroundShimmerOverlay()
    }

    func _jobs_startBackgroundShimmer() {
        self.jobs_startShimmer()
        DispatchQueue.main.async { [weak self] in self?.jobs_updateShimmerLayout() }
    }

    func _jobs_stopBackgroundShimmer() {
        self.jobs_stopShimmer()
    }
    /// ✅ 强制写入“前景图”（避免 jobsResetBtnImage 内部的保护挡掉更新）
    func _jobs_forceSetForegroundImage(_ image: UIImage?, for state: UIControl.State) {
        self.jobsResetBtnImage(image, for: state)

        if #available(iOS 15.0, *), state == .normal, var cfg = self.configuration {
            let current = cfg.image
            if (current !== image) && !(current == nil && image == nil) {
                cfg.image = image
                self.configuration = cfg
            }
        } else {
            let current = self.image(for: state)
            if (current !== image) && !(current == nil && image == nil) {
                self.setImage(image, for: state)
            }
        }
    }
    /// ✅ 强制写入“背景图”（逻辑同上）
    func _jobs_forceSetBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        self.jobsResetBtnBgImage(image, for: state)

        if #available(iOS 15.0, *), state == .normal, var cfg = self.configuration {
            let current = cfg.background.image
            if (current !== image) && !(current == nil && image == nil) {
                cfg.background.image = image
                self.configuration = cfg
            }
        } else {
            let current = self.backgroundImage(for: state)
            if (current !== image) && !(current == nil && image == nil) {
                self.setBackgroundImage(image, for: state)
            }
        }
    }

    func _jobs_kfGuessForegroundTargetSize() -> CGSize {
        if let s = self.jobs_remoteImageTargetSize, s.width > 1, s.height > 1 { return s }
        if let iv = self.imageView {
            let s = iv.bounds.size
            if s.width > 1, s.height > 1 { return s }
        }
        let h = self.bounds.size.height
        if h > 1 {
            let side = max(24, h - 16)
            return CGSize(width: side, height: side)
        };return CGSize(width: 48, height: 48)
    }

    // MARK: - Foreground loading placeholder（用于撑开 imageView frame，便于 overlay 精准覆盖）
    func _jobs_kfLoadingPlaceholderImage(targetPointSize: CGSize, fallback: UIImage?) -> UIImage? {
        if let fallback { return fallback }
        return UIImage._jobs_transparentPlaceholder(size: targetPointSize)
    }

    func _jobs_kfGuessBackgroundTargetSize() -> CGSize {
        if let s = self.jobs_bgImageTargetSize, s.width > 1, s.height > 1 { return s }
        let s = self.bounds.size
        if s.width > 1, s.height > 1 { return s }
        return CGSize(width: 320, height: 64)
    }

    func _jobs_kfUpsertDownsampleOptions(_ options: KingfisherOptionsInfo, targetPointSize: CGSize) -> KingfisherOptionsInfo {
        var opts = options

        // 1) 强制替换 processor 为“按 UI 尺寸 Downsampling”
        opts.removeAll { if case .processor = $0 { return true } else { return false } }
        opts.append(.processor(DownsamplingImageProcessor(size: targetPointSize)))

        // 2) 确保 scaleFactor 一致
        if !opts.contains(where: { if case .scaleFactor = $0 { return true } else { return false } }) {
            opts.append(.scaleFactor(UIScreen.main.scale))
        };return opts
    }
}

// MARK: - Transparent placeholder (internal)
private extension UIImage {
    static func _jobs_transparentPlaceholder(size: CGSize,
                                            scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let w = max(1, size.width)
        let h = max(1, size.height)
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        return UIGraphicsImageRenderer(size: CGSize(width: w, height: h), format: format).image { _ in }
    }
}

public extension UIButton {
    func _kf_loadImage(for state: UIControl.State) {
        let cfg = _kf_config
        let token = _jobs_kfNextForegroundToken(for: state)
        // ✅ 标记实际使用的框架（给 JobsImageCacheCleaner 用）
        self.jobs_imageLoaderKind = .kingfisher
        // ✅ 统一记录：前景 URL + state（供 JobsImageCacheCleaner 遍历重下）
        self.jobs_remoteState = state
        // ✅ 目标尺寸：优先你显式设置的 targetSize，否则按 UI 猜一个兜底值（用于 shimmer overlay + downsampling）
        let targetPointSize = cfg.targetSize ?? _jobs_kfGuessForegroundTargetSize()
        self.jobs_remoteImageTargetSize = targetPointSize
        let loadingPlaceholder = _jobs_kfLoadingPlaceholderImage(targetPointSize: targetPointSize, fallback: cfg.placeholder)

        guard let url = cfg.url else {
            self.jobs_remoteURL = nil
            // URL 解析失败也视为失败：直接落兜底（不需要 shimmer）
            _jobs_runOnMain { btn in
                guard btn._jobs_kfIsCurrentForegroundToken(token, for: state) else { return }
                btn._jobs_stopForegroundShimmer()
                btn._jobs_forceSetForegroundImage(cfg.placeholder, for: state)
            }
            return
        }

        self.jobs_remoteURL = url

        // ✅ 折中策略：先灌入兜底图（或透明占位）把前景 imageView 撑开 → 再盖 overlay 做 shimmer
        // 这样 overlay 的 frame 可以直接跟随系统最终算出来的 imageView/frame。
        _jobs_runOnMain { btn in
            guard btn._jobs_kfIsCurrentForegroundToken(token, for: state) else { return }
            btn._jobs_forceSetForegroundImage(loadingPlaceholder, for: state)
            btn.setNeedsLayout()
            btn.layoutIfNeeded()
            btn._jobs_startForegroundShimmer(targetSize: targetPointSize)
        }
        // ✅ 强制 Downsampling，保证不会被大图撑开 intrinsicContentSize
        let opts = _jobs_kfUpsertDownsampleOptions(cfg.options, targetPointSize: targetPointSize)
        self.kf.setImage(with: url,
                         for: state,
                         placeholder: nil,
                         options: opts,
                         progressBlock: { r, t in cfg.progress?(Int64(r), Int64(t)) }) { [weak self] result in
            guard let self else { return }
            self._jobs_runOnMain { btn in
                guard btn._jobs_kfIsCurrentForegroundToken(token, for: state) else { return }
                // ✅ 请求结束（成功/失败/取消）都必须停 shimmer
                btn._jobs_stopForegroundShimmer()
                switch result {
                case .success(let r):
                    btn._jobs_forceSetForegroundImage(r.image, for: state)
                case .failure:
                    // ✅ Failure：有兜底图就落兜底；没有就保持 nil
                    btn._jobs_forceSetForegroundImage(cfg.placeholder, for: state)
                }
                cfg.completed?(result)
            }
        }
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
    }
    // ✅ Kingfisher 背景图加载：按原逻辑下载，回写时只走 jobsResetBtnBgImage（= legacy）
    func _kf_loadBackgroundImage(for state: UIControl.State) {
        let cfg = _kf_config
        // ✅ 标记实际使用的框架（给 JobsImageCacheCleaner 用）
        self.jobs_imageLoaderKind = .kingfisher
        // ✅ 统一记录：背景 URL + state（供 JobsImageCacheCleaner 遍历重下 & 克隆）
        self.jobs_bgURL = cfg.url
        self.jobs_bgState = state
        self.kf_bgURL = cfg.url
        // ✅ Loading：永远先 Shimmer（placeholder 只作为「失败兜底」）
        _jobs_runOnMain { btn in
            btn._jobs_forceSetBackgroundImage(nil, for: state)
            btn._jobs_startBackgroundShimmer()
        }
        guard let url = cfg.url else {
            // URL 解析失败也视为失败：有兜底图则显示兜底并停 shimmer；否则继续 shimmer
            if let fb = cfg.placeholder {
                _jobs_runOnMain { btn in
                    btn._jobs_stopBackgroundShimmer()
                    btn._jobs_forceSetBackgroundImage(fb, for: state)
                }
            };return
        }
        // ✅ 背景图目标尺寸
        let targetPointSize = cfg.bgTargetSize ?? _jobs_kfGuessBackgroundTargetSize()
        self.jobs_bgImageTargetSize = targetPointSize
        var opts = _jobs_kfUpsertDownsampleOptions(cfg.options, targetPointSize: targetPointSize)
        // ✅ Shimmer 占位：不保留旧图，避免复用/叠图透出
        opts.removeAll { if case .keepCurrentImageWhileLoading = $0 { return true } else { return false } }
        if !opts.contains(where: { if case .backgroundDecode = $0 { return true } else { return false } }) {
            opts.append(.backgroundDecode)
        }

        self.kf.setBackgroundImage(
            with: url,
            for: state,
            placeholder: nil,
            options: opts,
            progressBlock: { r, t in cfg.progress?(Int64(r), Int64(t)) }
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor [weak self] in
                self?._jobs_runOnMain { btn in
                    switch result {
                    case .success(let s):
                        btn._jobs_stopBackgroundShimmer()
                        btn._jobs_forceSetBackgroundImage(s.image, for: state)
                    case .failure:
                        // ✅ Failure：有兜底图才落兜底；否则继续 shimmer
                        if let fb = cfg.placeholder {
                            btn._jobs_stopBackgroundShimmer()
                            btn._jobs_forceSetBackgroundImage(fb, for: state)
                        }
                    }
                    cfg.completed?(result)
                }
            }
        }
    }
}

public extension UIButton {
    /// 记录用于背景图的 URL（供克隆阶段读取）
    var kf_bgURL: URL? {
        get { objc_getAssociatedObject(self, &kfBgURLKey) as? URL }
        set { objc_setAssociatedObject(self, &kfBgURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    /// 源按钮使用：设置背景图并记录 URL（建议在 Demo 中用它替换直接的 kf.setBackgroundImage）
    @discardableResult
    func kf_setBackgroundImageURL(_ urlString: String,
                                  for state: UIControl.State = .normal,
                                  placeholder: UIImage? = nil,
                                  options: KingfisherOptionsInfo = [.transition(.fade(0.2)), .cacheOriginalImage]) -> Self {
        guard let u = URL(string: urlString) else { return self }
        kf_bgURL = u
        self.jobs_bgURL = u
        self.jobs_bgState = state
        self.jobs_imageLoaderKind = .kingfisher
        self.kf.setBackgroundImage(with: u, for: state, placeholder: placeholder, options: options)
        return self
    }
    /// 克隆阶段调用：优先现成位图 → 缓存 →（按需）拉网
    func kf_cloneBackground(to target: UIButton,
                            for state: UIControl.State = .normal,
                            allowNetworkIfMissing: Bool) {
        target.jobs_isClone = true
        target.jobs_bgState = state
        target.jobs_imageLoaderKind = .kingfisher
        // 0) 配置先 snapshot 出来，后面到处要用
        let snapCfg = self._kf_config
        // 1) 只有“纯本地背景图”（没有 url）时，才直接复用现成位图，不走缓存/网络
        if snapCfg.url == nil, self.kf_bgURL == nil, self.jobs_bgURL == nil {
            if #available(iOS 15.0, *), let img = self.configuration?.background.image {
                Task { @MainActor in target.jobsResetBtnBgImage(img, for: state) }
                return
            }
            if let img = self.backgroundImage(for: state) {
                Task { @MainActor in target.jobsResetBtnBgImage(img, for: state) }
                return
            }
        }
        // 2) 先把占位图顶上，保证克隆按钮立刻有图
        let ph = snapCfg.placeholder
        if let ph {
            Task { @MainActor in target.jobsResetBtnBgImage(ph, for: state) }
        }
        // 3) URL：优先 jobs_bgURL，其次显式记录的 kf_bgURL，再其次配置里的 url
        guard let url = self.jobs_bgURL ?? self.kf_bgURL ?? snapCfg.url else { return }
        target.jobs_bgURL = url
        // ✅ 同步复制目标尺寸配置
        target._kf_setBgTargetSize(snapCfg.bgTargetSize)
        if let s = snapCfg.bgTargetSize { target.jobs_bgImageTargetSize = s }
        // 4) 只从缓存取一次（不会触网）
        var cacheOnlyOpts: KingfisherOptionsInfo = snapCfg.options
        cacheOnlyOpts.append(.onlyFromCache)
        KingfisherManager.shared.retrieveImage(with: url, options: cacheOnlyOpts) { result in
            switch result {
            case .success(let r):
                Task { @MainActor in target.jobsResetBtnBgImage(r.image, for: state) }
            case .failure:
                // 5) 缓存没命中：按需走网
                guard allowNetworkIfMissing else { return }
                var opts = snapCfg.options
                // 克隆态建议去掉过渡动画，避免滚动闪一下
                opts.removeAll { if case .transition = $0 { return true } else { return false } }
                // 没占位时才保留 keepCurrentImageWhileLoading
                if ph == nil && !opts.contains(where: { if case .keepCurrentImageWhileLoading = $0 { return true } else { return false } }) {
                    opts.append(.keepCurrentImageWhileLoading)
                }
                // 强制后台解码
                if !opts.contains(where: { if case .backgroundDecode = $0 { return true } else { return false } }) {
                    opts.append(.backgroundDecode)
                }
                Task { @MainActor in
                    // ✅ 克隆走网也要 Downsampling 到 UI 尺寸
                    let targetSize = snapCfg.bgTargetSize ?? target._jobs_kfGuessBackgroundTargetSize()
                    let finalOpts = target._jobs_kfUpsertDownsampleOptions(opts, targetPointSize: targetSize)

                    target.kf.setBackgroundImage(
                        with: url,
                        for: state,
                        placeholder: ph,
                        options: finalOpts,
                        progressBlock: { r, t in snapCfg.progress?(Int64(r), Int64(t)) }
                    ) { res in
                        Task { @MainActor in
                            switch res {
                            case .success(let s): target.jobsResetBtnBgImage(s.image, for: state)
                            case .failure:        target.jobsResetBtnBgImage(ph, for: state)
                            }
                            snapCfg.completed?(res)
                        }
                    }
                }
            }
        }
    }
    /// 克隆“前景图”
    func kf_cloneImage(to target: UIButton, for state: UIControl.State = .normal) {
        guard let url = _kf_config.url else { return }
        target.jobs_imageLoaderKind = .kingfisher
        target._kf_setImageURL(url)
        target._kf_setPlaceholder(self._kf_config.placeholder)
        var o = self._kf_config.options
        if !o.contains(where: { if case .keepCurrentImageWhileLoading = $0 { return true } else { return false } }) {
            o.append(.keepCurrentImageWhileLoading)
        }
        target._kf_setOptions(o)
        target._kf_setProgress(self._kf_config.progress)
        target._kf_setCompleted(self._kf_config.completed)
        // ✅ 同步复制目标尺寸配置
        target._kf_setTargetSize(self._kf_config.targetSize)
        if let s = self._kf_config.targetSize { target.jobs_remoteImageTargetSize = s }
        target._kf_loadImage(for: state)
    }
}
#endif
