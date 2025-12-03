//
//  UICollectionView+空态数据占位按钮.swift
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
// MARK: - UICollectionView@空数据源占位图
/// 被交换的方法实现（调用原方法后自动评估空态）
extension UICollectionView {
    @objc dynamic func jobs_swizzled_reloadData() {
        // 交换后，此处调用的是“原始 reloadData”
        jobs_swizzled_reloadData()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            (self as UIScrollView).jobs_reloadEmptyViewAuto()  // 你的评估逻辑
        }
    }

    @objc dynamic func jobs_swizzled_performBatchUpdates(
        _ updates: (() -> Void)?,
        completion: ((Bool) -> Void)?
    ) {
        jobs_swizzled_performBatchUpdates(updates) { [weak self] finished in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                (self as UIScrollView).jobs_reloadEmptyViewAuto()
            };completion?(finished)
        }
    }
}
