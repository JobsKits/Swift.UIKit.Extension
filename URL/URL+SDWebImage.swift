//
//  URL+SDWebImage.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
// MARK: - SDWebImage 版本
#if canImport(SDWebImage)
import SDWebImage
public extension URL {
    /// 异步获取图片：远程用 SDWebImage 下载；文件/Bundle 直接读取
    func sdLoadImage() async throws -> UIImage {
        if isHTTPRemote {
            return try await withCheckedThrowingContinuation { continuation in
                SDWebImageManager.shared.loadImage(
                    with: self,
                    options: [],
                    progress: nil
                ) { image, _, error, _, finished, _ in
                    // 避免渐进加载多次回调，这里只在最终 finished 时续体
                    guard finished else { return }

                    if let image = image {
                        continuation.resume(returning: image)
                    } else if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        // 没有 image 也没有 error，兜底抛一个 SDWebImage 自带 Error
                        continuation.resume(throwing: SDWebImageError.badImageData as! Error)
                    }
                }
            }
        }

        if isFileURL {
            if let img = UIImage(contentsOfFile: path) { return img }
            throw SDWebImageError(.badImageData)
        }

        // 兜底：当作 Bundle 资源名（取最后路径段去扩展名）
        let name = self.deletingPathExtension().lastPathComponent
        if let img = UIImage(named: name) { return img }

        throw SDWebImageError(.badImageData)
    }
}
#endif
