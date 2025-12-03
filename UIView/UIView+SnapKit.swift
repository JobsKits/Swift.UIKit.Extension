//
//  UIView+SnapKit.swift
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
// MARK: - SnapKit
#if canImport(SnapKit)
import SnapKit
/// SnapKit 语法糖🍬
// 存的就是这个类型
public typealias JobsConstraintClosure = (_ make: ConstraintMaker) -> Void
private enum _JobsAssocKeys {
    static var addClosureKey: UInt8 = 0
}
public extension UIView {
    var jobsAddConstraintsClosure: JobsConstraintClosure? {
        get {
            objc_getAssociatedObject(self, &_JobsAssocKeys.addClosureKey) as? JobsConstraintClosure
        }
        set {
            // 闭包推荐 COPY 语义
            objc_setAssociatedObject(self,
                                     &_JobsAssocKeys.addClosureKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    // MARK: - 存储约束
    @discardableResult
    func byAddConstraintsClosure(_ closure: ((_ make: ConstraintMaker) -> Void)? = nil) -> Self {
        if let closure {
            self.jobsAddConstraintsClosure = closure
        };return self
    }
    // MARK: - 添加约束
    @discardableResult
    func byAdd(_ closure: ((_ make: ConstraintMaker) -> Void)? = nil) -> Self {
        if let closure {
            self.byAddConstraintsClosure(closure)
            self.snp.makeConstraints(closure)
        };return self
    }
    // MARK: - 添加到父视图
    @discardableResult
    func byAddTo(_ superview: UIView) -> Self {
        superview.addSubview(self)
        return self
    }

    @discardableResult
    func byAddTo(_ superview: UIView,
                 _ closure: ((_ make: ConstraintMaker) -> Void)? = nil) -> Self {
        superview.addSubview(self)
        byAdd(closure)
        return self
    }
    // MARK: - 链式 makeConstraints
    @discardableResult
    func byMakeConstraints(_ closure: @escaping (_ make: ConstraintMaker) -> Void) -> Self {
        self.byAddConstraintsClosure(closure)
        self.snp.makeConstraints(closure)
        return self
    }
    // MARK: - 链式 remakeConstraints
    @discardableResult
    func byRemakeConstraints(_ closure: @escaping (_ make: ConstraintMaker) -> Void) -> Self {
        self.byAddConstraintsClosure(closure)
        self.snp.remakeConstraints(closure)
        return self
    }
    // MARK: - 链式 updateConstraints
    @discardableResult
    func byUpdateConstraints(_ closure: @escaping (_ make: ConstraintMaker) -> Void) -> Self {
        self.byAddConstraintsClosure(closure)
        self.snp.updateConstraints(closure)
        return self
    }
    // MARK: - 链式 removeConstraints
    @discardableResult
    func byRemoveConstraints() -> Self {
        self.byAddConstraintsClosure(nil)
        self.snp.removeConstraints()
        return self
    }
}
#endif
