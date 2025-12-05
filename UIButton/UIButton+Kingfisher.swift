//
//  UIButton+Kingfisher.swift
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
// MARK: - Kingfisher
#if canImport(Kingfisher)
import UIKit
import Kingfisher
import ObjectiveC.runtime

public struct KFButtonLoadConfig {
    public var url: URL?
    public var placeholder: UIImage?
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
    @discardableResult func kf_bgNormalLoad() -> Self {
        _kf_loadBackgroundImage(for: .normal)
        return self
    }
    @discardableResult func kf_bgHighlightedLoad() -> Self {
        _kf_loadBackgroundImage(for: .highlighted)
        return self
    }
    @discardableResult func kf_bgDisabledLoad() -> Self {
        _kf_loadBackgroundImage(for: .disabled)
        return self
    }
    @discardableResult func kf_bgSelectedLoad() -> Self {
        _kf_loadBackgroundImage(for: .selected)
        return self
    }
    @available(iOS 9.0, *)
    @discardableResult func kf_bgFocusedLoad() -> Self {
        _kf_loadBackgroundImage(for: .focused)
        return self
    }
    @discardableResult func kf_bgApplicationLoad() -> Self {
        _kf_loadBackgroundImage(for: .application)
        return self
    }
    @discardableResult func kf_bgReservedLoad() -> Self {
        _kf_loadBackgroundImage(for: .reserved)
        return self
    }
}

public extension UIButton {
    func _kf_loadImage(for state: UIControl.State) {
        let cfg = _kf_config
        guard let url = cfg.url else {
            Task { @MainActor in self.jobsResetBtnImage(cfg.placeholder, for: state) }
            return
        }
        self.kf.setImage(with: url,
                         for: state,
                         placeholder: cfg.placeholder,
                         options: cfg.options,
                         progressBlock: { r, t in cfg.progress?(Int64(r), Int64(t)) }) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let r): self.jobsResetBtnImage(r.image, for: state)
                case .failure:        self.jobsResetBtnImage(cfg.placeholder, for: state)
                }
                cfg.completed?(result)
            }
        }
        if #available(iOS 15.0, *) { self.byAdoptConfigurationIfAvailable() }
    }
    // ✅ 2) Kingfisher 背景图加载：按原逻辑下载，回写时只走 jobsResetBtnBgImage（= legacy）
    func _kf_loadBackgroundImage(for state: UIControl.State) {
        let cfg = _kf_config
        self.jobs_bgURL = cfg.url
        self.jobs_bgState = state

        // 先立即显示占位
        if let ph = cfg.placeholder {
            Task { @MainActor in self.jobsResetBtnBgImage(ph, for: state) }
        }

        guard let url = cfg.url else { return }

        var opts = cfg.options
        if cfg.placeholder != nil {
            opts.removeAll { if case .keepCurrentImageWhileLoading = $0 { return true } else { return false } }
        } else if !opts.contains(where: { if case .keepCurrentImageWhileLoading = $0 { return true } else { return false } }) {
            opts.append(.keepCurrentImageWhileLoading)
        }
        if !opts.contains(where: { if case .backgroundDecode = $0 { return true } else { return false } }) {
            opts.append(.backgroundDecode)
        }

        // 用按钮绑定的 API，完成后只写 legacy 背景图（避免与 configuration 产生竞态）
        self.kf.setBackgroundImage(
            with: url,
            for: state,
            placeholder: cfg.placeholder,
            options: opts,
            progressBlock: { r, t in cfg.progress?(Int64(r), Int64(t)) }
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let s):
                    self.jobsResetBtnBgImage(s.image, for: state)
                case .failure:
                    self.jobsResetBtnBgImage(cfg.placeholder, for: state)
                }
                cfg.completed?(result)
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
        self.kf.setBackgroundImage(with: u, for: state, placeholder: placeholder, options: options)
        return self
    }
    /// 克隆阶段调用：优先现成位图 → 缓存 →（按需）拉网
    // MARK: - 克隆：背景图（Kingfisher）— 可直接替换
    func kf_cloneBackground(to target: UIButton,
                            for state: UIControl.State = .normal,
                            allowNetworkIfMissing: Bool) {
        target.jobs_isClone = true
        target.jobs_bgState = state
        // 0) 配置先 snapshot 出来，后面到处要用
        let snapCfg = self._kf_config   // KFButtonLoadConfig
        // 1) 只有“纯本地背景图”（没有 url）时，才直接复用现成位图，不走缓存/网络
        if snapCfg.url == nil {
            if #available(iOS 15.0, *), let img = self.configuration?.background.image {
                Task { @MainActor in
                    target.jobsResetBtnBgImage(img, for: state)
                };return
            }
            if let img = self.backgroundImage(for: state) {
                Task { @MainActor in
                    target.jobsResetBtnBgImage(img, for: state)
                };return
            }
        }
        // 2) 先把占位图顶上，保证克隆按钮立刻有图
        let ph = snapCfg.placeholder
        if let ph {
            Task { @MainActor in
                target.jobsResetBtnBgImage(ph, for: state)
            }
        }
        // 3) URL：优先显式记录的 kf_bgURL，其次配置里的 url
        guard let url = self.kf_bgURL ?? snapCfg.url else { return }
        target.jobs_bgURL = url
        // 4) 只从缓存取一次（不会触网）
        var cacheOnlyOpts = snapCfg.options
        cacheOnlyOpts.append(.onlyFromCache)
        KingfisherManager.shared.retrieveImage(with: url, options: cacheOnlyOpts) { result in
            switch result {
            case .success(let r):
                // ✅ 命中缓存
                Task { @MainActor in
                    target.jobsResetBtnBgImage(r.image, for: state)
                }
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
                    target.kf.setBackgroundImage(
                        with: url,
                        for: state,
                        placeholder: ph,
                        options: opts,
                        progressBlock: { r, t in snapCfg.progress?(Int64(r), Int64(t)) }
                    ) { res in
                        Task { @MainActor in
                            switch res {
                            case .success(let s):
                                target.jobsResetBtnBgImage(s.image, for: state)
                            case .failure:
                                target.jobsResetBtnBgImage(ph, for: state)
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
        target._kf_setImageURL(url)
        target._kf_setPlaceholder(self._kf_config.placeholder)
        var o = self._kf_config.options
        if !o.contains(where: { if case .keepCurrentImageWhileLoading = $0 { return true } else { return false } }) {
            o.append(.keepCurrentImageWhileLoading)
        }
        target._kf_setOptions(o)
        target._kf_setProgress(self._kf_config.progress)
        target._kf_setCompleted(self._kf_config.completed)
        target._kf_loadImage(for: state)
    }
}
#endif
