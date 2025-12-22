//
//  UIImageView+自研骨架屏呼吸占位效果Shimmer.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/20/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import ObjectiveC
// MARK: - Shimmer + 兜底图模式
/// 你说的两种模式：
/// 1) 没兜底图：始终 Shimmer（直到成功拿到图）
/// 2) 有兜底图：请求中 Shimmer；失败后展示兜底图并停止 Shimmer
public enum JobsShimmerFallbackMode {
    /// 没兜底图：失败时继续 shimmer
    case shimmerOnly
    /// 有兜底图：失败时展示兜底图并停止 shimmer
    case shimmerThenFallback(UIImage)

    @inline(__always)
    var fallbackImage: UIImage? {
        switch self {
        case .shimmerOnly: return nil
        case .shimmerThenFallback(let img): return img
        }
    }
}

private enum JobsImageLoadingKeys {
    static var urlKey: UInt8 = 0
    static var taskKey: UInt8 = 0
}

public extension UIImageView {
    private var jobs_loadingURL: URL? {
        get { objc_getAssociatedObject(self, &JobsImageLoadingKeys.urlKey) as? URL }
        set { objc_setAssociatedObject(self, &JobsImageLoadingKeys.urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var jobs_loadingTask: URLSessionDataTask? {
        get { objc_getAssociatedObject(self, &JobsImageLoadingKeys.taskKey) as? URLSessionDataTask }
        set { objc_setAssociatedObject(self, &JobsImageLoadingKeys.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    /// 开启“无图态呼吸”
    @inline(__always)
    func jobs_beginShimmerLoading(config: JobsShimmerConfig = .default) {
        byShimmering(true, config: config) // DSL 已有 :contentReference[oaicite:3]{index=3}
        // 下一帧补一次 layout，确保动画能跑起来
        DispatchQueue.main.async { [weak self] in
            self?.jobs_updateShimmerLayout()
        }
    }
    /// 结束“有图态”，关闭呼吸
    @inline(__always)
    func jobs_endShimmerLoading() {
        byShimmering(false) // 会移除 layer + 动画 :contentReference[oaicite:4]{index=4}
    }
    /// 取消当前 SimpleImageLoader 任务（仅 SimpleImageLoader 用）
    func jobs_cancelSimpleImageTask() {
        jobs_loadingTask?.cancel()
        jobs_loadingTask = nil
        jobs_loadingURL = nil
    }
    // MARK: - 内部：统一失败策略
    /// 失败时：
    /// - 有兜底图：展示兜底图 + 停止 shimmer
    /// - 无兜底图：继续 shimmer
    @inline(__always)
    func jobs_handleImageLoadFailure(
        mode: JobsShimmerFallbackMode,
        shimmerConfig: JobsShimmerConfig
    ) {
        if let fallback = mode.fallbackImage {
            image = fallback
            jobs_endShimmerLoading()
        } else {
            image = nil
            jobs_beginShimmerLoading(config: shimmerConfig)
        }
    }
}
// MARK: - SimpleImageLoader
public extension UIImageView {
    /// SimpleImageLoader：无数据(请求中/失败)持续呼吸；有数据(成功)停止呼吸
    @discardableResult
    func jobs_setImageSimple(
        _ src: String?,
        fallback: UIImage? = nil,
        shimmerConfig: JobsShimmerConfig = .default
    ) -> Self {
        let mode: JobsShimmerFallbackMode = fallback.map { .shimmerThenFallback($0) } ?? .shimmerOnly
        // 没地址：无图态 -> 呼吸
        guard
            let src,
            let url = URL(string: src)
        else {
            jobs_cancelSimpleImageTask()
            jobs_remoteURL = nil
            jobs_handleImageLoadFailure(mode: mode, shimmerConfig: shimmerConfig)
            return self
        }
        jobs_loadingURL = url
        jobs_remoteURL = url
        // 命中缓存：直接显示 + 关呼吸
        if let cached = SimpleImageLoader.shared.cachedImage(for: url) { // :contentReference[oaicite:6]{index=6}
            image = cached
            jobs_endShimmerLoading()
            return self
        }
        // 请求中：呼吸（你要求“正在请求网络图片数据”也呼吸）
        image = nil
        jobs_beginShimmerLoading(config: shimmerConfig)
        // 取消旧任务，发起新任务
        jobs_loadingTask?.cancel()
        jobs_loadingTask = SimpleImageLoader.shared.load(url) { [weak self] img in // :contentReference[oaicite:7]{index=7}
            guard let self else { return }
            guard self.jobs_loadingURL == url else { return }
            if let img {
                self.image = img
                self.jobs_endShimmerLoading()
            } else {
                self.jobs_handleImageLoadFailure(mode: mode, shimmerConfig: shimmerConfig)
            }
        };return self
    }
    /// placeholder 在这里等价于“兜底图”（不会在 loading 阶段展示）
    @discardableResult
    func jobs_setImageSimple(
        _ src: String?,
        placeholder: UIImage? = nil,
        shimmerConfig: JobsShimmerConfig = .default
    ) -> Self {
        jobs_setImageSimple(src, fallback: placeholder, shimmerConfig: shimmerConfig)
    }
}
// MARK: - Kingfisher
#if canImport(Kingfisher)
import Kingfisher
public extension UIImageView {
    @discardableResult
    func kf_setImage(
        from string: String,
        fallback: UIImage? = nil,
        fade: TimeInterval = 0.25,
        shimmerConfig: JobsShimmerConfig = .default
    ) -> Self {
        let mode: JobsShimmerFallbackMode = fallback.map { .shimmerThenFallback($0) } ?? .shimmerOnly
        switch string.imageSource {
        case .remote(let url)?:
            jobs_remoteURL = url
            // 请求中：只 shimmer（避免框架 placeholder 行为和 shimmer 叠加）
            image = nil
            jobs_beginShimmerLoading(config: shimmerConfig)
            // 如果你有复用场景，建议先 cancel
            kf.cancelDownloadTask()
            kf.setImage(
                with: url,
                placeholder: nil,
                options: [.transition(.fade(fade))]
            ) { [weak self] result in
                guard let self else { return }
                guard self.jobs_remoteURL == url else { return }
                switch result {
                case .success:
                    // 成功：关呼吸（KF 已经把图 set 进来了）
                    self.jobs_endShimmerLoading()
                case .failure:
                    self.jobs_handleImageLoadFailure(mode: mode, shimmerConfig: shimmerConfig)
                }
            }
        case .local(let name)?:
            jobs_remoteURL = nil
            if let img = UIImage(named: name) {
                image = img
                jobs_endShimmerLoading()
            } else {
                jobs_handleImageLoadFailure(mode: mode, shimmerConfig: shimmerConfig)
            }
        case nil:
            jobs_remoteURL = nil
            jobs_handleImageLoadFailure(mode: mode, shimmerConfig: shimmerConfig)
        };return self
    }
    /// placeholder 在这里等价于“兜底图”（不会在 loading 阶段展示）
    @discardableResult
    func kf_setImage(
        from string: String,
        placeholder: UIImage? = nil,
        fade: TimeInterval = 0.25,
        shimmerConfig: JobsShimmerConfig = .default
    ) -> Self {
        kf_setImage(from: string, fallback: placeholder, fade: fade, shimmerConfig: shimmerConfig)
    }
}
#endif
// MARK: - SDWebImage
#if canImport(SDWebImage)
import SDWebImage
public extension UIImageView {
    @discardableResult
    func sd_setImage(
        from string: String,
        fallback: UIImage? = nil,
        fade: TimeInterval = 0.25,
        shimmerConfig: JobsShimmerConfig = .default
    ) -> Self {
        let mode: JobsShimmerFallbackMode = fallback.map { .shimmerThenFallback($0) } ?? .shimmerOnly
        switch string.imageSource {
        case .remote(let url)?:
            jobs_remoteURL = url
            image = nil
            jobs_beginShimmerLoading(config: shimmerConfig)
            // 复用场景建议先 cancel
            sd_cancelCurrentImageLoad()
            sd_setImage(
                with: url,
                placeholderImage: nil,
                options: [.avoidAutoSetImage]
            ) { [weak self] image, error, _, _ in
                guard let self = self else { return }
                guard self.jobs_remoteURL == url else { return }

                if let image, error == nil {
                    UIView.transition(
                        with: self,
                        duration: fade,
                        options: .transitionCrossDissolve,
                        animations: { self.image = image },
                        completion: nil
                    )
                    self.jobs_endShimmerLoading()
                } else {
                    self.jobs_handleImageLoadFailure(mode: mode, shimmerConfig: shimmerConfig)
                }
            }

        case .local(let name)?:
            jobs_remoteURL = nil
            if let img = UIImage(named: name) {
                image = img
                jobs_endShimmerLoading()
            } else {
                jobs_handleImageLoadFailure(mode: mode, shimmerConfig: shimmerConfig)
            }

        case nil:
            jobs_remoteURL = nil
            jobs_handleImageLoadFailure(mode: mode, shimmerConfig: shimmerConfig)
        };return self
    }

    /// placeholder 在这里等价于“兜底图”（不会在 loading 阶段展示）
    @discardableResult
    func sd_setImage(
        _ string: String,
        placeholder: UIImage? = nil,
        fade: TimeInterval = 0.25,
        shimmerConfig: JobsShimmerConfig = .default
    ) -> Self {
        sd_setImage(from: string, fallback: placeholder, fade: fade, shimmerConfig: shimmerConfig)
    }
}
#endif
