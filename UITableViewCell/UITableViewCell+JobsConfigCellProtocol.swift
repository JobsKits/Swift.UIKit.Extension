//
//  UITableViewCell+JobsConfigCellProtocol.swift
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

extension UITableViewCell: JobsConfigCellProtocol {
    @discardableResult
    @objc
    public func byConfigure(_ any: Any?) -> Self {
        // 如果不是给普通 value1 用的，直接忽略
        guard let cfg = any as? JobsCellConfig else { return self }
        if #available(iOS 14.0, *) {
            return self
                .byJobsText(cfg.title)                  // 解析为普通字符串
                .bySecondaryJobsText(cfg.detail)        // 解析为富文本字符串
                .byImage(cfg.image)
        } else {
            // 旧系统依赖 textLabel / detailTextLabel
            if let title = cfg.title {
                textLabel?.byJobsAttributedText(title)
            }
            if let detail = cfg.detail {
                detailTextLabel?.byJobsAttributedText(detail)
            }
            if let image = cfg.image {
                imageView?.byImage(image)
            };return self
        }
    }
}
