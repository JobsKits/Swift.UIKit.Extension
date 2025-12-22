//
//  UIImageView+Kingfisher.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

#if canImport(Kingfisher)
import Kingfisher
public extension UIImageView {
    /// 如果图片URL为空 ==> 执行兜底图
    /// 如果图片URL不为空，请求阶段和请求失败 ==> 则执行兜底图
    @discardableResult
    func kf_setImage(_ string: String,
                     placeholder: UIImage? = nil,
                     fade: TimeInterval = 0.25) -> Self {
        switch string.imageSource {
        case .remote(let url)?:
            jobs_remoteURL = url
            kf.setImage(with: url,
                        placeholder: placeholder,
                        options: [.transition(.fade(fade))])
        case .local(let name)?:
            jobs_remoteURL = nil
            image = UIImage(named: name) ?? placeholder
        case nil:
            jobs_remoteURL = nil
            image = placeholder
        };return self
    }
    /// 带呼吸效果
    /// 如果图片URL为空 ==> 执行兜底图
    /// 如果图片URL不为空，请求阶段是呼吸效果，请求失败 ==> 执行兜底图
    @discardableResult
    func byShimmeringAsyncImageKF(
        _ src: String,
        placeholder: @autoclosure @escaping @Sendable () -> UIImage
    ) -> Self {
        // 关键：这里传 shimmerConfig label，确保走“带呼吸”的实现
        kf_setImage(from: src,
                    placeholder: placeholder(),
                    fade: 0.25,
                    shimmerConfig: .default)
        return self
    }
    ///
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
