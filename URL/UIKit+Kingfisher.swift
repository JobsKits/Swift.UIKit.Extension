//
//  UIKit+Kingfisher.swift
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
#if canImport(Kingfisher)
import Kingfisher
public extension URL {
    /// 异步获取图片：远程用 Kingfisher 下载；文件/Bundle 直接读取
    func kfLoadImage() async throws -> UIImage {
        if isHTTPRemote {
            // Kingfisher 的并发 API
            let result = try await KingfisherManager.shared.retrieveImage(with: self)
            return result.image
        }
        if isFileURL {
            if let img = UIImage(contentsOfFile: path) { return img }
            throw KFError.notFound
        }
        // 兜底：当作 Bundle 资源名（取最后路径段去扩展名）
        let name = self.deletingPathExtension().lastPathComponent
        if let img = UIImage(named: name) { return img }
        throw KFError.notFound
    }
}
#endif
