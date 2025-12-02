//
//  UICollectionViewFlowLayout.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/23/25.
//

import UIKit

public extension UICollectionViewFlowLayout {
    // MARK: - Spacing
    @discardableResult
    func byMinimumLineSpacing(_ value: CGFloat) -> Self {
        self.minimumLineSpacing = value
        return self
    }

    @discardableResult
    func byMinimumInteritemSpacing(_ value: CGFloat) -> Self {
        self.minimumInteritemSpacing = value
        return self
    }
    // MARK: - Item Size
    @discardableResult
    func byItemSize(_ size: CGSize) -> Self {
        self.itemSize = size
        return self
    }
    /// iOS 8+: 估算尺寸（配合 Auto Layout 自适应）
    @available(iOS 8.0, *)
    @discardableResult
    func byEstimatedItemSize(_ size: CGSize) -> Self {
        self.estimatedItemSize = size
        return self
    }
    /// 快捷：开启 Auto Layout 自适应（estimatedItemSize = automaticSize）
    @available(iOS 8.0, *)
    @discardableResult
    func byAutomaticEstimatedItemSize() -> Self {
        self.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return self
    }
    // MARK: - Scroll Direction
    @discardableResult
    func byScrollDirection(_ direction: UICollectionView.ScrollDirection) -> Self {
        self.scrollDirection = direction
        return self
    }
    // MARK: - Header / Footer
    @discardableResult
    func byHeaderReferenceSize(_ size: CGSize) -> Self {
        self.headerReferenceSize = size
        return self
    }

    @discardableResult
    func byFooterReferenceSize(_ size: CGSize) -> Self {
        self.footerReferenceSize = size
        return self
    }
    // MARK: - Section Insets
    @discardableResult
    func bySectionInset(_ inset: UIEdgeInsets) -> Self {
        self.sectionInset = inset
        return self
    }
    /// iOS 11+: inset 参考系
    @available(iOS 11.0, *)
    @discardableResult
    func bySectionInsetReference(_ ref: UICollectionViewFlowLayout.SectionInsetReference) -> Self {
        self.sectionInsetReference = ref
        return self
    }
    // MARK: - Pin to visible bounds
    /// iOS 9+: 头部吸顶
    @available(iOS 9.0, *)
    @discardableResult
    func byHeadersPinToVisibleBounds(_ pin: Bool) -> Self {
        self.sectionHeadersPinToVisibleBounds = pin
        return self
    }
    /// iOS 9+: 尾部吸底
    @available(iOS 9.0, *)
    @discardableResult
    func byFootersPinToVisibleBounds(_ pin: Bool) -> Self {
        self.sectionFootersPinToVisibleBounds = pin
        return self
    }
    // MARK: - Helpers
    /// 按列数计算 itemSize（竖向滚动常用）
    /// - Parameters:
    ///   - columns: 列数（>=1）
    ///   - containerWidth: 容器宽度（collectionView.bounds.width）
    ///   - height: 固定高度（或你算好的高度）
    ///   - extraHorizontalInset: 额外左右内边距（除去 sectionInset 外的，比如 contentInset 或你想预留的边距）
    @discardableResult
    func byGrid(columns: Int,
                containerWidth: CGFloat,
                height: CGFloat,
                extraHorizontalInset: CGFloat = 0) -> Self {
        guard columns > 0 else { return self }
        let totalInset = sectionInset.left + sectionInset.right + extraHorizontalInset
        let totalSpacing = minimumInteritemSpacing * CGFloat(max(columns - 1, 0))
        let w = floor((containerWidth - totalInset - totalSpacing) / CGFloat(columns))
        self.itemSize = CGSize(width: w, height: height)
        return self
    }
    /// 快捷：常见的卡片列表预设
    /// - oneLineSpacing: 行间距；- interitemSpacing: 列间距；- inset: 分区内边距
    @discardableResult
    func byPresetCardList(oneLineSpacing: CGFloat = 10,
                          interitemSpacing: CGFloat = 10,
                          inset: UIEdgeInsets = .init(top: 10, left: 12, bottom: 10, right: 12)) -> Self {
        self.minimumLineSpacing = oneLineSpacing
        self.minimumInteritemSpacing = interitemSpacing
        self.sectionInset = inset
        return self
    }
    /// 一键开启「列表样式 + Header 吸顶」
    @available(iOS 9.0, *)
    @discardableResult
    func byListWithPinnedHeader(_ headerHeight: CGFloat) -> Self {
        self.scrollDirection = .vertical
        self.headerReferenceSize = .init(width: 0, height: headerHeight)
        self.sectionHeadersPinToVisibleBounds = true
        return self
    }
}
