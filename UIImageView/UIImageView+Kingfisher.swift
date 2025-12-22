//
//  UIImageView+Kingfisher.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
//  ================================== 语义统一 ==================================
//  这里的 placeholder 统一为「兜底图(Fallback)」：
//  - URL 无效 / 本地找不到 / 请求失败：展示 placeholder
//  - 请求中：不展示 placeholder（如果要 loading 占位，请用 byShimmeringAsyncImageKF）
//  ============================================================================
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

#if canImport(Kingfisher)
import Kingfisher
public extension UIImageView {
    /// placeholder = 兜底图（仅失败/无效时显示），加载中不显示
    @discardableResult
    func kf_setImage(
        _ string: String,
        placeholder: UIImage? = nil,
        fade: TimeInterval = 0.25
    ) -> Self {
        switch string.imageSource {
        case .remote(let url)?:
            jobs_remoteURL = url
            // 复用场景建议先 cancel
            kf.cancelDownloadTask()
            // 注意：placeholder 传 nil，避免和 shimmer / 其它占位策略重复
            kf.setImage(
                with: url,
                placeholder: nil,
                options: [.transition(.fade(fade))]
            ) { [weak self] result in
                guard let self else { return }
                // 只在失败时落兜底图
                if case .failure = result {
                    self.image = placeholder
                }
            }

        case .local(let name)?:
            jobs_remoteURL = nil
            image = UIImage(named: name) ?? placeholder

        case nil:
            jobs_remoteURL = nil
            image = placeholder
        };return self
    }
    // MARK: - Shimmer Loading（两种模式）
    /// 模式 1：不配置兜底图 -> 失败后持续 shimmer
    @discardableResult
    func byShimmeringAsyncImageKF(
        _ src: String,
        shimmerConfig: JobsShimmerConfig = .default,
        fade: TimeInterval = 0.25
    ) -> Self {
        kf_setImage(
            src,
            fallback: nil,
            fade: fade,
            shimmerConfig: shimmerConfig
        );return self
    }
    /// 模式 2：配置兜底图 -> 请求中 shimmer；失败后显示兜底图并停止 shimmer
    @discardableResult
    func byShimmeringAsyncImageKF(
        _ src: String,
        fallback: @autoclosure @escaping @Sendable () -> UIImage,
        shimmerConfig: JobsShimmerConfig = .default,
        fade: TimeInterval = 0.25
    ) -> Self {
        kf_setImage(
            src,
            fallback: fallback(),
            fade: fade,
            shimmerConfig: shimmerConfig
        );return self
    }
    /// placeholder 在这里等价于「兜底图」
    @discardableResult
    func byShimmeringAsyncImageKF(
        _ src: String,
        placeholder: @autoclosure @escaping @Sendable () -> UIImage
    ) -> Self {
        byShimmeringAsyncImageKF(src, fallback: placeholder(), shimmerConfig: .default, fade: 0.25)
    }
    /// 保持原来的 async 版本（不带 shimmer）
    @discardableResult
    func byAsyncImageKF(
        _ src: String,
        fallback: @autoclosure @escaping @Sendable () -> UIImage
    ) -> Self {
        // 统一记录 URL，便于 JobsImageCacheCleaner 遍历重下
        if case .remote(let url)? = src.imageSource { jobs_remoteURL = url } else { jobs_remoteURL = nil }
        Task { @MainActor in
            let img = await src.kfLoadImage(fallbackImage: fallback())
            image = img
        };return self
    }
}
#endif
