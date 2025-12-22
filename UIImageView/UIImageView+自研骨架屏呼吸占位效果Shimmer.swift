//
//  UIImageView+自研骨架屏呼吸占位效果Shimmer.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/20/25.
//
//  ================================== 设计意图 ==================================
//  统一「Shimmer Loading」与「兜底图(Fallback)」语义，避免与 Kingfisher/SDWebImage 自带 placeholder 重复：
//  1) 没配置兜底图：请求中/失败 都持续 Shimmer（直到成功拿到图）
//  2) 配置了兜底图：请求中 只 Shimmer；失败后 才显示兜底图，并停止 Shimmer
//  ============================================================================
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

import ObjectiveC
// MARK: - 兜底图模式
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

private extension UIImageView {
    @inline(__always)
    func jobs_runOnMain(_ work: @escaping (UIImageView) -> Void) {
        if Thread.isMainThread {
            work(self)
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                work(self)
            }
        }
    }
}

public extension UIImageView {
    // MARK: - SimpleImageLoader 内部状态
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
        byShimmering(true, config: config)
        // 下一帧补一次 layout，确保动画能跑起来（尤其是 autolayout 尚未落位时）
        DispatchQueue.main.async { [weak self] in
            self?.jobs_updateShimmerLayout()
        }
    }
    /// 结束“有图态”，关闭呼吸
    @inline(__always)
    func jobs_endShimmerLoading() {
        byShimmering(false)
    }
    /// 取消当前 SimpleImageLoader 任务（仅 SimpleImageLoader 用）
    func jobs_cancelSimpleImageTask() {
        jobs_loadingTask?.cancel()
        jobs_loadingTask = nil
        jobs_loadingURL = nil
    }
    // MARK: - 统一失败策略
    /// 失败时：
    /// - 有兜底图：展示兜底图 + 停止 shimmer
    /// - 无兜底图：继续 shimmer（image 保持 nil）
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
    /// SimpleImageLoader：请求中 shimmer；成功停 shimmer；失败按 mode 决定：兜底图 or 持续 shimmer
    @discardableResult
    func jobs_setImageSimple(
        _ src: String?,
        fallback: UIImage? = nil,
        shimmerConfig: JobsShimmerConfig = .default
    ) -> Self {
        let mode: JobsShimmerFallbackMode = fallback.map { .shimmerThenFallback($0) } ?? .shimmerOnly
        // 没地址：视为失败
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
        if let cached = SimpleImageLoader.shared.cachedImage(for: url) {
            image = cached
            jobs_endShimmerLoading()
            return self
        }
        // 请求中：只 shimmer（不显示 fallback）
        image = nil
        jobs_beginShimmerLoading(config: shimmerConfig)
        // 取消旧任务，发起新任务
        jobs_loadingTask?.cancel()
        jobs_loadingTask = SimpleImageLoader.shared.load(url) { [weak self] img in
            guard let self else { return }
            guard self.jobs_loadingURL == url else { return }

            self.jobs_runOnMain { iv in
                if let img {
                    iv.image = img
                    iv.jobs_endShimmerLoading()
                } else {
                    iv.jobs_handleImageLoadFailure(mode: mode, shimmerConfig: shimmerConfig)
                }
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
        jobs_setImageSimple(src,
                            fallback: placeholder,
                            shimmerConfig: shimmerConfig)
    }
}
// MARK: - Kingfisher
#if canImport(Kingfisher)
import Kingfisher
public extension UIImageView {
    /// 带 shimmer 的 Kingfisher 加载：
    /// - loading：只 shimmer
    /// - success：显示网络图并停止 shimmer
    /// - failure：有 fallback -> 显示 fallback 并停 shimmer；无 fallback -> 持续 shimmer
    @discardableResult
    func kf_setImage(
        _ string: String,
        fallback: UIImage? = nil,
        fade: TimeInterval = 0.25,
        shimmerConfig: JobsShimmerConfig = .default
    ) -> Self {
        let mode: JobsShimmerFallbackMode = fallback.map { .shimmerThenFallback($0) } ?? .shimmerOnly

        switch string.imageSource {
        case .remote(let url)?:
            jobs_remoteURL = url
            // loading：只 shimmer
            image = nil
            jobs_beginShimmerLoading(config: shimmerConfig)
            // 复用场景建议先 cancel
            kf.cancelDownloadTask()
            kf.setImage(
                with: url,
                placeholder: nil,
                options: [.transition(.fade(fade))]
            ) { [weak self] result in
                guard let self else { return }
                guard self.jobs_remoteURL == url else { return }

                self.jobs_runOnMain { iv in
                    switch result {
                    case .success:
                        iv.jobs_endShimmerLoading()
                    case .failure:
                        iv.jobs_handleImageLoadFailure(mode: mode, shimmerConfig: shimmerConfig)
                    }
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
        _ string: String,
        placeholder: UIImage? = nil,
        fade: TimeInterval = 0.25,
        shimmerConfig: JobsShimmerConfig = .default
    ) -> Self {
        kf_setImage(string,
                    fallback: placeholder,
                    fade: fade,
                    shimmerConfig: shimmerConfig)
    }
}
#endif
// MARK: - SDWebImage
#if canImport(SDWebImage)
import SDWebImage

public extension UIImageView {
    /// 带 shimmer 的 SDWebImage 加载：
    /// - loading：只 shimmer
    /// - success：显示网络图并停止 shimmer
    /// - failure：有 fallback -> 显示 fallback 并停 shimmer；无 fallback -> 持续 shimmer
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

            // loading：只 shimmer
            image = nil
            jobs_beginShimmerLoading(config: shimmerConfig)

            // 复用场景建议先 cancel
            sd_cancelCurrentImageLoad()

            // 注意：placeholderImage 传 nil，避免 SD 的 loading placeholder 和 shimmer 重叠
            sd_setImage(
                with: url,
                placeholderImage: nil,
                options: [.avoidAutoSetImage]
            ) { [weak self] image, error, _, _ in
                guard let self else { return }
                guard self.jobs_remoteURL == url else { return }

                self.jobs_runOnMain { iv in
                    if let image, error == nil {
                        UIView.transition(
                            with: iv,
                            duration: fade,
                            options: .transitionCrossDissolve,
                            animations: { iv.image = image },
                            completion: nil
                        )
                        iv.jobs_endShimmerLoading()
                    } else {
                        iv.jobs_handleImageLoadFailure(mode: mode, shimmerConfig: shimmerConfig)
                    }
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
        from string: String,
        placeholder: UIImage? = nil,
        fade: TimeInterval = 0.25,
        shimmerConfig: JobsShimmerConfig = .default
    ) -> Self {
        sd_setImage(from: string, fallback: placeholder, fade: fade, shimmerConfig: shimmerConfig)
    }
}
#endif
