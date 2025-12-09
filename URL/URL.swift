//
//  URL.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/8/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
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
}
