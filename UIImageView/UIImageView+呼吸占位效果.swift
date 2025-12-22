//
//  UIImageView+呼吸占位效果.swift
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
}
// MARK: - SimpleImageLoader
public extension UIImageView {
    /// SimpleImageLoader：无数据(请求中/失败)持续呼吸；有数据(成功)停止呼吸
    @discardableResult
    func jobs_setImageSimple(
        _ src: String?,
        placeholder: UIImage? = nil,
        shimmerConfig: JobsShimmerConfig = .default
    ) -> Self {
        // 没地址：无图态 -> 呼吸
        guard
            let src,
            let url = URL(string: src)
        else {
            jobs_cancelSimpleImageTask()
            jobs_remoteURL = nil
            image = placeholder
            jobs_beginShimmerLoading(config: shimmerConfig)
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
        image = placeholder
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
                // 失败：你要求“请求失败网络图片数据”也继续呼吸
                self.jobs_beginShimmerLoading(config: shimmerConfig)
            }
        };return self
    }
}
// MARK: - Kingfisher
#if canImport(Kingfisher)
import Kingfisher
public extension UIImageView {
    @discardableResult
    func kf_setImage(
        from string: String,
        placeholder: UIImage? = nil,
        fade: TimeInterval = 0.25,
        shimmerConfig: JobsShimmerConfig = .default
    ) -> Self {
        switch string.imageSource {
        case .remote(let url)?:
            jobs_remoteURL = url
            // 请求中：呼吸
            image = placeholder
            jobs_beginShimmerLoading(config: shimmerConfig)
            // 如果你有复用场景，建议先 cancel
            kf.cancelDownloadTask()
            kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [.transition(.fade(fade))]
            ) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    // 成功：关呼吸（KF 已经把图 set 进来了）
                    self.jobs_endShimmerLoading()
                case .failure:
                    // 失败：继续呼吸
                    self.jobs_beginShimmerLoading(config: shimmerConfig)
                }
            }
        case .local(let name)?:
            jobs_remoteURL = nil
            image = UIImage(named: name) ?? placeholder
            // 本地有图：关呼吸
            if image != nil { jobs_endShimmerLoading() }
            else { jobs_beginShimmerLoading(config: shimmerConfig) }
        case nil:
            jobs_remoteURL = nil
            image = placeholder
            jobs_beginShimmerLoading(config: shimmerConfig)
        };return self
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
        placeholder: UIImage? = nil,
        fade: TimeInterval = 0.25,
        shimmerConfig: JobsShimmerConfig = .default
    ) -> Self {
        switch string.imageSource {
        case .remote(let url)?:
            jobs_remoteURL = url
            image = placeholder
            jobs_beginShimmerLoading(config: shimmerConfig)

            // 复用场景建议先 cancel
            sd_cancelCurrentImageLoad()

            sd_setImage(
                with: url,
                placeholderImage: placeholder,
                options: [.avoidAutoSetImage]
            ) { [weak self] image, error, _, _ in
                guard let self = self else { return }

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
                    // 失败：继续呼吸
                    self.jobs_beginShimmerLoading(config: shimmerConfig)
                }
            }

        case .local(let name)?:
            jobs_remoteURL = nil
            image = UIImage(named: name) ?? placeholder
            if image != nil { jobs_endShimmerLoading() }
            else { jobs_beginShimmerLoading(config: shimmerConfig) }

        case nil:
            jobs_remoteURL = nil
            image = placeholder
            jobs_beginShimmerLoading(config: shimmerConfig)
        };return self
    }
}
#endif
