//
//  UICollectionView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
import ObjectiveC
/// UICollectionView、UICollectionViewCell、UICollectionReusableView@注册和提取
extension UICollectionView {
    // MARK: - register@Cell（Nib）
    /// 按类名从 Nib 注册 Cell
    /// - Parameter cellClass: `UICollectionViewCell` 子类
    /// - Returns: self（便于链式调用）
    @discardableResult
    public func registerCellNib<T: UICollectionViewCell>(_ cellClass: T.Type) -> Self {
        let id = String(describing: cellClass)
        let nib = UINib(nibName: id, bundle: nil)
        register(nib, forCellWithReuseIdentifier: id)
        return self
    }
    // MARK: - register@Cell（Class）
    /// 按类名注册 Cell（Class）
    /// - Parameter cellClass: `UICollectionViewCell` 子类
    /// - Returns: self
    @discardableResult
    func registerCell<T: UICollectionViewCell>(_ cellClass: T.Type) -> Self {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
        return self
    }
    // MARK: - register@Cell（Class with ID）
    /// 指定复用 ID 注册 Cell（Class）
    /// - Parameters:
    ///   - cellClass: `UICollectionViewCell` 子类
    ///   - reuseID: 自定义复用标识
    /// - Returns: self
    @discardableResult
    public func registerCell<T: UICollectionViewCell>(_ cellClass: T.Type, reuseID: String) -> Self {
        register(cellClass, forCellWithReuseIdentifier: reuseID)
        return self
    }
    // MARK: - register@Cell（Nib with ID）
    /// 指定复用 ID 注册 Cell（Nib）
    /// - Parameters:
    ///   - cellClass: `UICollectionViewCell` 子类
    ///   - reuseID: 自定义复用标识
    /// - Returns: self
    @discardableResult
    public func registerCellNib<T: UICollectionViewCell>(_ cellClass: T.Type, reuseID: String) -> Self {
        let nib = UINib(nibName: String(describing: cellClass), bundle: nil)
        register(nib, forCellWithReuseIdentifier: reuseID)
        return self
    }
    // MARK: - register@Cell（py_ Class）
    /// py_ 按类名注册 Cell（Class）
    /// - Parameter cellClassType: `UICollectionViewCell` 子类类型
    public func py_register(cellClassType: UICollectionViewCell.Type) {
        let cellId = cellClassType.className
        let cellClass: AnyClass = cellClassType.classForCoder()
        register(cellClass, forCellWithReuseIdentifier: cellId)
    }
    // MARK: - register@Cell（py_ Nib）
    /// py_ 按类名从 Nib 注册 Cell
    /// - Parameter cellNibType: `UICollectionViewCell` 子类类型
    public func py_register(cellNibType: UICollectionViewCell.Type) {
        let cellId = cellNibType.className
        let cellNib = UINib(nibName: cellId, bundle: nil)
        register(cellNib, forCellWithReuseIdentifier: cellId)
    }
    // MARK: - register@SupplementaryView（Class）
    /// 注册 SupplementaryView（Class）
    /// - Parameters:
    ///   - viewClass: `UICollectionReusableView` 子类
    ///   - kind: 视图类型（如 `UICollectionView.elementKindSectionHeader`）
    /// - Returns: self
    @discardableResult
    public func registerSupplementaryView<T: UICollectionReusableView>(_ viewClass: T.Type,
                                                                       kind: String) -> Self {
        let id = String(describing: viewClass)
        register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: id)
        return self
    }
    // MARK: - register@SupplementaryView（Nib）
    /// 注册 SupplementaryView（Nib）
    /// - Parameters:
    ///   - viewClass: `UICollectionReusableView` 子类
    ///   - kind: 视图类型（如 `UICollectionView.elementKindSectionHeader`）
    /// - Returns: self
    @discardableResult
    public func registerSupplementaryNib<T: UICollectionReusableView>(_ viewClass: T.Type,
                                                                      kind: String) -> Self {
        let id = String(describing: viewClass)
        let nib = UINib(nibName: id, bundle: nil)
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: id)
        return self
    }
    // MARK: - register@Header（py_ Class）
    /// py_ 注册 Header（Class）
    /// - Parameter headerViewClassType: `UICollectionReusableView` 子类
    public func py_registerHeaderView(headerViewClassType: UICollectionReusableView.Type) {
        let cellId = headerViewClassType.className
        let viewType: AnyClass = headerViewClassType.classForCoder()
        register(viewType,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: cellId)
    }
    // MARK: - register@Header（py_ Nib）
    /// py_ 注册 Header（Nib）
    /// - Parameter headerViewNibType: `UICollectionReusableView` 子类
    public func py_registerHeaderView(headerViewNibType: UICollectionReusableView.Type) {
        let cellId = headerViewNibType.className
        let viewNib = UINib(nibName: cellId, bundle: nil)
        register(viewNib,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: cellId)
    }
    // MARK: - register@Footer（py_ Class）
    /// py_ 注册 Footer（Class）
    /// - Parameter footerViewClassType: `UICollectionReusableView` 子类
    public func py_registerFooterView(footerViewClassType: UICollectionReusableView.Type) {
        let cellId = footerViewClassType.className
        let viewType: AnyClass = footerViewClassType.classForCoder()
        register(viewType,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                 withReuseIdentifier: cellId)
    }
    // MARK: - register@Footer（py_ Nib）
    /// py_ 注册 Footer（Nib）
    /// - Parameter footerViewNibType: `UICollectionReusableView` 子类
    public func py_registerFooterView(footerViewNibType: UICollectionReusableView.Type) {
        let cellId = footerViewNibType.className
        let viewNib = UINib(nibName: cellId, bundle: nil)
        register(viewNib,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                 withReuseIdentifier: cellId)
    }
    // MARK: - dequeue@Cell（Generic）
    /// 出队 Cell（泛型安全，按类名）
    /// - Parameters:
    ///   - type: `UICollectionViewCell` 子类
    ///   - indexPath: 位置
    /// - Returns: 出队后的具体 Cell
    public func dequeueCell<T: UICollectionViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        let id = String(describing: type)
        return dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! T
    }
    // MARK: - dequeue@Cell（py_ Generic）
    /// py_ 出队 Cell（泛型安全，按类名）
    /// - Parameters:
    ///   - cellType: `UICollectionViewCell` 子类
    ///   - indexPath: 位置
    /// - Returns: 出队后的具体 Cell
    public func py_dequeueReusableCell<T: UICollectionViewCell>(withType cellType: T.Type, for indexPath: IndexPath) -> T {
        let py_cellId = cellType.className
        return dequeueReusableCell(withReuseIdentifier: py_cellId, for: indexPath) as! T
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
        let id = String(describing: type)
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! T
    }
    // MARK: - dequeue@Header（py_ Generic）
    /// py_ 出队 Header（泛型安全，按类名）
    /// - Parameters:
    ///   - viewType: `UICollectionReusableView` 子类
    ///   - indexPath: 位置
    /// - Returns: Header 视图
    public func py_dequeueReusableHeaderView<T: UICollectionReusableView>(viewType: T.Type, for indexPath: IndexPath) -> T {
        let py_cellId = viewType.className
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                withReuseIdentifier: py_cellId,
                                                for: indexPath) as! T
    }
    // MARK: - dequeue@Footer（py_ Generic）
    /// py_ 出队 Footer（泛型安全，按类名）
    /// - Parameters:
    ///   - viewType: `UICollectionReusableView` 子类
    ///   - indexPath: 位置
    /// - Returns: Footer 视图
    public func py_dequeueReusableFooterView<T: UICollectionReusableView>(viewType: T.Type, for indexPath: IndexPath) -> T {
        let py_cellId = viewType.className
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                withReuseIdentifier: py_cellId,
                                                for: indexPath) as! T
    }
}
/// UICollectionView@数据源
extension UICollectionView {
    // MARK: - 数据源 delegate
    @discardableResult
    public func byDelegate(_ delegate: UICollectionViewDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
    // MARK: - 数据源 dataSource
    @discardableResult
    func byDataSource(_ dataSource: UICollectionViewDataSource?) -> Self {
        self.dataSource = dataSource
        return self
    }
}
/// UICollectionView@UICollectionViewLayout
extension UICollectionView {
    // MARK: - 布局对象 UICollectionViewLayout
    @discardableResult
    func byCollectionViewLayout(_ layout: UICollectionViewLayout) -> Self {
        collectionViewLayout = layout
        return self
    }
    // MARK: - FlowLayout 的滚动方向
    @discardableResult
    public func byScrollDirection(_ direction: UICollectionView.ScrollDirection) -> Self {
        (collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = direction
        return self
    }
    // MARK: - 切换布局（动画）
    @discardableResult
    public func bySetLayout(_ layout: UICollectionViewLayout, animated: Bool) -> Self {
        setCollectionViewLayout(layout, animated: animated)
        return self
    }
    // MARK: - iOS 7.0+ 切换布局（动画 + 完成回调）
    @available(iOS 7.0, *)
    @discardableResult
    public func bySetLayout(_ layout: UICollectionViewLayout,
                            animated: Bool,
                            completion: ((Bool) -> Void)?) -> Self {
        setCollectionViewLayout(layout, animated: animated, completion: completion)
        return self
    }
}
/// 预取、拖拽放置、重排、自适应失效@UICollectionView
extension UICollectionView {
    // MARK: - iOS 10.0+ 预取数据源
    @available(iOS 10.0, *)
    @discardableResult
    public func byPrefetchDataSource(_ ds: UICollectionViewDataSourcePrefetching?) -> Self {
        prefetchDataSource = ds
        return self
    }
    // MARK: - iOS 10.0+ 是否启用预取
    @available(iOS 10.0, *)
    @discardableResult
    public func byPrefetchingEnabled(_ enabled: Bool) -> Self {
        isPrefetchingEnabled = enabled
        return self
    }
    // MARK: - iOS 11.0+ 拖拽代理
    @available(iOS 11.0, *)
    @discardableResult
    public func byDragDelegate(_ delegate: UICollectionViewDragDelegate?) -> Self {
        dragDelegate = delegate
        return self
    }
    // MARK: - iOS 11.0+ 放置代理
    @available(iOS 11.0, *)
    @discardableResult
    public func byDropDelegate(_ delegate: UICollectionViewDropDelegate?) -> Self {
        dropDelegate = delegate
        return self
    }
    // MARK: - iOS 11.0+ 是否启用拖拽交互
    @available(iOS 11.0, *)
    @discardableResult
    public func byDragInteractionEnabled(_ enabled: Bool) -> Self {
        dragInteractionEnabled = enabled
        return self
    }
    // MARK: - iOS 11.0+ 重排节奏
    @available(iOS 11.0, *)
    @discardableResult
    public func byReorderingCadence(_ cadence: UICollectionView.ReorderingCadence) -> Self {
        reorderingCadence = cadence
        return self
    }
    // MARK: - iOS 16.0+ 自适应失效策略
    @available(iOS 16.0, *)
    @discardableResult
    public func bySelfSizingInvalidation(_ value: UICollectionView.SelfSizingInvalidation) -> Self {
        selfSizingInvalidation = value
        return self
    }
}
/// 背景、Context_Menu@UICollectionView
extension UICollectionView {
    @discardableResult
    public func byBackgroundView(_ view: UIView?) -> Self {
        backgroundView = view
        return self
    }
    // MARK: - iOS 13.2+ ContextMenuInteraction 配置闭包
    @available(iOS 13.2, *)
    @discardableResult
    public func byContextMenuInteraction(_ config: (UIContextMenuInteraction) -> Void) -> Self {
        if let interaction = contextMenuInteraction {
            config(interaction)
        }
        return self
    }
}
/// 选择、编辑、焦点@UICollectionView
extension UICollectionView {

