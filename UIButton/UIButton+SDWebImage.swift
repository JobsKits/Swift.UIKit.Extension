//
//  UIButton+SDWebImage.swift
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
// MARK: - SDWebImage
#if canImport(SDWebImage)
import SDWebImage
public struct SDButtonLoadConfig {
    public var url: URL?
    public var placeholder: UIImage?
    public var options: SDWebImageOptions = []
    public var context: [SDWebImageContextOption: Any]? = nil
    public var progress: SDImageLoaderProgressBlock? = nil
    public var completed: SDExternalCompletionBlock? = nil
    /// ✅ 目标尺寸（point）。用于强制下采样：避免远端大图撑开 UIButton 的 intrinsicContentSize。
    /// - Note: 不设置时会按按钮当前 UI 猜一个兜底值。
    public var targetSize: CGSize? = nil
    /// ✅ 背景图目标尺寸（point）。不设置时默认取按钮 bounds（取不到则兜底 320x64）。
    public var bgTargetSize: CGSize? = nil
    public init() {}
}

private enum _SDButtonAOKey {
    static var config: UInt8 = 0
}

private extension UIButton {
    var _sd_config: SDButtonLoadConfig {
        get { (objc_getAssociatedObject(self, &_SDButtonAOKey.config) as? SDButtonLoadConfig) ?? SDButtonLoadConfig() }
        set { objc_setAssociatedObject(self, &_SDButtonAOKey.config, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

private extension UIButton {
    @discardableResult func _sd_setImageURL(_ url: URL?) -> Self { var c = _sd_config; c.url = url; _sd_config = c; return self }
    @discardableResult func _sd_setPlaceholder(_ img: UIImage?) -> Self { var c = _sd_config; c.placeholder = img; _sd_config = c; return self }
    @discardableResult func _sd_setOptions(_ opts: SDWebImageOptions) -> Self { var c = _sd_config; c.options = opts; _sd_config = c; return self }
    @discardableResult func _sd_setContext(_ ctx: [SDWebImageContextOption: Any]?) -> Self { var c = _sd_config; c.context = ctx; _sd_config = c; return self }
    @discardableResult func _sd_setProgress(_ block: SDImageLoaderProgressBlock?) -> Self { var c = _sd_config; c.progress = block; _sd_config = c; return self }
    @discardableResult func _sd_setCompleted(_ block: SDExternalCompletionBlock?) -> Self { var c = _sd_config; c.completed = block; _sd_config = c; return self }
    @discardableResult func _sd_setTargetSize(_ size: CGSize?) -> Self { var c = _sd_config; c.targetSize = size; _sd_config = c; return self }
    @discardableResult func _sd_setBgTargetSize(_ size: CGSize?) -> Self { var c = _sd_config; c.bgTargetSize = size; _sd_config = c; return self }
}

public extension UIButton {
    @discardableResult func sd_imageURL(_ url: URL?) -> Self { _sd_setImageURL(url) }
    @discardableResult func sd_imageURL(_ urlString: String?) -> Self {
        guard let s = urlString, let u = URL(string: s) else { return _sd_setImageURL(nil) }
        return _sd_setImageURL(u)
    }
    @discardableResult func sd_placeholderImage(_ img: UIImage?) -> Self { _sd_setPlaceholder(img) }
    @discardableResult func sd_options(_ opts: SDWebImageOptions) -> Self { _sd_setOptions(opts) }
    @discardableResult func sd_context(_ ctx: [SDWebImageContextOption: Any]?) -> Self { _sd_setContext(ctx) }
    @discardableResult func sd_progress(_ block: SDImageLoaderProgressBlock?) -> Self { _sd_setProgress(block) }
    @discardableResult func sd_completed(_ block: SDExternalCompletionBlock?) -> Self { _sd_setCompleted(block) }
    /// ✅ 目标尺寸（point）：用于下采样（前景图）
    @discardableResult func sd_targetSize(_ size: CGSize?) -> Self { _sd_setTargetSize(size) }
    /// ✅ 目标尺寸（point）：用于下采样（背景图）
    @discardableResult func sd_bgTargetSize(_ size: CGSize?) -> Self { _sd_setBgTargetSize(size) }

    @discardableResult func sd_normalLoad() -> Self { _sd_loadImage(for: .normal); return self }
    @discardableResult func sd_highlightedLoad() -> Self { _sd_loadImage(for: .highlighted); return self }
    @discardableResult func sd_disabledLoad() -> Self { _sd_loadImage(for: .disabled); return self }
    @discardableResult func sd_selectedLoad() -> Self { _sd_loadImage(for: .selected); return self }
    @available(iOS 9.0, *)
    @discardableResult func sd_focusedLoad() -> Self { _sd_loadImage(for: .focused); return self }
    @discardableResult func sd_applicationLoad() -> Self { _sd_loadImage(for: .application); return self }
    @discardableResult func sd_reservedLoad() -> Self { _sd_loadImage(for: .reserved); return self }

    @discardableResult func sd_bgNormalLoad() -> Self { _sd_loadBackgroundImage(for: .normal); return self }
    @discardableResult func sd_bgHighlightedLoad() -> Self { _sd_loadBackgroundImage(for: .highlighted); return self }
    @discardableResult func sd_bgDisabledLoad() -> Self { _sd_loadBackgroundImage(for: .disabled); return self }
    @discardableResult func sd_bgSelectedLoad() -> Self { _sd_loadBackgroundImage(for: .selected); return self }
    @available(iOS 9.0, *)
    @discardableResult func sd_bgFocusedLoad() -> Self { _sd_loadBackgroundImage(for: .focused); return self }
    @discardableResult func sd_bgApplicationLoad() -> Self { _sd_loadBackgroundImage(for: .application); return self }
    @discardableResult func sd_bgReservedLoad() -> Self { _sd_loadBackgroundImage(for: .reserved); return self }
}
// MARK: - internal helpers
private extension UIButton {
    /// ✅ 统一主线程执行：避免占位图 Task 乱序覆盖最终图（尤其是缓存命中时回调极快）。
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
    // MARK: - Shimmer helpers（loading 占位）
    func _jobs_startForegroundShimmer() {
        let v: UIView = self.imageView ?? self
        v.jobs_startShimmer()
        DispatchQueue.main.async { [weak v] in v?.jobs_updateShimmerLayout() }
    }

    func _jobs_stopForegroundShimmer() {
        let v: UIView = self.imageView ?? self
        v.jobs_stopShimmer()
    }

    func _jobs_startBackgroundShimmer() {
        self.jobs_startShimmer()
        DispatchQueue.main.async { [weak self] in self?.jobs_updateShimmerLayout() }
    }

    func _jobs_stopBackgroundShimmer() {
        self.jobs_stopShimmer()
    }

    func _jobs_sdGuessForegroundTargetSize() -> CGSize {
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

    func _jobs_sdGuessBackgroundTargetSize() -> CGSize {
        if let s = self.jobs_bgImageTargetSize, s.width > 1, s.height > 1 { return s }
        let s = self.bounds.size
        if s.width > 1, s.height > 1 { return s }
        return CGSize(width: 320, height: 64)
    }

    func _jobs_sdBuildContext(base: [SDWebImageContextOption: Any]?, targetPointSize: CGSize?) -> [SDWebImageContextOption: Any] {
        var ctx = base ?? [:]
        if ctx[.imageScaleFactor] == nil {
            ctx[.imageScaleFactor] = UIScreen.main.scale
        }
        // ✅ 核心：强制缩略图像素尺寸（避免 image.size 过大导致 UIButton intrinsicContentSize 被撑开）
        if ctx[.imageThumbnailPixelSize] == nil {
            let point = targetPointSize
            if let point, point.width > 1, point.height > 1 {
                let scale = UIScreen.main.scale
                ctx[.imageThumbnailPixelSize] = CGSize(width: max(1, point.width * scale), height: max(1, point.height * scale))
            }
        };return ctx
    }
    /// ✅ 强制写入“前景图”。
    ///
    /// 你现在的现象是：只要配置了 `.sd_placeholderImage(...)`，按钮就一直停在兜底图；
    /// 把占位注释掉反而能显示网络图。
    ///
    /// 本质原因通常是你自己的 `jobsResetBtnImage` 做了“已有 image 就不再覆盖”的保护：
    /// 先写了占位图 → 后续回调再写网络图被它挡住，于是 UI 永远停在 placeholder。
    ///
    /// 这里做一个「先走 jobsReset；如果没生效再强制覆盖」的兜底，保证占位一定能被最终图替换。
    func _jobs_forceSetForegroundImage(_ image: UIImage?, for state: UIControl.State) {
        // 1) 先走你现有的统一封装（保证你的配置/布局逻辑不丢）
        self.jobsResetBtnImage(image, for: state)
        // 2) 如果 jobsReset 内部做了“已有 image 不覆盖”，这里强制补写
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
    /// ✅ 强制写入“背景图”，逻辑同上。
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
}

public extension UIButton {
    // MARK: - 前景图（SDWebImage）
    func _sd_loadImage(for state: UIControl.State) {
        let cfg = _sd_config
        // ✅ 标记实际使用的框架（给 JobsImageCacheCleaner 用）
        self.jobs_imageLoaderKind = .sdwebimage
        // ✅ 记录：前景 state / url（供 JobsImageCacheCleaner 遍历重下）
        self.jobs_remoteState = state
        // ✅ Loading：永远先 Shimmer（placeholder 只作为「失败兜底」）
        _jobs_runOnMain { btn in
            btn._jobs_forceSetForegroundImage(nil, for: state)
            btn._jobs_startForegroundShimmer()
        }

        guard let url = cfg.url else {
            self.jobs_remoteURL = nil
            // URL 解析失败也视为失败：有兜底图则显示兜底并停 shimmer；否则继续 shimmer
            if let fb = cfg.placeholder {
                _jobs_runOnMain { btn in
                    btn._jobs_stopForegroundShimmer()
                    btn._jobs_forceSetForegroundImage(fb, for: state)
                }
            };return
        }
        self.jobs_remoteURL = url
        // ✅ 目标尺寸：优先你显式设置的 targetSize，否则按 UI 猜一个兜底值
        let targetPointSize = cfg.targetSize ?? _jobs_sdGuessForegroundTargetSize()
        self.jobs_remoteImageTargetSize = targetPointSize
        // 取消同 state 的在途请求
        self.sd_cancelImageLoad(for: state)
        // ✅ SD 只在回调里写图：避免 SD 自动写回导致“先被大图撑开，再被你重置”的竞态
        var opts = cfg.options
        opts.insert(.continueInBackground)
        opts.insert(.highPriority)
        opts.insert(.scaleDownLargeImages)
        opts.insert(.avoidAutoSetImage)
        let ctx = _jobs_sdBuildContext(base: cfg.context, targetPointSize: targetPointSize)
        self.sd_setImage(
            with: url,
            for: state,
            placeholderImage: nil,
            options: opts,
            context: ctx,
            progress: cfg.progress
        ) { [weak self] img, err, cacheType, imageURL in
            guard let self else { return }
            self._jobs_runOnMain { btn in
                let nsErr = err as NSError?
                let isCancelled = (nsErr?.domain == SDWebImageErrorDomain && nsErr?.code == SDWebImageError.cancelled.rawValue)
                if isCancelled { return }
                if let img {
                    // ✅ Success：停 shimmer，显示最终图
                    btn._jobs_stopForegroundShimmer()
                    // 如果是新下载（非缓存），做一次淡入；缓存命中则直接显示更干净
                    if cacheType == .none {
                        UIView.transition(with: btn,
                                          duration: 0.18,
                                          options: .transitionCrossDissolve,
                                          animations: {
                            btn._jobs_forceSetForegroundImage(img, for: state)
                        }, completion: nil)
                    } else {
                        btn._jobs_forceSetForegroundImage(img, for: state)
                    }
                } else {
                    // ✅ Failure：有兜底图才落兜底；否则继续 shimmer
                    if let fb = cfg.placeholder {
                        btn._jobs_stopForegroundShimmer()
                        btn._jobs_forceSetForegroundImage(fb, for: state)
                    }
                }
                cfg.completed?(img, err, cacheType, imageURL)
            }
        }
    }
    // MARK: - 背景图（SDWebImage）
    func _sd_loadBackgroundImage(for state: UIControl.State) {
        let cfg = _sd_config
        // ✅ 标记实际使用的框架（给 JobsImageCacheCleaner 用）
        self.jobs_imageLoaderKind = .sdwebimage
        // 记录元数据（克隆/复用要用）
        self.jobs_bgURL = cfg.url
        self.jobs_bgState = state
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
        // ✅ 目标尺寸：背景优先显式设置，否则按按钮 bounds 兜底
        let targetPointSize = cfg.bgTargetSize ?? _jobs_sdGuessBackgroundTargetSize()
        self.jobs_bgImageTargetSize = targetPointSize
        // 取消在途任务（同一 state）
        self.sd_cancelBackgroundImageLoad(for: state)
        // 只在回调里写图，避免 SD 自动写回导致的闪白/覆盖
        var opts = cfg.options
        opts.insert(.continueInBackground)
        opts.insert(.highPriority)
        opts.insert(.scaleDownLargeImages)
        opts.insert(.avoidAutoSetImage)
        let ctx = _jobs_sdBuildContext(base: cfg.context, targetPointSize: targetPointSize)
        self.sd_setBackgroundImage(
            with: url,
            for: state,
            placeholderImage: nil,
            options: opts,
            context: ctx,
            progress: cfg.progress
        ) { [weak self] img, err, cacheType, _ in
            guard let self else { return }
            self._jobs_runOnMain { btn in
                let nsErr = err as NSError?
                let isCancelled = (nsErr?.domain == SDWebImageErrorDomain && nsErr?.code == SDWebImageError.cancelled.rawValue)
                if isCancelled { return }

                if let img {
                    // ✅ Success：停 shimmer，显示最终图
                    btn._jobs_stopBackgroundShimmer()
                    // 如果是新下载（非缓存），做一次淡入；缓存命中则直接显示更干净
                    if cacheType == .none {
                        UIView.transition(with: btn,
                                          duration: 0.22,
                                          options: .transitionCrossDissolve,
                                          animations: {
                            btn._jobs_forceSetBackgroundImage(img, for: state)
                        }, completion: nil)
                    } else {
                        btn._jobs_forceSetBackgroundImage(img, for: state)
                    }
                } else {
                    // ✅ Failure：有兜底图才落兜底；否则继续 shimmer
                    if let fb = cfg.placeholder {
                        btn._jobs_stopBackgroundShimmer()
                        btn._jobs_forceSetBackgroundImage(fb, for: state)
                    }
                }
                cfg.completed?(img, err, cacheType, url)
            }
        }
    }
    /// 克隆 SD 的“背景图”到目标按钮：优先现成位图/配置 → 缓存 → 可选走网
    func sd_cloneBackground(to target: UIButton,
                            for state: UIControl.State = .normal,
                            allowNetworkIfMissing: Bool = false) {
        target.jobs_isClone = true
        target.jobs_bgState = state
        target.jobs_imageLoaderKind = .sdwebimage
        // 先 snapshot 一份配置，避免跨 actor 反复读 AO
        let snapCfg = self._sd_config
        // 有效 URL：优先用 _sd_loadBackgroundImage 记录的 jobs_bgURL，退回配置里的 url
        let effectiveURL = self.jobs_bgURL ?? snapCfg.url
        // ===== 情况 1：没有 URL，说明是纯本地背景图，直接复用现成位图后结束 =====
        if effectiveURL == nil {
            if #available(iOS 15.0, *), let cfgImg = self.configuration?.background.image {
                target._jobs_runOnMain { btn in
                    btn._jobs_forceSetBackgroundImage(cfgImg, for: state)
                };return
            }
            if let img = self.backgroundImage(for: state) {
                target._jobs_runOnMain { btn in
                    btn._jobs_forceSetBackgroundImage(img, for: state)
                };return
            }
            // 只有占位图的极端情况
            if let ph = snapCfg.placeholder {
                target._jobs_runOnMain { btn in
                    btn._jobs_forceSetBackgroundImage(ph, for: state)
                }
            };return
        }
        // ===== 情况 2：有 URL，说明是远程图；此时现成位图很可能只是占位，不能直接 return =====
        if let ph = snapCfg.placeholder {
            target._jobs_runOnMain { btn in
                btn._jobs_forceSetBackgroundImage(ph, for: state)
            }
        }

        let url = effectiveURL!
        target.jobs_bgURL = url
        // ✅ 同步复制目标尺寸配置
        target._sd_setBgTargetSize(snapCfg.bgTargetSize)
        if let s = snapCfg.bgTargetSize { target.jobs_bgImageTargetSize = s }
        // 先查缓存（同步），命中就直接用缓存图
        let key = SDWebImageManager.shared.cacheKey(for: url) ?? url.absoluteString
        if let cached = SDImageCache.shared.imageFromCache(forKey: key) {
            target._jobs_runOnMain { btn in
                btn._jobs_forceSetBackgroundImage(cached, for: state)
            };return
        }
        // 不允许走网，直接停在占位图
        guard allowNetworkIfMissing else { return }
        // 允许走网：复制源按钮的加载配置；克隆场景加 avoidAutoSetImage，避免闪烁
        var opts = snapCfg.options
        opts.insert(.continueInBackground)
        opts.insert(.highPriority)
        opts.insert(.scaleDownLargeImages)
        opts.insert(.avoidAutoSetImage)

        target._sd_setImageURL(url)
        target._sd_setPlaceholder(snapCfg.placeholder)
        target._sd_setOptions(opts)
        target._sd_setContext(snapCfg.context)
        target._sd_setProgress(snapCfg.progress)
        target._sd_setCompleted(snapCfg.completed)
        // 用已有的淡入版本，真正发起 SD 的背景图加载
        target._sd_loadBackgroundImage(for: state)
    }
    /// 克隆“前景图”
    func sd_cloneImage(to target: UIButton, for state: UIControl.State = .normal) {
        guard let url = _sd_config.url else { return }
        target.jobs_imageLoaderKind = .sdwebimage

        target._sd_setImageURL(url)
        target._sd_setPlaceholder(self._sd_config.placeholder)
        target._sd_setOptions(self._sd_config.options)
        target._sd_setContext(self._sd_config.context)
        target._sd_setProgress(self._sd_config.progress)
        target._sd_setCompleted(self._sd_config.completed)
        // ✅ 同步复制目标尺寸配置
        target._sd_setTargetSize(self._sd_config.targetSize)
        if let s = self._sd_config.targetSize { target.jobs_remoteImageTargetSize = s }
        target._sd_loadImage(for: state)
    }
}
#endif
