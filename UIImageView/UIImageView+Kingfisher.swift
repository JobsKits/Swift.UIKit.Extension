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
    @discardableResult
    func kf_setImage(from string: String,
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
        }
        return self
    }

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
    /// 带呼吸效果
    @discardableResult
    func byShimmeringAsyncImageKF(
        _ src: String,
        fallback: @autoclosure @escaping @Sendable () -> UIImage
    ) -> Self {
        // 关键：这里传 shimmerConfig label，确保走“带呼吸”的实现
        kf_setImage(from: src,
                    placeholder: fallback(),
                    fade: 0.25,
                    shimmerConfig: .default)
        return self
    }
}
#endif
