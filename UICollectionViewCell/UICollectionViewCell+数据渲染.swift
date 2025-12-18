//
//  UICollectionViewCell+数据渲染.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/18/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

public extension CellDataProtocol where Self: UICollectionViewCell {
    /// ✅ Collection 的默认实现（先给 no-op，后面你要渲染再扩展）
    @discardableResult
    func byData(_ any: Any?) -> Self { self }
}

extension UICollectionViewCell: CellDataProtocol {}
