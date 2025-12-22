//
//  UICollectionView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import ObjectiveC
/**

 private lazy var flowLayout: UICollectionViewFlowLayout = {
     UICollectionViewFlowLayout()
         .byScrollDirection(.vertical)
         .byMinimumLineSpacing(10)
         .byMinimumInteritemSpacing(10)
         .bySectionInset(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
 }()

 private lazy var collectionView: UICollectionView = {
     UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
         .byDataSource(self)
         .byDelegate(self)
         .registerCell(UICollectionViewCell.self)
         .byBackgroundView(nil)
         .byDragInteractionEnabled(false)

         // 空态按钮（与 UITableView Demo 一致）
         .jobs_emptyButtonProvider { [unowned self] in
             UIButton.sys()
                 .byTitle("暂无数据", for: .normal)
                 .bySubTitle("点我填充示例数据", for: .normal)
                 .byImage(UIImage(systemName: "square.grid.2x2"), for: .normal)
                 .byImagePlacement(.top)
                 .onTap { [weak self] _ in
                     guard let self else { return }
                     self.items = (1...12).map { "Item \($0)" }
                     self.collectionView.byReloadData()        // ✅ reload 后自动评估空态
                 }
                 // 可选：自定义空态按钮布局
                 .jobs_setEmptyLayout { btn, make, host in
                     make.centerX.equalTo(host)
                     make.centerY.equalTo(host).offset(-40)
                     make.leading.greaterThanOrEqualTo(host).offset(16)
                     make.trailing.lessThanOrEqualTo(host).inset(16)
                     make.width.lessThanOrEqualTo(host).multipliedBy(0.9)
                 }
         }

         // 下拉刷新 Header
         .configRefreshHeader(component: JobsDefaultHeader(),
                              container: self,
                              trigger: 66) { [weak self] in
             guard let self else { return }
             Task { @MainActor in
                 try? await Task.sleep(nanoseconds: 1_000_000_000)
                 self.rows = 20
                 self.tableView.byReloadData()
                 self.tableView.switchRefreshHeader(to: .normal)
                 self.tableView.switchRefreshFooter(to: .normal) // 复位“无更多”
             }
         }
         // 上拉加载 Footer
         .configRefreshFooter(component: JobsDefaultFooter(),
                                       container: self,
                                       trigger: 66) { [weak self] in
             guard let self else { return }
             Task { @MainActor in
                 try? await Task.sleep(nanoseconds: 1_000_000_000)
                 if self.rows < 60 {
                     self.rows += 20
                     self.tableView.byReloadData()
                     self.tableView.switchRefreshFooter(to: .normal)
                 } else {
                     self.tableView.switchRefreshFooter(to: .noMoreData)
                 }
             }
         }

         .byAddTo(view) { [unowned self] make in
             if view.jobs_hasVisibleTopBar() {
                 make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                 make.left.right.bottom.equalToSuperview()
             } else {
                 make.edges.equalToSuperview()
             }
         }
 }()

 func collectionView(_ collectionView: UICollectionView,
                     cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     collectionView
         .dequeueCell(HCell.self, for: indexPath)
         .byData(indexPath.item)
         .onResult { _ in

         }
 }
 */
