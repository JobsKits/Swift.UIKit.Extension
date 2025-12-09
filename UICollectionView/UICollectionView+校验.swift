//
//  UICollectionView+校验.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

extension UICollectionView {
    /// 校验 IndexPath 是否在当前 collectionView 的有效范围内
    private func isValid(indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let item = indexPath.item

        guard section >= 0, item >= 0 else { return false }
        guard section < numberOfSections else { return false }
        guard item < numberOfItems(inSection: section) else { return false }
        return true
    }
    /// 通过 IndexPath 安全获取 cell：越界 / 不存在 返回 nil
    subscript(safe indexPath: IndexPath) -> UICollectionViewCell? {
        guard isValid(indexPath: indexPath) else { return nil }
        return cellForItem(at: indexPath)
    }
    /// 通过 section / item 安全获取 cell：越界 / 不存在 返回 nil
    subscript(section section: Int, item item: Int) -> UICollectionViewCell? {
        let indexPath = IndexPath(item: item, section: section)
        return self[safe: indexPath]
    }
}
