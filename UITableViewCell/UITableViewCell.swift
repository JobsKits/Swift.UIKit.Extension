//
//  UITableViewCell.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/23/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
// MARK: - 工厂：按样式创建（便于老系统 detailTextLabel 显示）
public extension UITableViewCell {
    /// 便捷工厂：指定 CellStyle 与复用 ID
    static func make(style: UITableViewCell.CellStyle = .default,
                     reuseIdentifier: String? = nil) -> UITableViewCell {
        UITableViewCell(style: style, reuseIdentifier: reuseIdentifier ?? String(describing: self))
    }
}



