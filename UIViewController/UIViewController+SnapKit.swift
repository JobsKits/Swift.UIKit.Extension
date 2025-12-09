//
//  UIViewController+SnapKit.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/2/25.
//

#if os(OSX)
import AppKit
#endif

#if os(iOS) || os(tvOS)
import UIKit
#endif

#if canImport(SnapKit)
import SnapKit
/// 利用SnapKit 给 UIViewController 加背景图（UIImageView）
public extension UIViewController {
    // MARK: - AO Key（UInt8 哨兵）
    private struct _JobsAssocKeys {
        static var imageView: UInt8 = 0
    }
    // MARK: - 懒载 imageView（挂在 VC 上）
    var jobsImageView: UIImageView {
        if let iv = objc_getAssociatedObject(self, &_JobsAssocKeys.imageView) as? UIImageView {
            return iv
        }
        let iv = UIImageView().byUserInteractionEnabled(false).byClipsToBounds(true).byContentMode(.scaleAspectFill)
        objc_setAssociatedObject(self, &_JobsAssocKeys.imageView, iv, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return iv
    }
    // MARK: - 安装并约束（默认铺满 Safe Area）
    @discardableResult
    func bgImageView(
        to container: UIView? = nil,
        contentMode: UIView.ContentMode = .scaleAspectFill,
        backgroundColor: UIColor? = nil,
        remakeConstraints: Bool = true,
        layout: (jobsByConstraintMakerBlock)? = nil
    ) -> UIImageView {
        let holder = container ?? view
        let iv = jobsImageView
        if iv.superview !== holder {
            iv.removeFromSuperview()
            holder?.addSubview(iv)
        }

        iv.contentMode = contentMode
        if let bg = backgroundColor { iv.backgroundColor = bg }

        if let layout = layout {
            if remakeConstraints { iv.snp.remakeConstraints(layout) }
            else { iv.snp.makeConstraints(layout) }
        } else {
            if remakeConstraints {
                iv.snp.remakeConstraints { make in
                    if let holder = holder {
                        make.edges.equalTo(holder.safeAreaLayoutGuide)
                    } else {
                        make.edges.equalToSuperview()
                    }
                }
            } else {
                iv.snp.makeConstraints { make in
                    if let holder = holder {
                        make.edges.equalTo(holder.safeAreaLayoutGuide)
                    } else {
                        make.edges.equalToSuperview()
                    }
                }
            }
        }
        view.sendSubviewToBack(iv)
        return iv
    }
    // MARK: - 卸载
    func removeJobsImageView() {
        jobsImageView.removeFromSuperview()
    }
}
#endif