    @discardableResult
    public func byAllowsSelection(_ allow: Bool) -> Self {
        allowsSelection = allow
        return self
    }

    @discardableResult
    public func byAllowsMultipleSelection(_ allow: Bool) -> Self {
        allowsMultipleSelection = allow
        return self
    }
    // MARK: - 选择/取消选择
    @discardableResult
    public func bySelectItem(_ indexPath: IndexPath?, animated: Bool = true,
                             scrollPosition: UICollectionView.ScrollPosition = []) -> Self {
        selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        return self
    }

    @discardableResult
    public func byDeselectItem(_ indexPath: IndexPath, animated: Bool = true) -> Self {
        deselectItem(at: indexPath, animated: animated)
        return self
    }
    // MARK: - iOS 14.0+ 编辑状态
    @available(iOS 14.0, *)
    @discardableResult
    public func byEditing(_ editing: Bool) -> Self {
        isEditing = editing
        return self
    }
    // MARK: - iOS 14.0+ 编辑时允许选择
    @available(iOS 14.0, *)
    @discardableResult
    public func byAllowsSelectionDuringEditing(_ allow: Bool) -> Self {
        allowsSelectionDuringEditing = allow
        return self
    }
    // MARK: - iOS 14.0+ 编辑时允许多选
    @available(iOS 14.0, *)
    @discardableResult
    public func byAllowsMultipleSelectionDuringEditing(_ allow: Bool) -> Self {
        allowsMultipleSelectionDuringEditing = allow
        return self
    }
    // MARK: - iOS 9.0+ 记住上次聚焦
    @available(iOS 9.0, *)
    @discardableResult
    public func byRemembersLastFocusedIndexPath(_ remember: Bool) -> Self {
        remembersLastFocusedIndexPath = remember
        return self
    }
    // MARK: - iOS 14.0+ 焦点移动自动选中
    @available(iOS 14.0, *)
    @discardableResult
    public func bySelectionFollowsFocus(_ enable: Bool) -> Self {
        selectionFollowsFocus = enable
        return self
    }
    // MARK: - iOS 15.0+ 允许聚焦
    @available(iOS 15.0, *)
    @discardableResult
    public func byAllowsFocus(_ allow: Bool) -> Self {
        allowsFocus = allow
        return self
    }
    // MARK: - iOS 15.0+ 编辑时允许聚焦
    @available(iOS 15.0, *)
    @discardableResult
    public func byAllowsFocusDuringEditing(_ allow: Bool) -> Self {
        allowsFocusDuringEditing = allow
        return self
    }
}
/// 滚动、可视区域@UICollectionView
extension UICollectionView {

