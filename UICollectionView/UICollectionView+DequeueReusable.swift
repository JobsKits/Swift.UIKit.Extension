//
//  UICollectionView+DequeueReusable.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
/// UICollectionView、UICollectionViewCell、UICollectionReusableView@提取
extension UICollectionView {
    // MARK: - dequeue@Cell（Generic）
    /// 出队 Cell（泛型安全，按类名）
    /// - Parameters:
    ///   - type: `UICollectionViewCell` 子类
    ///   - indexPath: 位置
    /// - Returns: 出队后的具体 Cell
    public func dequeueCell<T: UICollectionViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: String(describing: type), for: indexPath) as! T
    }
    // MARK: - dequeue@Cell（py_ Generic）
    /// py_ 出队 Cell（泛型安全，按类名）
    /// - Parameters:
    ///   - cellType: `UICollectionViewCell` 子类
    ///   - indexPath: 位置
    /// - Returns: 出队后的具体 Cell
    public func py_dequeueReusableCell<T: UICollectionViewCell>(withType cellType: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: cellType.className, for: indexPath) as! T
    }
    // MARK: - dequeue@Supplementary（Generic）
    /// 出队 SupplementaryView（泛型安全，按类名）
    /// - Parameters:
    ///   - type: `UICollectionReusableView` 子类
    ///   - kind: 视图类型（Header/Footer）
    ///   - indexPath: 位置
    /// - Returns: 出队后的具体 View
    public func dequeueSupplementary<T: UICollectionReusableView>(_ type: T.Type,
                                                                  kind: String,
                                                                  for indexPath: IndexPath) -> T {
        dequeueReusableSupplementaryView(ofKind: kind,
                                         withReuseIdentifier: String(describing: type),
                                         for: indexPath) as! T
    }
    // MARK: - dequeue@Header（py_ Generic）
    /// py_ 出队 Header（泛型安全，按类名）
    /// - Parameters:
    ///   - viewType: `UICollectionReusableView` 子类
    ///   - indexPath: 位置
    /// - Returns: Header 视图
    public func py_dequeueReusableHeaderView<T: UICollectionReusableView>(viewType: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                         withReuseIdentifier: viewType.className,
                                         for: indexPath) as! T
    }
    // MARK: - dequeue@Footer（py_ Generic）
    /// py_ 出队 Footer（泛型安全，按类名）
    /// - Parameters:
    ///   - viewType: `UICollectionReusableView` 子类
    ///   - indexPath: 位置
    /// - Returns: Footer 视图
    public func py_dequeueReusableFooterView<T: UICollectionReusableView>(viewType: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                         withReuseIdentifier: viewType.className,
                                         for: indexPath) as! T
    }
}
