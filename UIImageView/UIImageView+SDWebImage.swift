//
//  UIImageView+SDWebImage.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
//  ================================== 语义统一 ==================================
//  这里的 placeholder 统一为「兜底图(Fallback)」：
//  - URL 无效 / 本地找不到 / 请求失败：展示 placeholder
//  - 请求中：不展示 placeholder（如果你要 loading 占位，请用 byShimmeringAsyncImageSD）
//  ============================================================================
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

#if canImport(SDWebImage)
import SDWebImage
public extension UIImageView {
    /// placeholder = 兜底图（仅失败/无效时显示），加载中不显示
    @discardableResult
    func sd_setImage(
        _ string: String,
        placeholder: UIImage? = nil,
        fade: TimeInterval = 0.25
    ) -> Self {
        switch string.imageSource {
        case .remote(let url)?:
            // 复用场景建议先 cancel
            sd_cancelCurrentImageLoad()
            // 注意：placeholderImage 传 nil，避免 SD 的 loading placeholder 行为
            sd_setImage(
                with: url,
                placeholderImage: nil,
                options: [.avoidAutoSetImage]
            ) { [weak self] image, error, _, _ in
                guard let self else { return }
                let ok = (error == nil && image != nil)
                let finalImage: UIImage? = ok ? image : placeholder

                UIView.transition(
                    with: self,
                    duration: fade,
                    options: .transitionCrossDissolve,
                    animations: { self.image = finalImage },
                    completion: nil
                )
            }

        case .local(let name)?:
            image = UIImage(named: name) ?? placeholder

        case nil:
            image = placeholder
        };return self
    }
    // MARK: - Shimmer Loading（两种模式）
    /// 模式 1：不配置兜底图 -> 失败后持续 shimmer
    @discardableResult
    func byShimmeringAsyncImageSD(
        _ src: String,
        shimmerConfig: JobsShimmerConfig = .default,
        fade: TimeInterval = 0.25
    ) -> Self {
        sd_setImage(
            from: src,
            fallback: nil,
            fade: fade,
            shimmerConfig: shimmerConfig
        );return self
    }
    /// 模式 2：配置兜底图 -> 请求中 shimmer；失败后显示兜底图并停止 shimmer
    @discardableResult
    func byShimmeringAsyncImageSD(
        _ src: String,
        fallback: @autoclosure @escaping @Sendable () -> UIImage,
        shimmerConfig: JobsShimmerConfig = .default,
        fade: TimeInterval = 0.25
    ) -> Self {
        sd_setImage(
            from: src,
            fallback: fallback(),
            fade: fade,
            shimmerConfig: shimmerConfig
        );return self
    }
    /// placeholder 在这里等价于「兜底图」
    @discardableResult
    func byShimmeringAsyncImageSD(
        _ src: String,
        placeholder: @autoclosure @escaping @Sendable () -> UIImage
    ) -> Self {
        byShimmeringAsyncImageSD(src, fallback: placeholder(), shimmerConfig: .default, fade: 0.25)
    }
    /// 保持你原来的 async 版本（不带 shimmer）
    @discardableResult
    func byAsyncImageSD(
        _ src: String,
        fallback: @autoclosure @escaping @Sendable () -> UIImage
    ) -> Self {
        Task { @MainActor in
            let img = await src.sdLoadImage(fallbackImage: fallback())
            image = img
        };return self
    }
}
#endif