    @discardableResult
    public func byScrollToItem(_ indexPath: IndexPath,
                               at position: UICollectionView.ScrollPosition,
                               animated: Bool = true) -> Self {
        scrollToItem(at: indexPath, at: position, animated: animated)
        return self
    }
}
/// 更新、批量操作、交互式过渡_移动@UICollectionView
extension UICollectionView {

    @discardableResult
    public func byReloadData() -> Self {
        reloadData()
        return self
    }

    @discardableResult
    public func byPerformBatchUpdates(_ updates: (() -> Void)?,
                                      completion: ((Bool) -> Void)? = nil) -> Self {
        performBatchUpdates(updates, completion: completion)
        return self
    }
    // MARK: - Sections
    @discardableResult
    public func byInsertSections(_ sections: IndexSet) -> Self {
        insertSections(sections)
        return self
    }

    @discardableResult
    public func byDeleteSections(_ sections: IndexSet) -> Self {
        deleteSections(sections)
        return self
    }

    @discardableResult
    public func byMoveSection(_ from: Int, to: Int) -> Self {
        moveSection(from, toSection: to)
        return self
    }

    @discardableResult
    public func byReloadSections(_ sections: IndexSet) -> Self {
        reloadSections(sections)
        return self
    }
    // MARK: - Items
    @discardableResult
    public func byInsertItems(at indexPaths: [IndexPath]) -> Self {
        insertItems(at: indexPaths)
        return self
    }

