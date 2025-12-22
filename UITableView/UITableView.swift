//
//  UITableView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/15.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
/**
 private lazy var tableView: UITableView = {
     UITableView(frame: .zero, style: .insetGrouped)
         .byDataSource(self)
         .byDelegate(self)
         .registerCell(UITableViewCell.self)
         .byNoContentInsetAdjustment()
         .bySeparatorStyle(.singleLine)
         .byNoSectionHeaderTopPadding()

         .jobs_emptyButtonProvider { [unowned self] in
             UIButton(type: .system)
                 .byTitle("暂无数据", for: .normal)
                 .bySubTitle("点我填充示例数据", for: .normal)
                 .byImage("tray".sysImg, for: .normal)
                 .byImagePlacement(.top)
                 .onTap { [weak self] _ in
                     guard let self else { return }
                     self.items = (1...10).map { "Row \($0)" }
                     self.tableView.reloadData()   // ✅ reload 后会自动评估空态，无需你再手动调用
                 }
                 // 可选：不满意默认居中 -> 自定义布局
                 .jobs_setEmptyLayout { btn, make, host in
                     make.centerX.equalTo(host)
                     make.centerY.equalTo(host).offset(-40)
                     make.leading.greaterThanOrEqualTo(host).offset(16)
                     make.trailing.lessThanOrEqualTo(host).inset(16)
                     make.width.lessThanOrEqualTo(host).multipliedBy(0.9)
                 }
         }

 //            .byContentInset(UIEdgeInsets(
 //                top: UIApplication.jobsSafeTopInset + 30,
 //                left: 0,
 //                bottom: 0,
 //                right: 0
 //            ))
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

         .byAddTo(view) {[unowned self] make in
             if view.jobs_hasVisibleTopBar() {
                 make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                 make.left.right.bottom.equalToSuperview()
             } else {
                 make.edges.equalToSuperview()
             }
         }
 }()

 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     tableView.py_dequeueReusableCell(withType: UITableViewCell.self, for: indexPath)
         .byData(data[indexPath.row])
         .byText(Row(rawValue: indexPath.row)?.title)
         .byAccessoryType(.disclosureIndicator)
         .onResult { _ in

         }
 }

 */
