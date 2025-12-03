//
//  URL.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/8/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

#if canImport(Kingfisher)
import Kingfisher
#endif

public extension URL {
    /// 是否 http/https 远程资源
    var isHTTPRemote: Bool {
        guard let s = scheme?.lowercased() else { return false }
        return s == "http" || s == "https"
    }
    /// 同步获取图片：仅本地/文件可用；远程 URL 不支持同步返回，直接给空图并打印提示
    var img: UIImage {
        if isHTTPRemote {
            print("🚫 检测到网络 URL：\(self.absoluteString)，无法同步返回图片")
            return UIImage()
        }
        if isFileURL {
            return UIImage(contentsOfFile: path) ?? UIImage()
        }
        // 兜底：当作 Bundle 资源名（取最后路径段去扩展名）
        let name = self.deletingPathExtension().lastPathComponent
        return UIImage(named: name) ?? UIImage()
    }
#if canImport(Kingfisher)
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
#endif
}
