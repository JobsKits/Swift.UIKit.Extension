//
//  String+获取资源.swift
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
#endif

#if canImport(SDWebImage)
import SDWebImage
#endif

#if canImport(JobsSwiftBaseDefines)
import JobsSwiftBaseDefines
#endif
// MARK: 字符串转换成资源
public extension String {
    // MARK: - 字符串@Bundle
    /// 在指定 Bundle 查找媒体资源 URL（支持 "name.ext" 或 "name"）。
    /// - Parameter bundle: 默认 .main
    /// - Returns: URL?（找不到返回 nil）
    var bundleMediaURL: URL? {
        return bundleMediaURL(in: .main)
    }

    func bundleMediaURL(in bundle: Bundle) -> URL? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        // 既支持 "name.ext" 也支持 "name"
        let name = (trimmed as NSString).deletingPathExtension
        let ext  = (trimmed as NSString).pathExtension.isEmpty ? nil : (trimmed as NSString).pathExtension

        return bundle.url(forResource: name, withExtension: ext)
    }
    /// 必得版（开发期断言失败直接崩，等价你以前的 `!`）
    var bundleMediaURLRequire: URL {
        if let u = self.bundleMediaURL { return u }
        assertionFailure("❌ Bundle media not found: \(self) (check Target Membership)")
        fatalError("Bundle media not found: \(self)")
    }
    // MARK: - 字符串@URL
    /// "https://..." → URL?  （仅放行 http/https；自动做轻度编码）
    var url: URL? {
        let raw = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }
        let s = raw.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? raw
        guard let u = URL(string: s) else { return nil }
        if let scheme = u.scheme?.lowercased(),
           scheme == "http" || scheme == "https" {
            return u
        };return nil
    }
    /// "https://..." → URL  （开发期断言必得；等价你原来的 `!` 用法）
    var urlRequire: URL {
        if let u = self.url { return u }
        assertionFailure("❌ Invalid URL string: \(self)")
        fatalError("Invalid URL: \(self)")
    }
    // MARK: - 字符串@图片
    /// 统一解析：字符串 → 图片来源
    var imageSource: ImageSource? {
        // 优先判断 http/https
        if let url = URL(string: self),
           let scheme = url.scheme?.lowercased(),
           scheme == "http" || scheme == "https" {
            return .remote(url)
        };return .local(self)// 其余视为本地资源名（包括空 scheme、非 http(s)）
    }
    /// 本地同步图（仅当来源是 .local 时有意义）
    var img: UIImage {
        guard let source = imageSource else { return UIImage() }
        switch source {
        case .remote:
            // 同步返回不支持网络加载，避免阻塞
            print("🚫 检测到网络 URL：\(self)，无法同步返回图片")
            return UIImage()
        case .local(let name):
            return UIImage(named: name) ?? UIImage()
        }
    }

    var sysImg: UIImage {
        UIImage(systemName: self) ?? jobsSolidBlue()
    }

    func sysImg(_ config: UIImage.SymbolConfiguration) -> UIImage {
        UIImage(systemName: self, withConfiguration: config) ?? jobsSolidBlue()
    }
#if canImport(Kingfisher)
    /// 远程：通过 KF 异步下载后返回；本地：直接返回
    func kfLoadImage() async throws -> UIImage {
        guard let source = imageSource else { throw KFError.badURL }
        switch source {
        case .remote(let url):
            let result = try await KingfisherManager.shared.retrieveImage(with: url)
            return result.image
        case .local(let name):
            if let img = UIImage(named: name) { return img }
            throw KFError.notFound
        }
    }
    /// A) 允许传 nil：nil -> 蓝色兜底
    func kfLoadImage(fallbackImage: @autoclosure () -> UIImage?) async -> UIImage {
        do { return try await self.kfLoadImage() }         // 你已有的 throws 版本
        catch { return fallbackImage() ?? jobsSolidBlue() }
    }
    /// B) 非可选便捷版
    func kfLoadImage(fallback: UIImage) async -> UIImage {
        await kfLoadImage(fallbackImage: fallback)
    }
#endif

#if canImport(SDWebImage)
    /// 远程：通过 SDWebImage 异步下载后返回；本地：直接返回
    func sdLoadImage() async throws -> UIImage {
        guard let source = imageSource else {
            throw NSError(domain: "SDWebImage",
                          code: -1000,
                          userInfo: [NSLocalizedDescriptionKey: "Bad URL string"])
        }
        switch source {
        case .remote(let url):
            return try await withCheckedThrowingContinuation { cont in
                SDWebImageManager.shared.loadImage(
                    with: url,
                    options: [],
                    progress: nil
                ) { image, _, error, _, _, _ in
                    if let error = error {
                        cont.resume(throwing: error)
                    } else if let image = image {
                        cont.resume(returning: image)
                    } else {
                        cont.resume(throwing: NSError(
                            domain: "SDWebImage",
                            code: -1001,
                            userInfo: [NSLocalizedDescriptionKey: "Image not found"]
                        ))
                    }
                }
            }

        case .local(let name):
            if let img = UIImage(named: name) {
                return img
            }
            throw NSError(domain: "SDWebImage",
                          code: -1002,
                          userInfo: [NSLocalizedDescriptionKey: "Local image not found: \(name)"])
        }
    }
    /// 不抛错：加载失败则返回 fallbackImage()；若其为 nil，则返回蓝色占位图
    func sdLoadImage(fallbackImage: @autoclosure () -> UIImage?) async -> UIImage {
        do {
            return try await self.sdLoadImage()   // 你已有的 throws 版本
        } catch {
            return fallbackImage() ?? jobsSolidBlue()
        }
    }
#endif
}
