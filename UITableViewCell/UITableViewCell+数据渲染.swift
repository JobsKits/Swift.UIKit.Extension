//
//  UITableViewCell+数据渲染.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
@MainActor
public extension ViewDataProtocol where Self: UITableViewCell {
    @discardableResult
    func byData(_ any: Any?) -> Self {
        guard let cfg = any as? JobsCellConfig else { return self }
        if #available(iOS 14.0, *) {
            return self
                .byJobsText(cfg.title)
                .bySecondaryJobsText(cfg.detail)
                .byImage(cfg.image)
        } else {
            if let title = cfg.title { textLabel?.byJobsAttributedText(title) }
            if let detail = cfg.detail { detailTextLabel?.byJobsAttributedText(detail) }
            if let image = cfg.image { imageView?.byImage(image) }
            return self
        }
    }
}