    @discardableResult
    public func byDeleteItems(at indexPaths: [IndexPath]) -> Self {
        deleteItems(at: indexPaths)
        return self
    }

    @discardableResult
    public func byMoveItem(from: IndexPath, to: IndexPath) -> Self {
        moveItem(at: from, to: to)
        return self
    }

    @discardableResult
    public func byReloadItems(at indexPaths: [IndexPath]) -> Self {
        reloadItems(at: indexPaths)
        return self
    }
    // MARK: - iOS 15.0+ 重新配置（不重载）
    @available(iOS 15.0, *)
    @discardableResult
    public func byReconfigureItems(at indexPaths: [IndexPath]) -> Self {
        reconfigureItems(at: indexPaths)
        return self
    }
    // MARK: - iOS 7.0+ 交互式布局过渡
    @available(iOS 7.0, *)
    @discardableResult
    public func byStartInteractiveTransition(to layout: UICollectionViewLayout,
                                             completion: UICollectionView.LayoutInteractiveTransitionCompletion? = nil)
    -> UICollectionViewTransitionLayout {
        return startInteractiveTransition(to: layout, completion: completion)
    }
    // MARK: - iOS 7.0+ 完成交互式过渡
    @available(iOS 7.0, *)
    @discardableResult
    public func byFinishInteractiveTransition() -> Self {
        finishInteractiveTransition()
        return self
    }
    // MARK: - iOS 7.0+ 取消交互式过渡
    @available(iOS 7.0, *)
    @discardableResult
    public func byCancelInteractiveTransition() -> Self {
        cancelInteractiveTransition()
        return self
    }
    // MARK: - iOS 9.0+ 交互式移动（开始/更新/结束/取消）
    @available(iOS 9.0, *)
    @discardableResult
    public func byBeginInteractiveMovement(for indexPath: IndexPath) -> Bool {
        return beginInteractiveMovementForItem(at: indexPath)
    }

    @available(iOS 9.0, *)
    @discardableResult
    public func byUpdateInteractiveMovementTargetPosition(_ position: CGPoint) -> Self {
        updateInteractiveMovementTargetPosition(position)
        return self
    }

    @available(iOS 9.0, *)
    @discardableResult
    public func byEndInteractiveMovement() -> Self {
        endInteractiveMovement()
        return self
    }

    @available(iOS 9.0, *)
    @discardableResult
    public func byCancelInteractiveMovement() -> Self {
        cancelInteractiveMovement()
        return self
    }
}
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
            }
            completion?(finished)
        }
    }
}

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
