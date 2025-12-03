//
//  UIButton+SDWebImage.swift
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
// MARK: - SDWebImage
#if canImport(SDWebImage)
import UIKit
import SDWebImage
import ObjectiveC.runtime

public struct SDButtonLoadConfig {
    public var url: URL?
    public var placeholder: UIImage?
    public var options: SDWebImageOptions = []
    public var context: [SDWebImageContextOption: Any]? = nil
    public var progress: SDImageLoaderProgressBlock? = nil
    public var completed: SDExternalCompletionBlock? = nil

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

public extension UIButton {
    func _sd_loadImage(for state: UIControl.State) {
        let cfg = _sd_config
        guard let url = cfg.url else {
            Task { @MainActor in self.jobsResetBtnImage(cfg.placeholder, for: state) }
            return
        }
        self.sd_setImage(with: url,
                         for: state,
                         placeholderImage: cfg.placeholder,
                         options: cfg.options,
                         context: cfg.context,
                         progress: cfg.progress) { [weak self] img, err, cacheType, imageURL in
            guard let self else { return }
            Task { @MainActor in
                self.jobsResetBtnImage(img ?? cfg.placeholder, for: state)
                cfg.completed?(img, err, cacheType, imageURL)
            }
        }
    }
    // ✅ SDWebImage：背景图加载（完整替换此方法）
    func _sd_loadBackgroundImage(for state: UIControl.State) {
        let cfg = _sd_config
        // 记录元数据（克隆/复用要用）
        self.jobs_bgURL = cfg.url
        self.jobs_bgState = state
        // 先显示占位图（用 legacy API，避免与 configuration 竞态）
        if let ph = cfg.placeholder {
            Task { @MainActor in self.jobsResetBtnBgImage(ph, for: state) }
        }
        guard let url = cfg.url else { return }
        // 取消在途任务（同一 state）
        self.sd_cancelBackgroundImageLoad(for: state)
        // 只在回调里写图，避免 SD 自动写回导致的闪白/覆盖
        var opts = cfg.options
        opts.insert(.continueInBackground)
        opts.insert(.highPriority)
        opts.insert(.avoidAutoSetImage)

        var ctx = cfg.context ?? [:]
        if ctx[.imageScaleFactor] == nil { ctx[.imageScaleFactor] = UIScreen.main.scale }
        // ❌ SD 没有 .imageTransition 这个 context 键，千万不要写它
        self.sd_setBackgroundImage(
            with: url,
            for: state,
            placeholderImage: cfg.placeholder,
            options: opts,
            context: ctx,
            progress: cfg.progress
        ) { [weak self] img, err, cacheType, _ in
            guard let self = self else { return }
            Task { @MainActor in
                let finalImage = img ?? cfg.placeholder
                // 如果是新下载（非缓存），做一次淡入；缓存命中则直接显示更干净
                if cacheType == .none, let finalImage {
                    UIView.transition(with: self, duration: 0.22, options: .transitionCrossDissolve, animations: {
                        self.jobsResetBtnBgImage(finalImage, for: state)
                    }, completion: nil)
                } else {
                    self.jobsResetBtnBgImage(finalImage, for: state)
                }
                cfg.completed?(img, err, cacheType, url)
            }
        }
    }
    /// 克隆 SD 的“背景图”到目标按钮：优先现成位图/配置 → 缓存 → 可选走网
    // ✅ SDWebImage：克隆背景图（完整替换此方法）
    /// 从“源按钮”克隆背景图到 target：
    /// 1) 先用现成位图（configuration / legacy）；
    /// 2) 命中缓存则立即显示；
    /// 3) 否则在 allowNetworkIfMissing=true 时触网下载（用你已有的 _sd_loadBackgroundImage 做手动淡入）
    func sd_cloneBackground(to target: UIButton,
                            for state: UIControl.State = .normal,
                            allowNetworkIfMissing: Bool = false) {
        target.jobs_isClone = true
        target.jobs_bgState = state
        // 先 snapshot 一份配置，避免跨 actor 反复读 AO
        let snapCfg = self._sd_config
        // 有效 URL：优先用 _sd_loadBackgroundImage 记录的 jobs_bgURL，退回配置里的 url
        let effectiveURL = self.jobs_bgURL ?? snapCfg.url
        // ===== 情况 1：没有 URL，说明是纯本地背景图，直接复用现成位图后结束 =====
        if effectiveURL == nil {
            if #available(iOS 15.0, *), let cfgImg = self.configuration?.background.image {
                Task { @MainActor in
                    target.jobsResetBtnBgImage(cfgImg, for: state)
                };return
            }
            if let img = self.backgroundImage(for: state) {
                Task { @MainActor in
                    target.jobsResetBtnBgImage(img, for: state)
                };return
            }
            // 只有占位图的极端情况
            if let ph = snapCfg.placeholder {
                Task { @MainActor in
                    target.jobsResetBtnBgImage(ph, for: state)
                }
            };return
        }
        // ===== 情况 2：有 URL，说明是远程图；此时现成位图很可能只是占位，不能直接 return =====
        if let ph = snapCfg.placeholder {
            Task { @MainActor in
                target.jobsResetBtnBgImage(ph, for: state)
            }
        }
        let url = effectiveURL!
        target.jobs_bgURL = url
        // 先查缓存（同步），命中就直接用缓存图
        let key = SDWebImageManager.shared.cacheKey(for: url) ?? url.absoluteString
        if let cached = SDImageCache.shared.imageFromCache(forKey: key) {
            Task { @MainActor in
                target.jobsResetBtnBgImage(cached, for: state)
            };return
        }
        // 不允许走网，直接停在占位图
        guard allowNetworkIfMissing else { return }
        // 允许走网：复制源按钮的加载配置；克隆场景加 avoidAutoSetImage，避免闪烁
        var opts = snapCfg.options
        opts.insert(.continueInBackground)
        opts.insert(.highPriority)
        opts.insert(.avoidAutoSetImage)

        target._sd_setImageURL(url)
        target._sd_setPlaceholder(snapCfg.placeholder)
        target._sd_setOptions(opts)
        target._sd_setContext(snapCfg.context)
        target._sd_setProgress(snapCfg.progress)
        target._sd_setCompleted(snapCfg.completed)
        // 用你已有的淡入版本，真正发起 SD 的背景图加载
        target._sd_loadBackgroundImage(for: state)
    }
    /// 克隆“前景图”
    func sd_cloneImage(to target: UIButton, for state: UIControl.State = .normal) {
        guard let url = _sd_config.url else { return }
        target._sd_setImageURL(url)
        target._sd_setPlaceholder(self._sd_config.placeholder)
        target._sd_setOptions(self._sd_config.options)
        target._sd_setContext(self._sd_config.context)
        target._sd_setProgress(self._sd_config.progress)
        target._sd_setCompleted(self._sd_config.completed)
        target._sd_loadImage(for: state)
    }
}
#endif
